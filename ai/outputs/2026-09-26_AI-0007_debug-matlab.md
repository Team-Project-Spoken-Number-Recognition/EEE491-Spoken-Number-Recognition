# AI-0007 — Lab-DEBUG PC side: COE generator, decoder, receiver, MATLAB tests

```text
ID:            AI-0007
Date:          2026-09-26
Team Member:   omerkutlu1030 (Ömer, Lab-DEBUG work package "board, ROM, MATLAB")
AI Tool:       Claude Code, desktop app (Code tab)
Model:         Claude Opus 5.5 (claude-opus-5-5)
Purpose:       Write the MATLAB side of Lab-DEBUG (PROJECT_TIMELINE §4, Sun–Mon row) and the
               demo ROM content; review PR #4 as a second reviewer.
```

## Prompt (summary — verbatim in the session export)
Session-start prompt of TEAM_MANUAL §6 for the MATLAB part; the AI proposed a plan (test pattern,
file list, error handling) and waited for "OK" before writing code. Then: "commit and open the PR",
"review newcoming PR if there is".

## Input data
Lab-DEBUG manual (`docs/manuals/Lab-DEBUG_Assignment.pdf`), REQUIREMENTS (DEBUG-004…017, SW-001…003),
DEC-005/010/011, TEST_PLAN §2–3, CONTRIBUTING §7, `debug.md` v0.2, Hande's request to put 55AACC03 /
AA5503CC into the COE. The reference design (DEC-018) has no ROM-demo receiver; nothing was reused.

## AI output
New files (all AI-written, reviewed by Ömer before the PR):
- `matlab/debug/`: `debug_frame_spec.m`, `generate_debug_coe.m`, `read_coe.m`, `decode_debug_frame.m`,
  `receive_debug_frame.m`, `compare_with_coe.m`, `run_debug_demo.m`
- `matlab/tests/`: `test_debug.m` (MT-DEBUG-01…04, 15 tests), `run_debug_tests.m`
- `fpga/ip/debug_rom.coe` (generated, 16 384 × 32 bit)
- `simulation/results/2026-09-26_mt_debug.log`

Design choices (approved by Ömer before coding):
- Test pattern: address k → `[k | NOT k]`; addresses 1, 2, 3, 4, last-1, last hold 55AACC03, AA5503CC,
  00000000, FFFFFFFF, 55AACC03, AA5503CC (delimiter right before the real end word).
- Fixed-length decode (DEC-010) with error IDs `debug:frameLength`, `debug:badStartWord`,
  `debug:badEndWord`; never returns partial data.
- COM port always passed as an argument (CONTRIBUTING §7).

## Verification
- MATLAB R2025b: `MT_RESULT: PASS (15/15 tests)` — log in `simulation/results/2026-09-26_mt_debug.log`.
- MT-DEBUG-01 includes a frame written by hand from the manual's table, independent of the test encoder.
- PR #4 review: `tb_uart_tx` PASS 37/37 and `tb_debug` PASS 97/97 re-run in Vivado 2025.2 XSim on
  Ömer's PC, sources unmodified; RTL traced against debug.md, no blocking finding.

## Things the AI could not verify
- `receive_debug_frame` / `run_debug_demo` against real hardware (needs board, top level, data cable) →
  HW-DEBUG-02…05.
- That Vivado's Block Memory Generator accepts `debug_rom.coe` (second half of MT-DEBUG-04) and the ROM
  read latency (ASSUMPTION-011) → when the ROM IP is created.
- MATLAB R2023b compatibility (only R2025b tested; only R2019b+ functions used).

## Human Review / Final Decision
_PENDING — Ömer reviews the code; Hande or Eren approve the PR._

## Related Commit
Branch `feature/debug-matlab`. Commits carry `AI-assisted: AI-0007`.
