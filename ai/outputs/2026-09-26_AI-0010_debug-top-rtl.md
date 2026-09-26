# AI-0010 — Lab-DEBUG demo top level: RTL, testbenches, synthesis, implementation

```text
ID:            AI-0010
Date:          2026-09-26
Team Member:   eeerenbuyukbas
AI Tool:       Claude Code, desktop app (Code tab)
Model:         Claude Opus 5.5 (claude-opus-5-5)
Purpose:       Implement the reviewed design top_debug_demo.md (PR #7) — "Approval received. We can start the RTL."
```

## AI Output (branch `feature/debug-top`, PR #7)
| File | Content |
|---|---|
| `fpga/rtl/common/sync_2ff.vhd` | 2-FF synchroniser, `ASYNC_REG`, generic init value |
| `fpga/rtl/common/button_conditioner.vhd` | sync + counter debounce (G_DEBOUNCE_CYCLES) + 1-clock pulse |
| `fpga/rtl/top/top_debug_demo.vhd` | BTNC reset sync, BTNU conditioning, `debug`, `debug_rom`, LD6 |
| `fpga/constraints/top_debug_demo.xdc` | pins from the official XDC, clock, false paths for async I/O, config options |
| `fpga/tb/debug/tb_button_conditioner.vhd` | TB-BTN-01…05 |
| `fpga/tb/debug/tb_top_debug_demo.vhd` | TB-TOPDBG-01…03 with the real IP, expected data read from the COE |
| `fpga/vivado/sim_top_debug_demo.tcl` | project-mode simulation with the IP (same pattern as Ömer's script) |
| `fpga/vivado/build_debug_demo.tcl` | non-project synthesis → implementation → bitstream, reports |

## Verification performed by the AI (Eren's PC, Vivado 2025.2)
| Item | Result |
|---|---|
| TB-BTN-01…05 | PASS 22/22; mutation: 3 injected bugs → FAIL 4/22, 5/22, 1/22 (all detected) |
| TB-TOPDBG-01…03 | PASS 15/15 (N = 14, two full frames = 131 088 bytes equal to the COE); mutation G_MEM_LATENCY = 1 → FAIL 2/15 (every word shifted) |
| Synthesis / implementation / bitstream | WNS +5.083 ns, WHS +0.122 ns, DRC 0, methodology 0; 128 LUT, 114 FF, 14.5 BRAM tiles |

## Problems met and how they were solved (for the team)
1. **Non-ASCII/space path:** Vivado could not open sources under `…\OneDrive\Masaüstü\EEE391 Project\…`
   → build from a git worktree at `C:\dev\eee491_build` (DEC-014 updated, TEAM_MANUAL §10).
2. **`'compile.bat' is not recognized`:** the Claude Code shell sets `NoDefaultCurrentDirectoryInExePath=1`,
   so `cmd` ignores `.bat` files in the current folder → removed for the Vivado command (TEAM_MANUAL §10).
3. **Own mistakes, corrected in-session:** (a) a PowerShell edit wrote a UTF-8 BOM into a mutated testbench
   copy (compile error) — redone with `sed`; (b) the first mutation run overwrote the evidence log with a
   FAIL result — the passing simulation was re-run and its log stored; (c) path redaction in the button log
   left a fragment — replaced by repository-relative paths; (d) the button-latency formula in the design doc
   (2 + D + 1) was one edge off — measured value is 2 + D, doc corrected (v0.3).
4. BRAM estimate 16 RAMB36 → actual 14.5 tiles; doc corrected.

## Reference design use (DEC-018)
None in this step (debounce deviation already recorded in DEC-019).

## Follow-up AI-0011 — Ömer's §12 review comment (PR #7)
Ömer reviewed §12 in a PR comment at 13:06 (before the RTL commits). **The AI did not check the PR for new
comments before continuing and missed it** until Eren asked. Items: (1) BRAM estimate 16 → IP estimate
14 RAMB36 + 1 RAMB18 — accepted, confirmed in `debug_rom.xci` and by the post-route report; SYN-TOPDBG
criterion had already been changed in v0.3; (2) pattern example `k = 5 → 0005FFFA` — accepted; (3) changing N
also needs a new COE + TB-ROM re-run — accepted; (4) "6.6 M cycles, not 6.7 M" — **partly disputed**: 6.55 M
counts only the bits; with the 2-clock byte gap and the 4-clock word overhead it is 6.75 M, matching the
simulated 67.5 ms — formula written into §12. Design doc v0.4.
Lesson: re-read PR reviews/comments before every push to a PR branch.

## Human Review / Detected Issues / Final Decision
_PENDING — reviewers of PR #7 (Ömer, Hande)._

## Related Commit
Branch `feature/debug-top` (PR #7).
