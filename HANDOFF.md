# Current Project State

_Last updated: 2026-09-26 by Claude (Opus 5.5) in a session with `eeerenbuyukbas`._
_Everything below is AI-generated and **not yet reviewed by the team**._

## Current Objective
**Lab-DEBUG demo on Wed Sep 30** (all-hands week, plan in PROJECT_TIMELINE §4). Hande starts the
debugger design/RTL on 2026-09-26. The demo does **not** need Lab-CTRL (TA Q-04): top module + button
conditioning + ROM + Lab-DEBUG. Eren may start the Lab-CTRL design (Oct 7) in parallel.

## What Has Been Completed
- Repository skeleton created (see README §4); initial commit `1680976` pushed.
- Course PDFs moved: syllabus → `docs/syllabus/`; DEBUG + CTRL manuals → `docs/manuals/`;
  ADC, WINDOW, PCB, MATLAB, FFT, MEL manuals → `docs/manuals/pending/` (not released, not read).
- Planning documents: README, CLAUDE, CONTRIBUTING, REQUIREMENTS, ARCHITECTURE, INTERFACES,
  VERIFICATION_PLAN, TEST_PLAN, PROJECT_TIMELINE, PROJECT_STATUS, DECISIONS, ASSUMPTIONS,
  INSTRUCTOR_QUESTIONS, manual analyses for DEBUG and CTRL, traceability matrix, AI-log structure,
  GitHub PR/issue templates, CI plan.

- 2026-09-25: `TEAM_MANUAL.md` (setup, Lead/Partner/off-week rotation, weekly Thu→Wed cycle, git
  workflow, Claude prompts, public-repo rules). DEC-016 (temporarily public), DEC-017 (rotation).
  Timeline switched to Wednesday deadlines. Committed on branch `docs/team-manual`, submitted as the
  first pull request (needs one approval to merge).
- 2026-09-25: branch protection enabled on `main` (PR + 1 approval, admins included, no force-push).
- 2026-09-26: TA answers Q-02…Q-13 recorded; requirements, assumptions, decisions (DEC-003/005/007/012
  updated, **DEC-018** reference-design rule), interfaces (board pin table), architecture, test plan,
  timeline and team manual updated. Reference design inspected only for Lab-DEBUG-relevant files
  (`constraints/jc_homefab.xdc`, `rtl/debug.vhd`, `rtl/top_module.vhd` IO/generics). Branch
  `docs/ta-answers-2026-09-26` (stacked on `docs/team-manual`), not yet committed.

## What Is Currently Working
Nothing is implemented. No VHDL, MATLAB, or hardware work exists yet.

## What Is Not Working
n/a

## Current Branch
`main` — remote `origin` = https://github.com/Team-Project-Spoken-Number-Recognition/EEE491-Spoken-Number-Recognition
(transferred from `eeerenbuyukbas` to the organization on 2026-09-24, DEC-015; old URL redirects;
**temporarily public** since 2026-09-25, DEC-016). All three members are org owners/admins.

## Last Commit
Initial commit `chore: initialize project repository and Phase 1 engineering documents`
(bootstrap commit made directly on `main`, before branch protection existed — the only allowed exception).
Commit identity on this PC is repo-local: `eeerenbuyukbas <185053941+eeerenbuyukbas@users.noreply.github.com>`.

## Files Changed
On branch `docs/team-manual` (2026-09-24/25): TEAM_MANUAL.md (new), README.md, CLAUDE.md, CONTRIBUTING.md, DECISIONS.md,
ASSUMPTIONS.md, PROJECT_STATUS.md, PROJECT_TIMELINE.md, HANDOFF.md, docs/meetings/INSTRUCTOR_QUESTIONS.md,
ai/AI_USAGE_LOG.md, ai/outputs/2026-09-25_AI-0002_github-setup-team-manual.md (new).

## Current Architecture
PLANNED only — see `ARCHITECTURE.md`. Single 100 MHz domain, start/ready handshake, one output
dual-port RAM per block, Lab-DEBUG as a read-only tap to MATLAB via FT2232HQ.

## Important Technical Decisions
DEC-015 (organization, all owners), DEC-016 (temporarily public) and DEC-017 (rotation model) are
ACCEPTED; DEC-001 … DEC-014 are still PROPOSED. Most important for the next step:
DEC-003 (CTRL released with DEBUG), DEC-005 (UART protocol, **1 000 000 baud**, fixed), DEC-007 (sync reset),
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
2. Repo is in the organization (DEC-015), all three are owners, temporarily public (DEC-016).
   Still open: every member follows TEAM_MANUAL §2 (clone outside OneDrive, identity); review and merge the `docs/team-manual` PR.
3. Baud rate decided: **1 000 000** (DEC-005) — verify 1 Mbaud on PC/MATLAB in HW-DEBUG-01. Decide spoken language EN/TR (U-18). Ask Enis Hoca Q-14 (DCT/COMPARE → NN labs?) in class.
4. Write `docs/architecture/subsystems/debug.md` (FSM, timing, latency; parameter named `N`) — review — then RTL. Eren: top-level plan + button conditioning; optionally start `ctrl.md` (full CTRL).
5. Download datasheets listed in `hardware/README.md`.
6. Export this chat session into `ai/sessions/` (syllabus GenAI policy).

## Blockers
- Only 4 days until the Lab-DEBUG deadline.

## Assumptions
See `ASSUMPTIONS.md` — now VERIFIED by the TA: -006 (MSB byte first), -007 (ready high after reset),
-008 (start ignored while busy). Still open: -001 (part number), -003 (TX pin A18, supported by reference design),
-011 (ROM latency), -013 (dates after Sep 30).

## Questions for Instructor
Q-01 … Q-13 answered (`docs/meetings/INSTRUCTOR_QUESTIONS.md`). Open: **Q-14** to Enis Hoca (DCT/COMPARE → NN labs?).

## Things That MUST NOT Be Changed Without Review
- Port names and handshake semantics taken from the manuals (`INTERFACES.md` §2–4).
- Start/end words `55AACC03` / `AA5503CC` and the MSB-first byte order (TA-confirmed).
- Board pin assignment in `INTERFACES.md` §1.1 (DEC-018).
- The released/pending split of manuals (`docs/manuals/` vs `docs/manuals/pending/`).
- Requirement IDs (never renumber; deprecate instead).
