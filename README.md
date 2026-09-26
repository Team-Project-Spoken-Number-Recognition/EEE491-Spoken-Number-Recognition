# EEE491 — FPGA Spoken Number Recognition

Bilkent University · EEE491 Electrical and Electronics Engineering Design I · Fall 2026
Platform: Digilent Basys-3 (Xilinx Artix-7) · VHDL · Vivado · MATLAB · LTspice · KiCad (proposed)

> This repository is our **engineering notebook, project-management system, verification record,
> AI-usage record and final-report source** — not only a code store.

## 1. What the system does (target — PLANNED, not yet implemented)

Speech from a microphone is amplified/filtered (analog PCB), digitised by an SPI ADC, captured by the
FPGA, framed and windowed, transformed (FFT → MEL filter banks → DCT) into a feature vector,
compared with stored templates, and the recognised number is shown on the Basys-3 7-segment display.
A UART debugger (Lab-DEBUG) streams any on-chip RAM to MATLAB for analysis.

See [ARCHITECTURE.md](ARCHITECTURE.md).

## 2. Current stage

| Item | Value |
|---|---|
| Current stage | **Lab-DEBUG** (with the Lab-CTRL dependency required for its demo) |
| Official manuals in use | [docs/manuals/Lab-DEBUG_Assignment.pdf](docs/manuals/Lab-DEBUG_Assignment.pdf), [docs/manuals/Lab-CTRL_Assignment.pdf](docs/manuals/Lab-CTRL_Assignment.pdf) |
| Status | Phase 1 (project initialisation) complete — design of Lab-DEBUG not started |
| Due date | Lab-DEBUG: **Wed Sep 30 2026** (one lab deadline per week, on Wednesdays) |

**New team member or new Claude session? Read [TEAM_MANUAL.md](TEAM_MANUAL.md) first** — setup,
weekly rotation, git workflow, Claude prompts, public-repo rules.

Live status: [PROJECT_STATUS.md](PROJECT_STATUS.md) · Session handoff: [HANDOFF.md](HANDOFF.md)

## 3. Start here (humans and AI sessions)

Read in this order before changing anything:

1. `README.md` (this file)
2. [HANDOFF.md](HANDOFF.md) — where the last session stopped
3. [PROJECT_STATUS.md](PROJECT_STATUS.md) — stage status and completion checklists
4. [REQUIREMENTS.md](REQUIREMENTS.md) — requirement IDs
5. [ARCHITECTURE.md](ARCHITECTURE.md) — system blocks
6. [INTERFACES.md](INTERFACES.md) + the relevant `docs/architecture/subsystems/*.md`
7. [CONTRIBUTING.md](CONTRIBUTING.md) — branch / PR / VHDL rules
8. [CLAUDE.md](CLAUDE.md) — rules for AI assistant sessions

## 4. Repository map

```text
.
├── README.md  HANDOFF.md  PROJECT_STATUS.md  REQUIREMENTS.md  ARCHITECTURE.md
├── INTERFACES.md  VERIFICATION_PLAN.md  TEST_PLAN.md  PROJECT_TIMELINE.md
├── DECISIONS.md  ASSUMPTIONS.md  CONTRIBUTING.md  CLAUDE.md
├── docs/
│   ├── syllabus/            official syllabus (PDF)
│   ├── manuals/             RELEASED official lab manuals (source of truth for the active stage)
│   │   └── pending/         received but NOT yet released to the team workflow (do not implement from)
│   ├── manual_analysis/     "NEW MANUAL ANALYSIS" record per released manual
│   ├── architecture/        diagrams + subsystems/<block>.md design docs
│   ├── requirements/        traceability matrix
│   ├── verification/        test reports (sim + hardware)
│   ├── reports/             lab reports, initialisation report, final report drafts
│   └── meetings/            meeting notes, INSTRUCTOR_QUESTIONS.md
├── matlab/                  reference ("golden") model, analysis, PC-side debug receiver
├── fpga/
│   ├── rtl/<block>/         synthesizable VHDL, one folder per lab block (+ common/, top/)
│   ├── tb/<block>/          VHDL testbenches (self-checking)
│   ├── constraints/         XDC files
│   ├── ip/                  Vivado IP (.xci only) + .coe init files
│   └── vivado/              Tcl scripts that re-create the Vivado project (project dirs are NOT committed)
├── analog/                  LTspice, schematic, PCB
├── simulation/              exported waveforms, reference vectors, results
├── hardware/                datasheets (or links), board notes, ADC notes
├── tests/                   system-level / hardware test procedures and records
├── ai/                      GenAI usage record (required by syllabus)
└── .github/                 PR template, issue templates, CI plan
```

Differences from the originally proposed layout are explained in [DECISIONS.md](DECISIONS.md) (DEC-002).

## 5. Status vocabulary (used in every document)

| Tag | Meaning |
|---|---|
| **VERIFIED** | Demonstrated by simulation, synthesis, hardware test, or official source |
| **IMPLEMENTED — NOT VERIFIED** | Code/design exists but not adequately tested |
| **PLANNED** | Intended future work |
| **ASSUMED** | Not yet confirmed (see [ASSUMPTIONS.md](ASSUMPTIONS.md)) |
| **UNKNOWN** | Information currently unavailable |

## 6. Tools (versions must be pinned — see DEC-008)

| Tool | Version | Status |
|---|---|---|
| Vivado ML Standard | **2025.2** (all members, DEC-008) | DECIDED 2026-09-26 |
| MATLAB | R2025b (Hande, Ömer), R2023b (Eren) — code must run on R2019b+ | NOT PINNED |
| LTspice | UNKNOWN | — |
| PCB tool | KiCad proposed | PLANNED |

## 7. Team

Repository: https://github.com/Team-Project-Spoken-Number-Recognition/EEE491-Spoken-Number-Recognition
(owned by the GitHub organization `Team-Project-Spoken-Number-Recognition` — DEC-015; **temporarily
public** — DEC-016). Organization owners (equal admin rights): `eeerenbuyukbas`, `handeery`, `omerkutlu1030`.
Weekly Lead/Partner/off-week rotation: [TEAM_MANUAL.md §3](TEAM_MANUAL.md#3-roles-and-weekly-rotation).

| Role | Name | GitHub |
|---|---|---|
| Member A | _TBD_ | _TBD_ |
| Member B | _TBD_ | _TBD_ |
| Member C | _TBD_ | _TBD_ |
| Instructor | İsmail Enis Ungan |
| Lab assistant | Arda Keskin |

Ownership matrix: [CONTRIBUTING.md §3](CONTRIBUTING.md#3-ownership-matrix-proposed).

> **Repository visibility:** this repository contains official course material (manuals, syllabus) and
> is currently public by team decision (DEC-016). Follow the public-repository rules in
> [TEAM_MANUAL.md §9](TEAM_MANUAL.md#9-public-repository-rules).
