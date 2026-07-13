# MeowMiner

Pre-tuned miners for NVIDIA GPUs and selected CPU algorithms, distributed as
ready-to-run binaries for Windows, Linux, and HiveOS.

## Supported coins

| Coin | Algorithm | Package | Latest |
|------|-----------|---------|--------|
| **Keryx (KRX)** | keryxhash | `MeowMiner-keryx` | v1.6.25 |
| **Pearl (PRL)** | pearlhash (int8 tensor-core + BLAKE3) | `MeowMiner-pearl` | v1.6.43 |
| **Cereblix (CRB)** | neuromorph | `MeowMiner-cereblix` | v1.6.48 |
| **BTX (BTX)** | matmul | `MeowMiner` multi-coin | v1.6.53 |
| **Lucky Pepe (LPEPE)** | yescryptR32 | `MeowMiner` | v1.3.2 |
| **YCash (YEC)** | Equihash 192,7 | `MeowMiner` | v1.3.2 |

Keryx ships as its own CUDA package, wrapping Keryx miner 0.3.2 with
MeowMiner launchers and HiveOS integration.
Pearl ships as its own package (a CUDA engine plus a lightweight pool client).
Cereblix ships as a CPU-only package with the optimized NeuroMorph miner,
MeowMiner launchers, and HiveOS integration.
BTX and Pearl also ship together in the v1.6.53 multi-coin package, selected
with `--coin btx` or `--coin pearl` and supporting disjoint GPU assignment.
Lucky Pepe and YCash share a single unified launcher, selected with `--algo`.

---

## BTX + Pearl multi-coin

MeowMiner v1.6.53 combines the native BTX `matmul` miner and Pearl `pearlhash`
miner behind one launcher. BTX validates the exact candidate header against
the consensus pre-hash gate before submission; Pearl retains its
architecture-specific Ampere, Ada, Hopper, and Blackwell engines.

- **BTX:** LuckyPool by default, with NinjaRaider also supported; no dev fee.
- **Windows RTX 5070:** automatic 12 GB compatibility profile.
- **Pearl:** HeroMiners by default, 2% dev fee.
- **GPU assignment:** use `--devices 0,1`. Separate instances can mine BTX and
  Pearl concurrently when their device lists do not overlap.

### Downloads

| OS | Download |
|----|----------|
| Windows 10/11 x64 | [MeowMiner-1.6.53-windows-x64.zip](../../releases/download/v1.6.53/MeowMiner-1.6.53-windows-x64.zip) |
| Linux x86_64 | [MeowMiner-1.6.53-linux-x86_64.tar.gz](../../releases/download/v1.6.53/MeowMiner-1.6.53-linux-x86_64.tar.gz) |
| HiveOS | [meowminer-1.6.53.tar.gz](../../releases/download/v1.6.53/meowminer-1.6.53.tar.gz) |

### Windows and Linux

Extract the archive and use `MeowMiner.ps1` on Windows or `./MeowMiner` on
Linux. Examples:

```bash
./MeowMiner --coin btx -u btx1zYOUR_ADDRESS -o btx-us-east.lproute.com:8660
./MeowMiner --coin btx -u btx1zYOUR_ADDRESS -o ninjaraider.com:44920
./MeowMiner --coin pearl -u prl1YOUR_ADDRESS -o us2.pearl.herominers.com:1200
./MeowMiner --coin btx -u btx1zYOUR_ADDRESS --devices 0,2
```

### HiveOS

Create a Custom miner flight sheet with:

| Field | Value |
|-------|-------|
| Installation URL | `https://github.com/JustAResearcher/MeowMiner/releases/download/v1.6.53/meowminer-1.6.53.tar.gz` |
| Miner name | `meowminer` |
| Hash algorithm | `btx` or `pearl` |
| Wallet and worker template | the matching `btx1z...` or `prl1...` address |
| Pool URL | `btx-us-east.lproute.com:8660` or `us2.pearl.herominers.com:1200` |
| Pass | `x` |

Set `MEOW_COIN=btx` or `MEOW_COIN=pearl` in Extra config if the flight-sheet
algorithm field is unavailable. Use `CUSTOM_DEVICES=0,1` to restrict GPUs.

---

## Keryx (KRX)

A CUDA miner package for Keryx `keryxhash`, with optimized Ada / `sm_89`
and Blackwell / `sm_120` kernel paths for RTX 40-series and 50-series GPUs.

- **Architectures:** NVIDIA CUDA GPUs; RTX 4070 Ti SUPER uses the optimized `sm_89` cubin, and RTX 5090 / 50-series uses the optimized `sm_120` cubin.
- **Components:** `MeowMiner-keryx` and the `keryxcuda` plugin.
- **Pool default:** LuckyPool `stratum+tcp://keryx-us.lproute.com:8460`.
- **Model tier:** package starter scripts use `--light` to minimize OPoI model requirements.

### Downloads

| OS | Download |
|----|----------|
| Windows 10/11 x64 | [MeowMiner-keryx-1.6.25-windows-x64.zip](../../releases/download/v1.6.25/MeowMiner-keryx-1.6.25-windows-x64.zip) |
| Linux x86_64 | [MeowMiner-keryx-1.6.25-linux-x86_64.tar.gz](../../releases/download/v1.6.25/MeowMiner-keryx-1.6.25-linux-x86_64.tar.gz) |
| HiveOS | [meowminer-keryx-1.6.25.tar.gz](../../releases/download/v1.6.25/meowminer-keryx-1.6.25.tar.gz) |

### Windows and Linux

Edit `start.bat` or `start.sh`, set your Keryx wallet, then run the script.
Worker names can be appended to the wallet, for example `keryx:ADDRESS.rig1`.

Direct run example:

```bash
./MeowMiner-keryx --mining-address keryx:YOUR_ADDRESS.rig1 --keryxd-address stratum+tcp://keryx-us.lproute.com:8460 --light
```

### HiveOS

Create a Custom miner flight sheet with:

| Field | Value |
|-------|-------|
| Installation URL | `https://github.com/JustAResearcher/MeowMiner/releases/download/v1.6.25/meowminer-keryx-1.6.25.tar.gz` |
| Miner name | `meowminer-keryx` |
| Hash algorithm | `keryxhash` |
| Wallet and worker template | `%WAL%.%WORKER_NAME%` |
| Pool URL | `stratum+tcp://keryx-us.lproute.com:8460` |
| Pass | `x` |

Other LuckyPool regions use the same port: `keryx-eu.lproute.com:8460`,
`keryx-pl.lproute.com:8460`, `keryx-ru.lproute.com:8460`,
`keryx-hk.lproute.com:8460`, `keryx-sg.lproute.com:8460`, and
`keryx-br.lproute.com:8460`.

### Reference performance

| GPU | keryxhash |
|-----|-----------|
| RTX 4070 Ti SUPER | ~1.30 GH/s |

---

## Pearl (PRL)

A tensor-core miner for Pearl's `pearlhash` proof-of-work — an int8 matrix-multiply
workload finalized with BLAKE3. NVIDIA-only.

- **Architectures:** Ampere, Ada, Hopper, Blackwell (`sm_86` / `sm_89` / `sm_90` / `sm_120`).
- **Optimized GPU paths:** RTX 30-series / `sm_86`, RTX 40-series / `sm_89`,
  and RTX 50-series / `sm_120` are supported and route to tuned Pearl kernels.
- **Components:** a CUDA engine (`MeowMiner-pearl`) and a pool client (`pearl_ours`).
  The Linux client is statically linked and runs on any modern distribution and on
  HiveOS (engine built against glibc 2.17).
- **Requirements:** a recent NVIDIA driver. The CUDA runtime is linked statically into
  the engine, so there is nothing else to install.
- **Multi-GPU:** the launcher detects every GPU and runs one instance per card.
- **Fee:** 2%, applied as a brief time slice; the GPU never pauses.

### Downloads

| OS | Download |
|----|----------|
| Windows 10/11 x64 | [MeowMiner-pearl-1.6.43-windows-x64.zip](../../releases/download/v1.6.43/MeowMiner-pearl-1.6.43-windows-x64.zip) |
| Linux x86_64 | [MeowMiner-pearl-1.6.43-linux-x86_64.tar.gz](../../releases/download/v1.6.43/MeowMiner-pearl-1.6.43-linux-x86_64.tar.gz) |
| HiveOS | [meowminer-pearl-1.6.43.tar.gz](../../releases/download/v1.6.43/meowminer-pearl-1.6.43.tar.gz) |
| MMPOS | [meowminer-pearl-1.6.23-mmpos.tar.gz](../../releases/download/v1.6.23/meowminer-pearl-1.6.23-mmpos.tar.gz) |

v1.6.43 is the full parity Pearl package for Windows, Linux, and HiveOS. Each
package includes the RTX 30-series sm86 engine, the RTX 40-series Ada engine,
and the Blackwell/Hopper legacy engine. The launchers select by GPU compute
capability per card: `8.6` uses `MeowMiner-pearl.sm86`, `8.9` uses
`MeowMiner-pearl`, and `9.0` / `12.0` use `MeowMiner-pearl.legacy`.

The sm86 path uses the fixed-grid/no-forced-L2-block default measured faster on
RTX 30-series. The launcher prints the selected engine and sm86 scheduler flags
per GPU; an RTX 3060 Ti default run should show `sm86_fixed_grid=38`,
`l2block=n/axn/a`, and `bk64_stage=2`. This is a software-only
kernel/scheduler package update; it does not change clocks, fan settings, or
power limits.

### Windows and Linux

A wallet and pool are both required; the miner will not start without them and never
falls back to a default. Open `start.bat` (Windows) or `start.sh` (Linux), set your
Pearl wallet (`prl1…`) and pool, then run it — the script detects every GPU and
launches one instance per card.

To run the client directly, or to target specific GPUs:

```bash
./pearl_ours --wallet prl1youraddress... --pool us2.pearl.herominers.com:1200 --worker rig1
./pearl_ours --dev 1 --wallet prl1youraddress... --pool us2.pearl.herominers.com:1200   # GPU 1 only
```

| Flag | Purpose |
|------|---------|
| `--wallet <prl1…>` | Pearl payout address (required) |
| `--pool <host:port>` | Stratum pool (required) |
| `--worker <name>` | Worker / rig name |
| `--dev <index>` | GPU index — run one instance per card to mine a subset |

### HiveOS

Create a Custom miner flight sheet with the following fields:

| Field | Value |
|-------|-------|
| Installation URL | `https://github.com/JustAResearcher/MeowMiner/releases/download/v1.6.43/meowminer-pearl-1.6.43.tar.gz` |
| Miner name | `meowminer-pearl` |
| Hash algorithm | `pearlhash` |
| Wallet and worker template | `%WAL%.%WORKER_NAME%` |
| Pool URL | `us2.pearl.herominers.com:1200` |
| Pass | `x` |

Allow roughly 60 seconds after applying for the GPU engine to initialize. A
separate sm86-only HiveOS package is no longer needed for RTX 30-series cards.

### MMPOS

Register a Custom miner with the package URL, then set the pool, wallet, and
arguments in the flight sheet:

| Field | Value |
|-------|-------|
| Custom miner URL | `https://github.com/JustAResearcher/MeowMiner/releases/download/v1.6.23/meowminer-pearl-1.6.23-mmpos.tar.gz` |
| Pool | `us2.pearl.herominers.com:1200` |
| Wallet | your `prl1…` address |
| Arguments | `--wallet %wallet_address% --pool %pool_server%:%pool_port% --worker %rig_name%` |

The agent launches one instance per GPU and reports per-GPU hashrate to the dashboard.

### Reference performance

| GPU | pearlhash |
|-----|-----------|
| RTX 5090 (v1.6.19) | ~325 TH/s |
| RTX 4070 Ti SUPER (v1.6.20 Ada path) | ~181.6 TH/s |

Pool-credited rate depends on the pool's difficulty target and PPLNS window.

### Sample output

```
pearl-ours: connected us2.pearl.herominers.com:1200 worker=rig1 ping=42ms
pearl-ours: authorized (result=True)
pearl-ours: share accepted (total 12) ping=48ms
pearl-ours:   gpu0:  175.2 TH  pwr 285W  acc=12 rej=0  ping   48ms  core 64C
pearl-ours: 175.2 TH/s | acc=12 rej=0 ping=48ms
```

## Cereblix (CRB)

An optimized CPU miner package for Cereblix `neuromorph`. This is the
MeowMiner-wrapped NeuroMorph miner used on the Mini rigs and AI hosts.

- **Architectures:** x86_64 CPUs with AES-NI and AVX2; VAES and AVX-512 are
  selected automatically when available.
- **Components:** `MeowMiner-cereblix`, the optimized `nmminer-cereblix` binary,
  and bundled source/rebuild scripts.
- **Pool default:** `us.cereblix.com:3333`.
- **Dev fee:** 2.00% to `crb1c41078c7d958b88042c22f0c3c4cbedc9e8d9dba`
  at `us.cereblix.com:3333`.
- **GPU:** not used by this package; run Pearl/Keryx GPU mining separately if
  desired.

### Downloads

| OS | Download |
|----|----------|
| Windows 10/11 x64 | [MeowMiner-cereblix-1.6.48-windows-x64.zip](../../releases/download/v1.6.48/MeowMiner-cereblix-1.6.48-windows-x64.zip) |
| Linux x86_64 | [MeowMiner-cereblix-1.6.48-linux-x86_64.tar.gz](../../releases/download/v1.6.48/MeowMiner-cereblix-1.6.48-linux-x86_64.tar.gz) |
| HiveOS | [meowminer-cereblix-1.6.48.tar.gz](../../releases/download/v1.6.48/meowminer-cereblix-1.6.48.tar.gz) |

### Windows

Extract the zip, then edit `start.bat` and set your Cereblix wallet, or run:

```bat
start.bat crb1youraddress rig1
```

The Windows release is built with a portable AES-NI baseline; AVX2, VAES, and
AVX512 paths are selected at runtime only when the CPU supports them.

To override Cereblix thread autotune, pass a thread count as the third argument:

```bat
start.bat crb1youraddress rig1 28
```

Direct run example:

```bat
MeowMiner-cereblix.exe -o us.cereblix.com:3333 -u crb1youraddress.rig1 -p x -lanes 1 -noupdate
MeowMiner-cereblix.exe -o us.cereblix.com:3333 -u crb1youraddress.rig1 --cpu-threads=28 -noupdate
```

### Linux

Edit `start.sh`, set your Cereblix wallet, then run the script. Worker names are
appended by default, for example `crb1...rig1`.

```bash
WALLET=crb1youraddress WORKER=rig1 POOL=us.cereblix.com:3333 ./start.sh
WALLET=crb1youraddress THREADS=28 ./start.sh
```

Direct run example:

```bash
./MeowMiner-cereblix -a neuromorph -o us.cereblix.com:3333 -u crb1youraddress.rig1 -p x -noupdate
./MeowMiner-cereblix -a neuromorph -o us.cereblix.com:3333 -u crb1youraddress.rig1 --cpu-threads=28 -noupdate
```

### HiveOS

Create a Custom miner flight sheet with:

| Field | Value |
|-------|-------|
| Installation URL | `https://github.com/JustAResearcher/MeowMiner/releases/download/v1.6.48/meowminer-cereblix-1.6.48.tar.gz` |
| Miner name | `meowminer-cereblix` |
| Hash algorithm | `neuromorph` |
| Wallet and worker template | `%WAL%.%WORKER_NAME%` |
| Pool URL | `us.cereblix.com:3333` |
| Pass | `x` |

To override Cereblix thread autotune in HiveOS, set Extra config arguments to
`--cpu-threads=28` or `-threads 28 -noauto`. The package also accepts
`threads=28`, `CUSTOM_THREADS=28`, and `CUSTOM_CPU_THREADS=28`.

The package reports CPU hashrate in kH/s and keeps the GPU miner untouched.

### Reference performance

| CPU / rig | neuromorph |
|-----------|------------|
| Ryzen Mini rig | ~78-83 kH/s |
| AI02 dual EPYC 7742 | ~75-80 kH/s |

## Lucky Pepe (LPEPE) and YCash (YEC)

A single unified launcher; select the coin with `--algo`.

```
MeowMiner --algo lpepe
MeowMiner --algo yec
MeowMiner --algo yec --worker rig2   # any backend flag may be overridden
```

### Downloads

| OS | Download |
|----|----------|
| Windows 10/11 x64 | [MeowMiner-v1.3.2-windows.zip](../../releases/download/v1.3.2/MeowMiner-v1.3.2-windows.zip) |
| Linux x86_64 | [MeowMiner-v1.3.2-linux.tar.gz](../../releases/download/v1.3.2/MeowMiner-v1.3.2-linux.tar.gz) |
| HiveOS (LPEPE) | [MeowMiner-1.0.29-hiveos.tar.gz](../../releases/download/v1.0.29/MeowMiner-1.0.29-hiveos.tar.gz) |

### Usage

- **Windows:** extract the archive, then double-click `mine-lpepe.bat` or
  `mine-yec.bat`, or run `MeowMiner.exe --algo lpepe|yec` with your own flags.
- **Linux:** extract and run `./MeowMiner --algo lpepe|yec`, or use the
  `mine-lpepe.sh` / `mine-yec.sh` scripts.
- **YCash** requires Python 3 on the `PATH`.

Requirements: NVIDIA driver ≥ 525 and the CUDA 12 runtime (bundled with the driver
on most systems).

### Algorithm aliases

| `--algo` value | Maps to |
|----------------|---------|
| `lpepe`, `yescryptr32`, `yescrypt` | Lucky Pepe yescryptR32 |
| `yec`, `equihash-192-7`, `equihash`, `ycash` | YCash Equihash 192,7 |

### Launcher defaults

| Algo | Pool | Worker |
|------|------|--------|
| `lpepe` | `pool.luckypepe.org:3333` | `rig1` |
| `yec` | `ycash.dapool.io:3344` | `rig1` |

Set your own wallet by editing the `mine-lpepe.*` / `mine-yec.*` scripts. Any flag
passed after `--algo` overrides the corresponding default.

### HiveOS (LPEPE)

| Field | Value |
|-------|-------|
| Installation URL | `https://github.com/JustAResearcher/MeowMiner/releases/download/v1.0.29/MeowMiner-1.0.29-hiveos.tar.gz` |
| Miner name | `meowminer` |
| Hash algorithm | `yescryptR32` |
| Wallet and worker template | `%WAL%.%WORKER_NAME%` |
| Pool URL | `stratum+tcp://pool.luckypepe.org:3333` |
| Pass | `x` |

### Reference performance

| GPU | LPEPE (yescryptR32) | YEC (Equihash 192,7) |
|-----|---------------------|----------------------|
| RTX 5090 | ~15 kH/s | ~338 Sol/s |
| RTX 4070 Ti SUPER | ~5.75 kH/s | ~142 Sol/s |

---

## Supported Hardware

| Algorithm | Architectures |
|-----------|---------------|
| Keryx (keryxhash) | CUDA GPUs; optimized `sm_89` path for RTX 40-series |
| Cereblix (neuromorph) | x86_64 CPUs with AES-NI + AVX2; VAES / AVX-512 selected when present |
| BTX (matmul) | `sm_86` / `sm_89` / `sm_120`; v0.33 pool-template context |
| Pearl (pearlhash) | `sm_86` / `sm_89` / `sm_90` / `sm_120` (Ampere → Blackwell) |
| LPEPE (yescryptR32) | `sm_60`+ (Pascal → Blackwell) |
| YEC (Equihash 192,7) | `sm_75` / `sm_80` / `sm_86` / `sm_89` / `sm_120` (Turing → Blackwell) |

The binaries are unsigned. If Windows SmartScreen warns about an unrecognized app,
choose **More info → Run anyway**.

## License

Closed-source; binary redistribution only. No reverse engineering, rebranding, or
rehosting. See `LICENSE.txt`.
