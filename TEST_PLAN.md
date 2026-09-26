# Test Plan

Test IDs: `TB-<block>-NN` (VHDL simulation) · `MT-<block>-NN` (MATLAB test) · `HW-<block>-NN` (hardware).
Status: PLANNED / PASS / FAIL (with link to evidence).

Only the current stage (Lab-DEBUG; Lab-CTRL is not needed for its demo — TA Q-04) is detailed. Later
stages are added when their manuals are released.

## 1. Lab-DEBUG — simulation

Testbench approach: a **behavioural UART receiver model** (in `fpga/tb/common/`) samples `txd_out`
at mid-bit, reconstructs bytes, checks the start and stop bits, and compares the byte stream against
the expected stream built from the memory model contents. A **memory model** with configurable
read latency (1 or 2 cycles) drives `mem_data_in`.

Simulation parameters: `G_ADDR_WIDTH` = 3 or 4 (8–16 words) and a small baud divider (e.g. 16 clocks/bit)
for speed, except TB-UART-02 which uses the real 100 MHz / 1 000 000 divider (100).

**Results 2026-09-26** (PR #4, commit `d6bdd94`): `tb_uart_tx` → `TB_RESULT: PASS (37/37 checks)`,
`tb_debug` → `TB_RESULT: PASS (97/97 checks)`. Run by Hande in Vivado 2025.2 XSim (GUI) and re-run in
XSim batch mode (AI-0006); the batch logs are in `simulation/results/2026-09-26_tb_*.log`. Actual settings:
`tb_uart_tx` 10 and 100 clocks/bit; `tb_debug` N = 3, 10 clocks/bit, three DUTs (latency generic/memory =
2/2, 1/1, 2/1). Testbench sensitivity (AI-0004, not repeated here): 3 injected bugs in `uart_tx` and 7 in
`debug` were all detected.
**Deviation:** the UART receiver and memory models are written inline in each testbench, not in
`fpga/tb/common/` as planned above; move them there when a second testbench needs them.

| ID | Test | Expected result | Req. | Status |
|---|---|---|---|---|
| TB-UART-01 | Single byte 0x55, 0x00, 0xFF, 0x81 through the UART TX sub-block | Start bit 0, 8 bits LSB first, stop bit 1; line idle high before/after | REQ-DEBUG-008 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_uart_tx.log) |
| TB-UART-02 | Real divider: measure bit period | 100 clocks ± 0 (1.00 µs); frame = 10 bit periods | REQ-DEBUG-009, REQ-PERF-001 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_uart_tx.log) |
| TB-UART-03 | Back-to-back bytes | No glitch between stop bit and next start bit; stop bit ≥ 1 bit period | REQ-DEBUG-008 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_uart_tx.log) |
| TB-DEBUG-01 | Reset: assert `reset_in` | `txd_out` = '1', `ready_out` = '1', FSM idle | REQ-DEBUG-012, REQ-IF-006 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_debug.log) |
| TB-DEBUG-02 | Handshake: 1-cycle `start_in` | `ready_out` is cleared at the edge that samples `start_in` = '1' (low one clock after `start_in` rose), stays low until the last stop bit, then rises | REQ-DEBUG-013/014, REQ-IF-002/003 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_debug.log) |
| TB-DEBUG-03 | Full frame, N small, known memory pattern | Byte stream = 55 AA CC 03, words 0..2^N−1 MSB-byte first, AA 55 03 CC; count = 8 + 4·2^N | REQ-DEBUG-004..007 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_debug.log) |
| TB-DEBUG-04 | Address sequence | `mem_addr_out` visits 0 … 2^N−1 exactly once, in order; no out-of-range address | REQ-DEBUG-003/004 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_debug.log) |
| TB-DEBUG-05 | `start_in` while busy | Ignored; stream unchanged | REQ-IF-007 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_debug.log) |
| TB-DEBUG-06 | Reset during transfer, then new start | Transfer aborts, line idle high, next start produces a complete correct frame | REQ-DEBUG-012 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_debug.log) |
| TB-DEBUG-07 | Memory latency 1 and 2 cycles | Correct data captured for both settings | REQ-DEBUG-019 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_debug.log) |
| TB-DEBUG-08 | Payload containing delimiter values (0x55AACC03, 0xAA5503CC), 0x00000000, 0xFFFFFFFF, walking-ones | Sent unchanged | DEC-010 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_debug.log) |
| TB-DEBUG-09 | Two consecutive transfers | Second frame identical and complete | REQ-DEBUG-001 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_debug.log) |
| TB-TOPDBG-01 | Demo top (`top_debug_demo`: button conditioning + real `debug_rom` IP + `debug`; no CTRL), N = 14, bouncing BTNU press | Exactly one frame of 65 544 bytes; header, all words = COE, footer; 8N1; LD6 off during / on after | REQ-DEBUG-016, REQ-IF-006 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_top_debug_demo.log) |
| TB-TOPDBG-02 | Button held beyond the end of the transfer, released with bounce | No second frame; LD6 stays on | REQ-IF-007, DEC-019 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_top_debug_demo.log) |
| TB-TOPDBG-03 | Second press; release and press again during the transfer | Exactly one more frame (131 088 bytes total), identical content; press during transfer ignored | REQ-DEBUG-001, REQ-IF-007 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_top_debug_demo.log) |
| TB-BTN-01 | `button_conditioner`: clean press; press of exactly D clocks | 1 pulse, 1 clock wide, after 2 + D edges; D-clock press accepted | REQ-IF-002, DEC-019 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_button_conditioner.log) |
| TB-BTN-02 | Press with bounce (glitches < D) | Exactly 1 pulse | REQ-IF-002, DEC-019 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_button_conditioner.log) |
| TB-BTN-03 | Release with bounce; idle glitches of D/2 and D−1 clocks | 0 pulses | DEC-019 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_button_conditioner.log) |
| TB-BTN-04 | Long hold (10 D) | Exactly 1 pulse | REQ-IF-002 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_button_conditioner.log) |
| TB-BTN-05 | Press during reset; still held when reset ends | No pulse in reset; 1 pulse afterwards (top_debug_demo.md §15) | DEC-007 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_button_conditioner.log) |
| SYN-TOPDBG | `fpga/vivado/build_debug_demo.tcl`: synthesis, implementation, bitstream | No errors / critical warnings; WNS ≥ 0, WHS ≥ 0 at 100 MHz; DRC clean | REQ-VER-001 | PASS 2026-09-26 — WNS +5.083 ns, WHS +0.122 ns, DRC 0; [utilization](docs/verification/2026-09-26_top_debug_demo_utilization.rpt), [timing](docs/verification/2026-09-26_top_debug_demo_timing.rpt) |
| TB-ROM-01 | Demo ROM IP `debug_rom`: address change → new word on `douta` | Read latency = 2 clock edges (= `G_MEM_LATENCY` default of `debug`) | REQ-DEBUG-019, ASSUMPTION-011 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_debug_rom.log) |
| TB-ROM-02 | Demo ROM IP: read all 16 384 addresses | Every word equals `fpga/ip/debug_rom.coe` | REQ-DEBUG-016 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_debug_rom.log) |
| TB-ROM-03 | Demo ROM IP: test-pattern addresses 0–5, 16382, 16383 | Expected / Actual printed, all equal | REQ-DEBUG-016, DEC-010 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_tb_debug_rom.log) |

## 2. Lab-DEBUG — MATLAB tests (no hardware)

| ID | Test | Expected | Req. | Status |
|---|---|---|---|---|
| MT-DEBUG-01 | Decode a synthetic byte vector (built in MATLAB) | Words equal the source words | REQ-DEBUG-015 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_mt_debug.log) |
| MT-DEBUG-02 | Synthetic stream with delimiter values inside the payload | Correct decode, no truncation | DEC-010 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_mt_debug.log) |
| MT-DEBUG-03 | Corrupted header / short stream | Clear error message, no silent wrong data | REQ-SW-003 | PASS 2026-09-26 — [log](simulation/results/2026-09-26_mt_debug.log) |
| MT-DEBUG-04 | COE generator writes a file that Vivado accepts and MATLAB reads back identically | Round-trip identical | REQ-DEBUG-016 | PASS 2026-09-26 — MATLAB round trip + format ([log](simulation/results/2026-09-26_mt_debug.log)); Vivado accepts the COE and the ROM holds it exactly (TB-ROM-02, [log](simulation/results/2026-09-26_tb_debug_rom.log)) |

## 3. Lab-DEBUG — hardware tests (Basys-3)

| ID | Procedure | Pass criterion | Req. | Status |
|---|---|---|---|---|
| HW-DEBUG-01 | Bring-up: send a fixed byte repeatedly at low baud, then at 1 000 000; view in a terminal program (hex mode, set to 1 000 000 baud) | Correct byte value on screen | REQ-DEBUG-008..010 | PLANNED |
| HW-DEBUG-02 | Full demo: press START; MATLAB reads 65 544 bytes; compare 16 384 words with the COE file | Header/footer correct; 0 mismatching words | REQ-DEBUG-015..017 | PLANNED |
| HW-DEBUG-03 | Repeat HW-DEBUG-02 ten times; record duration | 10/10 pass; duration ≈ 0.66 s | REQ-PERF-002 | PLANNED |
| HW-DEBUG-04 | Press START once / hold START / press during transfer | Exactly one transfer per press; no corrupted frame | REQ-DEBUG-013, REQ-IF-007 | PLANNED |
| HW-DEBUG-05 | Press RESET during transfer, then START | Clean new frame | REQ-DEBUG-012 | PLANNED |

## 4. Lab-CTRL (Oct 7 lab — not needed for the DEBUG demo; full plan written with the CTRL design)

| ID | Test | Req. | Status |
|---|---|---|---|
| TB-CTRL-01 | Reset state: all `start_*_out` low, `ready_out` high (ASSUMED) | REQ-CTRL-007 | PLANNED |
| TB-CTRL-02 | `start_in` → `start_debug_out` pulse → waits for `ready_debug_in` → `ready_out` high | REQ-CTRL-005 | PLANNED |
| TB-CTRL-03 | 50 % framing: `frame_addr_out` = k·L/2 for k = 0,1,2,… with generic L | REQ-CTRL-002/003 | PLANNED |
| TB-CTRL-04 | Full sequence with stub sub-systems of different latencies | REQ-CTRL-004 | PLANNED |
| TB-CTRL-05 | Every `start_*_out` is exactly one cycle wide | REQ-IF-002 | PLANNED |
| TB-CTRL-06 | Reset in the middle of a sequence | REQ-CTRL-006 | PLANNED |
