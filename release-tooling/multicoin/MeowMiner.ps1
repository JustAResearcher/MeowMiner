$ErrorActionPreference = "Stop"

function Show-Usage {
@'
MeowMiner multi-coin launcher

Usage:
  .\MeowMiner.ps1 --coin btx   -u BTX_WALLET -o btx-us-east.lproute.com:8660
  .\MeowMiner.ps1 --coin pearl -u PRL_WALLET -o us2.pearl.herominers.com:1200

Options:
  --coin COIN          btx or pearl
  -u, --user VALUE     payout wallet or pool login
  -o, --pool VALUE     pool host:port, optionally with a stratum scheme
  -w, --worker NAME    worker prefix/name
  -p, --password PASS  pool password (default: x)
  --devices LIST       comma-separated NVIDIA GPU indexes
  -h, --help           show this help
'@ | Write-Host
}

$coin = $env:MEOW_COIN
$user = $env:MEOW_USER
$pool = $env:MEOW_POOL
$worker = if ($env:MEOW_WORKER) { $env:MEOW_WORKER } else { $env:COMPUTERNAME.ToLowerInvariant() }
$password = if ($env:MEOW_PASSWORD) { $env:MEOW_PASSWORD } else { "x" }
$devices = $env:MEOW_DEVICES

for ($i = 0; $i -lt $args.Count; $i++) {
    $arg = $args[$i]
    switch ($arg) {
        "--coin" { if (++$i -ge $args.Count) { throw "--coin requires a value" }; $coin = $args[$i] }
        "-u" { if (++$i -ge $args.Count) { throw "-u requires a value" }; $user = $args[$i] }
        "--user" { if (++$i -ge $args.Count) { throw "--user requires a value" }; $user = $args[$i] }
        "--wallet" { if (++$i -ge $args.Count) { throw "--wallet requires a value" }; $user = $args[$i] }
        "-o" { if (++$i -ge $args.Count) { throw "-o requires a value" }; $pool = $args[$i] }
        "--pool" { if (++$i -ge $args.Count) { throw "--pool requires a value" }; $pool = $args[$i] }
        "--url" { if (++$i -ge $args.Count) { throw "--url requires a value" }; $pool = $args[$i] }
        "-w" { if (++$i -ge $args.Count) { throw "-w requires a value" }; $worker = $args[$i] }
        "--worker" { if (++$i -ge $args.Count) { throw "--worker requires a value" }; $worker = $args[$i] }
        "-p" { if (++$i -ge $args.Count) { throw "-p requires a value" }; $password = $args[$i] }
        "--password" { if (++$i -ge $args.Count) { throw "--password requires a value" }; $password = $args[$i] }
        "--pass" { if (++$i -ge $args.Count) { throw "--pass requires a value" }; $password = $args[$i] }
        "--devices" { if (++$i -ge $args.Count) { throw "--devices requires a value" }; $devices = $args[$i] }
        "-h" { Show-Usage; exit 0 }
        "--help" { Show-Usage; exit 0 }
        default { throw "Unknown option: $arg" }
    }
}

$coin = $(if ($coin) { $coin } else { "" })
$coin = $coin.ToLowerInvariant()
if ($coin -notin @("btx", "pearl")) { throw "--coin must be btx or pearl" }
if (!$user) { throw "A payout wallet/login is required (-u or MEOW_USER)." }
if ($devices -and $devices -notmatch '^\d+(,\d+)*$') {
    throw "--devices must be a comma-separated list of GPU indexes"
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($coin -eq "btx") {
    if (!$pool) { $pool = "btx-us-east.lproute.com:8660" }
    if ($pool -notmatch '^[a-z][a-z0-9+.-]*://') { $pool = "stratum+tcp://$pool" }
    $env:BTX_MODE = "pool"
    $env:BTX_WALLET = $user
    $env:BTX_POOL = $pool
    $env:BTX_WORKER_PREFIX = $worker
    $env:BTX_STRATUM_PASSWORD = $password
    if (!$devices) {
        & (Join-Path $root "btx\run.ps1") -Wallet $user -Pool $pool -WorkerPrefix $worker
        exit $LASTEXITCODE
    }

    $procs = @()
    try {
        foreach ($gpu in $devices.Split(',')) {
            $env:CUDA_VISIBLE_DEVICES = $gpu
            $env:BTX_WORKER = "$worker-gpu$gpu"
            $runOne = Join-Path $root "btx\run-one.ps1"
            $childArgs = @(
                "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$runOne`"",
                "-Wallet", "`"$user`"", "-Pool", "`"$pool`"",
                "-Worker", "`"$worker-gpu$gpu`"", "-Gpu", $gpu
            )
            $procs += Start-Process powershell.exe -ArgumentList $childArgs -PassThru -NoNewWindow
        }
        Wait-Process -Id $procs.Id
    } finally {
        foreach ($proc in $procs) {
            if (!$proc.HasExited) { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue }
        }
    }
    exit 0
}

if (!$pool) { $pool = "us2.pearl.herominers.com:1200" }
$authority = $pool -replace '^[a-z][a-z0-9+.-]*://', ''
$authority = ($authority -split '/', 2)[0]
if ($authority -notmatch ':') { $authority = "${authority}:1200" }
$hostName, $port = $authority -split ':', 2
if (!$hostName -or $port -notmatch '^\d+$') { throw "Pearl pool must be host:port" }

$env:PEARL_WALLET = $user
$env:PEARL_WORKER = $worker
$env:PEARL_POOL_HOST = $hostName
$env:PEARL_POOL_PORT = $port
$env:PEARL_PASSWORD = $password
$env:PEARL_STATDIR = Join-Path $root "pearl\stat"
New-Item -ItemType Directory -Force -Path $env:PEARL_STATDIR | Out-Null

$gpuIndexes = @()
if ($devices) {
    $gpuIndexes = $devices.Split(',')
} else {
    $gpuIndexes = @(& nvidia-smi --query-gpu=index --format=csv,noheader,nounits 2>$null | ForEach-Object { $_.Trim() })
}
if (!$gpuIndexes) { throw "No NVIDIA GPUs detected." }

$pearlDir = Join-Path $root "pearl"
$procs = @()
try {
    foreach ($gpu in $gpuIndexes) {
        $cap = (& nvidia-smi -i $gpu --query-gpu=compute_cap --format=csv,noheader,nounits 2>$null | Select-Object -First 1).Trim()
        $smCount = (& nvidia-smi -i $gpu --query-gpu=multiprocessor_count --format=csv,noheader,nounits 2>$null | Select-Object -First 1).Trim()
        $env:PEARL_DEV = $gpu
        $env:PEARL_REPORT = if ($procs.Count -eq 0) { "1" } else { "0" }
        $env:PEARL_MINER_BLOCKING_SYNC = if ($env:PEARL_MINER_BLOCKING_SYNC) { $env:PEARL_MINER_BLOCKING_SYNC } else { "1" }
        @(
            "PEARL_SM86_AUTO_L2BLOCK", "PEARL_SM86_FIXED_GRID_X", "PEARL_SM86_FIXED_GRID_STRICT",
            "PEARL_SM89_L2BLOCK_BM", "PEARL_SM89_L2BLOCK_BN", "PEARL_SM89_POW_BK64_STAGE",
            "PEARL_SM89_SWIZZLE", "PEARL_SM89_SWIZZLE_NMAJ", "PEARL_SM89_CARVEOUT_MAX",
            "PEARL_SM89_STAT_INTERVAL"
        ) | ForEach-Object { [Environment]::SetEnvironmentVariable($_, $null, "Process") }

        if ($cap -eq "8.6") {
            $env:PEARL_MINER_SM89_BIN = Join-Path $pearlDir "MeowMiner-pearl.sm86.exe"
            $env:PEARL_MINER_FIXED_B = "1"
            $env:PEARL_SM86_AUTO_L2BLOCK = "0"
            $env:PEARL_SM89_POW_BK64_STAGE = "2"
            $env:PEARL_SM89_SWIZZLE = "16"
            $env:PEARL_SM89_SWIZZLE_NMAJ = "1"
            $env:PEARL_SM89_CARVEOUT_MAX = "1"
            $env:PEARL_SM89_STAT_INTERVAL = "4"
            if ($smCount -match '^\d+$') {
                $env:PEARL_SM86_FIXED_GRID_X = $smCount
                $env:PEARL_SM86_FIXED_GRID_STRICT = "1"
            }
        } elseif ($cap -eq "8.9") {
            $env:PEARL_MINER_SM89_BIN = Join-Path $pearlDir "MeowMiner-pearl.exe"
            $env:PEARL_MINER_FIXED_B = "1"
            $env:PEARL_SM89_L2BLOCK_BM = "32"
            $env:PEARL_SM89_L2BLOCK_BN = "3"
        } elseif ($cap -in @("9.0", "12.0")) {
            $env:PEARL_MINER_SM89_BIN = Join-Path $pearlDir "MeowMiner-pearl.legacy.exe"
            $env:PEARL_MINER_FIXED_B = "0"
        } else {
            Write-Warning "Skipping GPU ${gpu}: unsupported compute capability $cap"
            continue
        }

        $client = Join-Path $pearlDir "pearl_ours.exe"
        $procs += Start-Process -FilePath $client -WorkingDirectory $pearlDir -PassThru -NoNewWindow
    }
    if (!$procs) { throw "No supported Pearl GPUs found." }
    Wait-Process -Id $procs.Id
} finally {
    foreach ($proc in $procs) {
        if (!$proc.HasExited) { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue }
    }
}
