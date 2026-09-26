# NEW MANUAL ANALYSIS — Lab-DEBUG

```text
Manual:        docs/manuals/Lab-DEBUG_Assignment.pdf (4 pages; SHA-256 first 12: aa6f9171228d)
Stage:         Lab-DEBUG — current stage
Analysed by:   Claude Opus 5.5 (AI), 2026-09-24 — text extraction + page images (waveforms, tables)
Reviewed by:   _pending_
```

## Purpose
A transmit-only UART "debugger" that streams the contents of any on-chip memory (2^N × 32-bit) to
MATLAB over the Basys-3 USB-UART bridge. It becomes the observation tool for every later lab.

## Explicit Requirements (→ REQUIREMENTS.md §1.2)
| Manual text (paraphrased) | Section | REQ |
|---|---|---|
| Debugger on Basys-3 FPGA sends multiple 32-bit data to MATLAB via USB | §1 ¶1 | REQ-DEBUG-001 |
| Only the transmitter part of a UART | §1 ¶1 | REQ-DEBUG-002 |
| Reads the read-only port of a memory in the FPGA | §1 ¶2 | REQ-DEBUG-003 |
| Address width N set as a VHDL constant; transmits 2^N words | §1 ¶2 | REQ-DEBUG-004 |
| Start word 55AACC03 first | §1 ¶3 | REQ-DEBUG-005 |
| End word AA5503CC after the data | §1 ¶3 | REQ-DEBUG-006 |
| Each 32-bit word = four 8-bit transmissions (table) | §1 ¶3 | REQ-DEBUG-007 |
| MATLAB: data between start/stop code, 4 bytes → 32-bit integer by concatenation | §1 ¶4 | REQ-DEBUG-015 |
| Interface with FT2232HQ; figure: FT2232 TXD → B18, RXD ← A18 | §1 ¶5 | REQ-DEBUG-010 |
| ≥ 115200 baud if supported by FT2232HQ | §1 ¶5; §3 | REQ-DEBUG-009 |
| IO: reset_in, clock_in (100 MHz), mem_addr_out (N), mem_data_in (32), txd_out, start_in, ready_out | §1 ¶6 | REQ-DEBUG-011..014 |
| start_in: active high, single clock pulse; ready_out: active high, low just after start (waveform) | §1 ¶6 | REQ-DEBUG-013/014 |
| VHDL testbench; verify specs by simulation | §1 ¶7 | REQ-VER-001 |
| Integrate with a sub-system to send its RAM data to MATLAB | §1 ¶8 | REQ-DEBUG-018 |
| Demo: implemented on FPGA | §2 | REQ-DEBUG-017 |
| Demo: TB waveforms show start, ready, UART TX, transactions | §2 | REQ-VER-002 |
| Demo: DEBUG + Lab-CTRL + ROM (Block Memory Generator, 14-bit addr, 32-bit data, COE), N = 14 | §2 | REQ-DEBUG-016 |
| Demo: configure FPGA, transfer ROM to MATLAB, verify in MATLAB | §2 | REQ-DEBUG-017 |

Guidance items (§3, "should"-level): FSM triggering the UART 4× per word; use Basys3_Master.xdc; FT2232HQ
datasheet; build progressively (8-bit fixed data, low baud first); install FTDI VCP driver; AN232B-05 for
baud; 8N1, LSB first example; zero-pad words < 32 bits; memory latency 1–2 cycles; terminal program;
MATLAB receive code; COE format example.

## Inputs
`reset_in`, `clock_in` (100 MHz), `start_in` (1-cycle pulse), `mem_data_in[31:0]`.

## Outputs
`txd_out` (serial), `mem_addr_out[N-1:0]`, `ready_out`.

## Interfaces
- FPGA ↔ FT2232HQ (UART TX only, 8N1, ≥ 115 200 baud) → USB VCP → MATLAB.
- DEBUG ↔ memory read port (address out, data in, latency 1–2 cycles).
- DEBUG ↔ Lab-CTRL (start/ready).

## Dependencies on Previous Stages
None (first lab). **Forward dependency:** the demo requires Lab-CTRL (next lab) → DEC-003.

## New Requirements
REQ-DEBUG-001 … 020, REQ-VER-001/002, REQ-HW-002/003, REQ-SW-001..003, REQ-PERF-001/002.

## Changes Required to Existing System
None (no existing system).

## Verification Requirements
Self-checking VHDL TB (UART RX model, memory model with latency), MATLAB decode tests, hardware transfer
of a known COE with 0 mismatches. See TEST_PLAN §1–3.

## Hardware Requirements
Basys-3, micro-USB cable, FTDI VCP driver on the PC, Vivado Block Memory Generator IP, Basys3_Master.xdc.

## Potential Risks
- Byte order not defined in words (only by the header example) → Q-02.
- Behaviour of `ready_out` at reset and of `start_in` while busy not defined → Q-03.
- ROM latency mis-handled → first word wrong/shifted by one (classic bug) → TB-DEBUG-07.
- Payload may contain delimiter values → PC parser must read a fixed length (DEC-010).
- Push-button bounce → multiple transfers → debounce + edge detect.
- 16 384 × 32 ROM uses ≈ 16 BRAM36 → fine for the demo; note for BRAM budget.
- Deadline in 6–9 days with CTRL dependency.

## Questions / Ambiguities
Q-01 … Q-07 — all answered (see "Clarifications received" below). Baud rate decided: 1 000 000 (DEC-005).

## Clarifications received (TA, 2026-09-26)
| Question | Answer | Effect |
|---|---|---|
| Q-02 byte order | MSB byte first for all words | REQ-DEBUG-007 confirmed |
| Q-03 handshake | `ready_out` = '1' after reset; `start_in` during a transfer is ignored | REQ-IF-006, REQ-IF-007 |
| Q-04 CTRL in demo | Not required — top module drives `start_in`/`ready_out` | REQ-DEBUG-016 relaxed; step 6 below changes |
| Q-05 board inputs | Our choice → reference design: RESET = BTNC, START = BTNU | DEC-018, INTERFACES §1.1 |
| Q-06 higher baud | No (team interpretation: about changing the rate between labs) | Team chose 1 000 000 baud, fixed for all labs (DEC-005) |
| Q-07 constant N | Use N, defined as a number at the top of the code; no hard-coded widths | DEC-012, REQ-DEBUG-004 |

## Recommended Implementation Order
1. `docs/architecture/subsystems/debug.md`: block diagram (baud-tick generator, UART byte TX, word
   serializer FSM, address counter), FSM diagram, timing incl. memory latency → review.
2. UART byte transmitter + TB (8-bit fixed data, then real baud) — manual's "build progressively".
3. Word/frame FSM (header → 2^N words → footer, ready/start) + TB with memory model.
4. MATLAB: COE generator + decoder + MT tests (in parallel, owner C).
5. Button/reset conditioning + XDC (in parallel, owner B).
6. Demo top level (button/reset conditioning + Block Memory Generator ROM + Lab-DEBUG; **no Lab-CTRL**, TA Q-04); integration TB.
7. Synthesis/implementation; hardware bring-up (terminal, then MATLAB); evidence; demo.
