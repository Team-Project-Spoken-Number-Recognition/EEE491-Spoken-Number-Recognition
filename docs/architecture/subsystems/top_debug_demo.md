# Lab-DEBUG demo top level — Subsystem Design Document

```text
Owner:        Eren (top level)            Reviewer: Ömer (ROM/COE interface), Hande (debug interface)
Stage / manual: Lab-DEBUG — docs/manuals/Lab-DEBUG_Assignment.pdf (DBG §2 demo); TA Q-04, Q-05
Status:       DRAFT v0.2 (2026-09-26) — to be REVIEWED before RTL
Requirements: REQ-DEBUG-010, REQ-DEBUG-016, REQ-DEBUG-017, REQ-CTRL-006 (inputs), REQ-HW-002,
              REQ-IF-002 (start pulse), REQ-IF-006, REQ-VER-001
AI-assisted:  yes — Claude Code, Claude Opus 5.5 (AI-0008)
```

Sources: `debug.md` v0.2 (Lab-DEBUG block), `INTERFACES.md` §1.1 and §3, DEC-005/007/008/012/013/018,
TA Q-04/Q-05, Ömer's ROM IP and COE (PR #5: `fpga/ip/create_debug_rom.tcl`, `debug_rom.coe`,
`tb_debug_rom` — latency 2 measured), Digilent `Basys-3-Master.xdc` (digilent-xdc commit `69d3501`, MIT), reference design
`Borek-32/…/rtl/top_module.vhd` (start-button handling only). **DESIGN CHOICE** = decided here, needs
reviewer approval. **TO VERIFY** = open until a test confirms it.

## 1. Purpose

Board-level wrapper for the Lab-DEBUG demonstration (DBG §2, TA Q-04): press **BTNU** → Lab-DEBUG reads
the whole 16 384 × 32 demo ROM and sends it to MATLAB at 1 Mbaud; **LD6** shows `ready`. Lab-CTRL is not
part of this demo (TA Q-04).

Inside this top level: reset synchroniser, start-button conditioning, Lab-DEBUG instance, ROM instance,
LED. Not inside: the UART/FSM logic (`debug`, Hande), the ROM IP `debug_rom`, its COE and the MATLAB
receiver (Ömer, PR #5).

## 2. Inputs

| Port | Width | Pin | Type/format | Description |
|---|---|---|---|---|
| `clock_in` | 1 | W5 | 100 MHz oscillator | System clock (REQ-IF-005) |
| `reset_in` | 1 | U18 (BTNC) | raw push-button, active high, asynchronous | System reset (DEC-007, TA Q-05 → DEC-018) |
| `start_in` | 1 | T18 (BTNU) | raw push-button, active high, asynchronous, bouncing | Start one transfer |

## 3. Outputs

| Port | Width | Pin | Type/format | Description |
|---|---|---|---|---|
| `txd_out` | 1 | A18 | UART 8N1, 1 Mbaud, idle '1' | To FT2232HQ RXD (REQ-DEBUG-010) |
| `ready_out` | 1 | U14 (LD6) | '1' = LED on = idle | Lab-DEBUG `ready_out` (REQ-IF-006) |

All five pins verified against Digilent's official `Basys-3-Master.xdc` (2026-09-26) → ASSUMPTION-003 VERIFIED.

Generics (defaults = hardware; simulation overrides them):

| Generic | Default | Purpose |
|---|---|---|
| `N` | 14 | Address width, passed to `debug`. **Must equal the ROM address width (14) in hardware** |
| `G_CLK_FREQ_HZ` | 100_000_000 | Passed to `debug` |
| `G_BAUD_RATE` | 1_000_000 | Passed to `debug` (DEC-005) |
| `G_MEM_LATENCY` | 2 | Passed to `debug`; must be ≥ ROM latency (2, measured in TB-ROM-01) |
| `G_DEBOUNCE_CYCLES` | 1_000_000 | Start-button stable time = 10 ms at 100 MHz (DEC-019) |

## 4. Clock

Single domain, `clock_in` 100 MHz, constrained with `create_clock -period 10.000` (XDC). No MMCM
(DEC-006). The ROM uses the same clock.

## 5. Reset

- `reset_in` (BTNC) → `sync_2ff` (two flip-flops, `ASYNC_REG`) → `rst` → `reset_in` of `debug` and of the
  button conditioner (DEC-007: synchronous use). The reference design feeds the raw button directly; we
  synchronise it (DEC-007 outranks DEC-018).
- Power-up: all registers have initial values (FPGA configuration loads them), so no extra power-on
  reset is needed. **DESIGN CHOICE:** the reset synchroniser initialises to '1', which additionally holds
  the design in reset for the first two clocks after configuration.
- Reset bounce is harmless (several resets in a row). No debounce on reset.
- The ROM has no reset (read-only).

## 6. Algorithm

```text
rst       = sync2(reset_in)
start_p   = rising_edge_pulse( debounce( sync2(start_in), G_DEBOUNCE_CYCLES ) )   -- exactly 1 clock
debug     : start_in <= start_p ; mem_data_in <= debug_rom[mem_addr_out] (latency 2)
txd_out   = debug.txd_out ; ready_out = debug.ready_out
```

**Start-button conditioning (DESIGN CHOICE, DEC-019 — deviation from the reference design):**
the reference design only synchronises BTNU and detects its rising edge. Mechanical bounce (typically
< 5 ms) then produces several rising edges per press. During a transfer they are ignored (REQ-IF-007), but
if the button is held longer than one transfer (0.66 s), the bounce **on release** or a re-press bounce can
start a second, unwanted transfer. We therefore require the synchronised level to be stable for
`G_DEBOUNCE_CYCLES` (10 ms) before accepting it, and emit a pulse only on the debounced 0 → 1 change.

Debounce algorithm (counter-based, one clock domain):

```text
if sync_level = stable then cnt <= 0
elsif cnt = G_DEBOUNCE_CYCLES - 1 then stable <= sync_level; cnt <= 0
else cnt <= cnt + 1
pulse <= stable_new and not stable_old          -- registered, 1 clock
```

## 7. Internal architecture

| File | Entity | Content |
|---|---|---|
| `fpga/rtl/common/sync_2ff.vhd` | `sync_2ff` | 2-FF synchroniser, generic init value, `ASYNC_REG` attribute |
| `fpga/rtl/common/button_conditioner.vhd` | `button_conditioner` | `sync_2ff` + debounce + rising-edge pulse |
| `fpga/rtl/top/top_debug_demo.vhd` | `top_debug_demo` | Top level: instances below + ROM component |
| `fpga/ip/debug_rom/debug_rom.xci` (Ömer, PR #5) | `debug_rom` | Block Memory Generator ROM (§12) |

```text
 BTNC reset_in ──► sync_2ff ──► rst ─────────────┬──────────────┐
                                                  ▼              ▼
 BTNU start_in ──► button_conditioner ──start_p──► debug ──txd_out──► A18 (FT2232HQ)
                     (sync+debounce+pulse)        │  │  └─ready_out──► U14 LD6
                                     mem_addr_out │  ▲ mem_data_in
                                        (14 bit)  ▼  │ (32 bit)
                                           debug_rom (16384 × 32, latency 2)
 W5 clock_in ───────────────────────────────► all of the above
```

## 8. State machines

- `debug`: see `debug.md` §8 (unchanged).
- `button_conditioner`: no explicit FSM — a stable-level register, a counter and an edge detector (§6).
- Top level: none.

## 9. Timing

| Path | Cycles |
|---|---|
| BTNU press (clean) → `start_p` | 2 (sync) + `G_DEBOUNCE_CYCLES` + 1 ≈ 10 ms |
| `start_p` → `ready_out` low | 1 (debug.md §13) |
| Full transfer, N = 14 | ≈ 65.74 M cycles ≈ 0.657 s (debug.md §14) |
| Bounces shorter than 10 ms | produce **no** pulse |

## 10. Data format

Unchanged from `debug.md` §10: start word, 16 384 ROM words MSB byte first, end word → 65 544 bytes.

## 11. Fixed-point representation

Not applicable (no arithmetic).

## 12. Memory requirements — ROM interface (Ömer's IP, PR #5)

The demo ROM is Ömer's `debug_rom` IP, (re)created by `fpga/ip/create_debug_rom.tcl` from
`fpga/ip/debug_rom.coe`; the `.xci` is committed (DEC-013). This top level only instantiates it.

| Parameter | Value (from `create_debug_rom.tcl` / `.xci`) |
|---|---|
| Component | `debug_rom` (Block Memory Generator, Vivado 2025.2) |
| Memory type | Single Port ROM, Native interface |
| Width × depth | 32 × 16 384 (address 14 bit) |
| Enable | Always enabled (no `ena` port), no reset pin |
| Output register | Primitives output register ON, core register OFF → **read latency 2**, measured by TB-ROM-01 (PASS) |
| Ports | `clka`, `addra(13:0)`, `douta(31:0)` |
| Init file | `fpga/ip/debug_rom.coe`, generated by `matlab/debug/generate_debug_coe.m` |
| BRAM | 16 × RAMB36 of 50 (32 %) — TO VERIFY in the utilisation report |

Test pattern (Ömer, `generate_debug_coe.m`): word k = `k[15:0] & (not k)[15:0]`, except
address 1 = `55AACC03`, 2 = `AA5503CC`, 3 = `00000000`, 4 = `FFFFFFFF`, last−1 = `55AACC03`,
last = `AA5503CC`. The top-level testbench does not re-implement the formula: it reads the expected words
from the same COE file, like `tb_debug_rom`.

**Simulation:** the top-level testbench runs in a Vivado project created by a Tcl script (as Ömer's
`sim_debug_rom.tcl`), so the real IP simulation model is used — no behavioural ROM model, no duplicate
entity. Consequence: TB-TOPDBG uses N = 14 (the IP is fixed at 14 bits); a full frame at 10 clocks/bit is
≈ 6.7 M clock cycles, acceptable for XSim.

## 13. Latency

See §9. ROM read latency 2; `debug` waits `G_MEM_LATENCY` = 2 (debug.md §12).

## 14. Throughput

Unchanged from `debug.md` §14 (≈ 0.657 s per transfer).

## 15. Interface protocol

- `start_p` is a clean 1-clock pulse, as required by `debug.md` §15 and REQ-IF-002.
- A press during a transfer is ignored by `debug` (REQ-IF-007); a press held through the end of a transfer
  does **not** start a new transfer (no new 0 → 1 debounced edge).
- **DESIGN CHOICE:** if BTNU is held while BTNC is released, the debounced level rises after reset and one
  transfer starts ≈ 10 ms later. Accepted (operator action, harmless).

## 16. Resource estimate

| Resource | Estimate | Basis |
|---|---|---|
| FF | ≈ 105 | debug 78 (synthesised), button 20-bit counter + 5, reset sync 2 |
| LUT | ≈ 110 | debug 79 (synthesised) + counter/compare |
| BRAM | 16 RAMB36 | ROM |
| DSP | 0 | |

## 17. Verification method

| ID | File | What it proves | REQ |
|---|---|---|---|
| TB-BTN-01 | `fpga/tb/debug/tb_button_conditioner.vhd` | clean press → exactly 1 pulse, 1 clock wide, after 2 + D + 1 cycles | IF-002 |
| TB-BTN-02 | same | press with bounce (glitches shorter than D) → exactly 1 pulse | IF-002 |
| TB-BTN-03 | same | release with bounce → 0 pulses; glitch while idle → 0 pulses | IF-002 |
| TB-BTN-04 | same | long hold → 1 pulse only | IF-002 |
| TB-BTN-05 | same | reset during a press → no pulse while in reset | DEC-007 |
| TB-TOPDBG-01 | `fpga/tb/debug/tb_top_debug_demo.vhd` | bouncing press → exactly one frame of `8 + 4·2^14` bytes; header, all 16 384 words = COE, footer; LED low during / high after | DEBUG-016 |
| TB-TOPDBG-02 | same | press held beyond the end of the transfer and released with bounce → no second frame | IF-007, DEC-019 |
| TB-TOPDBG-03 | same | second press → second identical frame | DEBUG-001 |
| SYN-TOPDBG | `fpga/vivado/create_debug_demo.tcl` | synthesis + implementation, timing met at 100 MHz, BRAM = 16, no critical warnings | REQ-VER-001 |
| HW-DEBUG-01…05 | TEST_PLAN §3 | on the board with Ömer's MATLAB receiver | DEBUG-008…017 |

Simulation settings: N = 14 with the real `debug_rom` IP (Vivado project flow, script
`fpga/vivado/sim_top_debug_demo.tcl`), `G_BAUD_RATE` = 10 000 000 (10 clocks/bit), `G_DEBOUNCE_CYCLES` = 50.
`tb_button_conditioner` is pure RTL (plain XSim, no IP).

## 18. Known limitations

- The ROM IP is fixed at 14 address bits; changing N requires regenerating the IP (`addr_bits` in `create_debug_rom.tcl`).
- Buttons are the only inputs; no switch selects other memories (not needed for this demo).
- Input ports are asynchronous; the XDC sets `set_false_path` from `reset_in`/`start_in` because they only
  feed synchronisers.
- 1 Mbaud and the whole chain are verified on hardware only in HW-DEBUG-01…05.

## 19. Change history

| Version | Date | Author | Change |
|---|---|---|---|
| 0.1 | 2026-09-26 | Eren (AI-assisted, Claude Opus 5.5, AI-0008) | First draft for review |
| 0.2 | 2026-09-26 | Eren (AI-0008) | Aligned with Ömer's ROM (PR #5): IP `debug_rom`, COE and pattern from `generate_debug_coe.m`, latency 2 measured; real IP in simulation instead of a behavioural model; DEC-013 proposal dropped |
