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
`DERIVED` = engineering derivation from a cited source (must be confirmed) · `TEAM` = team decision.

**Verification methods:** `I` inspection/review · `A` analysis · `S` simulation (testbench) ·
`H` hardware test · `D` lab demonstration.

**Status values:** `OPEN` (not started) · `IN PROGRESS` · `IMPLEMENTED — NOT VERIFIED` · `VERIFIED` · `DEFERRED`.

**Owner:** A / B / C placeholders until names are assigned (see `CONTRIBUTING.md` §3).

Traceability to files/tests/commits: [docs/requirements/TRACEABILITY_MATRIX.md](docs/requirements/TRACEABILITY_MATRIX.md).

---

## 1. Functional Requirements

### 1.1 System level (syllabus — high-level only)

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-SYS-001 | The system shall recognise a spoken number and display it on the Basys-3 7-segment display. | Project goal | SYL (Brief description; Lab-COMPARE) | D | OPEN | ALL |
| REQ-SYS-002 | The processing chain shall follow the lab sub-systems ADC → WINDOW → FFT → MEL → DCT → COMPARE, each implemented on the FPGA. | Course architecture; final-demo grading per sub-system | SYL (Lab Assignments table; final-demo points) | I, D | OPEN | ALL |
| REQ-SYS-003 | An analog microphone amplifier with anti-aliasing filter shall be implemented on a PCB (not breadboard). | Breadboard degrades grade (x0.2; final-demo PCB 20 pts vs 5) | SYL (Lab-PCB; Degrading factors) | D | OPEN | B |
| REQ-SYS-004 | A complete MATLAB model of the recognition system shall run on a PC using the PC microphone and display the spoken number on the PC. | Lab-MATLAB; golden reference | SYL (Lab-MATLAB) | D | OPEN | C |
| REQ-SYS-005 | Any deviation from the standard recognition algorithm shall be approved by the lecturer before implementation, with lab-style assignments and sub-system specifications. | Syllabus rule | SYL (note under Lab Assignments) | I | OPEN | ALL |

Detailed functional requirements for ADC/WINDOW/PCB/MATLAB/FFT/MEL/DCT/COMPARE: **deferred until the
corresponding manual is released.**

### 1.2 Lab-DEBUG — UART debugger (manual: `docs/manuals/Lab-DEBUG_Assignment.pdf`)

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-DEBUG-001 | A debugger shall be implemented on the Basys-3 FPGA that transmits multiple 32-bit data words to a MATLAB program on a PC via the USB connection. | Primary debug path of the whole project | DBG §1 ¶1 | S, H, D | OPEN | A |
| REQ-DEBUG-002 | The debugger shall implement only the **transmitter** part of a UART. | Scope limit | DBG §1 ¶1 | I | OPEN | A |
| REQ-DEBUG-003 | The debugger shall read data through the **read-only port** of a memory inside the FPGA. | Decouples debugger from producer | DBG §1 ¶2 | I, S | OPEN | A |
| REQ-DEBUG-004 | The memory address width **N** shall be a constant in the VHDL code; the debugger shall transmit **2^N** 32-bit words per transfer. | Reusable for any RAM size | DBG §1 ¶2 | I, S | OPEN | A |
| REQ-DEBUG-005 | Before the data, the debugger shall transmit the 32-bit start word **0x55AACC03**. | Frame delimiter | DBG §1 ¶3 | S, H | OPEN | A |
| REQ-DEBUG-006 | After the 2^N data words, the debugger shall transmit the 32-bit end word **0xAA5503CC**. | Frame delimiter | DBG §1 ¶3 | S, H | OPEN | A |
| REQ-DEBUG-007 | Each 32-bit word shall be sent as four 8-bit UART transactions. Byte order: **most-significant byte first** (DERIVED from the header table: start word 55AACC03 is sent as 55, AA, CC, 03). | Frame format | DBG §1 ¶3 table; DERIVED — see ASSUMPTION-006 | S, H | OPEN | A |
| REQ-DEBUG-008 | The UART frame shall be 1 start bit, 8 data bits **LSB first**, no parity, 1 stop bit (8N1). | UART compatibility with FT2232HQ/PC | DBG §3 (baud-rate guidance example) | S, H | OPEN | A |
| REQ-DEBUG-009 | The baud rate shall be **at least 115200**, if supported by the FT2232HQ. | Transfer time | DBG §1 ¶5, §3 | A, S, H | OPEN | A |
| REQ-DEBUG-010 | The UART shall interface with the on-board FT2232HQ USB-UART bridge (FPGA TX → FT2232 RXD). | Board wiring | DBG §1 ¶5 figure | I, H | OPEN | A |
| REQ-DEBUG-011 | Ports: `reset_in`, `clock_in` (100 MHz), `mem_addr_out` (N-bit), `mem_data_in` (32-bit), `txd_out`, `start_in`, `ready_out` — names exactly as in the manual. | Grading/interface consistency | DBG §1 ¶6 | I | OPEN | A |
| REQ-DEBUG-012 | `reset_in` shall reset the FSM registers. | Defined start-up | DBG §1 ¶6 | S | OPEN | A |
| REQ-DEBUG-013 | `start_in` is active high, asserted for a **single clock cycle**; it starts a transfer from memory to MATLAB. | Common handshake | DBG §1 ¶6 + waveform | S | OPEN | A |
| REQ-DEBUG-014 | `ready_out` is active high; it shall go **low just after** `start_in` is asserted and return high when all data has been transferred. | Common handshake | DBG §1 ¶6 + waveform | S | OPEN | A |
| REQ-DEBUG-015 | On the PC, MATLAB shall extract the bytes between start and end word and concatenate every four bytes into one 32-bit integer. | PC-side decoding | DBG §1 ¶4 | S (MATLAB test), H | OPEN | C |
| REQ-DEBUG-016 | Demo design: Lab-DEBUG integrated with Lab-CTRL and a ROM from Vivado *Block Memory Generator* (Single-Port ROM, 14-bit address, 32-bit data, initialised from a COE file); N = 14. | Demo requirement | DBG §2 bullet 3 | I, D | OPEN | A |
| REQ-DEBUG-017 | The design shall be implemented on the FPGA and the ROM content transferred to MATLAB and verified there. | Demo requirement | DBG §2 bullets 1, 4 | H, D | OPEN | A, C |
| REQ-DEBUG-018 | The debugger shall be integrable with any sub-system to transfer that sub-system's RAM data to MATLAB. | Reuse in all later labs | DBG §1 ¶7, ¶4 | I (at each later stage) | OPEN | A |
| REQ-DEBUG-019 | The design shall account for the memory read latency (typically 1–2 clock cycles for Block RAM). | Correct data capture | DBG §3 (ROM guidance) | S | OPEN | A |
| REQ-DEBUG-020 | Words narrower than 32 bits may be zero-padded in the unused MSBs. | Convention for later sub-systems | DBG §3 | I | OPEN | A |

### 1.3 Lab-CTRL — system controller (manual: `docs/manuals/Lab-CTRL_Assignment.pdf`)

Released together with Lab-DEBUG because the Lab-DEBUG demo requires Lab-CTRL (DEC-003).

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-CTRL-001 | Lab-CTRL shall control the data flow between sub-systems using each sub-system's `start` and `ready` signals. | Central sequencing | CTRL §1 ¶2 | S | OPEN | C |
| REQ-CTRL-002 | Lab-CTRL shall divide the speech signal stored in the Lab-ADC dual-port RAM into frames by generating the **frame start address** for Lab-WINDOW. | Framing | CTRL §1 ¶3 | S | OPEN | C |
| REQ-CTRL-003 | Consecutive frames shall overlap by **50 %**. | Framing | CTRL §1 ¶3 | S | OPEN | C |
| REQ-CTRL-004 | For each frame, Lab-CTRL shall send `start` to each sub-system and observe its `ready`. | Sequencing | CTRL §1 ¶3 | S | OPEN | C |
| REQ-CTRL-005 | Lab-CTRL shall control Lab-DEBUG when it is attached to any sub-system's output. | Debug integration | CTRL §1 ¶3; CTRL §3 | S, D | OPEN | C |
| REQ-CTRL-006 | The Basys-3 RESET input shall drive the reset of every sub-system; the START input shall start Lab-CTRL, which starts the overall system. | Operator control | CTRL §1 ¶4 | H | OPEN | C |
| REQ-CTRL-007 | Ports: `reset_in`, `clock_in` (100 MHz), `start_adc_out`, `ready_adc_in`, `frame_addr_out` (14-bit), `start_window_out`, `ready_window_in`, `start_fft_out`, `ready_fft_in`, `start_mel_out`, `ready_mel_in`, `start_dct_out`, `ready_dct_in`, `start_comp_out`, `ready_comp_in`, `start_debug_out`, `ready_debug_in`, `start_in`, `ready_out`. | Interface definition | CTRL §1 IO list | I | OPEN | C |
| REQ-CTRL-008 | A VHDL testbench shall show the 50 % framing (frame addressing) and the sequence of operations clearly on the waveforms. | Demo requirement | CTRL §1, §2 | S, D | OPEN | C |
| REQ-CTRL-009 | On the board, `start_in` shall be driven by a push-button and LEDs shall show the `ready` signals of the sub-systems. | Observability | CTRL §3 | H, D | OPEN | C |
| REQ-CTRL-010 | Versions of Lab-CTRL shall be kept as it is modified during integration. | Traceability | CTRL §3 | I (git tags) | OPEN | C |

## 2. Interface Requirements (cross-subsystem)

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-IF-001 | Every sub-system shall have a `start` input and a `ready` output. | Uniform control | CTRL §1 ¶5 | I, S | OPEN | ALL |
| REQ-IF-002 | `start` shall be logic-1 at a rising clock edge as a single pulse of one clock-cycle duration. | Uniform control | CTRL §1 ¶5 + waveform | S | OPEN | ALL |
| REQ-IF-003 | `ready` shall be active high, go low just after `start` is asserted, and become active at the rising edge after the sub-system completes its operation. | Uniform control | CTRL §1 ¶5 + waveform | S | OPEN | ALL |
| REQ-IF-004 | Each sub-system shall hold its processed data in an internal dual-port RAM that is read by the following sub-system. | Data hand-over | CTRL §1 ¶2 | I, S | OPEN | ALL |
| REQ-IF-005 | All sub-systems use the 100 MHz Basys-3 oscillator as `clock_in`. | Single clock domain | DBG §1, CTRL §1 IO lists | I | OPEN | ALL |

## 3. Performance Requirements

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-PERF-001 | UART bit period error relative to the nominal baud rate shall be < 2 % (target < 0.5 %). | Reliable 8N1 reception | DERIVED (standard UART tolerance) — TO CONFIRM | A, S | OPEN | A |
| REQ-PERF-002 | A full N = 14 transfer (65 544 bytes) shall complete without byte loss. At 115200 baud (8N1) this takes ≈ 5.69 s. | Demo robustness | DERIVED from DBG §1, §2 | H | OPEN | A |
| REQ-PERF-003 | Recognition performance is graded in the final demo; the target recognition rate is **UNKNOWN** (to be asked). | Grading | SYL (final-demo table) | D | OPEN | ALL |

## 4. Hardware Requirements

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-HW-001 | Target board: Digilent Basys-3 (Artix-7 FPGA), one board per group. | Course platform | SYL (Required materials) | I | OPEN | ALL |
| REQ-HW-002 | FPGA pin assignment shall come from Digilent's `Basys3_Master.xdc`, with port names renamed to the top-level names. | Correct pinning | DBG §3 | I, H | OPEN | A |
| REQ-HW-003 | The FTDI Virtual COM Port driver shall be installed on each PC used for demos. | USB-UART link | DBG §3 | H | OPEN | ALL |

## 5. Software Requirements (PC side)

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-SW-001 | A MATLAB script shall receive the UART data from the USB port. | PC receiver | DBG §3 | H | OPEN | C |
| REQ-SW-002 | A terminal program shall be used during bring-up to observe raw bytes. | Incremental bring-up | DBG §3 | H | OPEN | A |
| REQ-SW-003 | The MATLAB receiver shall read a fixed number of bytes (8 + 4·2^N) and use the start/end words as **validation**, not as the only delimiter (payload may contain the delimiter values). | Robust parsing | DERIVED — design choice, see DEC-010 | S (MATLAB test), H | OPEN | C |

## 6. Verification Requirements

| ID | Description | Rationale | Source | Verif. | Status | Owner |
|---|---|---|---|---|---|---|
| REQ-VER-001 | Every designed VHDL block shall have a VHDL testbench; simulation results shall verify the technical specifications. | "No Simulation: x0.0" grading factor | SYL (Degrading factors); DBG §1, §3; CTRL §1 | I | OPEN | ALL |
| REQ-VER-002 | Lab-DEBUG waveforms shall show start, ready, UART transmit signal and transactions clearly. | Demo | DBG §2 | D | OPEN | A |
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
| REQ-PROC-005 | Lab-MATLAB functions may be used in the final demo only if Lab-MATLAB was demonstrated and checked by the assistant. | Grading | SYL (note under final-demo table) | I | OPEN | C |
