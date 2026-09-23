# Current Project State

_Last updated: 2026-09-24 by Claude (Opus 5.5) in a session with the team member whose GitHub account is `eeerenbuyukbas`._
_Everything below is AI-generated and **not yet reviewed by the team**._

## Current Objective
Finish Phase 1 review. Then start the **Lab-DEBUG** design (subsystem design doc → VHDL → TB),
together with the Lab-CTRL subset needed for the Lab-DEBUG demo.

## What Has Been Completed
- Repository skeleton created (see README §4); local `git init -b main` done — **no commits yet**.
- Course PDFs moved: syllabus → `docs/syllabus/`; DEBUG + CTRL manuals → `docs/manuals/`;
  ADC, WINDOW, PCB, MATLAB, FFT, MEL manuals → `docs/manuals/pending/` (not released, not read).
- Planning documents: README, CLAUDE, CONTRIBUTING, REQUIREMENTS, ARCHITECTURE, INTERFACES,
  VERIFICATION_PLAN, TEST_PLAN, PROJECT_TIMELINE, PROJECT_STATUS, DECISIONS, ASSUMPTIONS,
  INSTRUCTOR_QUESTIONS, manual analyses for DEBUG and CTRL, traceability matrix, AI-log structure,
  GitHub PR/issue templates, CI plan.

## What Is Currently Working
Nothing is implemented. No VHDL, MATLAB, or hardware work exists yet.

## What Is Not Working
n/a

## Current Branch
`main` — remote `origin` = https://github.com/eeerenbuyukbas/EEE491-Spoken-Number-Recognition (private).

## Last Commit
Initial commit `chore: initialize project repository and Phase 1 engineering documents`
(bootstrap commit made directly on `main`, before branch protection existed — the only allowed exception).
Commit identity on this PC is repo-local: `eeerenbuyukbas <185053941+eeerenbuyukbas@users.noreply.github.com>`.

## Files Changed
All files are new (see Completed).

## Current Architecture
PLANNED only — see `ARCHITECTURE.md`. Single 100 MHz domain, start/ready handshake, one output
dual-port RAM per block, Lab-DEBUG as a read-only tap to MATLAB via FT2232HQ.

## Important Technical Decisions
All PROPOSED, none accepted yet: DEC-001 … DEC-014 in `DECISIONS.md`. Most important for the next step:
DEC-003 (CTRL released with DEBUG), DEC-005 (UART protocol, 115 200 baud first), DEC-007 (sync reset),
DEC-010 (fixed-length MATLAB read), DEC-012 (generics), DEC-014 (move repo out of OneDrive).

## Known Bugs
None (no code).

## Current Test Results
None.

## Simulation Results
None.

## Hardware Results
None.

## Next Steps
1. Team reviews the Phase 1 documents; fills in names; accepts/rejects DEC-001…014.
2. ~~Initial commit; create private GitHub repo~~ (done 2026-09-24). Still open: add the two teammates
   as collaborators (GitHub usernames needed); protect `main` (needs GitHub Pro — free via GitHub
   Student Developer Pack — for private repos); move local clone out of OneDrive (DEC-014).
3. Ask Q-01 … Q-05 (`docs/meetings/INSTRUCTOR_QUESTIONS.md`) at the Sep 26 lab session.
4. Write `docs/architecture/subsystems/debug.md` (FSM, timing, latency) and `ctrl.md` (subset) — review — then RTL.
5. Download datasheets listed in `hardware/README.md`.
6. Export this chat session into `ai/sessions/` (syllabus GenAI policy).

## Blockers
- Demo date uncertainty (Q-01).
- Team names/roles not yet assigned.

## Assumptions
See `ASSUMPTIONS.md` — most relevant now: ASSUMPTION-003 (TX pin A18), -006 (MSB byte first),
-007 (ready high after reset), -008 (start ignored while busy), -011 (ROM latency), -013 (dates).

## Questions for Instructor
Q-01 … Q-13 in `docs/meetings/INSTRUCTOR_QUESTIONS.md` (Q-01 urgent).

## Things That MUST NOT Be Changed Without Review
- Port names and handshake semantics taken from the manuals (`INTERFACES.md` §2–4).
- Start/end words `55AACC03` / `AA5503CC` and the byte order once Q-02 is answered.
- The released/pending split of manuals (`docs/manuals/` vs `docs/manuals/pending/`).
- Requirement IDs (never renumber; deprecate instead).
