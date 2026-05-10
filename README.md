# MeowMiner

A closed-source, pre-tuned CUDA miner for **two coins**:

- **Lucky Pepe (LPEPE)** — yescryptR32
- **YCash (YEC)** — Equihash 192,7

One archive, two binaries, one launcher per coin. Pick the coin you want
to mine, double-click the matching launcher.

## Downloads

| OS                    | Download |
|-----------------------|----------|
| Windows 10/11 x64     | [**MeowMiner-1.1.0-windows-x64.zip**](../../releases/latest/download/MeowMiner-1.1.0-windows-x64.zip) |
| Linux x86_64          | [**MeowMiner-1.1.0-linux-x86_64.tar.gz**](../../releases/latest/download/MeowMiner-1.1.0-linux-x86_64.tar.gz) |
| HiveOS (LPEPE only)   | [**MeowMiner-1.0.30-hiveos.tar.gz**](../../releases/download/v1.0.30/MeowMiner-1.0.30-hiveos.tar.gz) |

HiveOS multi-algo packaging will land in a later release.

---

## Windows

1. Download **MeowMiner-1.1.0-windows-x64.zip**.
2. Right-click → *Extract All…*
3. Double-click the launcher for the coin you want:
   - **`run-lpepe.bat`** — Lucky Pepe
   - **`run-yec.bat`** — YCash *(requires Python 3 in PATH; get it from
     [python.org](https://www.python.org/downloads/) — check "Add Python
     to PATH" during install)*

Pool and wallet are pre-filled. Worker name defaults to `rig1`; if you run
more than one rig, edit the launcher and change `WORKER=rig1` to `rig2`,
`rig3`, etc.

If Windows Defender/SmartScreen nags about an unrecognized app, click
"More info" → "Run anyway" — the binary isn't signed (intentionally, no
code signing fee yet).

---

## Linux

```bash
curl -sL https://github.com/JustAResearcher/MeowMiner/releases/latest/download/MeowMiner-1.1.0-linux-x86_64.tar.gz \
  | tar -xz
cd MeowMiner-1.1.0-linux
./run-lpepe.sh   # Lucky Pepe
# OR
./run-yec.sh     # YCash (needs python3 — usually pre-installed)
```

Requires nVidia driver ≥ 525 and the CUDA 12 runtime (included with the
driver on most distros). Pool + wallet are pre-filled in each `.sh`.

---

## HiveOS (LPEPE only, on the 1.0.30 package for now)

Paste this URL into the **Installation URL** field of a Custom miner
flight sheet. That's it.

```
https://github.com/JustAResearcher/MeowMiner/releases/download/v1.0.30/MeowMiner-1.0.30-hiveos.tar.gz
```

Full flight-sheet setup (HiveOS dashboard):

1. **Wallets → Add Wallet**
   - Coin: pick any Custom coin
   - Address: your LPEPE wallet

2. **Flight Sheets → Add Flight Sheet → Setup Miner Config → Custom**
   - Miner name: `meowminer`
   - Installation URL: *(paste the link above)*
   - Hash algorithm: `yescryptR32`
   - Wallet and worker template: `%WAL%.%WORKER_NAME%`
   - Pool URL: `stratum+tcp://pool.luckypepe.org:3333`
   - Pass: `x`

3. Apply the flight sheet. HiveOS pulls the tarball, extracts to
   `/hive/miners/custom/meowminer`, and runs it. Hashrate, temps, fan,
   and accept/reject counts show up in the web dashboard via
   `h-stats.sh`. Crashes get auto-restarted.

YEC + HiveOS will be supported once the YEC backend has h-stats.sh and an
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

## Pools (defaults)

| Coin | Pool | Port |
|------|------|------|
| LPEPE | `pool.luckypepe.org` | 3333 |
| YEC | `ycash.dapool.io` | 3344 |

You can edit the launcher to point at any other pool that speaks stratum
for the matching algorithm.

---

## Benchmarks (reference)

LPEPE (yescryptR32):

| GPU                 | Hashrate    |
|---------------------|-------------|
| RTX 5090            | ~15 kH/s    |
| RTX 4070 Ti Super   | ~5,750 H/s  |
| CMP 170HX           | ~2,750 H/s  |

YEC (Equihash 192,7):

| GPU                 | I/s    | Valid sols/sec |
|---------------------|--------|----------------|
| RTX 5090            | ~110   | ~233           |
| RTX 4070 Ti Super   | ~19    | ~41            |

---

## What about a single multi-algo binary?

This v1.1 ships two separate binaries inside one archive, one launcher
each. A future v1.2 will merge into a single `MeowMiner` command that
dispatches via `--algo`.

## License

Binary redistribution only. Source is not published. No reverse
engineering, no rebranding, no rehosting. See `LICENSE.txt` inside each
download.
