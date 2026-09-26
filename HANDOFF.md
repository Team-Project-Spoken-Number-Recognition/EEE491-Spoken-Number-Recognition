# Current Project State

_Last updated: 2026-09-26 by Claude Code (Opus 5.5, AI-0010) in a session with Eren (`eeerenbuyukbas`)._
_Everything below is AI-generated and **not yet reviewed by the team**._

> **HANDOFF/REPOSITORY INCONSISTENCY fixed in this update:** the previous version (AI-0006) still said
> PR #4 was open and the MATLAB receiver / ROM were not started. PR #4 was squash-merged on 2026-09-26;
> the MATLAB side and the ROM IP are in PR #5.

## Current Objective
**Lab-DEBUG demo on Wed Sep 30.** All design pieces exist: `debug` (#4), MATLAB + ROM IP (#5), demo top level
(#7, RTL + bitstream). **Remaining: review/merge PR #7, then the hardware tests HW-DEBUG-01…05 on the board.**

## What Has Been Completed
- Phase 1 documents, TEAM_MANUAL (#1), TA answers + DEC-018 (#2), `debug.md` v0.2 (#3) — merged.
- **#4 merged:** `uart_tx`, `debug` + testbenches (Hande, AI-0004/0006).
- **#5 merged:** MATLAB side (`matlab/debug/`, MT-DEBUG-01…04) + demo ROM IP `debug_rom` + COE + `tb_debug_rom` (Ömer, AI-0007).
- **#6 merged:** DEC-008 — Vivado ML Standard 2025.2 for everyone.
- **#7 open (`feature/debug-top`, Eren, AI-0008/0009/0010):** design doc `top_debug_demo.md` v0.3 (approved by
  Ömer); RTL `sync_2ff`, `button_conditioner`, `top_debug_demo`; XDC `top_debug_demo.xdc` (pins verified against
  the official Digilent XDC); `tb_button_conditioner`, `tb_top_debug_demo`; scripts `sim_top_debug_demo.tcl`,
  `build_debug_demo.tcl`; DEC-019 (debounce); reports in `docs/verification/`.

## What Is Currently Working (simulation + implementation, no hardware yet)
- `uart_tx` 37/37, `debug` 97/97, `debug_rom` 11/11, MATLAB 15/15 (R2025b and R2023b).
- `button_conditioner` **22/22** (TB-BTN-01…05, 3 mutants detected).
- **Demo top level with the real ROM IP, N = 14: 15/15** (TB-TOPDBG-01…03: two full frames of 65 544 bytes
  equal to the COE, bounce/hold/press-while-busy handled; latency mutant detected).
- **Bitstream built:** WNS +5.083 ns, WHS +0.122 ns, DRC 0; 128 LUT, 114 FF, 14.5 BRAM tiles.
- Logs: `simulation/results/2026-09-26_*.log`; reports: `docs/verification/2026-09-26_top_debug_demo_*`.

## What Is Not Working / Not Done
- No hardware test yet (HW-DEBUG-01…05); 1 Mbaud on the real FT2232HQ/VCP/MATLAB chain unverified (R-15).
- Bitstream is not in git (build output): rebuild with `fpga/vivado/build_debug_demo.tcl`, or use the file in
  `C:\dev\eee491_build\fpga\vivado\build\debug_demo\` on Eren's PC; attach to the demo release.
- Data-capable micro-USB cable: Hande's is charge-only; Eren has one.

## Current Branch
`feature/debug-top` (PR #7), pushed. Build worktree on Eren's PC: `C:\dev\eee491_build` (detached, for
Vivado — the main working copy is under OneDrive\Masaüstü, which Vivado cannot use, DEC-014).
Remote: https://github.com/Team-Project-Spoken-Number-Recognition/EEE491-Spoken-Number-Recognition (public, DEC-016).

## Build / simulation notes (all members)
- Run Vivado scripts from a clone at an **ASCII path without spaces** (DEC-014), with Vivado's `bin` on `PATH`.
- Simulation with the IP: `vivado -mode batch -source fpga/vivado/sim_top_debug_demo.tcl` (≈ 1 min).
- Bitstream: `vivado -mode batch -source fpga/vivado/build_debug_demo.tcl` (≈ 2 min) → `fpga/vivado/build/debug_demo/top_debug_demo.bit`.
- In Claude Code shells remove `NoDefaultCurrentDirectoryInExePath` for Vivado commands (TEAM_MANUAL §10).

## Open review findings (non-blocking)
- PR #4 findings 1–7 (style: `numeric_std` in `uart_tx`, inner `when others`, named constants, UART RX
  model not in `fpga/tb/common/`, TB-DEBUG-05 coverage, debug.md header "DRAFT v0.1", GHDL claim without
  evidence) — after the demo; any RTL change needs both TBs re-run.
- Merge style: PR #4 was squash-merged and its branch deleted (DEC-004).

## Important Technical Decisions
DEC-004/005/015/016/017/018 ACCEPTED; DEC-008 ACCEPTED (Vivado 2025.2) once PR #6 is merged; others PROPOSED.
Relevant now: DEC-007 (sync reset), DEC-010 (fixed-length MATLAB read), DEC-011, DEC-012, DEC-013.

## Known Bugs
None found in simulation or MATLAB tests.

## Current Test Results
TB-UART-01…03, TB-DEBUG-01…09, TB-ROM-01…03, MT-DEBUG-01…04 PASS (2026-09-26).
TB-TOPDBG-01, HW-DEBUG-01…05 PLANNED.

## Simulation Results
See above; logs in `simulation/results/`.

## Hardware Results
None.

## Next Steps
1. Hande (and/or Ömer): review + squash-merge PR #7 (RTL part).
2. Program the board (Hardware Manager → `top_debug_demo.bit`); LD6 must be on after configuration.
3. HW-DEBUG-01: terminal at 1 000 000 baud 8N1, press BTNU → bytes `55 AA CC 03 …` visible.
4. HW-DEBUG-02…05: `run_debug_demo("COMx")` in MATLAB, press BTNU → `PASS: 16384/16384 words match`; repeat
   10×, hold/press-during-transfer, BTNC during transfer. Evidence into `docs/verification/`.
5. Demo prep: waveform screenshots (start, ready, txd) from `tb_debug` / `tb_top_debug_demo`; Tuesday evening freeze.
6. Session exports: AI-0004 (Hande) still to add; AI-0008…0010 (Eren) to export.
7. Wed Sep 30: demo, tag `lab-debug-demo`, release with the bitstream.

## Blockers
- Demo top level not started (critical path: top level → integration sim → bitstream → hardware).
- PR #5 / #6 need a review (authors cannot approve their own PRs).

## Assumptions
See `ASSUMPTIONS.md` — VERIFIED: -006, -007, -008 (TA), **-011 (ROM latency 2, TB-ROM-01)**, -004 (Vivado
2025.2 for Hande/Ömer). Open: -001 (part number), -003 (TX pin A18), -005 (MATLAB version), -009 (1 Mbaud on
PC), -013 (dates after Sep 30).

## Questions for Instructor
Q-01 … Q-13 answered (`docs/meetings/INSTRUCTOR_QUESTIONS.md`). Open: **Q-14** to Enis Hoca (DCT/COMPARE → NN labs?).

## Things That MUST NOT Be Changed Without Review
- Port names and handshake semantics taken from the manuals (`INTERFACES.md` §2–4).
- Start/end words `55AACC03` / `AA5503CC` and the MSB-first byte order (TA-confirmed).
- Board pin assignment in `INTERFACES.md` §1.1 (DEC-018).
- The released/pending split of manuals (`docs/manuals/` vs `docs/manuals/pending/`).
- Requirement IDs (never renumber; deprecate instead).
- `debug` / `uart_tx` behaviour — every change needs a TB re-run and a new log.
- ROM settings (output register ON → latency 2) and the COE test pattern — `G_MEM_LATENCY`, TB-ROM and
  MT-DEBUG tests depend on them; regenerate COE + IP + logs together.
