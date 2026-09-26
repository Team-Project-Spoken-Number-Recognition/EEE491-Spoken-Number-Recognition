# Contributing — Team Workflow

## 1. Principles

- We are three engineers building **one** system. Anything one of us writes must be understood by the
  other two (the syllabus puts group-specific questions in everyone's exams).
- `main` must always simulate and build.
- No stage is "done" because it compiles — see the completion checklist in `PROJECT_STATUS.md`.

## 2. Branches, commits, tags

| Branch | Use |
|---|---|
| `main` | Protected. Only reviewed PRs. Always buildable. |
| `feature/<block>` | New functionality, e.g. `feature/debug-uart`, `feature/ctrl`, `feature/matlab-debug-rx` |
| `fix/<topic>` | Bug fixes, e.g. `fix/uart-stop-bit` |
| `docs/<topic>` | Documentation-only changes |
| `sim/<topic>` | Testbench/verification-only changes |

- Keep branches short-lived (≤ 3 days); rebase or merge `main` in often.
- Commit messages (Conventional Commits): `feat(debug): add UART byte transmitter`,
  `test(debug): add self-checking frame testbench`, `fix(ctrl): one-cycle start pulse`,
  `docs(arch): update debug path`, `chore(vivado): add project Tcl script`.
- Tag each demonstrated lab: `lab-debug-demo`, `lab-ctrl-v1`, `lab-ctrl-v2`, … (REQ-CTRL-010).
- Bitstreams used in a demo are attached to a GitHub **release** for that tag, not committed.

**GitHub settings:** repo is in the organization `Team-Project-Spoken-Number-Recognition`, all three
members are owners (DEC-015), currently public (DEC-016). **Branch protection on `main` is enabled
(2026-09-25)**: PR required, 1 approving review, stale approvals dismissed on new pushes, all review
conversations resolved, no force-push, no deletion — **also enforced for admins**. It stops being
enforced if the repo becomes private on the free plan.
Squash-merge only · delete branch after merge. Day-to-day usage: [TEAM_MANUAL.md](TEAM_MANUAL.md).

## 3. Ownership matrix — SUPERSEDED by the weekly rotation

> Since 2026-09-25 each lab is owned by a **Lab Lead + Partner** pair with a rotating off-week member
> (DEC-017). The authoritative plan is [TEAM_MANUAL.md §3](TEAM_MANUAL.md#3-roles-and-weekly-rotation):
> the Lead is the block owner, the Partner is the reviewer. The table below is kept for history only.

Each block has one **owner** (designs, writes, documents), one **reviewer** (reviews design doc *and*
code *and* test evidence), and the whole team is responsible for integration. Replace A/B/C with names.

| Subsystem | Owner | Reviewer | Rationale |
|---|---|---|---|
| DEBUG / UART | A | C | C writes the MATLAB receiver → natural protocol reviewer |
| CTRL | C | A | A integrates DEBUG with CTRL |
| MATLAB debug receiver + COE tools | C | A | |
| Board bring-up, XDC, button/reset conditioning | B | A | Frees A and C for the DEBUG deadline |
| ADC / SPI | B | A | Same owner as the analog board it connects to |
| PCB / analog (LTspice, schematic, layout) | B | C | |
| WINDOW | A | C | C owns the MATLAB reference |
| MATLAB model (golden reference) | C | B | |
| FFT (Vivado IP) | A | C | |
| MEL | C | A | Close to the MATLAB model |
| DCT | B | C | |
| COMPARE + 7-segment | C | B | Classifier tied to the MATLAB model |
| Integration / Vivado top-level | A (lead), ALL | — | |
| Documentation & AI-usage log steward | rotates weekly | — | Every owner logs their own AI use |

Difficulty-factor load (syllabus): A = 3+2+5 = 10 (+ integration lead) · B = 4+5+2 = 11 (+ bring-up) ·
C = 2+3+3+5 = 13 (+ MATLAB receiver). Rebalance if strengths differ.

## 4. Issues

Use the templates in `.github/ISSUE_TEMPLATE/`. Title prefix = block: `[DEBUG] Implement UART byte
transmitter`, `[BUG][FFT] Incorrect magnitude scaling`. Every issue links the requirement IDs it serves.
Suggested labels: `stage:debug`, `stage:ctrl`, …, `type:feature`, `type:bug`, `type:docs`,
`type:verification`, `blocked`, `needs-instructor`.

## 5. Pull requests

Use the PR template. Before requesting review, the author confirms:
- [ ] Testbench runs and prints `TB_RESULT: PASS` (log attached/committed)
- [ ] Synthesis runs without errors (and implementation, when the change touches the top level)
- [ ] Interfaces unchanged — or `INTERFACES.md` + dependants updated
- [ ] Requirement status and traceability matrix updated
- [ ] AI usage for this change logged in `ai/`

The reviewer checks **functionality, synthesizability, timing, numerical accuracy, interface
compatibility and test coverage** — not only style.

## 6. VHDL coding rules

1. `library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;` — never `std_logic_arith`/`std_logic_unsigned`.
2. One entity per file; file name = entity name (`uart_tx.vhd`); testbench `tb_<entity>.vhd`.
3. Port names follow the manuals (`<name>_in`, `<name>_out`); internal signals `snake_case`;
   constants/generics `G_`/`C_` prefix in UPPER_CASE; active-low signals end in `_n`.
4. No magic numbers: generics for sizes/rates, shared constants in `fpga/rtl/common/*_pkg.vhd`.
5. One clock (`clock_in`); slow timing with clock-enable ticks; never gate clocks or use logic as a clock.
6. Synchronous, active-high reset (DEC-007); every register has a defined reset value.
7. FSMs: enumerated state type, one clocked process; explicit `when others`; state diagram in the subsystem doc.
8. Every asynchronous input (buttons, switches, ADC data line) goes through a 2-FF synchroniser.
9. Outputs to pins are registered.
10. Variables only for local combinational calculation inside a clocked process, with a comment why.
11. Header comment in each file: purpose, requirement IDs, author, AI-assisted (yes/no + log ID).

## 7. MATLAB rules

- Functions over scripts for anything reused; each function has a help comment.
- Tests in `matlab/tests/` (`matlab.unittest` or simple assert scripts), runnable with one command.
- No hard-coded COM port or paths — pass as arguments or read from a config struct.

## 8. Session hand-off

At the end of every significant work session (human or AI): update `HANDOFF.md` and `PROJECT_STATUS.md`.
