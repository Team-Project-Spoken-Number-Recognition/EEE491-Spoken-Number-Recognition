# Current Project State

_Last updated: 2026-09-26 by Claude Code (Opus 5.5, AI-0006) in a session with Hande (`handeery`)._
_Everything below is AI-generated and **not yet reviewed by the team**._

> **HANDOFF/REPOSITORY INCONSISTENCY fixed in this update:** the previous version (AI-0003) still said
> "nothing is implemented", "debug.md TODO" and "current branch main", although PR #3 (debug.md v0.2) was
> merged and PR #4 (RTL + testbenches) was open. The PR #1/#2 history below is unchanged.

## Current Objective
**Lab-DEBUG demo on Wed Sep 30** (all-hands week, PROJECT_TIMELINE §4). Lab-CTRL is not needed for the
demo (TA Q-04): top module + button conditioning + ROM + Lab-DEBUG.
Right now: **PR #4 (`feature/debug-design` → `main`) waits for an approving review by Eren or Ömer.**

## What Has Been Completed
- Phase 1 documents, TEAM_MANUAL (PR #1), TA answers Q-02…Q-13 + DEC-018 (PR #2) — merged.
- `docs/architecture/subsystems/debug.md` v0.2 — reviewed and merged (PR #3, AI-0004/AI-0005).
- **PR #4 (open):** `fpga/rtl/debug/uart_tx.vhd`, `fpga/rtl/debug/debug.vhd`,
  `fpga/tb/debug/tb_uart_tx.vhd`, `fpga/tb/debug/tb_debug.vhd` (AI-0004, claude.ai chat).
- 2026-09-26 (AI-0006): RTL reviewed against debug.md / INTERFACES §3 / CONTRIBUTING §6 (no blocking
  finding); both testbenches re-run in Vivado 2025.2 XSim batch mode; logs stored; REQUIREMENTS, TEST_PLAN,
  TRACEABILITY_MATRIX, PROJECT_STATUS and AI records updated.

## What Is Currently Working (simulation only)
- `uart_tx`: `TB_RESULT: PASS (37/37 checks)` — TB-UART-01…03.
- `debug`: `TB_RESULT: PASS (97/97 checks)` — TB-DEBUG-01…09 (N = 3, 10 clocks/bit, latency 1 and 2).
- Evidence: `simulation/results/2026-09-26_tb_uart_tx.log`, `simulation/results/2026-09-26_tb_debug.log`.

## What Is Not Working / Not Done
- Not synthesised in Vivado; no timing numbers.
- Demo top level, button conditioning, ROM IP + COE, XDC — not started (Eren).
- MATLAB receiver — not started (Ömer).
- No hardware test (HW-DEBUG-01…05).

## Current Branch
`feature/debug-design` at `d6bdd94` + this session's docs/log commits; up to date with `origin/main`
(no merge needed). Remote: https://github.com/Team-Project-Spoken-Number-Recognition/EEE491-Spoken-Number-Recognition
(public, DEC-016). Branch protection on `main`: PR + 1 approval.

## Review findings for PR #4 (AI-0006, non-blocking, RTL unchanged)
1. `uart_tx.vhd` has no `use ieee.numeric_std.all;` (CONTRIBUTING §6.1 lists it). Not needed functionally —
   no vector arithmetic; no forbidden libraries used anywhere.
2. `debug.vhd`: the inner `case phase is` has no `when others` (all three values covered; CONTRIBUTING §6.7
   targets the state register, which has one).
3. Magic-number style: byte slicing `31 downto 24`, `23 downto 0`, `x"00"` and the `4` in the
   `C_CLKS_PER_BIT >= 4` assert could become named constants (CONTRIBUTING §6.4). Widths are fixed by the
   manual (32-bit data, 8-bit bytes), so this is cosmetic.
4. TEST_PLAN §1 / debug.md §17 planned the UART receiver model in `fpga/tb/common/`; it is inline in each
   testbench (deviation noted in TEST_PLAN).
5. Testbench coverage: TB-DEBUG-05 injects busy starts only while the FSM waits for a byte (not in
   `S_MEM_WAIT`/`S_NEXT_WORD`); structurally safe because `start_in` is only read in `S_IDLE`.
   `tb_debug` label "ready rises N clocks…" uses `N`, which is also the address-width generic — cosmetic.
6. debug.md header still says "DRAFT v0.1 — to be REVIEWED before any RTL is written" (stale; v0.2 reviewed).
7. PR #4 text mentions a GHDL 4.1 cross-check and GHDL synthesis check — no evidence in the repo; Hande to
   say who ran them (probably the claude.ai chat → AI-reported, not human-verified).
8. **Process conflict:** Hande asked to merge PR #4 with a merge commit and keep the branch;
   DEC-004 (ACCEPTED) and CONTRIBUTING §2 say squash-merge and delete the branch. PR #3 was already merged
   with a merge commit and the branch kept. Team to decide (update DEC-004, or squash).
Checked and OK: one entity per file, file = entity, `tb_<entity>`, headers (purpose, REQ, author, AI log ID),
`numeric_std` only, synchronous active-high reset on every register (`done_reg` via default assignment),
registered outputs (`txd_out`, `ready_out`, `mem_addr_out`), `N` declared first, no latches expected.

## Important Technical Decisions
DEC-004/015/016/017 ACCEPTED; DEC-005 (1 Mbaud) ACCEPTED; others PROPOSED. Relevant now: DEC-007 (sync
reset), DEC-008 (tool versions — Hande has Vivado 2025.2, another PC 2023.2), DEC-010, DEC-011, DEC-012, DEC-018.

## Known Bugs
None found in simulation.

## Current Test Results
TB-UART-01…03 PASS, TB-DEBUG-01…09 PASS (2026-09-26). TB-TOPDBG-01, MT-DEBUG-*, HW-DEBUG-* PLANNED.

## Simulation Results
See above; logs in `simulation/results/`.

## Hardware Results
None.

## Next Steps
1. Eren or Ömer reviews and approves PR #4 (reviewer checklist in the PR). Then the team settles
   finding 8 (merge style) and PR #4 is merged — the branch `feature/debug-design` is kept for further DEBUG work.
2. Hande: paste the updated PR #4 description (prepared in session AI-0006); add the AI-0004 claude.ai chat
   export to `ai/sessions/` after the personal-data check; confirm the GHDL claim (finding 7).
3. Decide on findings 1–3 (optional RTL style fixes; would need a TB re-run).
4. Eren: demo top level (button conditioning, reset sync, ROM IP, XDC) + TB-TOPDBG-01; set `G_MEM_LATENCY`
   from the ROM IP summary (ASSUMPTION-011). Vivado synthesis + utilisation + WNS.
5. Ömer: MATLAB receiver (MT-DEBUG-01…04). Then HW-DEBUG-01 (1 Mbaud bring-up) as early as possible.
6. Agree on one Vivado version (DEC-008) before creating the ROM IP.

## Blockers
- PR #4 needs an approving review (Hande cannot approve her own PR).
- 4 days until the Lab-DEBUG demo; top level, ROM, MATLAB receiver and hardware test still open.

## Assumptions
See `ASSUMPTIONS.md` — VERIFIED by the TA: -006, -007, -008. Open: -001 (part number), -003 (TX pin A18),
-009 (1 Mbaud on PC), -011 (ROM latency), -013 (dates after Sep 30).

## Questions for Instructor
Q-01 … Q-13 answered (`docs/meetings/INSTRUCTOR_QUESTIONS.md`). Open: **Q-14** to Enis Hoca (DCT/COMPARE → NN labs?).

## Things That MUST NOT Be Changed Without Review
- Port names and handshake semantics taken from the manuals (`INTERFACES.md` §2–4).
- Start/end words `55AACC03` / `AA5503CC` and the MSB-first byte order (TA-confirmed).
- Board pin assignment in `INTERFACES.md` §1.1 (DEC-018).
- The released/pending split of manuals (`docs/manuals/` vs `docs/manuals/pending/`).
- Requirement IDs (never renumber; deprecate instead).
- `debug` / `uart_tx` behaviour once PR #4 is merged — every change needs a TB re-run and a new log.
