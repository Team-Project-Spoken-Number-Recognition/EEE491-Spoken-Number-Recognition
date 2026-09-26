# AI-0004 — Lab-DEBUG design document, RTL and testbenches

```text
ID:            AI-0004
Date:          2026-09-26
Team Member:   handeery (Hande, Lab-DEBUG coordinator)
AI Tool:       claude.ai chat (web)
Model:         Claude Opus 5.5
Purpose:       (1) Lab-DEBUG subsystem design document (debug.md v0.1, PR #3)
               (2) RTL uart_tx + debug and self-checking testbenches (PR #4)
```

_Record written 2026-09-26 in Claude Code session AI-0006 from the information Hande gave and the
PR #3/#4 content; Hande to check it against the chat export._

## Part 1 — design document (PR #3, merged)
Output: `docs/architecture/subsystems/debug.md` v0.1. Reviewed in PR #3 (review session AI-0005,
correction CORR-0002), v0.2 merged into `main` (commit `8edbc2a`).

## Part 2 — RTL and testbenches (PR #4)

| File | Content | Commit |
|---|---|---|
| `fpga/rtl/debug/uart_tx.vhd` | One-byte 8N1 transmitter, `G_CLKS_PER_BIT` generic | `217276d` |
| `fpga/tb/debug/tb_uart_tx.vhd` | TB-UART-01…03, 37 checks | `217276d` |
| `fpga/rtl/debug/debug.vhd` | Word/frame FSM, address counter, latency wait, handshake | `d6bdd94` |
| `fpga/tb/debug/tb_debug.vhd` | TB-DEBUG-01…09, 97 checks, three DUTs (latency 2/2, 1/1, 2/1) | `d6bdd94` |

Raw AI output: the four files as first committed (`217276d`, `d6bdd94`) are the AI drafts after
Hande's review; any in-chat edits are visible only in the chat export.

## Testbench sensitivity (mutation tests, done in the chat)
Deliberately injected bugs, each of which the testbenches had to detect:
- `uart_tx`: 3 bugs — all detected.
- `debug`: 7 bugs — all detected.
Examples named in PR #4: memory-latency off-by-one, LSB-first bytes, one word short, restart on a busy
start, `ready_out` stuck high, wrong end word, reset not clearing the address.
**Not repeated** in session AI-0006 — the evidence for this is only in the chat export.

The PR #4 description also mentions a GHDL 4.1 cross-check and a GHDL synthesis check. No logs of these are
in the repository. Hande to confirm who ran them and where (most likely inside the claude.ai chat, which
would make them AI-reported, not human-verified).

## Human verification
- Hande simulated both testbenches in **Vivado 2025.2 XSim** (GUI): `tb_uart_tx` → `TB_RESULT: PASS
  (37/37 checks)`, `tb_debug` → `TB_RESULT: PASS (97/97 checks)`.
- Independent batch re-run 2026-09-26 (AI-0006, same sources, commit `d6bdd94`): same results. Logs:
  `simulation/results/2026-09-26_tb_uart_tx.log`, `simulation/results/2026-09-26_tb_debug.log`.
- Code review against debug.md / INTERFACES §3 / CONTRIBUTING §6: AI review in AI-0006 (no blocking
  finding); **human review by Eren or Ömer pending (PR #4)**.

## Session export
_Placeholder._ Hande adds the claude.ai chat export to `ai/sessions/` after checking it for personal
data (TEAM_MANUAL §9). Suggested name: `2026-09-26_handeery_claude-ai_debug-design-rtl.<ext>`.

## Human Review / Final Decision
_PENDING — approving review of PR #4 by Eren or Ömer._
