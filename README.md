# MeowMiner

A closed-source, pre-tuned YescryptR32 CUDA miner for **Lucky Pepe (LPEPE)**
on nVidia GPUs. Drop-in replacement for ccminer.

Live share counter. Optimized yescrypt CUDA kernel. Correct Lucky Pepe
dev-fund coinbase. Three one-click installers, one for each OS you might
run.

## Downloads

Pick the one that matches your OS — each is a standalone package, no
cross-platform junk dragging along.

| OS                | Download                                                                                       |
|-------------------|------------------------------------------------------------------------------------------------|
| Windows 10/11 x64 | [**MeowMiner-1.0.25-windows-x64.zip**](../../releases/latest/download/MeowMiner-1.0.25-windows-x64.zip) |
| Linux x86_64      | [**MeowMiner-1.0.25-linux-x86_64.tar.gz**](../../releases/latest/download/MeowMiner-1.0.25-linux-x86_64.tar.gz) |
| HiveOS (custom miner) | [**MeowMiner-1.0.25-hiveos.tar.gz**](../../releases/latest/download/MeowMiner-1.0.25-hiveos.tar.gz) |

All three bundle the same v1.0 miner. Just different launchers and
installer bits.

---

## Windows

1. Download **MeowMiner-1.0.25-windows-x64.zip**.
2. Right-click → *Extract All…*
3. Double-click **`run.bat`**.

Pool and wallet are pre-filled. Worker name defaults to `rig1`; if you
run more than one rig, edit `run.bat` and change `WORKER=rig1` to
`rig2`, `rig3`, etc.

If Windows Defender/SmartScreen nags about an unrecognized app, click
"More info" → "Run anyway" — the binary isn't signed (intentionally, no
code signing fee yet).

---

## Linux (bare-metal, non-HiveOS)

```bash
curl -sL https://github.com/JustAResearcher/MeowMiner/releases/latest/download/MeowMiner-1.0.25-linux-x86_64.tar.gz \
  | tar -xz
chmod +x run.sh MeowMiner
./run.sh
```

Requires nVidia driver ≥ 525 and the CUDA 12 runtime (included with the
driver on most distros). Pool + wallet are pre-filled in `run.sh`.

---

## HiveOS

Paste this URL into the **Installation URL** field of a Custom miner
flight sheet. That's it.

```
https://github.com/JustAResearcher/MeowMiner/releases/latest/download/MeowMiner-1.0.25-hiveos.tar.gz
```

Full flight-sheet setup (HiveOS dashboard):

1. **Wallets → Add Wallet**
   - Coin: pick any Custom coin
   - Address: your LPEPE wallet (or `LLhcyVdMJj7xLrTLRmhui1E4MB8AgHNB5Y` to mine to JustAResearcher)

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

No SSH. No manual setup. Same workflow as SRBMiner or XMRig.

---

## What the output looks like

```
[05:29:12] 6 miner threads started, using 'yescryptr32' algorithm.
[05:29:47] GPU #0: NVIDIA GeForce RTX 4070 Ti Super, 5.74 kH/s
[05:30:02] [Share FOUND]    GPU #0  nonce 0x3a8f91c2  submitting...
[05:30:03] [Share ACCEPTED]  1 accepted / 0 rejected  (100.00% good)  5.74 kH/s
[05:30:40] [Share FOUND]    GPU #2  nonce 0x71b4ef0a  submitting...
[05:30:41] [Share ACCEPTED]  2 accepted / 0 rejected  (100.00% good)  5.75 kH/s  1.58 shares/min
[05:31:11] [Share FOUND]    GPU #1  nonce 0xd2ef7004  submitting...
[05:31:12] [Share REJECTED]  2 accepted / 1 rejected  ( 66.67% good)  5.73 kH/s  1.95 shares/min
```

Every accepted/rejected share prints a line. Running totals + good-share
percentage are updated on every submission.

---

## Supported GPUs

| GPU family        | Compute cap. | Example cards            |
|-------------------|--------------|--------------------------|
| Turing            | sm_75        | RTX 20xx                 |
| Ampere            | sm_80/86     | RTX 30xx, CMP 170HX      |
| Ada Lovelace      | sm_89        | RTX 40xx                 |
| Blackwell         | sm_120       | RTX 50xx (PTX JIT)       |

The binary ships with sm_80 + sm_89 baked in + compute_90 PTX for
forward-compat JIT (covers Blackwell).

---

## Benchmarks (reference)

| GPU                 | Hashrate    | Core / Mem / Power   |
|---------------------|-------------|----------------------|
| RTX 5090            | ~15 kH/s    | stock                |
| RTX 4070 Ti Super   | ~5,750 H/s  | 2400 / 11501 / 180W  |
| CMP 170HX           | ~2,750 H/s  | 1200 / stock / 180W  |

---

## Advanced usage

### Flag reference

Pool mining (most users):

```
MeowMiner -a yescryptR32 \
          -o stratum+tcp://pool.luckypepe.org:3333 \
          -u <your_wallet>.<worker_name> \
          -p x
```

Solo mining against your own LPEPE node:

```
MeowMiner -a yescryptR32 \
          -o http://<node-ip>:<rpc-port> \
          -u <rpc-user> -p <rpc-pass> \
          --coinbase-addr=<payout-address> \
          --no-stratum --segwit --no-longpoll --timeout=30
```

| Flag | Required? | What it does |
|---|---|---|
| `-a <algo>` | **yes** | Algorithm. Use `yescryptR32` for Lucky Pepe. |
| `-o <url>` | **yes** | Pool URL (stratum) or node RPC URL (solo GBT). |
| `-u <user>` | **yes** | Pool mode: `<wallet>.<worker>`. Solo mode: node RPC user. |
| `-p <pass>` | **yes** | Pool mode: always `x`. Solo mode: node RPC password. |
| `-b <host:port>` | HiveOS only | Opens the built-in stats API. `h-stats.sh` reads it to report hashrate and accept/reject to the HiveOS dashboard. Default `127.0.0.1:4068`. |
| `--no-color` | optional | Strips ANSI escape codes from output. Useful when piping to a log file or running under a log collector (HiveOS). Drop it if you're watching the console — `[Share ACCEPTED]` is nicer in green. |
| `--coinbase-addr=<addr>` | solo only | Where the miner pays itself when it finds a block. Ignored in pool mode. **Case-sensitive** — one wrong letter and the miner exits with `invalid address`. |
| `--no-stratum` | solo only | Forces GBT (getblocktemplate) over JSON-RPC instead of stratum. Required when mining directly against a `bitcoind`-style node. |
| `--segwit` | solo only | Enables segwit rules in the GBT request. Required on chains where segwit is active (Lucky Pepe is). |
| `--no-longpoll` | solo only | Disables HTTP long-polling for new block notifications. Most local nodes behave better without it; the miner just polls `getblocktemplate` every ~15s. |
| `--timeout=30` | solo only | Network timeout in seconds for the RPC call. 30s is comfortable; default 270s is too long. |
| `--retries=-1` | optional | Retry pool/node connection forever on failure. Without this, the miner gives up after 10 attempts — which means a brief WiFi drop takes your rig offline until you SSH in and restart. Recommended for unattended rigs. |
| `-R 30` | optional | Wait 30 seconds between reconnect attempts. Pairs with `--retries=-1` to avoid hammering the pool on outages. |
| `-d <n>` | optional | Pick a specific GPU index (0, 1, …). Omit to mine on all GPUs. |
| `-i <n>` | optional | Intensity. The miner picks this for you based on VRAM — override only if you know what you're doing. |

The coinbase builder automatically includes Lucky Pepe's mandatory
dev-fund output, so solo blocks get accepted on the first submission —
no more `bad-cb-devfund-missing` rejections.

---

## License

Binary redistribution only. Source is not published. No reverse
engineering, no rebranding, no rehosting. See `LICENSE.txt` inside each
download.
