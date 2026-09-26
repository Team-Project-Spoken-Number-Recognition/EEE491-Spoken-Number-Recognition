# Assumptions and Unknowns

Anything not confirmed by a released manual, the syllabus, an official datasheet, or a test result is
listed here. Status: **UNVERIFIED → VERIFIED** (with evidence) or **REJECTED** (with the correct fact).

## 1. Assumptions

### ASSUMPTION-001 — FPGA part number
- **Statement:** The Basys-3 FPGA is the XC7A35T-1CPG236C (Artix-7).
- **Reason:** Digilent's published Basys-3 specification.
- **Source:** General knowledge of Digilent documentation — not yet checked against our board.
- **Status:** UNVERIFIED
- **How to verify:** Vivado Hardware Manager auto-detect on our board; chip marking; Basys-3 Reference Manual.

### ASSUMPTION-002 — Board revision
- **Statement:** Board revision is irrelevant for our pins as long as Digilent's current `Basys3_Master.xdc` is used.
- **Status:** UNVERIFIED · **How to verify:** Read revision on the PCB silkscreen; compare with the XDC revision notes.

### ASSUMPTION-003 — UART TX pin
- **Statement:** FPGA → PC transmit (`txd_out`) is on FPGA pin **A18** (`RsTx` in `Basys3_Master.xdc`); B18 is PC → FPGA.
- **Source:** DBG §1 figure (FT2232 TXD → B18, RXD ← A18).
- **Status:** **VERIFIED (official documentation)** — Digilent `Basys-3-Master.xdc` (digilent-xdc commit `69d3501`): `RsTx` = A18, `RsRx` = B18. Also used by the reference design. Hardware confirmation in HW-DEBUG-01.

### ASSUMPTION-004 — Vivado version
- **Statement:** Team uses Vivado ML Standard **2025.2** (DEC-008, 2026-09-26). Block Memory Generator in 2025.2 is newer than the 8.4 shown in the manual screenshots — check the configuration pages match.
- **Status:** VERIFIED for Hande and Ömer (2025.2 installed); Eren installing · **How to verify:** `Help → About` on each PC.

### ASSUMPTION-005 — MATLAB version and serial API
- **Statement:** MATLAB R2023b (observed on one PC); `serialport` (base MATLAB, R2019b+) is available.
- **Status:** UNVERIFIED · **How to verify:** `ver` on each PC.

### ASSUMPTION-006 — Byte order inside a 32-bit word
- **Statement:** Bytes are sent most-significant first (W[31:24] first).
- **Source:** DERIVED from the DBG §1 header table: start word 55AACC03 is listed as bytes 55, AA, CC, 03 and end word AA5503CC as AA, 55, 03, CC. The manual says "1st 8-bit of first 32-bit data" without defining which byte is "1st".
- **Status:** **VERIFIED** — TA answer Q-02 (2026-09-26): MSB byte first for all words, same as the header.

### ASSUMPTION-007 — `ready_out` after reset
- **Statement:** `ready_out` = '1' after reset (idle = ready).
- **Source:** Waveforms in DBG §1 and CTRL §1 show `ready_out` high before `start_in`.
- **Status:** **VERIFIED** — TA answer Q-03 (2026-09-26) → REQ-IF-006.

### ASSUMPTION-008 — `start_in` while busy
- **Statement:** A `start_in` pulse during an active transfer is ignored.
- **Source:** Not specified in the manuals; defensive design choice.
- **Status:** **VERIFIED** — TA answer Q-03 (2026-09-26) → REQ-IF-007.

### ASSUMPTION-009 — FT2232HQ link works at 1 000 000 baud
- **Statement:** FT2232HQ + Windows VCP driver + MATLAB `serialport` work reliably at 1 000 000 baud (DEC-005). Supporting evidence: the reference design used this rate.
- **Status:** UNVERIFIED · **How to verify:** FT2232H datasheet + AN232B-05; hardware test at each rate.

### ASSUMPTION-010 — ADC sample RAM address width
- **Statement:** Lab-ADC sample RAM is addressed with 14 bits (≤ 16 384 samples), because `frame_addr_out` is 14 bits.
- **Status:** UNVERIFIED — inferred from Lab-CTRL only · **How to verify:** Lab-ADC manual when released.

### ASSUMPTION-011 — Memory read latency of the demo ROM
- **Statement:** Block Memory Generator ROM latency is 1 cycle without, 2 cycles with the primitive output register.
- **Source:** DBG §3 ("usually one or two clock cycles, check the summary tab").
- **Status:** VERIFIED 2026-09-26 for the demo ROM `debug_rom` (primitive output register ON): **2 clock edges**, measured in simulation (TB-ROM-01, `simulation/results/2026-09-26_tb_debug_rom.log`); recorded in `debug.md` §12. Cross-check in the IP *Summary* tab when the IP is opened in the GUI.

### ASSUMPTION-012 — RECORD & NUMBER switches
- **Statement:** They select template-recording mode and the number being recorded for Lab-COMPARE.
- **Source:** Only their appearance in the CTRL §1 block diagram.
- **Status:** UNVERIFIED — **do not design for it** until the COMPARE manual is released. Note: COMPARE (and DCT) will very likely be replaced by NN-based labs (TA Q-11).

### ASSUMPTION-013 — Lab schedule dates
- **Statement:** Lab due dates are the Saturdays listed in the syllabus; they "may be advanced by three days" (to the Wednesday before).
- **Source:** Syllabus Lab Schedule (tentative).
- **Status:** PARTIALLY VERIFIED — TA Q-12 (2026-09-26): the Lab-ADC date is correct. The team was informed (2026-09-25) that there is one lab deadline per week on **Wednesday**, the first being Lab-DEBUG on **Wed Sep 30**. The other Wednesday dates (syllabus date − 3 days) are still to be confirmed per lab.

## 2. Unknown parameters register

| # | Parameter | Needed by stage | Resolved by | Status |
|---|---|---|---|---|
| U-01 | Exact FPGA part / board revision | DEBUG | ASSUMPTION-001/002 | UNVERIFIED |
| U-02 | Team-wide Vivado / MATLAB versions | DEBUG | DEC-008 | RESOLVED — Vivado 2025.2 (DEC-008); MATLAB not pinned |
| U-03 | Byte order in 32-bit word | DEBUG | Q-02 | **RESOLVED** — MSB byte first |
| U-04 | Baud rate | DEBUG | DEC-005 | **RESOLVED** — 1 000 000 baud, fixed for all labs (team decision) |
| U-05 | Block RAM latency of demo ROM | DEBUG | IP summary | UNKNOWN |
| U-06 | Which board input is RESET / START | DEBUG / CTRL | Q-05, DEC-018 | **RESOLVED** — RESET = BTNC (U18), START = BTNU (T18) |
| U-07 | Minimum Lab-CTRL function required in the Lab-DEBUG demo | DEBUG | Q-04 | **RESOLVED** — none; top module drives start/ready |
| U-08 | ADC part, resolution, SPI mode, SCLK limit | ADC | Lab-ADC manual + datasheet | UNKNOWN |
| U-09 | Sampling frequency | ADC | Lab-ADC manual / team decision | UNKNOWN |
| U-10 | Recording length / ADC RAM depth | ADC, CTRL | Lab-ADC manual | UNKNOWN |
| U-11 | Frame length, number of frames | CTRL, WINDOW | Lab-WINDOW manual | UNKNOWN |
| U-12 | Window function | WINDOW | Lab-WINDOW manual | UNKNOWN |
| U-13 | FFT size, scaling, IP configuration | FFT | Lab-FFT manual | UNKNOWN |
| U-14 | Where magnitude/power and log are computed | FFT / MEL / DCT | manuals | UNKNOWN |
| U-15 | Number and spacing of MEL filters | MEL | Lab-MEL manual | UNKNOWN |
| U-16 | Number of DCT coefficients | DCT | Lab-DCT manual (not received) | UNKNOWN — lab likely replaced by NN lab (Q-11, Q-14) |
| U-17 | Classification method, templates, distance metric | COMPARE | Lab-COMPARE manual (not received) | UNKNOWN — lab likely replaced by NN lab (Q-11, Q-14) |
| U-18 | Vocabulary, language, speaker dependence | MATLAB, COMPARE | Q-08 | **PARTLY RESOLVED** — digits 0–9, speaker-dependent OK; language (EN/TR) = team decision pending |
| U-19 | Required recognition rate | Final | Q-09 | **PARTLY RESOLVED** — Lab-MATLAB: 3 × 10 digits → score /30; final demo judged by Enis Hoca |
| U-20 | Microphone type, amplifier gain, filter corner, supply rails | PCB | Lab-PCB manual | UNKNOWN |
| U-21 | PCB manufacturing process and lead time | PCB | Q-10 | **PARTLY RESOLVED** — printed at the school's senior-design (bitirme) lab; details our choice / ask Enis Hoca |
| U-22 | Fixed-point formats of every numeric signal | WINDOW onward | per-stage analysis | UNKNOWN |
| U-23 | 7-segment display format for the result | COMPARE | Lab-COMPARE manual | UNKNOWN |
