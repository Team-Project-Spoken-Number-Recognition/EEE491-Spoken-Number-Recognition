# Project Status

_Last updated: 2026-09-24 — Phase 1 initialisation (AI-assisted, pending team review)_

## 1. Stage overview

| Stage | Manual | Manual status | Stage status |
|---|---|---|---|
| Phase 1 — initialisation | syllabus | Released | **DONE — pending team review** |
| Lab-DEBUG | `docs/manuals/Lab-DEBUG_Assignment.pdf` | Released, analysed | **CURRENT — NOT STARTED (design)** |
| Lab-CTRL | `docs/manuals/Lab-CTRL_Assignment.pdf` | Released, analysed (DEC-003) | NOT STARTED |
| Lab-ADC | `docs/manuals/pending/Lab-ADC_Assignment_v4.pdf` | Received, not released | — |
| Lab-WINDOW | `docs/manuals/pending/Lab-WINDOW_Assignment.pdf` | Received, not released | — |
| Lab-PCB | `docs/manuals/pending/Lab-PCB_Assignment.pdf` | Received, not released | — |
| Lab-MATLAB | `docs/manuals/pending/Lab-MATLAB_Assignment.pdf` | Received, not released | — |
| Lab-FFT | `docs/manuals/pending/Lab-FFT_Assignment.pdf` | Received, not released | — |
| Lab-MEL | `docs/manuals/pending/Lab-MEL_Assignment.pdf` | Received, not released | — |
| Lab-DCT | — | Not received | — |
| Lab-COMPARE | — | Not received | — |

## 2. Current stage: Lab-DEBUG

```text
Current Stage:   Lab-DEBUG (+ Lab-CTRL subset for the demo)
Official Manual: docs/manuals/Lab-DEBUG_Assignment.pdf
Analysis:        docs/manual_analysis/Lab-DEBUG_analysis.md
Status:          IN PROGRESS — requirements documented; design not started
Due:             Sat Oct 03 2026 (possibly Wed Sep 30 — Q-01)
```

### Completion checklist — Lab-DEBUG

```text
[x] Manual requirements understood          (docs/manual_analysis/Lab-DEBUG_analysis.md — pending team review)
[x] Requirements documented                 (REQUIREMENTS.md §1.2)
[ ] Architecture defined                    (docs/architecture/subsystems/debug.md — TODO)
[ ] Implementation completed
[ ] VHDL/MATLAB code reviewed
[ ] Testbench created
[ ] Functional simulation completed
[ ] Expected vs actual results compared
[ ] Synthesis completed
[ ] Hardware test completed
[ ] Lab demonstration completed
[ ] Known issues documented
[ ] Results documented
[ ] HANDOFF.md updated
[ ] PROJECT_STATUS.md updated
[ ] AI interaction documented
```

### Completion checklist — Lab-CTRL

```text
[x] Manual requirements understood          (docs/manual_analysis/Lab-CTRL_analysis.md — pending team review)
[x] Requirements documented                 (REQUIREMENTS.md §1.3)
[ ] Architecture defined
[ ] Implementation completed
[ ] Code reviewed
[ ] Testbench created
[ ] Functional simulation completed (framing + sequence waveforms)
[ ] Expected vs actual results compared
[ ] Synthesis completed
[ ] Hardware test completed (button start, LEDs)
[ ] Lab demonstration completed
[ ] Known issues / results documented
[ ] HANDOFF.md / PROJECT_STATUS.md updated
[ ] AI interaction documented
```

## 3. Requirement status summary

| Area | Total | OPEN | IN PROGRESS | IMPL. — NOT VERIFIED | VERIFIED |
|---|---|---|---|---|---|
| SYS | 5 | 5 | 0 | 0 | 0 |
| DEBUG | 20 | 20 | 0 | 0 | 0 |
| CTRL | 10 | 10 | 0 | 0 | 0 |
| IF | 5 | 5 | 0 | 0 | 0 |
| PERF / HW / SW / VER / DOC / PROC | 21 | 19 | 2 | 0 | 0 |

## 4. Risk register

| ID | Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|---|
| R-01 | Lab-DEBUG deadline (Oct 03, possibly Sep 30) missed — demo also needs CTRL subset, ROM IP, XDC, MATLAB | High | High (late factor) | Parallel split in PROJECT_TIMELINE §4; clarify date (Q-01) | ALL |
| R-02 | Byte-order / handshake interpretation differs from the assistant's expectation | Medium | Medium | Q-02, Q-03 before coding; single constant controls order | A |
| R-03 | Git repo inside OneDrive → lock/corruption | Medium | High | DEC-014: move repo outside OneDrive | ALL |
| R-04 | Vivado version mismatch between members / lab PC → IP upgrade issues | Medium | Medium | DEC-008 | ALL |
| R-05 | AI-generated code accepted without understanding → exam and demo risk | Medium | High | PR review rule; owner + reviewer explain each block; AI log | ALL |
| R-06 | PCB manufacturing lead time unknown; PCB is difficulty 5 and 20 final points | Medium | High | Q-10; consider early release of PCB manual | B |
| R-07 | BRAM budget: demo ROM alone ≈ 16 of 50 BRAM36 (ASSUMED XC7A35T); final system has RAMs for ADC, WINDOW, FFT, MEL, DCT, templates | Medium | High (late-stage redesign) | Track BRAM use per stage in synthesis reports; budget table from ADC stage | A |
| R-08 | Timing closure of FFT/MEL at 100 MHz | Low–Med | Medium | Decide at FFT stage; pipeline; DEC-006 revisit | A |
| R-09 | Incomplete AI-usage records (syllabus requires full unedited chats and raw outputs) | High | Medium (report grade) | Export every session to `ai/sessions/` the same day | ALL |
| R-10 | Delimiter values inside payload break PC parsing | Medium | Medium | DEC-010 fixed-length read | C |
| R-11 | FTDI VCP driver / COM-port issues on lab PC | Medium | Medium | Test on lab PC early (Sep 26) | B |
| R-12 | Lab-MATLAB comes after WINDOW, so no golden model exists when WINDOW is built | High | Medium | Write a stage-local MATLAB reference at each stage | C |

## 5. Environment observed (one member's PC, 2026-09-24)

| Item | Observation | Status |
|---|---|---|
| Vivado | `C:\Xilinx\Vivado\2023.2` | Observed |
| MATLAB | R2023b | Observed |
| ModelSim | Intel ModelSim ASE 18.1 present (not the planned simulator) | Observed |
| git / gh | git 2.54; gh logged in as `eeerenbuyukbas`; **no global git user.name/email configured** | Observed |
| Repo location | Inside OneDrive (`...\OneDrive\Masaüstü\EEE391 Project`) | **Risk R-03** |
