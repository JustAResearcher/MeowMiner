# MeowMiner v1.6.53 - BTX v0.33 + Pearl multi-coin

MeowMiner v1.6.53 combines the native BTX and Pearl NVIDIA miners behind one
`--coin btx|pearl` launcher on Windows, Linux, and HiveOS.

## What changed

- BTX candidates now receive a final consensus pre-hash check against the exact
  submitted header after meeting the pool share target and before emission.
  This prevents LuckyPool code 23 (`BTX pre-hash gate failed`) rejects even if
  the earlier CUDA scan-stage CPU recheck is explicitly disabled.
- CUDA scan CPU recheck now defaults on as an earlier safety filter.
- LuckyPool sessions now say `LuckyPool` / `luckypool job` in user-facing logs;
  the shared native protocol identifier remains internal.
- BTX now defaults to LuckyPool US-East at
  `btx-us-east.lproute.com:8660` on every packaged platform.
- Retained BTX v0.33 `parentMtp` validation and the Pearl v1.6.43
  architecture-specific engines for sm_86, sm_89, sm_90, and sm_120.
- BTX uses the pool-validated 0.33.0-opt37-luckypool-prehashfix CUDA solver. BTX has no dev fee;
  Pearl retains its 2% dev fee.

## Validation

- Released Windows solver control: 2 accepted / 12 code-23 rejects in 219s.
- Patched Windows solver: 8 accepted / 0 rejects across three independent
  LuckyPool canaries totaling about 268s, including a clean parent change.
- Final extracted v1.6.53 Windows archive: 3 accepted / 0 rejected in a
  140-second LuckyPool canary; it crossed a clean parent change and discarded
  the stale old-job result.
- The decisive canary ran with scan-stage CPU recheck disabled, isolating the
  final exact-header guard as the effective fix.
- Logs showed `LuckyPool` and `luckypool job`; no `ninjaraider` label appeared.
- Targeted wrapper tests passed: 51 passed, 2 skipped.
- RTX 5070 model fixture selected batch 128 and four CUDA pool slots.
- Pearl accepted shares: HeroMiners, RTX 5070 Ti, zero invalid shares during canary.
- Windows PowerShell launcher parse/help smoke test passed.
- Linux and HiveOS shell syntax checks passed.
- Staged mining-binary SHA256 values match the validated source packages.
- Archive layout checks passed for all three targets.

## Assets

- `MeowMiner-1.6.53-windows-x64.zip`
- `MeowMiner-1.6.53-linux-x86_64.tar.gz`
- `meowminer-1.6.53.tar.gz` (HiveOS)
- `SHA256SUMS.txt`

## SHA256

2941c31d00d414e5755665b8f90c6520a1348e7ba26bf3cc9c1228e44d04d094  meowminer-1.6.53.tar.gz
2e8862841e88ebc7db1e6218eb44d9643175373379334b1042d19581800b59a5  MeowMiner-1.6.53-linux-x86_64.tar.gz
305ef1d9fd35c5868e5c1b67a3d7121a3b09c65373b5531050e3449704ff8193  MeowMiner-1.6.53-windows-x64.zip
