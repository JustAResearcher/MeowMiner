# MeowMiner

A closed-source, pre-tuned YescryptR32 CUDA miner for **Lucky Pepe (LPEPE)**
on nVidia GPUs. Drop-in replacement wherever you'd use ccminer.

No setup. No flags to memorize. Unzip, double-click, mine.

## Download

Grab the latest release: **[MeowMiner-1.0.zip](../../releases/latest)**

Inside the zip:

```
windows-x64/MeowMiner.exe     Windows 64-bit binary
windows-x64/run.bat           one-click Windows launcher (pool + wallet pre-filled)
linux-x86_64/MeowMiner        Linux 64-bit binary
linux-x86_64/run.sh           one-click Linux launcher
```

## Quick start

### Windows
1. Download the zip, extract it.
2. Double-click `windows-x64\run.bat`.
3. That's it. The worker name is auto-set from your `%COMPUTERNAME%`.

### Linux
```bash
unzip MeowMiner-1.0.zip
cd linux-x86_64
chmod +x run.sh MeowMiner
./run.sh
```

## What's in the box

- Drop-in mining against **stratum+tcp://pool.luckypepe.org:3333**
- Single binary covers **Turing (20xx), Ampere (30xx, CMP 170HX), Ada (40xx),
  and Blackwell (50xx via compute_90 PTX JIT)**.
- Pre-tuned yescrypt CUDA kernel (`--maxrregcount=255 + #pragma unroll 8`) —
  squeezes every last H/s out of 40-series cards at stock power/clock.
- Lucky Pepe coinbase builder that correctly handles the 7% mandatory
  dev-fund consensus rule (blocks get accepted the first time, no
  `bad-cb-devfund-missing` rejections).

## Supported algorithm

- `yescryptR32` — Lucky Pepe

## Advanced usage

If you want to override the launcher:

```
MeowMiner -a yescryptR32 \
          -o stratum+tcp://pool.luckypepe.org:3333 \
          -u <your_wallet>.<worker_name> \
          -p x
```

Solo / GBT mining against your own node:

```
MeowMiner -a yescryptR32 \
          -o http://<node-ip>:<rpc-port> \
          -u <rpc-user> -p <rpc-pass> \
          --coinbase-addr=<payout-address> \
          --no-stratum --segwit --no-longpoll --timeout=30
```

## Benchmarks (reference)

| GPU              | Hashrate   | Core / Mem / Power |
|------------------|------------|--------------------|
| RTX 4070 Ti Super | ~5,750 H/s | 2400 / 11501 / 180W |
| RTX 5090          | ~18 kH/s   | stock               |
| CMP 170HX         | ~2,750 H/s | 1200 / stock / 180W |

## System requirements

- nVidia GPU (compute capability ≥ 7.5: Turing or newer)
- Windows 10/11 (x64) — CUDA 13.x runtime bundled with driver ≥ 581
- Linux x86_64 with CUDA 12.x runtime (matches HiveOS miners)

## License

Binary redistribution only. Source is not published. No reverse
engineering, no rebranding, no rehosting.
