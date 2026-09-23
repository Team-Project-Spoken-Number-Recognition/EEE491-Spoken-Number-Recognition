# MATLAB

| Folder | Content | Active from |
|---|---|---|
| `debug/` | PC side of Lab-DEBUG: serial receiver/decoder, COE generator, compare-with-COE | Lab-DEBUG |
| `model/` | Complete recognition model (golden reference) | Lab-MATLAB (manual pending) |
| `preprocessing/` | Pre-emphasis, framing, windowing reference | released stage only |
| `features/` | FFT / MEL / log / DCT reference, fixed-point (bit-true) versions | released stage only |
| `recognition/` | Templates, distance, decision | released stage only |
| `analysis/` | Scripts analysing data dumped from the FPGA | Lab-DEBUG onward |
| `tests/` | Automated tests (`MT-*` IDs from TEST_PLAN.md) | always |

Reference-model flow: `VERIFICATION_PLAN.md` §4. Rules: `CONTRIBUTING.md` §7.
Version: R2023b observed on one PC (ASSUMPTION-005).
