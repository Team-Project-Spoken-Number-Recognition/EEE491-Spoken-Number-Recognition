# Interfaces

Rule: any change to an item in this file requires a dependency analysis (who else uses it?) and a
reviewed PR. Changes are logged in `DECISIONS.md`.

## 1. Global conventions

| Item | Value | Status / Source |
|---|---|---|
| System clock | `clock_in`, 100 MHz Basys-3 oscillator | Manual-defined (DBG §1, CTRL §1) |
| Clock domains | One (100 MHz). Slow rates via clock enables | PROPOSED (DEC-006) |
| Reset | `reset_in`, active high, synchronised, synchronous use | Polarity: manual implies active-high "resets"; sync style PROPOSED (DEC-007) |
| Port naming | `<name>_in` / `<name>_out` as in the manuals | Manual convention |
| Handshake | `start` (1-cycle pulse) / `ready` (active high, low while busy) | Manual-defined (CTRL §1) |
| Inter-block data | Each block's output dual-port RAM, read by the next block | Manual-defined (CTRL §1) |
| Numeric library | `ieee.numeric_std` only | TEAM (CONTRIBUTING §6) |

### 1.1 Board I/O (Basys-3) — DEC-018 (reference design) unless noted

| Signal | Board resource | FPGA pin | Source |
|---|---|---|---|
| `clock_in` | 100 MHz oscillator | W5 | Basys-3 / reference XDC |
| `reset_in` | BTNC (centre button) | U18 | TA Q-05 → DEC-018 |
| `start_in` | BTNU (up button) — through sync + debounce + 1-cycle pulse | T18 | TA Q-05 → DEC-018 |
| `txd_out` | FT2232HQ UART RXD | A18 | DBG §1 figure; reference XDC |
| `ready_out` (demo LED) | LD6 | U14 | DEC-018 |

Pins still to be checked against Digilent's official `Basys3_Master.xdc` before the first bitstream.

## 2. start / ready handshake (all sub-systems) — REQ-IF-001..003

```text
clock_in   _|‾|_|‾|_|‾|_|‾|_ ... _|‾|_|‾|_|‾|_
start_in   ___|‾‾‾|_______________________________      one clock cycle, sampled at rising edge
ready_out  ‾‾‾‾‾‾‾|___________________ ... ___|‾‾‾‾‾‾   low just after start; high at the rising
                                                        edge after the operation completes
```

Clarified by the TA (Q-03, 2026-09-26):
- `ready_out` = '1' after reset; '1' = idle/waiting, '0' = working (REQ-IF-006).
- `start_in` only leaves the wait state; pulses while working are ignored (REQ-IF-007).
- "Low just after start": **PROPOSED:** `ready_out` is low from the first rising edge after the edge
  that sampled `start_in` = '1' (i.e. registered, 1-cycle response).

## 3. Lab-DEBUG (manual: DBG §1) — current stage

### 3.1 Ports

| Port | Dir | Width | Description | Source |
|---|---|---|---|---|
| `reset_in` | in | 1 | Resets the FSM registers | DBG §1 |
| `clock_in` | in | 1 | 100 MHz | DBG §1 |
| `mem_addr_out` | out | N | Address to the memory's read-only port; N is a VHDL constant (generic proposed) | DBG §1 |
| `mem_data_in` | in | 32 | Data output of the memory | DBG §1 |
| `txd_out` | out | 1 | UART serial output (idle = '1') | DBG §1; idle level = UART standard |
| `start_in` | in | 1 | 1-cycle active-high pulse: start transfer | DBG §1 |
| `ready_out` | out | 1 | Active high; low during transfer | DBG §1 |

### 3.2 Generics (PROPOSED — not manual-mandated; DEC-012)

| Generic | Default | Purpose |
|---|---|---|
| `N` | 14 | Memory address width → 2^N words. Named literally `N` and declared at the top of the code (TA Q-07, DEC-012) |
| `G_CLK_FREQ_HZ` | 100_000_000 | Clock frequency |
| `G_BAUD_RATE` | 1_000_000 | Baud rate — fixed for the whole project (DEC-005); divider 100 000 000 / 1 000 000 = 100 (exact) |
| `G_MEM_LATENCY` | from IP summary (1 or 2) | Clock cycles from address to valid data (REQ-DEBUG-019) |

Simulation will override `N` and the baud divider to keep run-time short; one test keeps
the real divider (see `TEST_PLAN.md`).

### 3.3 Serial frame (REQ-DEBUG-005..008)

| Field | Bytes on the wire (in order) |
|---|---|
| Start word | `0x55`, `0xAA`, `0xCC`, `0x03` |
| Data word k (k = 0 … 2^N − 1, read from address k) | `W[31:24]`, `W[23:16]`, `W[15:8]`, `W[7:0]` — MSB byte first (**confirmed, TA Q-02**) |
| End word | `0xAA`, `0x55`, `0x03`, `0xCC` |

Byte framing: start bit '0', D0 … D7 (LSB first), stop bit '1'; no parity (8N1).
Total bytes per transfer: `8 + 4 · 2^N` (N = 14 → 65 544 bytes).

Baud divider analysis (100 MHz):

| Baud | Ideal divider | Integer divider | Rate error | Transfer time N=14 |
|---|---|---|---|---|
| 115 200 | 868.06 | 868 | +0.006 % | 5.69 s |
| 230 400 | 434.03 | 434 | +0.006 % | 2.84 s |
| 460 800 | 217.01 | 217 | +0.006 % | 1.42 s |
| 921 600 | 108.51 | 109 | −0.45 % | 0.71 s |
| 1 000 000 | 100 | 100 | 0 % | 0.66 s |

**Selected: 1 000 000 baud** (DEC-005) — exact divider, 0 % error, 0.66 s per N = 14 transfer.

(Transfer time = 10 bits × 65 544 bytes / baud.) Rates above 115 200 require confirmation that the
FT2232HQ, the Windows VCP driver and MATLAB `serialport` all accept them — **UNVERIFIED** (DEC-005).

### 3.4 PC side (MATLAB)

| Item | Value | Status |
|---|---|---|
| Port | FTDI VCP COM port (number differs per PC) | — |
| Settings | baud = FPGA baud, 8 data, no parity, 1 stop, no flow control | PROPOSED |
| Read | exactly `8 + 4·2^N` bytes, with timeout | PROPOSED (REQ-SW-003) |
| Check | first 4 bytes == 55 AA CC 03 and last 4 bytes == AA 55 03 CC | PROPOSED |
| Decode | `w = b1·2^24 + b2·2^16 + b3·2^8 + b4` as `uint32` | REQ-DEBUG-015 |

## 4. Lab-CTRL (manual: CTRL §1)

### 4.1 Ports (exact names from the manual)

| Port | Dir | Width | Description |
|---|---|---|---|
| `reset_in` | in | 1 | Resets all registers |
| `clock_in` | in | 1 | 100 MHz |
| `start_in` | in | 1 | Starts Lab-CTRL (active high) |
| `ready_out` | out | 1 | Lab-CTRL finished (active high, low just after start) |
| `start_adc_out` / `ready_adc_in` | out / in | 1 / 1 | Lab-ADC handshake |
| `frame_addr_out` | out | 14 | Frame start address for Lab-WINDOW |
| `start_window_out` / `ready_window_in` | out / in | 1 / 1 | Lab-WINDOW handshake |
| `start_fft_out` / `ready_fft_in` | out / in | 1 / 1 | Lab-FFT handshake |
| `start_mel_out` / `ready_mel_in` | out / in | 1 / 1 | Lab-MEL handshake |
| `start_dct_out` / `ready_dct_in` | out / in | 1 / 1 | Lab-DCT handshake |
| `start_comp_out` / `ready_comp_in` | out / in | 1 / 1 | Lab-COMPARE handshake |
| `start_debug_out` / `ready_debug_in` | out / in | 1 / 1 | Lab-DEBUG handshake |

### 4.2 Framing parameters (values UNKNOWN until Lab-ADC / Lab-WINDOW manuals are released)

| Parameter | Value | Status |
|---|---|---|
| Frame length L (samples) | UNKNOWN — generic `G_FRAME_LEN` | UNKNOWN |
| Hop size | L/2 (50 % overlap, REQ-CTRL-003) | Manual-defined |
| Number of frames | UNKNOWN — depends on ADC RAM depth and L | UNKNOWN |
| ADC RAM address width | 14 bits implied by `frame_addr_out` | ASSUMED (ASSUMPTION-010) |
| Frame k start address | `k · L/2` | DERIVED |

Unused sub-system handshakes (blocks not yet built) are tied to stub models in the testbench and to a
constant/loop-back in hardware. How stubs behave in hardware demos is an open question.

## 5. Future interfaces (placeholders — do not fill until the manual is released)

| Block | Status |
|---|---|
| Lab-ADC (SPI, sample RAM) | UNKNOWN — manual pending |
| Lab-WINDOW | UNKNOWN — manual pending |
| Lab-FFT (Vivado FFT IP) | UNKNOWN — manual pending |
| Lab-MEL | UNKNOWN — manual pending |
| Lab-DCT | UNKNOWN — manual not received |
| Lab-COMPARE, 7-segment | UNKNOWN — manual not received |

## 6. Fixed-point register

Every numeric signal must be documented here **before** its RTL is written.

| Signal | Signed | Total width | Int bits | Frac bits | Range | Rounding | Overflow | MATLAB ref | Status |
|---|---|---|---|---|---|---|---|---|---|
| `mem_data_in` (DEBUG) | n/a — raw 32-bit container | 32 | — | — | — | — | — | uint32 | Manual-defined |
| `mem_addr_out` (DEBUG) | unsigned | N | N | 0 | 0 … 2^N−1 | — | wraps after last word → FSM stops | — | PROPOSED |
| ADC sample | UNKNOWN | UNKNOWN | | | | | | | UNKNOWN |
| Windowed sample | UNKNOWN | | | | | | | | UNKNOWN |
| FFT real / imag | UNKNOWN | | | | | | | | UNKNOWN |
| MEL energy | UNKNOWN | | | | | | | | UNKNOWN |
| DCT coefficient | UNKNOWN | | | | | | | | UNKNOWN |

Template for each numeric signal entry:

```text
Signal:           FFT_real
Format:           signed Qm.n
Width:            ...
Range:            ...
Expected maximum: ...
Quantisation err: ...
Rounding:         truncate / round-half-up / convergent
Overflow:         wrap / saturate / proven impossible (show analysis)
MATLAB reference: fi(...) / int16 / double model + quantiser
FPGA impl.:       ...
```
