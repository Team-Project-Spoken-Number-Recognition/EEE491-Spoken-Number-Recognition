# PROJECT INITIALIZATION REPORT — 2026-09-24

_AI-generated (AI-0001), pending team review._

## 1. Repository architecture
See `README.md` §4. Additions to the originally proposed layout and their reasons: `DECISIONS.md` DEC-002
(manual release folders, manual analyses, subsystem docs, traceability matrix, common RTL/TB folders,
MATLAB debug folder, raw chat exports, CONTRIBUTING.md, CLAUDE.md).

## 2. Proposed team workflow
Protected `main`, short-lived `feature/`/`fix/`/`docs/`/`sim/` branches, conventional commits, PR with
template + 1 reviewer, squash-merge, tag per demonstrated lab (DEC-004, `CONTRIBUTING.md`).
Owner/reviewer per block (`CONTRIBUTING.md` §3). Every session ends with HANDOFF/STATUS update and an AI record.

## 3. Subsystem breakdown
DEBUG · CTRL · ADC · WINDOW · PCB · MATLAB · FFT · MEL · DCT · COMPARE (+7-segment) — `ARCHITECTURE.md`.
Only DEBUG and CTRL have released manuals; everything else is PLANNED/UNKNOWN.

## 4. Requirements breakdown
64 requirements: SYS 5, DEBUG 20, CTRL 10, IF 5, PERF 3, HW 3, SW 3, VER 4, DOC 3, PROC 5 — all OPEN
except DOC-001 and PROC-002 (IN PROGRESS). `REQUIREMENTS.md`.

## 5. Major unknowns
U-01 … U-23 in `ASSUMPTIONS.md` §2. Most urgent: demo date (Q-01), byte order (Q-02), handshake
details (Q-03), CTRL scope in DEBUG demo (Q-04), RESET/START inputs (Q-05), team tool versions.

## 6. Technical risks
R-01 … R-12 in `PROJECT_STATUS.md` §4. Top: DEBUG deadline (R-01), OneDrive-hosted git repo (R-03),
unexamined AI code (R-05), PCB lead time (R-06), BRAM budget (R-07), incomplete AI records (R-09).

## 7. First two weeks
`PROJECT_TIMELINE.md` §4.

## 8. Questions needing instructor confirmation
`docs/meetings/INSTRUCTOR_QUESTIONS.md` Q-01 … Q-13.
