# Project Timeline

Two separate views are kept on purpose: **the syllabus plan** (official, tentative) and **our actual
progress**. Never overwrite one with the other.

## 1. Syllabus lab schedule (official, tentative)

Lab sessions are on Saturdays. Syllabus: *"Because lab due dates can fall on Wednesdays, the deadlines
listed below may be advanced by three days."* → plan against the Wednesday date until confirmed (Q-01).

| Week | Due date (Sat) | Possibly advanced to (Wed) | Lab | Difficulty factor | Manual status |
|---|---|---|---|---|---|
| 1 | Sep 19 | — | No lab | — | — |
| 2 | Sep 26 | — | Lab study | — | — |
| 3 | **Oct 03** | Sep 30 | **Lab-DEBUG** | 3 | Released |
| 4 | Oct 10 | Oct 07 | Lab-CTRL | 2 | Released (DEC-003) |
| 5 | Oct 17 | Oct 14 | Lab-ADC | 4 | Pending |
| 6 | Oct 24 | Oct 21 | Lab-WINDOW | 2 | Pending |
| 7 | Oct 31 | — | No lab | — | — |
| 8 | Nov 07 | Nov 04 | Lab-PCB | 5 | Pending |
| 9 | Nov 14 | Nov 11 | Lab-MATLAB | 3 | Pending |
| 10 | Nov 21 | Nov 18 | Lab-FFT | 5 | Pending |
| 11 | Nov 28 | — | Lab study | — | — |
| 12 | Dec 05 | Dec 02 | Lab-MEL | 3 | Pending |
| 13 | Dec 12 | Dec 09 | Lab-DCT | 2 | Not received |
| 14 | Dec 19 | Dec 16 | Lab-COMPARE | 5 | Not received |
| 15 | **Jan 11 (Mon)** | — | Overall system final demo | — | — |

Related lectures (Wednesdays): Oct 7 amplifiers/filters · Oct 14 PCB layout · Oct 21 sampling/ADC/SPI ·
Nov 4 FFT IP · Nov 11 FFT/DFT/windowing · Nov 18 system engineering · Nov 25 V-model · Dec 9 requirements & V&V.

Final-demo points (sub-systems used, /100): PCB 20 (breadboard 5) · ADC 10 · WINDOW 5 · FFT 20 (on MATLAB 5) ·
MEL 15 (on MATLAB 5) · DCT 10 (on MATLAB 5) · COMPARE 10 (on MATLAB 5) · recognition performance 10.

## 2. Stage plan

Each lab is done by a **Lead + Partner** pair while the third member is off (DEC-017). Slots:
P1 = Eren, P2 = Ömer, P3 = Hande; full rotation in [TEAM_MANUAL.md §3](TEAM_MANUAL.md#3-roles-and-weekly-rotation).
Deadlines are Wednesdays (only Sep 30 confirmed). "Sim req." and "HW req." describe what must exist
before the stage is complete.

| Stage | Deliverable | Lead | Partner | Off | Prerequisite | Sim req. | HW req. | Deadline (Wed) | Status |
|---|---|---|---|---|---|---|---|---|---|
| Phase 1 | Repo, requirements, architecture, plans, team manual | ALL | — | — | — | n/a | n/a | — | DONE — pending team review |
| DEBUG | UART debugger + CTRL subset + ROM demo + MATLAB receiver | Hande (coordinator) | Eren + Ömer | — (all hands) | Phase 1 | Self-checking TB, waveforms | ROM → MATLAB, 0 mismatches | **Sep 30** | NOT STARTED |
| CTRL | Controller with 50 % framing, all handshakes, LEDs | Eren | Ömer | Hande | DEBUG handshake | TB with stubs, framing waveform | Button start, LED sequence | Oct 7 | NOT STARTED |
| ADC | SPI capture into dual-port RAM, dump via DEBUG | Ömer | Hande | Eren | DEBUG, CTRL | TB with ADC model | Real ADC samples in MATLAB | Oct 14 | Manual pending |
| WINDOW | Framing × window → RAM | Hande | Eren | Ömer | ADC, CTRL, MATLAB ref. of window | Bit-true vs. MATLAB | Dump via DEBUG | Oct 21 | Manual pending |
| PCB | Mic amp + AA filter PCB interfaced to ADC | Eren | Ömer | Hande | LTspice sim, ADC | LTspice | Speech captured in MATLAB | Nov 4 | Manual pending (start in Oct 28 buffer week) |
| MATLAB | Complete recognition model on PC | Ömer | Hande | Eren | Dataset | MATLAB tests | PC-mic demo | Nov 11 | Manual pending |
| FFT | Vivado FFT IP stage | Hande | Eren | Ömer | WINDOW, MATLAB | Bit-true vs. MATLAB | Dump via DEBUG | Nov 18 | Manual pending |
| MEL | MEL filter-bank energies | Eren | Ömer | Hande | FFT | Bit-true vs. MATLAB | Dump via DEBUG | Dec 2 | Manual pending |
| DCT | DCT feature vector | Ömer | Hande | Eren | MEL | Bit-true vs. MATLAB | Dump via DEBUG | Dec 9 | Manual not received |
| COMPARE | Template store, decision, 7-segment | Hande | Eren | Ömer | DCT | TB + MATLAB | Spoken digit on display | Dec 16 | Manual not received |
| FINAL | Integrated system + report | ALL | — | — | all | Top-level sim | Live demo | Jan 11 (Mon) | — |

## 3. Critical-path observations

1. **DEBUG deadline is Wed Sep 30** (5 days from Sep 25) and its demo also requires a CTRL subset, a ROM
   IP, XDC, and a MATLAB receiver → all-hands week (see §4).
2. **PCB** (difficulty 5, 20 final points) is due 4 weeks after the analog lectures begin; manufacturing
   lead time is UNKNOWN (Q-10). Early release of the PCB manual may be justified — **team decision**.
3. **Lab-MATLAB** (Nov 14) comes after WINDOW (Oct 24): the MATLAB reference for the window stage will
   have to be written in the WINDOW stage itself, before the full MATLAB model exists.
4. The ADC/SPI lecture (Oct 21) is after the Lab-ADC due date (Oct 17) — Q-12.
5. Dec 26 – Jan 10 is the final-exam period; the final demo is Jan 11. Plan integration to be finished
   before Dec 25.

## 4. Lab-DEBUG week (Fri Sep 25 – Wed Sep 30) — all hands

Everyone has a work package (team decision). Hande coordinates and writes the debugger RTL. Eren builds
the demo top level (button/reset conditioning, XDC, Tcl) and — since TA Q-04 removed the CTRL dependency
of the DEBUG demo — starts the Lab-CTRL design early, as next week's Lead. Ömer does board bring-up,
ROM IP and the MATLAB side.

| Date | Hande — coordinator, DEBUG RTL | Eren — top level + early CTRL | Ömer — board, ROM, MATLAB |
|---|---|---|---|
| Fri Sep 25 | Everyone: TEAM_MANUAL §2 setup, clone outside OneDrive, accept/reject DEC-001…017. Write `docs/architecture/subsystems/debug.md` (baud tick, UART byte TX, word/frame FSM, memory latency, timing). | Write the top-level plan (button/reset conditioning, pin list from INTERFACES §1.1). | Download Basys-3 manual, `Basys3_Master.xdc`, FT2232H datasheet, AN232B-05; install FTDI VCP driver. |
| Sat Sep 26 (lab) | Review design docs together; TA answers received (Q-02…Q-13) — handshake fixed by REQ-IF-006/007. | Button/reset conditioning block (sync + debounce + 1-cycle pulse) design. | Board bring-up: blinky with XDC; confirm part number (ASSUMPTION-001); COM port visible. |
| Sun–Mon Sep 27–28 | UART TX + TB-UART-01..03; word/frame FSM + TB-DEBUG-01..09. | Button conditioning RTL + TB; start `docs/architecture/subsystems/ctrl.md` (full CTRL for Oct 7). | MATLAB: COE generator (incl. delimiter values) + receiver/decoder + MT-DEBUG-01..04; Block Memory Generator ROM (14b × 32b). |
| Tue Sep 29 | Review Eren's PRs; integration sim TB-TOPDBG-01. | Demo top level + XDC + `fpga/vivado/create_debug_demo.tcl`; synthesis/implementation. | Hardware tests HW-DEBUG-01..05 with Hande; review Hande's PRs. **Evening: freeze.** |
| **Wed Sep 30** | **Demo.** Tag `lab-debug-demo`, release with bitstream. | Evidence into `docs/verification/`. | AI sessions exported, records completed. |

Thu Oct 1: Lab-CTRL kickoff (Lead Eren, Partner Ömer, Hande off) — see TEAM_MANUAL §4.

## 5. Actual progress log

| Date | Event |
|---|---|
| 2026-09-24 | Phase 1 initialisation: repository structure and planning documents created (AI-assisted, pending team review). |
| 2026-09-24 | Repository created and moved to organization `Team-Project-Spoken-Number-Recognition`; all three members owners. |
| 2026-09-25 | Repository made temporarily public (DEC-016). Weekly Wednesday deadlines confirmed (first: Lab-DEBUG Sep 30). Rotation model and TEAM_MANUAL.md added (DEC-017). |
