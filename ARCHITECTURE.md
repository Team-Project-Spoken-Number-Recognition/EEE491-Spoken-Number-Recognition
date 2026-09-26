# System Architecture

Status legend: **VERIFIED / IMPLEMENTED — NOT VERIFIED / PLANNED / ASSUMED / UNKNOWN**.
At the time of writing **every block is PLANNED**; nothing is implemented.

Sources: syllabus (Lab Assignments table), Lab-CTRL manual §1 block diagram, Lab-DEBUG manual §1.
Blocks belonging to un-released stages are shown for context only; their internals are UNKNOWN
until their manuals are released.

## 1. Signal-processing chain (functional path)

```mermaid
flowchart TB
    MIC[Microphone] --> AMP[Analog amplifier]
    AMP --> AAF[Anti-aliasing filter]
    AAF --> ADCCHIP[ADC chip<br/>UNKNOWN part]
    subgraph PCB["Lab-PCB (analog board) — PLANNED"]
        MIC
        AMP
        AAF
    end
    ADCCHIP -- SPI --> CAP
    subgraph FPGA["Basys-3 FPGA (100 MHz, single clock domain — PROPOSED)"]
        CAP["Lab-ADC<br/>SPI capture + dual-port RAM"] --> WIN["Lab-WINDOW<br/>framing (CTRL addr) × window → RAM"]
        WIN --> FFT["Lab-FFT<br/>Vivado FFT IP → RAM"]
        FFT --> MAG["magnitude / power<br/>(location TBD: FFT or MEL stage)"]
        MAG --> MEL["Lab-MEL<br/>MEL filter-bank energies → RAM"]
        MEL --> LOG["log / energy processing<br/>(location TBD)"]
        LOG --> DCT["Lab-DCT<br/>DCT → feature vector RAM"]
        DCT --> CMP["Lab-COMPARE<br/>feature store + template comparison"]
        CMP --> SEG["7-segment driver"]
    end
    SEG --> DISP[7-segment display]
```

Notes
- The syllabus assigns *magnitude/power* and *log* steps to no specific lab. Their placement is
  **UNKNOWN** and will be decided when the FFT/MEL manuals are released (tracked in `ASSUMPTIONS.md`).
- Each lab block owns an **output dual-port RAM** (REQ-IF-004): port A written by the block,
  port B read by the next block (and by Lab-DEBUG when attached).

## 2. Control topology (from Lab-CTRL manual)

```mermaid
flowchart LR
    SW["RESET & START<br/>(board inputs)"] --> CTRL
    CTRL["Lab-CTRL"] <-->|start / ready| ADC[Lab-ADC]
    CTRL <-->|"start / ready<br/>frame_addr_out[13:0]"| WIN[Lab-WINDOW]
    CTRL <-->|start / ready| FFT[Lab-FFT]
    CTRL <-->|start / ready| MEL[Lab-MEL]
    CTRL <-->|start / ready| DCT[Lab-DCT]
    CTRL <-->|start / ready| CMP[Lab-COMPARE]
    CTRL <-->|start / ready| DBG[Lab-DEBUG]
    RN["RECORD & NUMBER<br/>switches"] --> CMP
    CMP --> SEG[7-segment]
    SW -. reset to every block .-> ADC & WIN & FFT & MEL & DCT & CMP & DBG
```

- Handshake: single-cycle `start` pulse in, `ready` out (low while busy). See `INTERFACES.md` §2.
- Lab-CTRL generates the 50 %-overlapped frame start addresses (REQ-CTRL-002/003).
- The RECORD & NUMBER switches appear in the Lab-CTRL block diagram as inputs to Lab-COMPARE;
  their behaviour is **UNKNOWN** until the COMPARE manual is released (presumably template recording
  vs. recognition — ASSUMPTION-012).

## 3. Debug path (designed in from the start)

```mermaid
flowchart LR
    subgraph FPGA
        R1[any block's output RAM<br/>read-only port] -->|mem_data_in 32b| DBG[Lab-DEBUG<br/>UART TX]
        DBG -->|mem_addr_out N b| R1
        CTRL[Lab-CTRL] -->|start_debug| DBG
        DBG -->|ready_debug| CTRL
    end
    DBG -->|txd_out, pin A18 ASSUMED| FTDI[FT2232HQ<br/>USB-UART bridge]
    FTDI -->|USB VCP| PC[PC: MATLAB receiver<br/>matlab/debug/]
    PC --> AN[MATLAB analysis<br/>vs. golden model]
```

Debug frame on the wire (REQ-DEBUG-005..008):

```text
| 55 AA CC 03 | W0[31:24] W0[23:16] W0[15:8] W0[7:0] | W1 ... | W(2^N-1) | AA 55 03 CC |
   start word          word 0 (MSB byte first — derived)                       end word
each byte: start bit, 8 data bits LSB first, stop bit (8N1)
```

**Separation of debug vs. functional path (PROPOSED, DEC-009):**
Lab-DEBUG is a *tap*: it only reads a RAM's read port. When a block's RAM port B is shared between the
next functional block and Lab-DEBUG, a port-B address multiplexer selects the reader, and Lab-CTRL
guarantees that Lab-DEBUG only runs while the functional pipeline is idle. Final mechanism to be decided
at the Lab-ADC stage (first real dual-port RAM).

## 4. Lab-DEBUG demo configuration (current stage — PLANNED)

TA Q-04: Lab-CTRL is **not** needed for this demo; the top module drives `start_in` / `ready_out` directly.

```mermaid
flowchart LR
    BTN["BTNU (START)<br/>→ sync + debounce + 1-cycle pulse"] -->|start_in| DBG[Lab-DEBUG<br/>N = 14]
    RST["BTNC (RESET)<br/>→ synchroniser"] --> DBG
    DBG -->|ready_out| LED["LED LD6"]
    DBG -->|mem_addr_out 14b| ROM["Block Memory Generator<br/>Single-Port ROM 16384 × 32<br/>init: .coe"]
    ROM -->|mem_data_in 32b| DBG
    DBG --> TXD[txd_out → FT2232HQ]
```

Resource note: a 16384 × 32 ROM = 524 288 bits ≈ **16 BRAM36** (≈ 32 % of the 50 BRAM36 of an
XC7A35T — ASSUMED part). Acceptable for the demo; the final system's BRAM budget must be tracked
(see risk R-07 in `PROJECT_STATUS.md`).

## 5. Clock and reset (PROPOSED — DEC-006, DEC-007)

| Topic | Proposal | Status |
|---|---|---|
| Clock | Single 100 MHz domain (`clock_in`, Basys-3 oscillator). Slower rates (UART baud, SPI SCLK) produced with **clock enables**, never with derived logic clocks. | PROPOSED |
| Reset | Active-high `reset_in`, synchronised to `clock_in` (2-FF), used **synchronously** in all processes. | PROPOSED |
| Push-buttons / switches | 2-FF synchroniser → debounce → rising-edge detector (1-cycle pulse). | PROPOSED |

## 6. Dependency graph (stages)

```mermaid
flowchart TD
    DEBUG[Lab-DEBUG] --> CTRLd[Lab-DEBUG demo needs Lab-CTRL]
    CTRL[Lab-CTRL] --> CTRLd
    DEBUG --> ADC[Lab-ADC]
    CTRL --> ADC
    ADC --> WIN[Lab-WINDOW]
    CTRL --> WIN
    ADC --> PCB[Lab-PCB<br/>interfaces with Lab-ADC]
    MAT[Lab-MATLAB<br/>golden model] -.reference.-> WIN
    MAT -.reference.-> FFT
    MAT -.reference.-> MEL
    MAT -.reference.-> DCT
    MAT -.reference / templates?.-> CMP
    WIN --> FFT[Lab-FFT]
    FFT --> MEL[Lab-MEL]
    MEL --> DCT[Lab-DCT]
    DCT --> CMP[Lab-COMPARE]
    PCB --> FINAL[Final system demo]
    CMP --> FINAL
    DEBUG -.debug of every stage.-> WIN & FFT & MEL & DCT & CMP
```

Critical path (schedule): DEBUG → CTRL → ADC → WINDOW → FFT → MEL → DCT → COMPARE → final demo.
PCB (difficulty 5, 20 final-demo points) runs in parallel and needs manufacturing lead time.

## 7. What is intentionally NOT defined yet

Sampling rate, ADC part and resolution, frame length, number of frames, window function, FFT size,
MEL filter count, log implementation, DCT coefficient count, classifier method, template storage,
7-segment protocol. See `ASSUMPTIONS.md` §2 ("Unknown parameters register").
