# Requirements

Scope rule: requirements are extracted **only** from released sources — the syllabus
(`docs/syllabus/`) and released manuals (`docs/manuals/`). Requirements for later stages will be
added when their manuals are released (see `docs/manuals/README.md`). Derived/assumed items are
marked as such and never presented as official.

## 0. Conventions

**ID format:** `REQ-<AREA>-<NNN>`
Areas: `SYS` system · `IF` cross-subsystem interface · `DEBUG` · `CTRL` · `FPGA` platform ·
`HW` hardware · `SW` PC/MATLAB software · `VER` verification · `DOC` documentation · `PROC` process.
Future (reserved, empty until manual release): `ADC`, `WIN`, `PCB`, `MAT`, `FFT`, `MEL`, `DCT`, `COMP`.

**Source codes:**
`SYL` = syllabus 2026-fall · `DBG §n` = Lab-DEBUG manual section n · `CTRL §n` = Lab-CTRL manual section n ·
`DERIVED` = engineering derivation from a cited source (must be confirmed) · `TEAM` = team decision ·
`TA Q-nn` = lab-assistant answer recorded in `docs/meetings/INSTRUCTOR_QUESTIONS.md`.

**Verification methods:** `I` inspection/review · `A` analysis · `S` simulation (testbench) ·
`H` hardware test · `D` lab demonstration.

**Status values:** `OPEN` (not started) · `IN PROGRESS` · `IMPLEMENTED — NOT VERIFIED` · `VERIFIED` · `DEFERRED`.

**Owner:** the Lab Lead/Partner of the stage per `TEAM_MANUAL.md` §3.1 (Eren, Ömer, Hande); ALL = whole team.

Traceability to files/tests/commits: [docs/requirements/TRACEABILITY_MATRIX.md](docs/requirements/TRACEABILITY_MATRIX.md).

---

## 1. Functional Requirements

### 1.1 System level (syllabus — high-level only)

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-SYS-001 | The system shall recognise a spoken number and display it on the Basys-3 7-segment display. | Project goal | SYL (Brief description; Lab-COMPARE) | D | OPEN | ALL |
| REQ-SYS-002 | The processing chain shall follow the lab sub-systems ADC → WINDOW → FFT → MEL → DCT → COMPARE, each implemented on the FPGA. **Note:** DCT and COMPARE will very likely be replaced by NN-based labs (TA Q-11; to be confirmed by Enis Hoca, Q-14). | Course architecture; final-demo grading per sub-system | SYL (Lab Assignments table; final-demo points); TA Q-11 | I, D | OPEN | ALL |
| REQ-SYS-003 | An analog microphone amplifier with anti-aliasing filter shall be implemented on a PCB (not breadboard). | Breadboard degrades grade (x0.2; final-demo PCB 20 pts vs 5) | SYL (Lab-PCB; Degrading factors) | D | OPEN | Eren, Ömer |
| REQ-SYS-004 | A complete MATLAB model of the recognition system shall run on a PC using the PC microphone and display the spoken number on the PC. | Lab-MATLAB; golden reference | SYL (Lab-MATLAB) | D | OPEN | Ömer, Hande |
| REQ-SYS-005 | Any deviation from the standard recognition algorithm shall be approved by the lecturer before implementation, with lab-style assignments and sub-system specifications. | Syllabus rule | SYL (note under Lab Assignments) | I | OPEN | ALL |
| REQ-SYS-006 | The system shall recognise the ten digits **0–9**. The spoken language is the team's choice (English or Turkish); speaker-dependent recognition is acceptable. | Scope of recognition | TA Q-08 (2026-09-26) | D | OPEN | ALL |

Detailed functional requirements for ADC/WINDOW/PCB/MATLAB/FFT/MEL/DCT/COMPARE: **deferred until the
corresponding manual is released.**

### 1.2 Lab-DEBUG — UART debugger (manual: `docs/manuals/Lab-DEBUG_Assignment.pdf`)

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-DEBUG-001 | A debugger shall be implemented on the Basys-3 FPGA that transmits multiple 32-bit data words to a MATLAB program on a PC via the USB connection. | Primary debug path of the whole project | DBG §1 ¶1 | S, H, D | IMPLEMENTED — NOT VERIFIED (sim + HW PASS: HW-DEBUG-02…05 PASS 2026-09-26 ([report](docs/verification/2026-09-26_HW-DEBUG.md)); lab demonstration open) | Hande |
| REQ-DEBUG-002 | The debugger shall implement only the **transmitter** part of a UART. | Scope limit | DBG §1 ¶1 | I | VERIFIED (I: `debug.vhd` / `uart_tx.vhd` have no receive path — reviewed in PR #4) | Hande |
| REQ-DEBUG-003 | The debugger shall read data through the **read-only port** of a memory inside the FPGA. | Decouples debugger from producer | DBG §1 ¶2 | I, S | IMPLEMENTED — NOT VERIFIED (sim PASS: TB-DEBUG-04, 2026-09-26; inspection = PR #4 review) | Hande |
| REQ-DEBUG-004 | The memory address width **N** shall be defined once as a number at the beginning of the VHDL code and used everywhere instead of hard-coded widths; the debugger shall transmit **2^N** 32-bit words per transfer. Changing N alone shall change the memory size handled. | Reusable for any RAM size | DBG §1 ¶2; TA Q-07 | I, S | IMPLEMENTED — NOT VERIFIED (sim PASS: TB-DEBUG-03/04 with N = 3, 2026-09-26; inspection = PR #4 review) | Hande |
| REQ-DEBUG-005 | Before the data, the debugger shall transmit the 32-bit start word **0x55AACC03**. | Frame delimiter | DBG §1 ¶3 | S, H | VERIFIED (sim TB-DEBUG-03; HW: HW-DEBUG-02…05 PASS 2026-09-26 ([report](docs/verification/2026-09-26_HW-DEBUG.md))) | Hande |
| REQ-DEBUG-006 | After the 2^N data words, the debugger shall transmit the 32-bit end word **0xAA5503CC**. | Frame delimiter | DBG §1 ¶3 | S, H | VERIFIED (sim TB-DEBUG-03; HW: HW-DEBUG-02…05 PASS 2026-09-26 ([report](docs/verification/2026-09-26_HW-DEBUG.md))) | Hande |
| REQ-DEBUG-007 | Each 32-bit word shall be sent as four 8-bit UART transactions, **most-significant byte first** — for header, data and end words alike. | Frame format; single concatenation rule on the PC | DBG §1 ¶3 table; **TA Q-02 confirmed** | S, H | VERIFIED (sim TB-DEBUG-03; HW: HW-DEBUG-02…05 PASS 2026-09-26 ([report](docs/verification/2026-09-26_HW-DEBUG.md))) | Hande |
| REQ-DEBUG-008 | The UART frame shall be 1 start bit, 8 data bits **LSB first**, no parity, 1 stop bit (8N1). | UART compatibility with FT2232HQ/PC | DBG §3 (baud-rate guidance example) | S, H | VERIFIED (sim TB-UART-01/03; HW: 8N1 frames decoded at the PC, HW-DEBUG-02…05 PASS 2026-09-26 ([report](docs/verification/2026-09-26_HW-DEBUG.md))) | Hande |
| REQ-DEBUG-009 | The baud rate shall be **1 000 000** (1 Mbaud) and stay fixed for all later labs; it satisfies the manual minimum of 115 200. | One rate used throughout the project; same as the reference design | DBG §1 ¶5, §3; team decision 2026-09-26 (DEC-005); DEC-018 | A, S, H | VERIFIED (A: INTERFACES §3.3; sim TB-UART-02 = 100 clocks/bit; HW: 1 000 000 baud link, HW-DEBUG-02…05 PASS 2026-09-26 ([report](docs/verification/2026-09-26_HW-DEBUG.md))) | Hande |
| REQ-DEBUG-010 | The UART shall interface with the on-board FT2232HQ USB-UART bridge (FPGA TX → FT2232 RXD). | Board wiring | DBG §1 ¶5 figure | I, H | VERIFIED (I: A18 vs. official XDC, PR #7; HW: HW-DEBUG-02…05 PASS 2026-09-26 ([report](docs/verification/2026-09-26_HW-DEBUG.md))) | Eren |
| REQ-DEBUG-011 | Ports: `reset_in`, `clock_in` (100 MHz), `mem_addr_out` (N-bit), `mem_data_in` (32-bit), `txd_out`, `start_in`, `ready_out` — names exactly as in the manual. | Grading/interface consistency | DBG §1 ¶6 | I | VERIFIED (I: `debug` entity ports equal the manual names — PR #4 review, top_debug_demo.md §2–3) | Hande |
| REQ-DEBUG-012 | `reset_in` shall reset the FSM registers. | Defined start-up | DBG §1 ¶6 | S | VERIFIED (sim TB-DEBUG-01/06; HW-DEBUG-05 reset during transfer + clean restart PASS 2026-09-26) | Hande |
| REQ-DEBUG-013 | `start_in` is active high, asserted for a **single clock cycle**; it only takes the debugger out of its wait state and starts a transfer (see REQ-IF-007). | Common handshake | DBG §1 ¶6 + waveform; TA Q-03 | S | VERIFIED (sim TB-DEBUG-02/05; HW-DEBUG-04a/b PASS 2026-09-26) | Hande |
| REQ-DEBUG-014 | `ready_out` is active high; it shall be '1' after reset, go **low just after** `start_in` is asserted and return high when all data has been transferred (see REQ-IF-006). | Common handshake | DBG §1 ¶6 + waveform; TA Q-03 | S | VERIFIED (sim: TB-DEBUG-01/02, 2026-09-26) | Hande |
| REQ-DEBUG-015 | On the PC, MATLAB shall extract the bytes between start and end word and concatenate every four bytes into one 32-bit integer. | PC-side decoding | DBG §1 ¶4 | S (MATLAB test), H | VERIFIED (MATLAB tests MT-DEBUG-01/02; HW: HW-DEBUG-02…05 PASS 2026-09-26 ([report](docs/verification/2026-09-26_HW-DEBUG.md))) | Ömer |
| REQ-DEBUG-016 | Demo design: Lab-DEBUG instantiated in a **top module** that drives `start_in` and observes `ready_out` (Lab-CTRL **not required** — TA Q-04), connected to a ROM from Vivado *Block Memory Generator* (Single-Port ROM, 14-bit address, 32-bit data, initialised from a COE file); N = 14. | Demo requirement | DBG §2 bullet 3, relaxed by TA Q-04 | I, D | IMPLEMENTED — NOT VERIFIED (top level + ROM IP: sim PASS TB-TOPDBG-01…03 and TB-ROM-01…03, bitstream built 2026-09-26; demonstration open) | Eren, Ömer |
| REQ-DEBUG-017 | The design shall be implemented on the FPGA and the ROM content transferred to MATLAB and verified there. | Demo requirement | DBG §2 bullets 1, 4 | H, D | IMPLEMENTED — NOT VERIFIED (HW PASS: HW-DEBUG-02…05 PASS 2026-09-26 ([report](docs/verification/2026-09-26_HW-DEBUG.md)); lab demonstration open) | Hande, Ömer |
| REQ-DEBUG-018 | The debugger shall be integrable with any sub-system to transfer that sub-system's RAM data to MATLAB. | Reuse in all later labs | DBG §1 ¶7, ¶4 | I (at each later stage) | OPEN | Hande |
| REQ-DEBUG-019 | The design shall account for the memory read latency (typically 1–2 clock cycles for Block RAM). | Correct data capture | DBG §3 (ROM guidance) | S | VERIFIED (sim: TB-DEBUG-07, L = 1 and 2, 2026-09-26; real ROM latency still to read from the IP summary, ASSUMPTION-011) | Hande |
| REQ-DEBUG-020 | Words narrower than 32 bits may be zero-padded in the unused MSBs. | Convention for later sub-systems | DBG §3 | I | OPEN | Hande |

### 1.3 Lab-CTRL — system controller (manual: `docs/manuals/Lab-CTRL_Assignment.pdf`)

Released together with Lab-DEBUG because the Lab-DEBUG demo requires Lab-CTRL (DEC-003).

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-CTRL-001 | Lab-CTRL shall control the data flow between sub-systems using each sub-system's `start` and `ready` signals. | Central sequencing | CTRL §1 ¶2 | S | OPEN | Eren |
| REQ-CTRL-002 | Lab-CTRL shall divide the speech signal stored in the Lab-ADC dual-port RAM into frames by generating the **frame start address** for Lab-WINDOW. | Framing | CTRL §1 ¶3 | S | OPEN | Eren |
| REQ-CTRL-003 | Consecutive frames shall overlap by **50 %**. | Framing | CTRL §1 ¶3 | S | OPEN | Eren |
| REQ-CTRL-004 | For each frame, Lab-CTRL shall send `start` to each sub-system and observe its `ready`. | Sequencing | CTRL §1 ¶3 | S | OPEN | Eren |
| REQ-CTRL-005 | Lab-CTRL shall control Lab-DEBUG when it is attached to any sub-system's output. | Debug integration | CTRL §1 ¶3; CTRL §3 | S, D | OPEN | Eren |
| REQ-CTRL-006 | The Basys-3 RESET input (**BTNC**, U18) shall drive the reset of every sub-system; the START input (**BTNU**, T18) shall start Lab-CTRL, which starts the overall system. | Operator control | CTRL §1 ¶4; input choice free (TA Q-05) → DEC-018 | H | OPEN | Eren |
| REQ-CTRL-007 | Ports: `reset_in`, `clock_in` (100 MHz), `start_adc_out`, `ready_adc_in`, `frame_addr_out` (14-bit), `start_window_out`, `ready_window_in`, `start_fft_out`, `ready_fft_in`, `start_mel_out`, `ready_mel_in`, `start_dct_out`, `ready_dct_in`, `start_comp_out`, `ready_comp_in`, `start_debug_out`, `ready_debug_in`, `start_in`, `ready_out`. | Interface definition | CTRL §1 IO list | I | OPEN | Eren |
| REQ-CTRL-008 | A VHDL testbench shall show the 50 % framing (frame addressing) and the sequence of operations clearly on the waveforms. | Demo requirement | CTRL §1, §2 | S, D | OPEN | Eren |
| REQ-CTRL-009 | On the board, `start_in` shall be driven by a push-button and LEDs shall show the `ready` signals of the sub-systems. | Observability | CTRL §3 | H, D | OPEN | Eren |
| REQ-CTRL-010 | Versions of Lab-CTRL shall be kept as it is modified during integration. | Traceability | CTRL §3 | I (git tags) | OPEN | Eren |

## 2. Interface Requirements (cross-subsystem)

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-IF-001 | Every sub-system shall have a `start` input and a `ready` output. | Uniform control | CTRL §1 ¶5 | I, S | OPEN | ALL |
| REQ-IF-002 | `start` shall be logic-1 at a rising clock edge as a single pulse of one clock-cycle duration. | Uniform control | CTRL §1 ¶5 + waveform | S | IN PROGRESS (Lab-DEBUG: sim PASS TB-DEBUG-02; demo top level: start pulse from `button_conditioner`, TB-BTN-01…05 PASS 2026-09-26; other sub-systems open) | ALL |
| REQ-IF-003 | `ready` shall be active high, go low just after `start` is asserted, and become active at the rising edge after the sub-system completes its operation. | Uniform control | CTRL §1 ¶5 + waveform | S | IN PROGRESS (Lab-DEBUG: sim PASS TB-DEBUG-02, 2026-09-26; other sub-systems open) | ALL |
| REQ-IF-004 | Each sub-system shall hold its processed data in an internal dual-port RAM that is read by the following sub-system. | Data hand-over | CTRL §1 ¶2 | I, S | OPEN | ALL |
| REQ-IF-005 | All sub-systems use the 100 MHz Basys-3 oscillator as `clock_in`. | Single clock domain | DBG §1, CTRL §1 IO lists | I | OPEN | ALL |
| REQ-IF-006 | Every sub-system's `ready` shall be '1' after reset: '1' = idle/waiting, '0' = working. | Uniform control | TA Q-03 (2026-09-26) | S | IN PROGRESS (Lab-DEBUG: sim PASS TB-DEBUG-01, 2026-09-26; other sub-systems open) | ALL |
| REQ-IF-007 | A `start` pulse arriving while a sub-system is working shall not change its operation; `start` only takes the block out of its wait state. | Robust sequencing | TA Q-03 (2026-09-26) | S | IN PROGRESS (Lab-DEBUG: sim PASS TB-DEBUG-05, 2026-09-26; other sub-systems open) | ALL |

## 3. Performance Requirements

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-PERF-001 | UART bit period error relative to the nominal baud rate shall be < 2 % (target < 0.5 %). | Reliable 8N1 reception | DERIVED (standard UART tolerance) — TO CONFIRM | A, S | VERIFIED (A: INTERFACES §3.3, divider exact; sim: TB-UART-02, 0 % error, 2026-09-26) | Hande |
| REQ-PERF-002 | A full N = 14 transfer (65 544 bytes) shall complete without byte loss. At 1 000 000 baud (8N1) this takes ≈ 0.66 s. | Demo robustness | DERIVED from DBG §1, §2 | H | VERIFIED (HW-DEBUG-03: 10/10 transfers without byte loss, PC-measured 0.62–0.67 s; design value 0.657 s) | Hande |
| REQ-PERF-003 | Lab-MATLAB: each digit is spoken 3 times; the score is the number recognised out of **30** (trials may be repeated). Final-demo recognition performance (10 pts) is judged by Enis Hoca; no numeric target given. | Grading | SYL (final-demo table); TA Q-09 | D | OPEN | ALL |

## 4. Hardware Requirements

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-HW-001 | Target board: Digilent Basys-3 (Artix-7 FPGA), one board per group. | Course platform | SYL (Required materials) | I | OPEN | ALL |
| REQ-HW-002 | FPGA pin assignment shall come from Digilent's `Basys3_Master.xdc`, with port names renamed to the top-level names. | Correct pinning | DBG §3 | I, H | VERIFIED (I: XDC derived from the official Basys3_Master.xdc, PR #7; HW: board works with it, HW-DEBUG-02…05) | Eren |
| REQ-HW-003 | The FTDI Virtual COM Port driver shall be installed on each PC used for demos. | USB-UART link | DBG §3 | H | IN PROGRESS (FTDI VCP driver works on Eren's PC, 2026-09-26; lab/demo PC still to check) | ALL |

## 5. Software Requirements (PC side)

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-SW-001 | A MATLAB script shall receive the UART data from the USB port. | PC receiver | DBG §3 | H | VERIFIED (HW: `receive_debug_frame` / `run_debug_demo` at 1 Mbaud, HW-DEBUG-02…05 PASS 2026-09-26 ([report](docs/verification/2026-09-26_HW-DEBUG.md))) | Ömer |
| REQ-SW-002 | A terminal program shall be used during bring-up to observe raw bytes. | Incremental bring-up | DBG §3 | H | OPEN | Ömer |
| REQ-SW-003 | The MATLAB receiver shall read a fixed number of bytes (8 + 4·2^N) and use the start/end words as **validation**, not as the only delimiter (payload may contain the delimiter values). | Robust parsing | DERIVED — design choice, see DEC-010 | S (MATLAB test), H | VERIFIED (MATLAB MT-DEBUG-02/03; HW: misaligned stream rejected with 'Start word is 2FCFD030' and truncated frame detected, 2026-09-26_HW-DEBUG.md §3) | Ömer |

## 6. Verification Requirements

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-VER-001 | Every designed VHDL block shall have a VHDL testbench; simulation results shall verify the technical specifications. | "No Simulation: x0.0" grading factor | SYL (Degrading factors); DBG §1, §3; CTRL §1 | I | OPEN | ALL |
| REQ-VER-002 | Lab-DEBUG waveforms shall show start, ready, UART transmit signal and transactions clearly. | Demo | DBG §2 | D | OPEN | Hande |
| REQ-VER-003 | Testbenches shall be self-checking (Expected / Actual / PASS-FAIL report). | Objective evidence | TEAM (DEC-011) | I | OPEN | ALL |
| REQ-VER-004 | Every simulation/hardware result used as evidence shall be stored in the repository (`docs/verification/`, `simulation/results/`). | Final report | TEAM | I | OPEN | ALL |

## 7. Documentation Requirements

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-DOC-001 | The group shall report its GenAI usage: initial problem definitions, every prompt/data input/clarification, the full unedited chat history, correction logs, all raw code outputs, and all tools/models used. | Syllabus GenAI policy | SYL (GenAI policy 2–5) | I | IN PROGRESS | ALL |
| REQ-DOC-002 | The GenAI report shall be presented in class, each member presenting a portion. | Syllabus | SYL (GenAI policy 6) | D | OPEN | ALL |
| REQ-DOC-003 | Design and verification results shall be described in project report documents during development. | Syllabus objective | SYL (Objectives) | I | OPEN | ALL |

## 8. Project / Process Requirements

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-PROC-001 | Lab demonstrations shall be made on the scheduled dates (late factors 0.9 / 0.7 / 0.5 / 0.4 / 0.0 per week). | Grading | SYL (Late demonstration factors) | I | OPEN | ALL |
| REQ-PROC-002 | The team shall apply V-model, requirements management, verification and validation. | Syllabus practice | SYL (Practices) | I | IN PROGRESS | ALL |
| REQ-PROC-003 | All members are collectively responsible for technical accuracy and for the synthesizability/function of AI-generated code; every member must understand every block (exam questions). | Syllabus | SYL (GenAI policy 7–8) | I | OPEN | ALL |
| REQ-PROC-004 | Development uses feature branches and reviewed pull requests; `main` is always buildable. | 3-person team | TEAM (DEC-004) | I | OPEN | ALL |
| REQ-PROC-005 | Lab-MATLAB functions may be used in the final demo only if Lab-MATLAB was demonstrated and checked by the assistant. | Grading | SYL (note under final-demo table) | I | OPEN | Ömer |
