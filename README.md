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
| Windows 10/11 x64 | [**MeowMiner-1.0.1-windows-x64.zip**](../../releases/latest/download/MeowMiner-1.0.1-windows-x64.zip) |
| Linux x86_64      | [**MeowMiner-1.0.1-linux-x86_64.tar.gz**](../../releases/latest/download/MeowMiner-1.0.1-linux-x86_64.tar.gz) |
| HiveOS (custom miner) | [**MeowMiner-1.0.1-hiveos.tar.gz**](../../releases/latest/download/MeowMiner-1.0.1-hiveos.tar.gz) |

All three bundle the same v1.0 miner. Just different launchers and
installer bits.

---

## Windows

1. Download **MeowMiner-1.0.1-windows-x64.zip**.
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
curl -sL https://github.com/JustAResearcher/MeowMiner/releases/latest/download/MeowMiner-1.0.1-linux-x86_64.tar.gz \
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
https://github.com/JustAResearcher/MeowMiner/releases/latest/download/MeowMiner-1.0.1-hiveos.tar.gz
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
[05:30:03] [Share ACCEPTED]  1 accepted / 0 rejected  (100.00% good)  5.74 kH/s
[05:30:41] [Share ACCEPTED]  2 accepted / 0 rejected  (100.00% good)  5.75 kH/s
[05:31:12] [Share REJECTED]  2 accepted / 1 rejected  ( 66.67% good)  5.73 kH/s
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

Override the launchers:

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

The coinbase builder automatically includes Lucky Pepe's mandatory
dev-fund output, so solo blocks get accepted on the first submission —
no more `bad-cb-devfund-missing` rejections.

---

## License

Binary redistribution only. Source is not published. No reverse
engineering, no rebranding, no rehosting. See `LICENSE.txt` inside each
download.
