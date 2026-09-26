# Current Project State

_Last updated: 2026-09-26 by Claude Code (Opus 5.5, AI-0015) in a session with Eren (`eeerenbuyukbas`)._
_Everything below is AI-generated and **not yet reviewed by the team**._

> **HANDOFF/REPOSITORY INCONSISTENCY fixed in this update:** the previous version (AI-0006) still said
> PR #4 was open and the MATLAB receiver / ROM were not started. PR #4 was squash-merged on 2026-09-26;
> the MATLAB side and the ROM IP are in PR #5.

## Current Objective
**Lab-DEBUG demo on Wed Sep 30.** Everything is implemented, simulated, synthesised **and hardware-tested**
(HW-DEBUG-02…05 PASS). Remaining: merge the evidence PR (`test/debug-hw`), demo preparation, the demonstration.

## What Has Been Completed
- Phase 1 documents, TEAM_MANUAL (#1), TA answers + DEC-018 (#2), `debug.md` v0.2 (#3) — merged.
- **#4 merged:** `uart_tx`, `debug` + testbenches (Hande, AI-0004/0006).
- **#5 merged:** MATLAB side (`matlab/debug/`, MT-DEBUG-01…04) + demo ROM IP `debug_rom` + COE + `tb_debug_rom` (Ömer, AI-0007).
- **#6 merged:** DEC-008 — Vivado ML Standard 2025.2 for everyone.
- **#7 open (`feature/debug-top`, Eren, AI-0008/0009/0010):** design doc `top_debug_demo.md` v0.3 (approved by
  Ömer); RTL `sync_2ff`, `button_conditioner`, `top_debug_demo`; XDC `top_debug_demo.xdc` (pins verified against
  the official Digilent XDC); `tb_button_conditioner`, `tb_top_debug_demo`; scripts `sim_top_debug_demo.tcl`,
  `build_debug_demo.tcl`; DEC-019 (debounce); reports in `docs/verification/`.

## What Is Currently Working (simulation, implementation and hardware)
- Simulation: `uart_tx` 37/37, `debug` 97/97, `debug_rom` 11/11, `button_conditioner` 22/22, demo top 15/15; MATLAB 15/15.
- Bitstream: WNS +5.083 ns, WHS +0.122 ns, DRC 0; 128 LUT, 114 FF, 14.5 BRAM tiles (PR #7, merged).
- **Hardware (Basys-3, COM4, 1 Mbaud): HW-DEBUG-02…05 PASS** — 16 384/16 384 words every time, 10/10 repeats
  (0.62–0.67 s), hold and press-during-transfer → one frame, reset during transfer → truncated frame + clean
  restart. Report: `docs/verification/2026-09-26_HW-DEBUG.md`; log `2026-09-26_hw_debug_session.log`.
- Guided hardware session: `addpath("<repo>/matlab/tests"); r = hw_debug_session("COM4")`.

## What Is Not Working / Not Done
- Lab demonstration (method D for REQ-DEBUG-001/016/017) — Wed Sep 30.
- HW-DEBUG-01 terminal view not performed (covered by HW-DEBUG-02).
- Not checked yet on the **lab/demo PC**: FTDI driver, COM port, 1 Mbaud (REQ-HW-003).
- Operator note: press BTNU only when LD6 is on — a press right after a transfer starts a new (correct) transfer,
  which made two early test sessions fail (analysis in the HW-DEBUG report §3).

## Current Branch
`test/debug-hw` (PR #8: hardware evidence, demo guide, waveforms). `main` = `f4ad383` (PR #7 merged).
**Working copy on Eren's PC: `C:\dev\EEE491-Spoken-Number-Recognition`** (moved from OneDrive 2026-09-26, DEC-014).
Build outputs there (git-ignored): `fpga\vivado\build\debug_demo\top_debug_demo.bit` (demo bitstream),
`fpga\vivado\build\debug_sim\debug_sim.xpr` (all testbenches, `create_debug_sim_project.tcl`),
`fpga\vivado\build\hw\` (raw MATLAB data of HW-DEBUG-02).
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
1. Review + squash-merge the `test/debug-hw` PR (hardware evidence).
2. Before the demo: check FTDI driver + COM port + one `run_debug_demo` on the lab PC (REQ-HW-003).
3. Demo prep: **done** — `docs/reports/lab-debug-demo/DEMO_GUIDE.md` (demo card per DBG §2, checklist, Q&A,
   fallbacks) and figures `simulation/waveforms/debug/debug_w1…w5` (live: `fpga/vivado/sim_debug_waves.tcl
   -tclargs gui`). Team: read the guide + Q&A, do one dry run. Tuesday evening freeze.
4. Session exports: AI-0004 (Hande); AI-0008…0012 (Eren).
5. Wed Sep 30: demo, then tag `lab-debug-demo` and a GitHub release with `top_debug_demo.bit`.
6. Thu Oct 1: Lab-CTRL kickoff (Lead Eren, Partner Ömer, Hande off).

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
