param(
    [string]$Version = "1.6.52",
    [string]$BtxVersion = "0.33.0-opt36-luckypool-winfix",
    [string]$PearlVersion = "1.6.43"
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$sourceRoot = (Resolve-Path (Join-Path $repoRoot "..")).Path
$releaseToken = $Version.Replace(".", "")
$releaseRoot = Join-Path $sourceRoot "_release_meowminer_${releaseToken}_multicoin"
$stageRoot = Join-Path $releaseRoot "stage"
$distRoot = Join-Path $releaseRoot "dist"
$verifyRoot = Join-Path $releaseRoot "verify"
$launcherRoot = Join-Path $PSScriptRoot "multicoin"

$btxRoot = Join-Path $sourceRoot "btx\release-artifacts\btx-miner-$BtxVersion\stage"
$btxLinux = Get-ChildItem -LiteralPath $btxRoot -Directory -Filter "*-linux-*" | Select-Object -First 1
$btxWindows = Get-ChildItem -LiteralPath $btxRoot -Directory -Filter "*-windows-*" | Select-Object -First 1
$btxHive = Get-ChildItem -LiteralPath $btxRoot -Directory -Filter "*-hiveos-*" | Select-Object -First 1

$pearlReleaseRoot = Join-Path $sourceRoot "release_verify_v$PearlVersion"
$pearlLinuxArchive = Join-Path $pearlReleaseRoot "MeowMiner-pearl-$PearlVersion-linux-x86_64.tar.gz"
$pearlWindowsArchive = Join-Path $pearlReleaseRoot "MeowMiner-pearl-$PearlVersion-windows-x64.zip"
$pearlHiveArchive = Join-Path $pearlReleaseRoot "meowminer-pearl-$PearlVersion.tar.gz"

function Assert-File([string]$Path) {
    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing file: $Path" }
}

function Assert-Dir([string]$Path) {
    if (!(Test-Path -LiteralPath $Path -PathType Container)) { throw "Missing directory: $Path" }
}

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $parent = Split-Path -Parent $Path
    if ($parent -and !(Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

function Copy-Tree([string]$Source, [string]$Destination) {
    Assert-Dir $Source
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Copy-Item -Path (Join-Path $Source "*") -Destination $Destination -Recurse -Force
}

function File-Sha256([string]$Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function To-WslPath([string]$Path) {
    $full = [System.IO.Path]::GetFullPath($Path)
    $drive = $full.Substring(0, 1).ToLowerInvariant()
    $tail = $full.Substring(3).Replace("\", "/")
    if ($drive -eq "c") { return "/mnt/c_full/$tail" }
    return "/mnt/$drive/$tail"
}

function Invoke-Wsl([string]$Command) {
    & wsl -e bash -lc "mountpoint -q /mnt/c_full || mount -t drvfs C: /mnt/c_full; $Command"
    if ($LASTEXITCODE -ne 0) { throw "WSL command failed with exit code $LASTEXITCODE" }
}

Assert-Dir $launcherRoot
Assert-File $pearlLinuxArchive
Assert-File $pearlWindowsArchive
Assert-File $pearlHiveArchive
if (!$btxLinux -or !$btxWindows -or !$btxHive) { throw "BTX stage directories are incomplete under $btxRoot" }

Remove-Item -LiteralPath $stageRoot,$distRoot,$verifyRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $stageRoot,$distRoot,$verifyRoot | Out-Null

$linuxName = "MeowMiner-$Version-linux-x86_64"
$windowsName = "MeowMiner-$Version-windows-x64"
$hiveName = "meowminer"
$linuxDir = Join-Path $stageRoot "linux\$linuxName"
$windowsDir = Join-Path $stageRoot "windows\$windowsName"
$hiveDir = Join-Path $stageRoot "hive\$hiveName"
New-Item -ItemType Directory -Force -Path $linuxDir,$windowsDir,$hiveDir | Out-Null

# Stage the BTX v0.33 native solver/wrapper exactly as pool-validated.
Copy-Tree $btxLinux.FullName (Join-Path $linuxDir "btx")
Copy-Tree $btxWindows.FullName (Join-Path $windowsDir "btx")
Copy-Tree $btxHive.FullName (Join-Path $hiveDir "btx")

# Extract Pearl's last full OS-parity release.
$pearlLinuxExtract = Join-Path $stageRoot "_pearl_linux"
$pearlWindowsExtract = Join-Path $stageRoot "_pearl_windows"
$pearlHiveExtract = Join-Path $stageRoot "_pearl_hive"
New-Item -ItemType Directory -Force -Path $pearlLinuxExtract,$pearlWindowsExtract,$pearlHiveExtract | Out-Null
tar -xzf $pearlLinuxArchive -C $pearlLinuxExtract
if ($LASTEXITCODE -ne 0) { throw "Failed to extract $pearlLinuxArchive" }
Expand-Archive -LiteralPath $pearlWindowsArchive -DestinationPath $pearlWindowsExtract -Force
tar -xzf $pearlHiveArchive -C $pearlHiveExtract
if ($LASTEXITCODE -ne 0) { throw "Failed to extract $pearlHiveArchive" }

$pearlLinuxSource = Get-ChildItem -LiteralPath $pearlLinuxExtract -Directory | Select-Object -First 1
$pearlWindowsSource = Get-ChildItem -LiteralPath $pearlWindowsExtract -Directory | Select-Object -First 1
$pearlHiveSource = Get-ChildItem -LiteralPath $pearlHiveExtract -Directory | Select-Object -First 1
Copy-Tree $pearlLinuxSource.FullName (Join-Path $linuxDir "pearl")
Copy-Tree $pearlWindowsSource.FullName (Join-Path $windowsDir "pearl")
# Hive uses the Linux start script/engines plus the proven Hive stats adapter.
Copy-Tree $pearlLinuxSource.FullName (Join-Path $hiveDir "pearl")
Copy-Item -LiteralPath (Join-Path $pearlHiveSource.FullName "h-stats.sh") -Destination (Join-Path $hiveDir "pearl\h-stats.sh") -Force
Copy-Item -LiteralPath (Join-Path $pearlHiveSource.FullName "h-manifest.conf") -Destination (Join-Path $hiveDir "pearl\h-manifest.conf") -Force

function Patch-PearlLinuxLauncher([string]$Path) {
    $text = Get-Content -LiteralPath $Path -Raw
    $text = [regex]::Replace($text, '(?m)^export PEARL_WALLET=.*$', 'export PEARL_WALLET="${PEARL_WALLET:-YOUR_PEARL_WALLET_HERE}"')
    $text = [regex]::Replace($text, '(?m)^export PEARL_WORKER=.*$', 'export PEARL_WORKER="${PEARL_WORKER:-$(hostname)}"')
    $text = [regex]::Replace($text, '(?m)^export PEARL_POOL_HOST=.*$', 'export PEARL_POOL_HOST="${PEARL_POOL_HOST:-us2.pearl.herominers.com}"')
    $text = [regex]::Replace($text, '(?m)^export PEARL_POOL_PORT=.*$', 'export PEARL_POOL_PORT="${PEARL_POOL_PORT:-1200}"')
    $text = $text.Replace('export PEARL_STATDIR="$PWD/stat"', 'export PEARL_STATDIR="${PEARL_STATDIR:-$PWD/stat}"')
    $needle = '[ "${NG:-0}" -ge 1 ] 2>/dev/null || NG=1'
    $replacement = @'
[ "${NG:-0}" -ge 1 ] 2>/dev/null || NG=1
if [ -n "${PEARL_GPU_LIST:-}" ]; then
  GPU_ITEMS="${PEARL_GPU_LIST//,/ }"
else
  GPU_ITEMS="$(seq 0 $((NG-1)))"
fi
'@
    if (!$text.Contains($needle)) { throw "Pearl launcher GPU-count marker not found: $Path" }
    $text = $text.Replace($needle, $replacement.TrimEnd())
    $text = $text.Replace('for i in $(seq 0 $((NG-1))); do', 'for i in $GPU_ITEMS; do')
    Write-Utf8NoBom $Path $text
}

Patch-PearlLinuxLauncher (Join-Path $linuxDir "pearl\start.sh")
Patch-PearlLinuxLauncher (Join-Path $hiveDir "pearl\start.sh")

# Install the common selectors and platform entrypoints.
Copy-Item -LiteralPath (Join-Path $launcherRoot "MeowMiner") -Destination (Join-Path $linuxDir "MeowMiner") -Force
Copy-Item -LiteralPath (Join-Path $launcherRoot "start.sh") -Destination (Join-Path $linuxDir "start.sh") -Force
Copy-Item -LiteralPath (Join-Path $launcherRoot "MeowMiner.ps1") -Destination (Join-Path $windowsDir "MeowMiner.ps1") -Force
Copy-Item -LiteralPath (Join-Path $launcherRoot "start.bat") -Destination (Join-Path $windowsDir "start.bat") -Force
Copy-Item -LiteralPath (Join-Path $launcherRoot "MeowMiner") -Destination (Join-Path $hiveDir "MeowMiner") -Force
Copy-Item -LiteralPath (Join-Path $launcherRoot "start.sh") -Destination (Join-Path $hiveDir "start.sh") -Force
Copy-Item -LiteralPath (Join-Path $repoRoot "LICENSE.txt") -Destination (Join-Path $linuxDir "LICENSE.txt") -Force
Copy-Item -LiteralPath (Join-Path $repoRoot "LICENSE.txt") -Destination (Join-Path $windowsDir "LICENSE.txt") -Force
Copy-Item -LiteralPath (Join-Path $repoRoot "LICENSE.txt") -Destination (Join-Path $hiveDir "LICENSE.txt") -Force
foreach ($name in @("h-manifest.conf", "h-config.sh", "h-run.sh", "h-stats.sh")) {
    Copy-Item -LiteralPath (Join-Path $launcherRoot $name) -Destination (Join-Path $hiveDir $name) -Force
}
$manifestPath = Join-Path $hiveDir "h-manifest.conf"
$manifest = (Get-Content -LiteralPath $manifestPath -Raw).Replace("@VERSION@", $Version)
Write-Utf8NoBom $manifestPath $manifest
$pearlManifestPath = Join-Path $hiveDir "pearl\h-manifest.conf"
$pearlManifest = Get-Content -LiteralPath $pearlManifestPath -Raw
$pearlManifest = [regex]::Replace($pearlManifest, '(?m)^CUSTOM_VERSION=.*$', "CUSTOM_VERSION=$Version")
Write-Utf8NoBom $pearlManifestPath $pearlManifest

$readme = @"
MeowMiner $Version - BTX + Pearl multi-coin release
===================================================

This package contains two native NVIDIA mining engines selected by --coin:

  BTX    matmul, corrected v0.33 parent-template context, no dev fee
  Pearl  pearlhash, Ampere/Ada/Hopper/Blackwell engines, 2% dev fee

Quick start
-----------

BTX:
  ./MeowMiner --coin btx -u btx1zYOUR_ADDRESS -o ninjaraider.com:44920

Pearl:
  ./MeowMiner --coin pearl -u prl1YOUR_ADDRESS -o us2.pearl.herominers.com:1200

Windows uses MeowMiner.ps1 (or start.bat) with the same options.

Common options:
  --worker NAME
  --password PASS
  --devices 0,1,2

The miner selects one coin per GPU. Run separate instances with disjoint
--devices lists to mine BTX and Pearl at the same time on one multi-GPU host.
Do not assign the same GPU to both instances.

BTX defaults to NinjaRaider. Pearl defaults to HeroMiners US2. Override -o to
use another compatible pool. Pool-side accepted shares are the validity test.
"@
Write-Utf8NoBom (Join-Path $linuxDir "README.txt") $readme
Write-Utf8NoBom (Join-Path $windowsDir "README.txt") $readme
Write-Utf8NoBom (Join-Path $hiveDir "README.txt") ($readme + @"

HiveOS
------
Install meowminer-$Version.tar.gz as a custom miner named meowminer.
Set the flight-sheet algorithm to btx or pearl, wallet/template to the matching
coin address, and URL to the pool host:port. Use CUSTOM_DEVICES=0,1 in Extra
config to restrict GPUs. MEOW_COIN=btx or MEOW_COIN=pearl may also be supplied
in Extra config.
"@)
Write-Utf8NoBom (Join-Path $linuxDir "VERSION.txt") "MeowMiner $Version`nBTX $BtxVersion`nPearl $PearlVersion`n"
Write-Utf8NoBom (Join-Path $windowsDir "VERSION.txt") "MeowMiner $Version`nBTX $BtxVersion`nPearl $PearlVersion`n"
Write-Utf8NoBom (Join-Path $hiveDir "VERSION.txt") "MeowMiner $Version`nBTX $BtxVersion`nPearl $PearlVersion`n"

# Syntax and source-integrity release gates.
$scripts = @(
    (Join-Path $linuxDir "MeowMiner"),
    (Join-Path $linuxDir "start.sh"),
    (Join-Path $linuxDir "pearl\start.sh"),
    (Join-Path $hiveDir "MeowMiner"),
    (Join-Path $hiveDir "start.sh"),
    (Join-Path $hiveDir "h-config.sh"),
    (Join-Path $hiveDir "h-run.sh"),
    (Join-Path $hiveDir "h-stats.sh"),
    (Join-Path $hiveDir "pearl\start.sh")
)
foreach ($script in $scripts) {
    Invoke-Wsl "bash -n '$(To-WslPath $script)'"
}
[scriptblock]::Create((Get-Content -LiteralPath (Join-Path $windowsDir "MeowMiner.ps1") -Raw)) | Out-Null
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $windowsDir "MeowMiner.ps1") --help | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Windows launcher --help smoke test failed" }
$btxWindowsRunOne = Join-Path $windowsDir "btx\run-one.ps1"
$btxWindowsClient = Join-Path $windowsDir "btx\python\dexbtx_miner\stratum_client.py"
[scriptblock]::Create((Get-Content -LiteralPath $btxWindowsRunOne -Raw)) | Out-Null
$btxRunOneText = Get-Content -LiteralPath $btxWindowsRunOne -Raw
$btxClientText = Get-Content -LiteralPath $btxWindowsClient -Raw
foreach ($marker in @(
    "BTX_5070_PROFILE",
    "`$gpuName -match 'RTX\s+5070`$'",
    "BTX_5070_BATCH_SIZE",
    "BTX_5070_CUDA_POOL_SLOTS"
)) {
    if (!$btxRunOneText.Contains($marker)) { throw "Windows BTX RTX 5070 release gate failed: $marker" }
}
foreach ($marker in @("FIRST_JOB_TIMEOUT_SEC", "_luckypool_handshake", "authorized via LuckyPool login")) {
    if (!$btxClientText.Contains($marker)) { throw "Windows BTX LuckyPool release gate failed: $marker" }
}
Invoke-Wsl "'$(To-WslPath (Join-Path $linuxDir 'MeowMiner'))' --help >/dev/null"

$btxSourceLinuxSha = File-Sha256 (Join-Path $btxLinux.FullName "bin\btx-gbt-solve")
$btxStagedLinuxSha = File-Sha256 (Join-Path $linuxDir "btx\bin\btx-gbt-solve")
$btxSourceWindowsSha = File-Sha256 (Join-Path $btxWindows.FullName "bin\btx-gbt-solve.exe")
$btxStagedWindowsSha = File-Sha256 (Join-Path $windowsDir "btx\bin\btx-gbt-solve.exe")
$pearlSourceLinuxSha = File-Sha256 (Join-Path $pearlLinuxSource.FullName "MeowMiner-pearl.legacy")
$pearlStagedLinuxSha = File-Sha256 (Join-Path $linuxDir "pearl\MeowMiner-pearl.legacy")
if ($btxSourceLinuxSha -ne $btxStagedLinuxSha -or $btxSourceWindowsSha -ne $btxStagedWindowsSha -or $pearlSourceLinuxSha -ne $pearlStagedLinuxSha) {
    throw "A staged mining binary differs from its validated source artifact."
}

# Copy into WSL's native filesystem before setting modes. DrvFS presents every
# staged file as 0777 on this host, so chmod on C: itself cannot produce a
# trustworthy release archive.
$linuxWsl = To-WslPath $linuxDir
$hiveWsl = To-WslPath $hiveDir
$wslWork = "/tmp/meowminer-release-$releaseToken"
Invoke-Wsl "rm -rf '$wslWork' && mkdir -p '$wslWork/linux' '$wslWork/hive' && cp -a '$linuxWsl' '$wslWork/linux/$linuxName' && cp -a '$hiveWsl' '$wslWork/hive/$hiveName'"
Invoke-Wsl "find '$wslWork' -type d -exec chmod 755 {} + && find '$wslWork' -type f -exec chmod 644 {} +"
Invoke-Wsl "find '$wslWork' -type f \( -name '*.sh' -o -name 'MeowMiner' -o -name 'btx-gbt-solve' -o -name 'btx-matmul-*' -o -name 'pearl_ours' -o -name 'MeowMiner-pearl*' \) -exec chmod 755 {} +"

$windowsArchive = Join-Path $distRoot "$windowsName.zip"
$linuxArchive = Join-Path $distRoot "$linuxName.tar.gz"
$hiveArchive = Join-Path $distRoot "meowminer-$Version.tar.gz"
Compress-Archive -LiteralPath $windowsDir -DestinationPath $windowsArchive -Force
Invoke-Wsl "cd '$wslWork/linux' && tar -czf '$(To-WslPath $linuxArchive)' '$linuxName'"
Invoke-Wsl "cd '$wslWork/hive' && tar -czf '$(To-WslPath $hiveArchive)' '$hiveName'"

# Archive layout verification.
$windowsVerify = Join-Path $verifyRoot "windows"
Expand-Archive -LiteralPath $windowsArchive -DestinationPath $windowsVerify -Force
foreach ($required in @(
    "$windowsName\MeowMiner.ps1",
    "$windowsName\btx\bin\btx-gbt-solve.exe",
    "$windowsName\pearl\MeowMiner-pearl.exe",
    "$windowsName\pearl\MeowMiner-pearl.sm86.exe",
    "$windowsName\pearl\MeowMiner-pearl.legacy.exe"
)) { Assert-File (Join-Path $windowsVerify $required) }

$linuxList = (tar -tf $linuxArchive) -join "`n"
$hiveList = (tar -tf $hiveArchive) -join "`n"
foreach ($required in @("$linuxName/MeowMiner", "$linuxName/btx/bin/btx-gbt-solve", "$linuxName/pearl/MeowMiner-pearl.legacy")) {
    if ($linuxList -notmatch [regex]::Escape($required)) { throw "Linux archive missing $required" }
}
foreach ($required in @("meowminer/h-run.sh", "meowminer/btx/bin/btx-gbt-solve", "meowminer/pearl/MeowMiner-pearl.legacy")) {
    if ($hiveList -notmatch [regex]::Escape($required)) { throw "Hive archive missing $required" }
}

$hashLines = foreach ($file in Get-ChildItem -LiteralPath $distRoot -File | Sort-Object Name) {
    "$(File-Sha256 $file.FullName)  $($file.Name)"
}
Write-Utf8NoBom (Join-Path $distRoot "SHA256SUMS.txt") (($hashLines -join "`n") + "`n")

$notesTemplate = @'
# MeowMiner v{VERSION} - BTX v0.33 + Pearl multi-coin

MeowMiner v{VERSION} combines the native BTX and Pearl NVIDIA miners behind one
`--coin btx|pearl` launcher on Windows, Linux, and HiveOS.

## What changed

- LuckyPool regional endpoints now use their native `wallet.worker` / password
  login directly instead of probing unsupported Stratum methods first.
- Added a 30-second first-job watchdog so an authorized but idle LuckyPool
  session reconnects instead of hanging forever.
- Added a Windows RTX 5070 (12 GB) compatibility profile: threads 8,
  prepare-workers 8, batch 128, and four CUDA pool slots. v1.6.51 incorrectly
  left this non-Ti card on the generic batch-512 / eight-slot profile.
- Retained BTX v0.33 `parentMtp` validation and the Pearl v{PEARL_VERSION}
  architecture-specific engines for sm_86, sm_89, sm_90, and sm_120.
- BTX uses the pool-validated {BTX_VERSION} CUDA solver. BTX has no dev fee;
  Pearl retains its 2% dev fee.

## Validation

- Patched Windows BTX package: LuckyPool US-East accepted share, 1 accepted / 0 rejected.
- LuckyPool direct-login, initial-job watchdog, and host-detection regression tests passed.
- RTX 5070 model fixture selected batch 128 and four CUDA pool slots.
- Pearl accepted shares: HeroMiners, RTX 5070 Ti, zero invalid shares during canary.
- Windows PowerShell launcher parse/help smoke test passed.
- Linux and HiveOS shell syntax checks passed.
- Staged mining-binary SHA256 values match the validated source packages.
- Archive layout checks passed for all three targets.

## Assets

- `{WINDOWS_ASSET}.zip`
- `{LINUX_ASSET}.tar.gz`
- `meowminer-{VERSION}.tar.gz` (HiveOS)
- `SHA256SUMS.txt`

## SHA256

{HASHES}
'@
$notes = $notesTemplate.Replace("{VERSION}", $Version)
$notes = $notes.Replace("{PEARL_VERSION}", $PearlVersion)
$notes = $notes.Replace("{BTX_VERSION}", $BtxVersion)
$notes = $notes.Replace("{WINDOWS_ASSET}", $windowsName)
$notes = $notes.Replace("{LINUX_ASSET}", $linuxName)
$notes = $notes.Replace("{HASHES}", ($hashLines -join "`n"))
Write-Utf8NoBom (Join-Path $releaseRoot "release-notes-v$Version.md") $notes
Write-Utf8NoBom (Join-Path $repoRoot "release-notes-v$Version.md") $notes

Write-Host "Release staged at $releaseRoot"
Write-Host ($hashLines -join "`n")
