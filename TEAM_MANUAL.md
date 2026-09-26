# Team Manual — How we use this repository

For: `eeerenbuyukbas`, `handeery`, `omerkutlu1030` (all organization owners).
Read this once completely; afterwards use §11 (cheat sheet) and §6 (Claude prompts).

**Contents:**
[1 Golden rules](#1-golden-rules) ·
[2 One-time setup](#2-one-time-setup-each-member-own-pc) ·
[3 Roles and weekly rotation](#3-roles-and-weekly-rotation) ·
[4 The weekly lab cycle](#4-the-weekly-lab-cycle-thursday--wednesday) ·
[5 Daily git workflow](#5-daily-git-workflow) ·
[6 Working with Claude](#6-working-with-claude) ·
[7 Avoiding conflicts](#7-working-in-parallel-without-conflicts) ·
[8 Definition of done](#8-definition-of-done-for-a-lab) ·
[9 Public-repository rules](#9-public-repository-rules) ·
[10 Troubleshooting](#10-troubleshooting) ·
[11 Cheat sheet](#11-cheat-sheet)

---

## 1. Golden rules

1. **GitHub is the single source of truth.** If it is not pushed, it does not exist for the other two.
2. **Never work directly on `main`.** Branch → pull request → review → squash-merge.
3. **Nothing is "done" because it compiles.** Done = simulated, synthesised, tested on the board where
   applicable, documented (§8). The syllabus multiplies a lab by **0.0 if there is no simulation**.
4. **Everyone must be able to explain every block** — including the weeks they were off. Exam questions
   are asked about *our* design and *our* AI usage, to all three of us.
5. **AI output is a draft.** We are the Lead Engineers: read it, question it, test it, log it (§6).
6. **Only released manuals drive work** (`docs/manuals/`). `docs/manuals/pending/` is not used until the
   lab team of that week releases it (§4, Thursday).
7. **Admin actions need the team.** Deleting/renaming the repo, changing visibility, adding/removing
   members, changing settings: agree in the group chat first, even though all of us are owners.
8. **End every work session by updating `HANDOFF.md`** so the next person (or Claude) can continue.

---

## 2. One-time setup (each member, own PC)

| # | Step | Check |
|---|---|---|
| 1 | Install **Git for Windows** and **GitHub CLI** (`gh`) | `git --version`, `gh --version` |
| 2 | Install **Vivado ML Standard 2025.2** (same version for all — DEC-008; devices: Artix-7 only is enough) | Vivado → Help → About |
| 3 | Install **MATLAB R2023b** (or agree on another common version) | `ver` in MATLAB |
| 4 | Install the **FTDI VCP driver** (Basys-3 USB-UART) | Device Manager → Ports → "USB Serial Port (COMx)" when the board is plugged in |
| 5 | Install the **Claude desktop app** and sign in to your own Claude account | Code tab opens |
| 6 | Log in to GitHub from the terminal | see below |
| 7 | Clone the repo **outside OneDrive** (OneDrive corrupts `.git` and Vivado folders — DEC-014) | see below |
| 8 | Set your commit identity **for this repo only** | see below |
| 9 | Open the cloned folder in the Claude app (Code tab → select folder) | Claude reads `CLAUDE.md` automatically |

Commands for steps 6–8 (PowerShell or Git Bash):

```bash
gh auth login
```
```bash
mkdir C:/dev
```
```bash
git clone https://github.com/Team-Project-Spoken-Number-Recognition/EEE491-Spoken-Number-Recognition.git C:/dev/EEE491-Spoken-Number-Recognition
```
```bash
cd C:/dev/EEE491-Spoken-Number-Recognition
```
```bash
git config user.name "<your GitHub username>"
```
```bash
git config user.email "<your GitHub noreply e-mail>"
```

Your noreply address is shown at GitHub → Settings → Emails ("Keep my email address private"). Using it
keeps your personal e-mail out of a public history.

---

## 3. Roles and weekly rotation

Every lab has a deadline on **Wednesday**. Each lab is done by **two people**; the third person has an
**off-week**. Roles for one lab week:

| Role | Responsibilities |
|---|---|
| **Lab Lead** | Owns delivery of the lab. Releases the manual, writes/assigns issues, owns the subsystem design doc, integrates, prepares the demo, updates `HANDOFF.md` / `PROJECT_STATUS.md` at the end. Final say on technical trade-offs *within* the lab (cross-lab interface changes need all three — §7). |
| **Partner** | Co-develops (typically: testbench + MATLAB side while the Lead writes RTL, or the reverse). **Reviews every PR of the Lead**; the Lead reviews the Partner's PRs. |
| **Off-week** | No implementation duties. Only two small obligations: (1) answer questions in the group chat if pinged, (2) at the start of the next week, do the 30-minute **catch-up** (§4, Thursday) — because you return as Partner and must be able to explain this lab in exams. |

**Rotation rule:** *this week's Partner becomes next week's Lead; this week's Lead goes off; the off-week
member returns as Partner.* Every lab team therefore contains one person who worked on the previous lab
(continuity), and nobody leads two labs in a row.

### 3.1 Rotation plan

Slot mapping (agreed 2026-09-25 — fixed by the decision "Lab-PCB: Eren Lead, Ömer Partner"):

| Slot | Member | GitHub |
|---|---|---|
| P1 | Eren | `eeerenbuyukbas` |
| P2 | Ömer | `omerkutlu1030` |
| P3 | Hande | `handeery` |

| Lab | Deadline (Wed) | Difficulty | Lead | Partner | Off | Note |
|---|---|---|---|---|---|---|
| Lab-DEBUG | **Sep 30** | 3 | Hande (P3) — coordinator | Eren (P1) + Ömer (P2) | — | **All three** work (team decision): Hande DEBUG RTL, Eren top level (+ early CTRL design), Ömer board/ROM/MATLAB |
| Lab-CTRL | Oct 7 | 2 | Eren (P1) | Ömer (P2) | Hande (P3) | Eren may start the design in the DEBUG week (no dependency — TA Q-04) |
| Lab-ADC | Oct 14 | 4 | Ömer (P2) | Hande (P3) | Eren (P1) | |
| Lab-WINDOW | Oct 21 | 2 | Hande (P3) | Eren (P1) | Ömer (P2) | |
| _(no lab)_ | Oct 28 | — | — | — | — | Buffer week. **Eren + Ömer start the PCB design here** — manufacturing takes time |
| Lab-PCB | Nov 4 | 5 | **Eren (P1)** | **Ömer (P2)** | Hande (P3) | Lead/Partner fixed by team decision |
| Lab-MATLAB | Nov 11 | 3 | Ömer (P2) | Hande (P3) | Eren (P1) | |
| Lab-FFT | Nov 18 | 5 | Hande (P3) | Eren (P1) | Ömer (P2) | Heavy: consider all three |
| _(lab study)_ | Nov 25 | — | — | — | — | Buffer / integration catch-up |
| Lab-MEL | Dec 2 | 3 | Eren (P1) | Ömer (P2) | Hande (P3) | |
| Lab-DCT | Dec 9 | 2 | Ömer (P2) | Hande (P3) | Eren (P1) | |
| Lab-COMPARE | Dec 16 | 5 | Hande (P3) | Eren (P1) | Ömer (P2) | Heavy: consider all three |
| Final demo | Jan 11 (Mon) | — | ALL | ALL | — | Integration must be finished before exams (Dec 26) |

Lead load (difficulty sum, DEBUG excluded because it is all-hands): Eren 2+5+3 = 10, Ömer 4+3+2 = 9,
Hande 2+5+5 = 12 — Hande leads both FFT and COMPARE (difficulty 5), so those two weeks are the first
candidates for an all-three week.

Only the DEBUG date (Sep 30) is confirmed. The others are the syllabus Saturday dates minus 3 days
(ASSUMPTION-013) — confirm each at the lab session.

### 3.2 Changing the plan

Swaps are fine — write them into the table above in a PR, so the plan in the repo is always the real plan.

---

## 4. The weekly lab cycle (Thursday → Wednesday)

The day after a deadline is the kickoff of the next lab. (First week is compressed: kickoff was Thu Sep 24.)

| Day | Who | What | Output in the repo |
|---|---|---|---|
| **Thu** | Lead + Partner (+ off-week person for catch-up) | **Kickoff (≈45 min).** (1) 30-min catch-up: previous Lead presents what was built, open issues, `HANDOFF.md`. (2) Lead **releases the manual**: `git mv docs/manuals/pending/<Lab>.pdf docs/manuals/`, update `docs/manuals/README.md`. (3) Ask Claude for the **NEW MANUAL ANALYSIS** (§6.2); review it together. | `docs/manual_analysis/<Lab>_analysis.md`, new REQ-IDs in `REQUIREMENTS.md` |
| **Thu–Fri** | Lead | Subsystem design doc (interface, algorithm, FSM, timing, fixed-point, memory, test plan) → PR → Partner reviews. **No RTL before this is merged.** Create GitHub issues for each task. | `docs/architecture/subsystems/<block>.md`, issues |
| **Sat** | both | Lab session (13:30–17:20, EE-LAB103): hardware bring-up, questions to the assistant (write answers into `INSTRUCTOR_QUESTIONS.md`). | meeting note in `docs/meetings/` |
| **Sat–Mon** | both | RTL + self-checking testbench + MATLAB reference, in small PRs. | `fpga/rtl/<block>/`, `fpga/tb/<block>/`, `matlab/...` |
| **Mon–Tue** | both | Simulation evidence, synthesis/implementation, hardware test, MATLAB comparison. | `simulation/results/`, `docs/verification/` |
| **Tue evening** | Lead | **Freeze:** everything needed for the demo is merged to `main`; demo rehearsal from a clean checkout. | tag candidate |
| **Wed** | both | **Demo.** After a successful demo: tag `lab-<name>-demo`, attach the bitstream to a GitHub release, update `PROJECT_STATUS.md` checklist, `HANDOFF.md`, `PROJECT_TIMELINE.md` §5, AI log. | tag, release, docs |

Staged-manual rule in practice: the next lab's manual is released **only at Thursday kickoff**, never
earlier — except by explicit team decision (e.g. PCB in the Oct 28 buffer week).

---

## 5. Daily git workflow

### Start of every work session
```bash
git switch main
```
```bash
git pull
```
```bash
git switch -c feature/<block>-<short-topic>
```
(or `git switch feature/...` to continue an existing branch, then `git pull` / `git merge main`).

Branch names: `feature/debug-uart-tx`, `feature/ctrl-framing`, `sim/debug-frame-tb`, `docs/debug-design`,
`fix/uart-stop-bit`, `matlab/debug-receiver` is also fine for MATLAB-only work.

### While working
- Commit small, meaningful steps: `feat(debug): add baud tick generator`, `test(debug): check stop bit`,
  `docs(debug): add FSM diagram`, `fix(ctrl): make start pulse one cycle wide`.
- AI-assisted commit? Add a line `AI-assisted: AI-NNNN` in the commit body (§6.4).
- Push at least at the end of each session (even unfinished work — on your branch):
```bash
git push -u origin HEAD
```

### Pull request
```bash
gh pr create --fill
```
Fill the PR template honestly (simulation / synthesis / hardware sections: write "not applicable: reason"
rather than leaving blanks). Request review from your lab partner:
```bash
gh pr edit --add-reviewer <partner-username>
```

### Review and merge
`main` is protected (also for us admins): a direct `git push` to `main` is rejected; a PR needs **one
approval from someone other than the author**; a new push after approval removes the approval; all
review comments must be resolved before merging.

- Reviewer checks functionality, synthesizability, timing, numeric accuracy, interfaces, test coverage —
  and must be able to explain the code afterwards (PR checklist).
- Merge with **Squash and merge** after approval; delete the branch.
- Everyone then updates their local `main` with `git pull`.

---

## 6. Working with Claude

Each of us runs Claude on our own PC. Claude acts with **your** GitHub rights and reads `CLAUDE.md`
automatically. You remain responsible for everything it does in your name.

### 6.1 Start of a Claude session (copy-paste)

> Follow CLAUDE.md. Read README, HANDOFF, PROJECT_STATUS, REQUIREMENTS, ARCHITECTURE and the relevant
> subsystem doc, check git status and the latest results, then give me the PROJECT STATE SUMMARY and
> CURRENT OBJECTIVE / BLOCKERS / FILES LIKELY TO CHANGE / VERIFICATION PLAN. This week I am the
> <Lead|Partner> for <Lab-XXX>; my task today is <...>. Do not write code until I confirm the plan.

### 6.2 New manual (Thursday kickoff)

> I released docs/manuals/<Lab-XXX>.pdf. Read the whole manual (including figures) and write the
> NEW MANUAL ANALYSIS into docs/manual_analysis/ using the template. Add the new requirements to
> REQUIREMENTS.md with IDs and sources. Do not change any code. List questions for the lab assistant.

### 6.3 End of a Claude session (copy-paste)

> Wrap up: update HANDOFF.md and PROJECT_STATUS.md, add an AI-usage record in ai/outputs/ and a line in
> ai/AI_USAGE_LOG.md, then give me the SUMMARY block. Do not commit until I say so.

### 6.4 AI records (syllabus requirement — part of the grade)

1. **Export the chat the same day:** session menu → Export → put the file in `ai/sessions/` named
   `YYYY-MM-DD_<username>_claude_<topic>.<ext>`. **Check it first** for anything that must not be public (§9).
2. Claude writes the `ai/outputs/…_AI-NNNN_….md` record; **you** fill in *Human Review*, *Detected Issues*
   and *Final Decision* — that is the "Lead Engineer" evidence the syllabus asks for.
3. When you correct AI output (wrong FSM, wrong timing, wrong assumption…), write a
   `ai/corrections/CORR-NNNN` record. These correction logs are explicitly required.
4. New tool or model? Add a row to `ai/TOOLS_AND_MODELS.md`.

AI-NNNN numbers are global: pick the next free number in `ai/AI_USAGE_LOG.md` when you open your PR; if two
PRs collide, the second one renumbers.

### 6.5 Reference design from last semester

`https://github.com/Borek-32/EEE491-Spoken-Digit-Recognizer-BASYS3` (public, MIT License) is last
semester's complete project; instructors accept reusing it. **DEC-018:** where our manual and the TA leave
a choice open, follow its specification. Released manual and TA answers always win; conflicts are logged
(e.g. baud rate, DEC-005). Copied code keeps the MIT notice, names its source in the file header and the
AI/decision log, and is re-verified with our own testbench. Don't read its future-stage code before that
stage's manual is released.

### 6.6 What to let Claude do / not do

| OK | Only after you checked | Never without team agreement |
|---|---|---|
| Read, explain, draft docs, draft RTL/TB/MATLAB, run simulations, analyse logs | Commit, push, open PRs | Repo/org settings, visibility, members, deleting branches of others, force-push, releasing a pending manual |

Claude will ask for permission before risky commands; read the command before approving.

---

## 7. Working in parallel without conflicts

- **Split by file, not by line.** Typical split: Lead → `fpga/rtl/<block>/`, Partner →
  `fpga/tb/<block>/` + `matlab/`. Two people editing the same VHDL file at once = merge pain.
- **Shared status files** (`HANDOFF.md`, `PROJECT_STATUS.md`, `REQUIREMENTS.md` status column,
  `TRACEABILITY_MATRIX.md`): during the week put notes in your PR description; the **Lead** updates these
  files in one wrap-up PR. This avoids constant conflicts.
- **Interfaces are shared property.** Changing anything in `INTERFACES.md` (ports, widths, handshake,
  clock/reset, sample rate, frame size, byte order…) needs a message in the group chat and approval of
  **all three**, plus a `DECISIONS.md` entry — the off-week person is affected next week.
- Pull `main` into your branch at least daily: `git merge main` (or ask Claude to do it and resolve conflicts with you).
- Vivado: never commit the project folder; commit sources, XDC, `.xci`, `.coe` and the
  `fpga/vivado/create_<design>.tcl` script (DEC-013). Rebuild the project from the script.

---

## 8. Definition of done for a lab

A lab is complete only when the Lead can tick every applicable item in `PROJECT_STATUS.md`:

```text
[ ] Manual analysed (NEW MANUAL ANALYSIS merged)       [ ] Synthesis/implementation report stored
[ ] Requirements with IDs in REQUIREMENTS.md            [ ] Hardware test report stored (if applicable)
[ ] Subsystem design doc reviewed and merged            [ ] Demo done; tag lab-<name>-demo + release
[ ] RTL / MATLAB reviewed via PR                        [ ] Known issues documented
[ ] Self-checking TB: TB_RESULT: PASS log stored        [ ] TRACEABILITY_MATRIX rows filled
[ ] Expected vs actual compared (MATLAB where relevant) [ ] HANDOFF.md + PROJECT_STATUS.md updated
[ ] Waveform screenshots stored                         [ ] AI sessions exported + records completed
```

Items that don't apply are written as `Not applicable: <reason>` — never silently skipped.

---

## 9. Public-repository rules

The repository is currently **public** (DEC-016). Everything pushed can be copied by anyone and stays in
the git history even after deletion or after making the repo private again.

**Never commit:**
- passwords, tokens, API keys, one-time codes, `gh`/Claude credentials;
- personal data: student IDs, phone numbers, personal e-mail addresses, addresses;
- **voice recordings of people** (digit datasets) unless the speaker agreed — keep raw recordings off the
  repo (shared drive) and commit only derived features or synthetic test signals;
- anything from another group.

**Before committing an AI chat export:** open it and search for `token`, `password`, `@`, phone numbers,
and one-time codes. Redact only by replacing the value with `[REDACTED]` and note that in `ai/sessions/README.md`
(the syllabus wants unedited chats, so redact the minimum).

If a secret was pushed: tell the group immediately and **revoke/rotate the secret** — deleting the commit
is not enough.

---

## 10. Troubleshooting

| Problem | Fix |
|---|---|
| "I committed on `main` by mistake" (not pushed) | `git switch -c feature/<name>` (keeps the commit), then `git switch main` and `git reset --hard origin/main`. Ask Claude if unsure. |
| `git push` to `main` rejected ("protected branch") | Expected. Move your commits to a branch (row above) and open a PR. |
| Partner is off / unreachable and a PR needs approval | The off-week member may approve — but only after actually reviewing it. |
| Merge conflict | Ask Claude: "merge main into my branch and walk me through each conflict" — decide each hunk yourself. |
| `git push` rejected | `git pull --rebase` (on your own branch) then push again. |
| Vivado project broken / different machine | Delete the local project folder, re-run `fpga/vivado/create_<design>.tcl`. |
| IP "locked" / needs upgrade | Someone used a different Vivado version (DEC-008) — do not upgrade in a PR without agreement. |
| Board not seen as COM port | Install FTDI VCP driver; try another USB cable (charge-only cables exist); close terminal programs holding the port. |
| Claude says HANDOFF/REPOSITORY INCONSISTENCY | Good — it found stale docs. Fix the doc in the same PR. |
| Repo is inside OneDrive and git behaves strangely | Re-clone into `C:\dev\` (§2). |
| Vivado: `File or Directory '…/Masa�st�/…' does not exist` | Vivado cannot handle non-ASCII characters (`ü`, `ş`, …) or spaces in paths. Work from a clone at e.g. `C:\dev\EEE491-Spoken-Number-Recognition` (DEC-014). |
| Vivado batch: `'compile.bat' is not recognized` / `Spawn failed` | Vivado's `bin` must be on `PATH` (use the "Vivado 2025.2 Tcl Shell" or add `C:\AMDDesignTools\2025.2\Vivado\bin`). In a Claude Code shell also remove `NoDefaultCurrentDirectoryInExePath` for that command (Claude sets it; `cmd` then ignores `.bat` files in the current folder). Fallback: `-tclargs scripts_only`. |

---

## 11. Cheat sheet

```text
Start:    git switch main ; git pull ; git switch -c feature/<block>-<topic>
Save:     git add <files> ; git commit -m "feat(<block>): ..." ; git push -u origin HEAD
PR:       gh pr create --fill ; gh pr edit --add-reviewer <partner>
Update:   git switch main ; git pull            (after a merge)
Sync branch: git merge main
Status:   git status ; git log --oneline -5 ; gh pr status
Week:     Thu kickoff+release manual → Thu/Fri design doc → Sat lab → Sat–Mon RTL/TB/MATLAB
          → Mon–Tue sim/synth/HW → Tue freeze → Wed demo + tag + wrap-up
Claude:   start prompt §6.1 · new manual §6.2 · end prompt §6.3 · export chat → ai/sessions/
```
