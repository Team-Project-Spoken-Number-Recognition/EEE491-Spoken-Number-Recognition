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

| ID | Test | Expected result | Req. | Status |
|---|---|---|---|---|
| TB-UART-01 | Single byte 0x55, 0x00, 0xFF, 0x81 through the UART TX sub-block | Start bit 0, 8 bits LSB first, stop bit 1; line idle high before/after | REQ-DEBUG-008 | PLANNED |
| TB-UART-02 | Real divider: measure bit period | 100 clocks ± 0 (1.00 µs); frame = 10 bit periods | REQ-DEBUG-009, REQ-PERF-001 | PLANNED |
| TB-UART-03 | Back-to-back bytes | No glitch between stop bit and next start bit; stop bit ≥ 1 bit period | REQ-DEBUG-008 | PLANNED |
| TB-DEBUG-01 | Reset: assert `reset_in` | `txd_out` = '1', `ready_out` = '1', FSM idle | REQ-DEBUG-012, REQ-IF-006 | PLANNED |
| TB-DEBUG-02 | Handshake: 1-cycle `start_in` | `ready_out` falls one cycle after start, stays low until the last stop bit, then rises | REQ-DEBUG-013/014, REQ-IF-002/003 | PLANNED |
| TB-DEBUG-03 | Full frame, N small, known memory pattern | Byte stream = 55 AA CC 03, words 0..2^N−1 MSB-byte first, AA 55 03 CC; count = 8 + 4·2^N | REQ-DEBUG-004..007 | PLANNED |
| TB-DEBUG-04 | Address sequence | `mem_addr_out` visits 0 … 2^N−1 exactly once, in order; no out-of-range address | REQ-DEBUG-003/004 | PLANNED |
| TB-DEBUG-05 | `start_in` while busy | Ignored; stream unchanged | REQ-IF-007 | PLANNED |
| TB-DEBUG-06 | Reset during transfer, then new start | Transfer aborts, line idle high, next start produces a complete correct frame | REQ-DEBUG-012 | PLANNED |
| TB-DEBUG-07 | Memory latency 1 and 2 cycles | Correct data captured for both settings | REQ-DEBUG-019 | PLANNED |
| TB-DEBUG-08 | Payload containing delimiter values (0x55AACC03, 0xAA5503CC), 0x00000000, 0xFFFFFFFF, walking-ones | Sent unchanged | DEC-010 | PLANNED |
| TB-DEBUG-09 | Two consecutive transfers | Second frame identical and complete | REQ-DEBUG-001 | PLANNED |
| TB-TOPDBG-01 | Demo top (button conditioning + ROM IP simulation model + DEBUG; no CTRL) with a small COE | Button pulse → one complete frame; ROM content matches COE | REQ-DEBUG-016 | PLANNED |

## 2. Lab-DEBUG — MATLAB tests (no hardware)

| ID | Test | Expected | Req. | Status |
|---|---|---|---|---|
| MT-DEBUG-01 | Decode a synthetic byte vector (built in MATLAB) | Words equal the source words | REQ-DEBUG-015 | PLANNED |
| MT-DEBUG-02 | Synthetic stream with delimiter values inside the payload | Correct decode, no truncation | DEC-010 | PLANNED |
| MT-DEBUG-03 | Corrupted header / short stream | Clear error message, no silent wrong data | REQ-SW-003 | PLANNED |
| MT-DEBUG-04 | COE generator writes a file that Vivado accepts and MATLAB reads back identically | Round-trip identical | REQ-DEBUG-016 | PLANNED |

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
