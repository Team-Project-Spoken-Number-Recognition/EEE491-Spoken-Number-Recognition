# Project Status

_Last updated: 2026-09-26 — PR #4 merged; MATLAB side + demo ROM IP in PR #5 (MT 15/15, TB-ROM 11/11 PASS), Vivado 2025.2 in PR #6 (AI-0007, pending team review)_

## 1. Stage overview

| Stage | Manual | Manual status | Stage status |
|---|---|---|---|
| Phase 1 — initialisation | syllabus | Released | **DONE — pending team review** |
| Lab-DEBUG | `docs/manuals/Lab-DEBUG_Assignment.pdf` | Released, analysed | **CURRENT — RTL merged (PR #4); MATLAB + ROM IP in PR #5; top level (Eren), synthesis, HW open** |
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
Current Stage:   Lab-DEBUG (Lab-CTRL not needed for its demo — TA Q-04)
Official Manual: docs/manuals/Lab-DEBUG_Assignment.pdf
Analysis:        docs/manual_analysis/Lab-DEBUG_analysis.md
Status:          IN PROGRESS — RTL merged (PR #4); MATLAB + ROM IP in PR #5 (PASS); demo top level open
Due:             Wed Sep 30 2026 (confirmed by team, 2026-09-25)
```

### Completion checklist — Lab-DEBUG

```text
[x] Manual requirements understood          (docs/manual_analysis/Lab-DEBUG_analysis.md — pending team review)
[x] Requirements documented                 (REQUIREMENTS.md §1.2)
[x] Architecture defined                    (docs/architecture/subsystems/debug.md v0.2, reviewed in PR #3)
[x] Implementation completed                (debug + uart_tx #4, MATLAB + ROM IP #5, demo top level #7 — 2026-09-26)
[~] VHDL/MATLAB code reviewed               (PR #4, #5 approved + merged; PR #7 RTL awaiting review)
[x] Testbench created                       (tb_uart_tx, tb_debug, tb_debug_rom, tb_button_conditioner, tb_top_debug_demo, MATLAB test_debug — DEC-011)
[x] Functional simulation completed         (block level + demo top with real ROM IP: TB-TOPDBG 15/15, TB-BTN 22/22)
[x] Expected vs actual results compared     (37/37, 97/97, 11/11, 22/22, 15/15, MT 15/15 PASS — simulation/results/2026-09-26_*.log)
[x] Synthesis completed                     (synth + impl + bitstream 2026-09-26: WNS +5.083 ns, DRC 0 — docs/verification/)
[x] Hardware test completed                 (HW-DEBUG-02…05 PASS 2026-09-26 — docs/verification/2026-09-26_HW-DEBUG.md)
[ ] Lab demonstration completed
[ ] Known issues documented
[~] Results documented                      (TEST_PLAN, REQUIREMENTS, TRACEABILITY_MATRIX updated 2026-09-26)
[~] HANDOFF.md updated                      (2026-09-26, AI-0007: MATLAB + ROM IP)
[~] PROJECT_STATUS.md updated               (2026-09-26, AI-0007: MATLAB + ROM IP)
[~] AI interaction documented               (AI-0004, AI-0006, AI-0007 records; AI-0007 chat export added; AI-0004 (Hande) still to add)
```

### Completion checklist — Lab-CTRL

```text
[x] Manual requirements understood          (docs/manual_analysis/Lab-CTRL_analysis.md — pending team review)
[x] Requirements documented                 (REQUIREMENTS.md §1.3)
[ ] Architecture defined
[x] Implementation completed                (debug + uart_tx #4, MATLAB + ROM IP #5, demo top level #7 — 2026-09-26)
[ ] Code reviewed
[x] Testbench created                       (tb_uart_tx, tb_debug, tb_debug_rom, tb_button_conditioner, tb_top_debug_demo, MATLAB test_debug — DEC-011)
[ ] Functional simulation completed (framing + sequence waveforms)
[x] Expected vs actual results compared     (37/37, 97/97, 11/11, 22/22, 15/15, MT 15/15 PASS — simulation/results/2026-09-26_*.log)
[x] Synthesis completed                     (synth + impl + bitstream 2026-09-26: WNS +5.083 ns, DRC 0 — docs/verification/)
[ ] Hardware test completed (button start, LEDs)
[ ] Lab demonstration completed
[ ] Known issues / results documented
[ ] HANDOFF.md / PROJECT_STATUS.md updated
[ ] AI interaction documented
```

## 3. Requirement status summary

| Area | Total | OPEN | IN PROGRESS | IMPL. — NOT VERIFIED | VERIFIED |
|---|---|---|---|---|---|
| SYS | 6 | 6 | 0 | 0 | 0 |
| DEBUG | 20 | 8 | 0 | 8 | 4 |
| CTRL | 10 | 10 | 0 | 0 | 0 |
| IF | 7 | 3 | 4 | 0 | 0 |
| PERF / HW / SW / VER / DOC / PROC | 21 | 18 | 2 | 0 | 1 |

2026-09-26: DEBUG/IF/PERF changes come from the block-level simulation of PR #4 only (VERIFIED = all
listed methods are simulation/analysis; IMPLEMENTED — NOT VERIFIED = hardware or inspection still open).
Details: `docs/requirements/TRACEABILITY_MATRIX.md`.

## 4. Risk register

| ID | Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|---|
| R-01 | Lab-DEBUG deadline (Wed Sep 30) missed — demo also needs CTRL subset, ROM IP, XDC, MATLAB | High | High (late factor) | All-hands week, parallel split in PROJECT_TIMELINE §4 | ALL |
| R-13 | Public repository exposes course material, lab work, AI records and possibly personal data; copies persist after going private | Medium | Medium–High | DEC-016; TEAM_MANUAL §9 rules; check exports before commit | ALL |
| R-14 | Rotation leaves the off-week member unable to explain a lab (exam questions to all members) | Medium | Medium | Thursday catch-up (TEAM_MANUAL §4) | ALL |
| R-15 | 1 Mbaud not working reliably on some PC/driver/MATLAB combination | — | — | **CLOSED 2026-09-26** for Eren's PC (HW-DEBUG-02…05, ≈ 20 transfers, 0 errors); check once on the lab PC before the demo | Hande |
| R-16 | Lab-DCT / Lab-COMPARE likely replaced by NN-based labs → architecture after MEL unknown | High | Medium | Don't plan beyond MEL; ask Enis Hoca (Q-14) | ALL |
| R-02 | Byte-order / handshake interpretation differs from the assistant's expectation | — | — | **CLOSED 2026-09-26** — TA Q-02/Q-03 answered (REQ-DEBUG-007, REQ-IF-006/007) | Hande |
| R-03 | Git repo inside OneDrive → lock/corruption | Medium | High | DEC-014: move repo outside OneDrive | ALL |
| R-04 | Vivado version mismatch between members / lab PC → IP upgrade issues | Medium | Medium | DEC-008: everyone on 2025.2 (decided 2026-09-26) | ALL |
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
| GitHub remote | `Team-Project-Spoken-Number-Recognition/EEE491-Spoken-Number-Recognition`, private, org on free plan | DEC-015 |
| Branch protection | Enabled on `main` 2026-09-25 (PR + 1 approval, admins included) | Lost if repo goes private on free plan |
| Hande's PC (2026-09-26) | Vivado **2025.2** (XSim batch mode works); MATLAB R2025b; `gh` not installed; no GHDL | **Version differs from 2023.2 above → DEC-008 / R-04** (IP `.xci` for the demo ROM is version-specific) |
