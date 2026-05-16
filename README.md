# MeowMiner

A closed-source, pre-tuned CUDA miner for **two coins**, behind a single
unified launcher:

- **Lucky Pepe (LPEPE)** — yescryptR32
- **YCash (YEC)** — Equihash 192,7

One `MeowMiner` command, pick the coin with `--algo`.

```
MeowMiner --algo lpepe              # Lucky Pepe defaults
MeowMiner --algo yec                # YCash defaults
MeowMiner --algo yec --worker rig2  # override any backend flag
```

## Downloads

| OS                    | Download |
|-----------------------|----------|
| Windows 10/11 x64     | [**MeowMiner-v1.3.2-windows.zip**](../../releases/latest/download/MeowMiner-v1.3.2-windows.zip) |
| Linux x86_64          | [**MeowMiner-v1.3.2-linux.tar.gz**](../../releases/latest/download/MeowMiner-v1.3.2-linux.tar.gz) |
| HiveOS (LPEPE only)   | [**MeowMiner-1.0.30-hiveos.tar.gz**](../../releases/download/v1.0.30/MeowMiner-1.0.30-hiveos.tar.gz) |

HiveOS multi-algo packaging will land in a later release.

---

## Windows

1. Download **MeowMiner-v1.3.2-windows.zip**.
2. Right-click → *Extract All…*
3. Either:
   - Double-click **`mine-lpepe.bat`** or **`mine-yec.bat`** (defaults pre-filled), or
   - Open `cmd` and run `MeowMiner.exe --algo lpepe` / `--algo yec` with your own
     flags appended.

YEC requires **Python 3** in PATH — install from [python.org](https://www.python.org/downloads/)
and check "Add Python to PATH" during install.

If Windows Defender/SmartScreen nags about an unrecognized app, click
"More info" → "Run anyway" — the binaries aren't signed (intentionally, no
code signing fee yet).

---

## Linux

```bash
curl -sL https://github.com/JustAResearcher/MeowMiner/releases/latest/download/MeowMiner-v1.3.2-linux.tar.gz \
  | tar -xz
cd MeowMiner-v1.3.2-linux
./MeowMiner --algo lpepe              # or
./MeowMiner --algo yec                # needs python3
# or use the convenience scripts:
./mine-lpepe.sh
./mine-yec.sh
```

Requires nVidia driver ≥ 525 and the CUDA 12 runtime (bundled with the
driver on most distros). YEC needs `python3` (pre-installed on essentially
every modern distro).

---

## Algorithm aliases

| `--algo` value | Maps to |
|---|---|
| `lpepe`, `yescryptr32`, `yescrypt` | Lucky Pepe yescryptR32 |
| `yec`, `equihash-192-7`, `equihash`, `ycash` | YCash Equihash 192,7 |

## Defaults baked into the launcher

| Algo | Pool | Wallet | Worker |
|---|---|---|---|
| lpepe | `pool.luckypepe.org:3333` | `LLhcyVdMJj7xLrTLRmhui1E4MB8AgHNB5Y` | `rig1` |
| yec | `ycash.dapool.io:3344` | `s1PCDy85t521qGrxbDcgUtUrh17waskFz39` | `rig1` |

Any flag you pass after `--algo X` is forwarded to the backend and overrides
the default. The launcher only fills in defaults for flags you haven't set.

To make your own permanent wallet, just edit the line in `mine-lpepe.bat` /
`mine-yec.bat` (Windows) or `mine-lpepe.sh` / `mine-yec.sh` (Linux).

---

## Archive layout

```
MeowMiner-v1.3.2-{linux,windows}/
├── MeowMiner[.exe]            ← multi-algo launcher (MeowPoW / Yescrypt / KawPoW)
├── start-meowpow.{sh,bat}
├── start-yescrypt.{sh,bat}
├── start-kawpow.{sh,bat}
├── start-yec.{sh,bat}         ← single-GPU YEC
├── start-yec-multi.{sh,bat}   ← multi-GPU YEC (new in v1.3.2)
├── kerrigan_v9d_pd4           ← YEC kernel, high-VRAM (4070 Ti SUPER / 4090 / 5090 / A100-80)
├── kerrigan_v9d_pd2           ← YEC kernel, low-VRAM (CMP 170HX / A100-10)
├── mine.pyc                   ← YEC stratum wrapper (single-GPU)
├── mine_farm_multigpu.pyc     ← YEC stratum wrapper (multi-GPU)
├── libcudart.so.12 / libnvrtc.so.12 / libnvrtc-builtins.so.12.4
└── README.{md,txt}
```

---

## HiveOS (LPEPE only, on the 1.0.30 package for now)

Paste this URL into the **Installation URL** field of a Custom miner
flight sheet:

```
https://github.com/JustAResearcher/MeowMiner/releases/download/v1.0.30/MeowMiner-1.0.30-hiveos.tar.gz
```

Flight-sheet config:

- Miner name: `meowminer`
- Hash algorithm: `yescryptR32`
- Wallet and worker template: `%WAL%.%WORKER_NAME%`
- Pool URL: `stratum+tcp://pool.luckypepe.org:3333`
- Pass: `x`

YEC + HiveOS will be supported once the YEC backend ships h-stats.sh and an
h-run.sh wrapper. Track in a future release.

---

## What the output looks like

**LPEPE:**

```
[05:29:12] 6 miner threads started, using 'yescryptr32' algorithm.
[05:29:47] GPU #0: NVIDIA GeForce RTX 4070 Ti Super, 5.74 kH/s
[05:30:02] [Share FOUND]    GPU #0  nonce 0x3a8f91c2  submitting...
[05:30:03] [Share ACCEPTED]  1 accepted / 0 rejected  (100.00% good)  5.74 kH/s
```

**YEC:**

```
[stratum] Connected to ycash.dapool.io:3344
[stratum] Subscribed. extranonce1=08030554 (4 bytes), extranonce2_size=28
[stratum] NEW JOB 1 (clean=True)
[mine] 19.7 I/s ≈ 41.4 valid sols/sec (accepted=12 rejected=0)
[stratum] >>> ACCEPTED (a=12 r=0)
```

---

## Supported GPUs

| Algorithm | Architectures |
|-----------|---------------|
| LPEPE (yescryptR32) | sm_60+ (Pascal P40, Turing, Ampere, Ada, Blackwell) |
| YEC (Equihash 192,7) | sm_75 / sm_80 / sm_86 / sm_89 / sm_120 (Turing → Blackwell) |

Tested on: RTX 5090, RTX 4070 Ti SUPER, CMP 170HX, GTX 1080 Ti (LPEPE only).

## Benchmarks (reference)

LPEPE (yescryptR32):

| GPU                 | Hashrate    |
|---------------------|-------------|
| RTX 5090            | ~15 kH/s    |
| RTX 4070 Ti Super   | ~5,750 H/s  |
| CMP 170HX           | ~2,750 H/s  |

YEC (Equihash 192,7) — v9d_pd4 kernel as of v1.3.2:

| GPU                 | I/s    | Local Sol/s (I/s × 2) |
|---------------------|--------|-----------------------|
| RTX 5090            | ~169   | ~338                  |
| RTX 4070 Ti Super   | ~71    | ~142                  |

Pool-credited rate is lower than the local reading (typically 50-90% depending on the pool's vardiff equilibrium and PPLNS scoring window).

## License

Binary redistribution only. Source is not published. No reverse
engineering, no rebranding, no rehosting. See `LICENSE.txt`.
