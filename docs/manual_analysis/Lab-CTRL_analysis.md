# NEW MANUAL ANALYSIS — Lab-CTRL

```text
Manual:        docs/manuals/Lab-CTRL_Assignment.pdf (3 pages; SHA-256 first 12: 3a042e816b6b)
Stage:         Lab-CTRL — released with Lab-DEBUG (DEC-003); due Oct 10
Analysed by:   Claude Opus 5.5 (AI), 2026-09-24 — text + page images
Reviewed by:   _pending_
```

## Purpose
Central data-flow controller. Sequences all sub-systems with start/ready, generates 50 %-overlapped
frame start addresses for Lab-WINDOW, and controls Lab-DEBUG when it is attached to a sub-system.
It also defines the **common handshake** that every sub-system must implement.

## Explicit Requirements (→ REQUIREMENTS.md §1.3, §2)
| Manual text (paraphrased) | Section | REQ |
|---|---|---|
| Project = sub-systems = lab assignments (block diagram) | §1 ¶1 | REQ-SYS-002 |
| Each sub-system has an internal dual-port RAM read by the following sub-system | §1 ¶2 | REQ-IF-004 |
| CTRL controls the data flow with start/ready | §1 ¶2 | REQ-CTRL-001 |
| CTRL divides the speech in the ADC RAM into frames by generating frame start address to WINDOW | §1 ¶3 | REQ-CTRL-002 |
| Frames overlap by 50 % | §1 ¶3 | REQ-CTRL-003 |
| Per frame: start each sub-system, observe ready | §1 ¶3 | REQ-CTRL-004 |
| Controls Lab-DEBUG when attached to any sub-system output | §1 ¶3 | REQ-CTRL-005 |
| RESET and START switches; RESET → every sub-system; START → CTRL | §1 ¶4 | REQ-CTRL-006 |
| start: 1-cycle pulse at rising edge; ready: active high, low just after start, high at the rising edge after completion | §1 ¶5 + waveform | REQ-IF-001..003 |
| IO list (19 ports incl. 14-bit `frame_addr_out`) | §1 | REQ-CTRL-007 |
| TB; waveforms show 50 % framing and sequence | §1, §2 | REQ-CTRL-008 |
| Implemented on FPGA | §2 | REQ-CTRL-009 |
| Button for start_in; LEDs for ready of sub-systems | §3 | REQ-CTRL-009 |
| Integrated progressively; may be modified so DEBUG is the last integrated sub-system; keep versions | §3 | REQ-CTRL-005, REQ-CTRL-010 |

## Inputs
`reset_in`, `clock_in`, `start_in`, `ready_adc_in`, `ready_window_in`, `ready_fft_in`, `ready_mel_in`,
`ready_dct_in`, `ready_comp_in`, `ready_debug_in`.

## Outputs
`ready_out`, `start_adc_out`, `frame_addr_out[13:0]`, `start_window_out`, `start_fft_out`,
`start_mel_out`, `start_dct_out`, `start_comp_out`, `start_debug_out`.

## Interfaces
Start/ready with seven sub-systems; frame address to WINDOW; board button/switch inputs; LEDs.
The block diagram also shows RECORD & NUMBER switches → COMPARE and 7-segment ← COMPARE
(not CTRL ports; COMPARE stage).

## Dependencies on Previous Stages
Lab-DEBUG (start/ready of the debugger; DEBUG demo needs CTRL).

## New Requirements
REQ-CTRL-001 … 010, REQ-IF-001 … 005.

## Changes Required to Existing System
None yet. Lab-DEBUG must implement exactly the REQ-IF handshake.

## Verification Requirements
TB with stub sub-systems (programmable latency) showing: 1-cycle start pulses, correct order, waiting
on ready, frame address sequence k·L/2, reset behaviour. Hardware: button start, LEDs.

## Hardware Requirements
Basys-3 buttons/switches for RESET and START, LEDs.

## Potential Risks
- Frame length L, number of frames and ADC RAM depth are unknown until ADC/WINDOW manuals →
  make them generics; demonstrate framing with a placeholder L (clearly labelled as such).
- Where the per-frame loop sits: which blocks run once per recording (ADC, COMPARE, DEBUG) vs. once
  per frame (WINDOW, FFT, MEL, DCT) is **implied, not stated** → confirm.
- Switch vs. button wording mismatch (§1 vs. §3) → Q-05.
- Hardware demo with non-existent sub-systems needs stubs/loop-backs → Q-04.

## Questions / Ambiguities
Q-03, Q-04, Q-05; plus: per-recording vs. per-frame sequencing of each block; does CTRL itself
assert `ready_out` after the last frame or after COMPARE?

## Recommended Implementation Order
1. Subset for Lab-DEBUG demo: `start_in` → `start_debug_out`, wait `ready_debug_in` → `ready_out`.
2. `docs/architecture/subsystems/ctrl.md`: full FSM (per-recording and per-frame loops), frame counter,
   generics (L, number of frames), stub strategy.
3. Full CTRL RTL + TB with stubs; framing waveform.
4. Board demo with LEDs; tag `lab-ctrl-v1`.
