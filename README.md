# MeowMiner

Pre-tuned, closed-source CUDA miners for NVIDIA GPUs, distributed as ready-to-run
binaries for Windows, Linux, and HiveOS.

## Supported coins

| Coin | Algorithm | Package | Latest |
|------|-----------|---------|--------|
| **Keryx (KRX)** | keryxhash | `MeowMiner-keryx` | v1.6.25 |
| **Pearl (PRL)** | pearlhash (int8 tensor-core + BLAKE3) | `MeowMiner-pearl` | v1.6.23 |
| **Lucky Pepe (LPEPE)** | yescryptR32 | `MeowMiner` | v1.3.2 |
| **YCash (YEC)** | Equihash 192,7 | `MeowMiner` | v1.3.2 |

Keryx ships as its own CUDA package, wrapping Keryx miner 0.3.2 with
MeowMiner launchers and HiveOS integration.
Pearl ships as its own package (a CUDA engine plus a lightweight pool client).
Lucky Pepe and YCash share a single unified launcher, selected with `--algo`.

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
| Windows 10/11 x64 | [MeowMiner-pearl-1.6.23-windows-x64.zip](../../releases/download/v1.6.23/MeowMiner-pearl-1.6.23-windows-x64.zip) |
| Linux x86_64 | [MeowMiner-pearl-1.6.23-linux-x86_64.tar.gz](../../releases/download/v1.6.23/MeowMiner-pearl-1.6.23-linux-x86_64.tar.gz) |
| HiveOS | [meowminer-pearl-1.6.23.tar.gz](../../releases/download/v1.6.23/meowminer-pearl-1.6.23.tar.gz) |
| MMPOS | [meowminer-pearl-1.6.23-mmpos.tar.gz](../../releases/download/v1.6.23/meowminer-pearl-1.6.23-mmpos.tar.gz) |

v1.6.23 keeps the v1.6.22 pool-ping wrapper and adds an experimental Windows,
Linux, HiveOS, and MMPOS RTX 30-series / sm_86 engine split. sm_86 GPUs now
route to a separate BK64 StreamK candidate binary, while RTX 40 / sm_89 keeps the
pool-soaked Ada fixed-B + 32x3 L2 path and RTX 50 / sm_120 keeps the tested
v1.6.19 stream-sync legacy engine. This is a software-only kernel/scheduler
package update; it does not change clocks, fan settings, or power limits.

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
| Installation URL | `https://github.com/JustAResearcher/MeowMiner/releases/download/v1.6.23/meowminer-pearl-1.6.23.tar.gz` |
| Miner name | `meowminer-pearl` |
| Hash algorithm | `pearlhash` |
| Wallet and worker template | `%WAL%.%WORKER_NAME%` |
| Pool URL | `us2.pearl.herominers.com:1200` |
| Pass | `x` |

Allow roughly 60 seconds after applying for the GPU engine to initialize.

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

---

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

## Supported GPUs

| Algorithm | Architectures |
|-----------|---------------|
| Keryx (keryxhash) | CUDA GPUs; optimized `sm_89` path for RTX 40-series |
| Pearl (pearlhash) | `sm_86` / `sm_89` / `sm_90` / `sm_120` (Ampere → Blackwell) |
| LPEPE (yescryptR32) | `sm_60`+ (Pascal → Blackwell) |
| YEC (Equihash 192,7) | `sm_75` / `sm_80` / `sm_86` / `sm_89` / `sm_120` (Turing → Blackwell) |

The binaries are unsigned. If Windows SmartScreen warns about an unrecognized app,
choose **More info → Run anyway**.

## License

Closed-source; binary redistribution only. No reverse engineering, rebranding, or
rehosting. See `LICENSE.txt`.
