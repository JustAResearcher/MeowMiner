# MeowMiner v1.6.51 - BTX v0.33 + Pearl multi-coin

MeowMiner v1.6.51 combines the native BTX and Pearl NVIDIA miners behind one
`--coin btx|pearl` launcher on Windows, Linux, and HiveOS.

## What changed

- Updated BTX pool work for v0.33 template context, including `parentMtp` seed
  handling and fail-closed validation when a post-upgrade job omits it.
- Added a common multi-coin launcher for BTX and Pearl.
- Added `--devices` GPU selection so separate instances can mine different
  coins concurrently on disjoint GPUs.
- Retained the Pearl v1.6.43 architecture-specific engines for sm_86,
  sm_89, sm_90, and sm_120.
- BTX uses the pool-validated 0.33.0-opt35-v033ctx CUDA solver. BTX has no dev fee;
  Pearl retains its 2% dev fee.

## Validation

- BTX accepted shares: NinjaRaider, RTX 5070 Ti, zero rejects during canary.
- Pearl accepted shares: HeroMiners, RTX 5070 Ti, zero invalid shares during canary.
- Windows PowerShell launcher parse/help smoke test passed.
- Linux and HiveOS shell syntax checks passed.
- Staged mining-binary SHA256 values match the validated source packages.
- Archive layout checks passed for all three targets.

## Assets

- `MeowMiner-1.6.51-windows-x64.zip`
- `MeowMiner-1.6.51-linux-x86_64.tar.gz`
- `meowminer-1.6.51.tar.gz` (HiveOS)
- `SHA256SUMS.txt`

## SHA256

070156a6fe09116b4e2b780f755ad42309ead0e5a638df4c36b5bb6f15dddd58  meowminer-1.6.51.tar.gz
1b5431228e5874e90e6aea517ef46486d9a8669082fd4f87bb94b49e3fab013b  MeowMiner-1.6.51-linux-x86_64.tar.gz
379b8c92ac35dd5a6523275999dcc35d6221629003ceb83bdeea53f372309619  MeowMiner-1.6.51-windows-x64.zip