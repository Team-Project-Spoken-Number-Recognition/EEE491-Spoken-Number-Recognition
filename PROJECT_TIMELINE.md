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

Owner/reviewer are **proposals** (see `CONTRIBUTING.md` §3). "Sim req." and "HW req." describe what
must exist before the stage is complete.

| Stage | Deliverable | Owner | Reviewer | Prerequisite | Sim req. | HW req. | Deadline (syllabus) | Status |
|---|---|---|---|---|---|---|---|---|
| Phase 1 | Repo, requirements, architecture, plans | ALL | ALL | — | n/a | n/a | Sep 26 (internal) | DONE — pending team review |
| DEBUG | UART debugger + CTRL subset + ROM demo + MATLAB receiver | A | C | Phase 1 | Self-checking TB, waveforms | ROM → MATLAB, 0 mismatches | Oct 03 (Sep 30?) | NOT STARTED |
| CTRL | Controller with 50 % framing, all handshakes, LEDs | C | A | DEBUG handshake | TB with stubs, framing waveform | Button start, LED sequence | Oct 10 | NOT STARTED |
| ADC | SPI capture into dual-port RAM, dump via DEBUG | B | A | DEBUG, CTRL | TB with ADC model | Real ADC samples in MATLAB | Oct 17 | Manual pending |
| WINDOW | Framing × window → RAM | A | C | ADC, CTRL, MATLAB ref. of window | Bit-true vs. MATLAB | Dump via DEBUG | Oct 24 | Manual pending |
| PCB | Mic amp + AA filter PCB interfaced to ADC | B | C | LTspice sim, ADC | LTspice | Speech captured in MATLAB | Nov 07 | Manual pending |
| MATLAB | Complete recognition model on PC | C | B | Dataset | MATLAB tests | PC-mic demo | Nov 14 | Manual pending |
| FFT | Vivado FFT IP stage | A | C | WINDOW, MATLAB | Bit-true vs. MATLAB | Dump via DEBUG | Nov 21 | Manual pending |
| MEL | MEL filter-bank energies | C | A | FFT | Bit-true vs. MATLAB | Dump via DEBUG | Dec 05 | Manual pending |
| DCT | DCT feature vector | B | C | MEL | Bit-true vs. MATLAB | Dump via DEBUG | Dec 12 | Manual not received |
| COMPARE | Template store, decision, 7-segment | C | B | DCT | TB + MATLAB | Spoken digit on display | Dec 19 | Manual not received |
| FINAL | Integrated system + report | ALL | ALL | all | Top-level sim | Live demo | Jan 11 | — |

## 3. Critical-path observations

1. **DEBUG deadline is 6–9 days away** and its demo also requires a CTRL subset, a ROM IP, XDC, and a
   MATLAB receiver. Work must be split across all three members immediately (see §4).
2. **PCB** (difficulty 5, 20 final points) is due 4 weeks after the analog lectures begin; manufacturing
   lead time is UNKNOWN (Q-10). Early release of the PCB manual may be justified — **team decision**.
3. **Lab-MATLAB** (Nov 14) comes after WINDOW (Oct 24): the MATLAB reference for the window stage will
   have to be written in the WINDOW stage itself, before the full MATLAB model exists.
4. The ADC/SPI lecture (Oct 21) is after the Lab-ADC due date (Oct 17) — Q-12.
5. Dec 26 – Jan 10 is the final-exam period; the final demo is Jan 11. Plan integration to be finished
   before Dec 25.

## 4. First two weeks (Sep 24 – Oct 10)

| Dates | A (DEBUG owner) | B | C (CTRL owner) |
|---|---|---|---|
| Thu–Fri Sep 24–25 | Team meeting: review Phase 1 docs, assign names/roles, accept/reject DEC-001…014. Create private GitHub repo **outside OneDrive**; initial commit; branch protection. Everyone: check Vivado/MATLAB versions, install FTDI VCP driver. | Download to `hardware/datasheets/`: Basys-3 Reference Manual, `Basys3_Master.xdc`, FT2232H datasheet, AN232B-05. Record revisions. | Write `docs/architecture/subsystems/ctrl.md` (subset needed for DEBUG demo first). |
| Sat Sep 26 (lab study) | Ask Q-01…Q-05 in the lab. Write `docs/architecture/subsystems/debug.md`: FSM diagram, timing, latency handling. | Board bring-up: blinky with XDC, verify programming flow; confirm part number (ASSUMPTION-001). | MATLAB: COE generator (test pattern incl. delimiter values) + receiver/decoder with MT-DEBUG-01..04. |
| Sun–Mon Sep 27–28 | Review of debug.md by C → then VHDL: UART TX (8-bit, low baud) + TB-UART-01..03. | Button sync/debounce/pulse block + TB; top-level XDC for demo. | CTRL subset VHDL + TB-CTRL-01/02. |
| Tue Sep 29 | Word serializer FSM + TB-DEBUG-01..09. | Block Memory Generator ROM (14b × 32b, COE) + top-level Tcl script. | Review A's RTL/TB. |
| Wed Sep 30 | Integration sim TB-TOPDBG-01; synthesis; HW-DEBUG-01..05. **If the deadline is advanced, this is demo day.** | Hardware tests with A. | MATLAB end-to-end with hardware. |
| Thu–Sat Oct 1–3 | Evidence + report; PR review; tag `lab-debug-demo`; **Lab-DEBUG demo Oct 03**. | AI-usage log for the stage. | Full CTRL design doc (framing). |
| Oct 4–10 | Support CTRL integration; start reading DEBUG ↔ future RAM interface. | Analog lecture prep (Oct 7), component research **only if PCB manual is released**. | Full CTRL: framing, stubs, TB-CTRL-03..06, LEDs; **Lab-CTRL demo Oct 10**. |

## 5. Actual progress log

| Date | Event |
|---|---|
| 2026-09-24 | Phase 1 initialisation: repository structure and planning documents created (AI-assisted, pending team review). |
