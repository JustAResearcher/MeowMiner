# MeowMiner v1.6.52 - BTX v0.33 + Pearl multi-coin

MeowMiner v1.6.52 combines the native BTX and Pearl NVIDIA miners behind one
`--coin btx|pearl` launcher on Windows, Linux, and HiveOS.

## What changed

- LuckyPool regional endpoints now use their native `wallet.worker` / password
  login directly instead of probing unsupported Stratum methods first.
- Added a 30-second first-job watchdog so an authorized but idle LuckyPool
  session reconnects instead of hanging forever.
- Added a Windows RTX 5070 (12 GB) compatibility profile: threads 8,
  prepare-workers 8, batch 128, and four CUDA pool slots. v1.6.51 incorrectly
  left this non-Ti card on the generic batch-512 / eight-slot profile.
- Retained BTX v0.33 `parentMtp` validation and the Pearl v1.6.43
  architecture-specific engines for sm_86, sm_89, sm_90, and sm_120.
- BTX uses the pool-validated 0.33.0-opt36-luckypool-winfix CUDA solver. BTX has no dev fee;
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

- `MeowMiner-1.6.52-windows-x64.zip`
- `MeowMiner-1.6.52-linux-x86_64.tar.gz`
- `meowminer-1.6.52.tar.gz` (HiveOS)
- `SHA256SUMS.txt`

## SHA256

80c79a2bb00bc965bf6e23d0d754dc16eeb5ec3cc1c176a2dbc254ec7f5ca617  meowminer-1.6.52.tar.gz
537a2f48bdd5b7beeaef94a5809734739e05003ddeaf31a21f55a5fdf97c7aa7  MeowMiner-1.6.52-linux-x86_64.tar.gz
7c35522e4ea1bf71345da8d9d778c466326da38499e4a503bbe0f475a14e468b  MeowMiner-1.6.52-windows-x64.zip