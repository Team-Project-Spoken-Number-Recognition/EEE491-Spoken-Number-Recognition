# Current Project State

_Last updated: 2026-09-26 by Claude Code (Opus 5.5, AI-0007) in a session with Ömer (`omerkutlu1030`)._
_Everything below is AI-generated and **not yet reviewed by the team**._

> **HANDOFF/REPOSITORY INCONSISTENCY fixed in this update:** the previous version (AI-0006) still said
> PR #4 was open and the MATLAB receiver / ROM were not started. PR #4 was squash-merged on 2026-09-26;
> the MATLAB side and the ROM IP are in PR #5.

## Current Objective
**Lab-DEBUG demo on Wed Sep 30** (all-hands week, PROJECT_TIMELINE §4). Lab-CTRL is not needed for the
demo (TA Q-04): top module + button conditioning + ROM + Lab-DEBUG.
Right now: **PR #5 and PR #6 wait for a review by Hande or Eren; the demo top level (Eren) is the
remaining design piece.**

## What Has Been Completed
- Phase 1 documents, TEAM_MANUAL (PR #1), TA answers + DEC-018 (PR #2), `debug.md` v0.2 (PR #3) — merged.
- **PR #4 merged (squash, 2026-09-26):** `uart_tx`, `debug`, `tb_uart_tx`, `tb_debug` (Hande, AI-0004/0006).
  Second review by Ömer (AI-0007): both testbenches re-run on Ömer's PC in Vivado 2025.2 — PASS 37/37, 97/97.
- **PR #5 (open, `feature/debug-matlab`), Ömer, AI-0007:**
  - MATLAB: `matlab/debug/` — `generate_debug_coe`, `read_coe`, `decode_debug_frame`, `receive_debug_frame`,
    `compare_with_coe`, `run_debug_demo`, `debug_frame_spec`; tests `matlab/tests/test_debug.m` (MT-DEBUG-01…04).
  - Demo ROM: `fpga/ip/debug_rom.coe` (test pattern `[k | NOT k]` + delimiter values at addresses 1, 2,
    16382, 16383), `fpga/ip/create_debug_rom.tcl` → `fpga/ip/debug_rom/debug_rom.xci` (Single Port ROM
    16384 × 32, always enabled, output register ON), `tb_debug_rom` + `fpga/vivado/sim_debug_rom.tcl`.
- **PR #6 (open, `docs/vivado-2025-2`):** DEC-008 → everyone on Vivado ML Standard 2025.2 (team decision
  2026-09-26; Eren moves from 2023.2). MATLAB not pinned (R2025b Hande/Ömer, R2023b Eren).

## What Is Currently Working (simulation / MATLAB only)
- `uart_tx` PASS 37/37 (TB-UART-01…03); `debug` PASS 97/97 (TB-DEBUG-01…09).
- MATLAB: `MT_RESULT: PASS (15/15 tests)` — MT-DEBUG-01…04.
- ROM IP: `TB_RESULT: PASS (11/11 checks)` — Vivado accepts the COE, all 16 384 words match,
  **read latency measured = 2** (= `G_MEM_LATENCY` default). Mutation (expect 1) → FAIL, shift-by-one.
- Logs: `simulation/results/2026-09-26_{tb_uart_tx,tb_debug,mt_debug,tb_debug_rom}.log`.

## What Is Not Working / Not Done
- Demo top level `top_debug_demo` (reset sync, button sync/debounce/1-cycle pulse, ROM + debug wiring,
  LD6), XDC from `Basys3_Master.xdc`, `create_debug_demo.tcl`, TB-TOPDBG-01 — Eren, not started.
- No synthesis / implementation / timing numbers yet.
- No hardware test (HW-DEBUG-01…05); MATLAB receiver untested on real hardware.
- Data-capable micro-USB cable: Hande's is charge-only; Eren has one.

## Current Branch
`feature/debug-matlab` (PR #5), pushed, up to date with `origin/main`. Also pushed: `docs/vivado-2025-2` (PR #6).
Remote: https://github.com/Team-Project-Spoken-Number-Recognition/EEE491-Spoken-Number-Recognition (public, DEC-016).

## Integration notes for the top level (Eren)
- ROM ports: `clka` ← `clock_in`, `addra(13:0)` ← `mem_addr_out`, `douta(31:0)` → `mem_data_in`; **no `ena`**
  (always enabled). Add the IP with `read_ip fpga/ip/debug_rom/debug_rom.xci` (or re-run `create_debug_rom.tcl`).
- Keep `debug` generic `G_MEM_LATENCY` = 2 (verified, TB-ROM-01).
- `start_in` must be a clean 1-cycle pulse (debug.md §15).
- **Vivado on Ömer's PC:** `.bat` scripts cannot run from `%TEMP%`, and `launch_simulation` crashed with a
  redirected console → build folders go to `fpga/vivado/build/` (git-ignored); `sim_debug_rom.tcl` has a
  `-tclargs scripts_only` fallback. Use the same pattern in `create_debug_demo.tcl` if needed.

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
1. Hande or Eren: review + squash-merge PR #5 and PR #6.
2. Eren: install Vivado 2025.2; demo top level + XDC + `create_debug_demo.tcl` + TB-TOPDBG-01; synthesis,
   utilisation (expect 16 RAMB36 for the ROM), WNS; bitstream. Target: PR by Monday evening.
3. Ömer: cross-check "Total Port A Read Latency: 2" in the `debug_rom` IP Summary tab (GUI, cancel without
   changes); get the Basys-3 back from Hande (Mon); install the FTDI VCP driver; find the COM port.
4. Tuesday (Hande + Ömer): HW-DEBUG-01 (terminal, 1 Mbaud), then `run_debug_demo("COMx")` for
   HW-DEBUG-02…05; evidence into `docs/verification/`. Tuesday evening: freeze.
5. Session exports: AI-0004 (Hande), AI-0007 (Ömer — this session) into `ai/sessions/` after the personal-data
   check (the chat contains pasted group messages with phone numbers → redact).
6. Wed Sep 30: demo, tag `lab-debug-demo`, release with bitstream.

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
