# AI-0008 — PR #4 verification and Lab-DEBUG demo top-level design

```text
ID:            AI-0008
Date:          2026-09-26
Team Member:   eeerenbuyukbas
AI Tool:       Claude Code, desktop app (Code tab)
Model:         Claude Opus 5.5 (claude-opus-5-5)
Purpose:       (1) Verify Hande's PR #4 (uart_tx + debug) independently; (2) design the demo top level
               (Eren's work package) — design document first, RTL after review.
```

## Prompts (summary — verbatim in the session export)
1. "PR 4 came in. Check it, tell me how I can test it myself, and what is missing to finish Lab-DEBUG."
2. Vivado 2025.2 installation choices (screenshot) → advice (select Artix-7, not Kintex-7).
3. "Start my part; check Hande's last open PR first. Hande's port list: clock_in, reset_in, start_in (1-clock
   pulse, debounce on my side), mem_addr_out (N), mem_data_in (32), txd_out (A18), ready_out (LD6); N = 14,
   1 Mbaud, G_MEM_LATENCY = 2."
4. After reinstalling Vivado 2025.2 correctly: "retry the test; if there is no problem, proceed."

## Verification performed by the AI (on Eren's PC)
| Item | Tool | Result |
|---|---|---|
| tb_uart_tx | Vivado 2023.2 XSim (first PR #4 version) and 2025.2 XSim | PASS 37/37 |
| tb_debug | Vivado 2025.2 XSim | PASS 97/97 |
| uart_tx OOC synthesis | Vivado 2023.2, xc7a35tcpg236-1 | 23 LUT, 22 FF, WNS +6.72 ns |
| debug OOC synthesis (N = 14, 1 Mbaud) | Vivado 2025.2, xc7a35tcpg236-1 | 79 LUT, 78 FF, 0 BRAM, WNS +6.29 ns, no latches |
| Pins W5/U18/T18/A18/U14 | Digilent `Basys-3-Master.xdc` (commit 69d3501) | match INTERFACES §1.1 |

Findings during the session: Eren's first 2025.2 install contained only Kintex-7 (synthesis failed with
"Invalid option value for -part"); 2023.2 had been removed. Fixed by reinstalling with Artix-7.

## AI Output
- `docs/architecture/subsystems/top_debug_demo.md` v0.1 (design doc; no RTL yet).
- DEC-019 (debounce — deviation from the reference design, PROPOSED). DEC-008 / ASSUMPTION-004 are left to
  Ömer's PR #6 (same change, avoids a conflict).
- ASSUMPTION-003 VERIFIED (official XDC).
- v0.2 of the design doc aligned with Ömer's ROM (PR #5): IP `debug_rom`, his COE/pattern, real IP in simulation.
- Record renumbered from AI-0007 to AI-0008 because Ömer's PR #5 already uses AI-0007.
- `fpga/constraints/Basys3_Master.xdc` (unmodified Digilent copy, MIT) + `fpga/constraints/README.md`.

## Items for the reviewers (AI proposals, not facts)
- Debounce 10 ms, reset only synchronised (DEC-019).
- Top-level simulation with the real `debug_rom` IP (Vivado project flow), N = 14.

## Reference design use (DEC-018)
Read `rtl/top_module.vhd` start-button handling only (2-FF sync + edge detect). Not copied; deviation logged in DEC-019.

## Human Review / Final Decision
_PENDING — Ömer (ROM interface), Hande (debug interface)._

## Related Commit
Branch `feature/debug-top`.
