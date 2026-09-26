# Test Report — SYN-TOPDBG — Lab-DEBUG demo top level

```text
Date:              2026-09-26        Tester: Claude Code (AI-0010) for Eren       Reviewer: _pending_
Git commit:        8eea97e + fpga/vivado/build_debug_demo.tcl (branch feature/debug-top, PR #7)
Tool / version:    Vivado ML Standard 2025.2, non-project batch flow, part xc7a35tcpg236-1
Requirements:      REQ-VER-001, REQ-DEBUG-016, REQ-HW-002
```

## Setup
`vivado -mode batch -source fpga/vivado/build_debug_demo.tcl`, run from a clone at an ASCII path
(`C:\dev\…`, DEC-014). Sources: `sync_2ff`, `button_conditioner`, `uart_tx`, `debug`, `top_debug_demo`,
IP `debug_rom` (from `fpga/ip/debug_rom/debug_rom.xci` + `debug_rom.coe`, synthesised in-line),
constraints `fpga/constraints/top_debug_demo.xdc`. Hardware generics: N = 14, 1 Mbaud, latency 2, 10 ms debounce.

## Expected
No errors or critical warnings; all timing met at 100 MHz (WNS ≥ 0, WHS ≥ 0); DRC clean; ROM in block RAM.

## Actual
| Item | Value |
|---|---|
| Errors / critical warnings | 0 / 0 |
| WNS / WHS (post-route) | **+5.083 ns / +0.122 ns** — all user constraints met |
| DRC / methodology checks | 0 / 0 |
| Slice LUTs | 128 (0.62 %) |
| Slice registers | 114 (0.27 %) |
| Block RAM | 14.5 tiles (14 RAMB36 + 1 RAMB18), 29 % |
| DSP | 0 |
| Bonded IOB | 5 |
| Bitstream | `fpga/vivado/build/debug_demo/top_debug_demo.bit` (453 264 bytes, not committed — attached to the demo release) |

Warnings: 1× IP file moved (expected, the build copies the `.xci` into the build folder), and
`Synth 8-7129` "port unconnected" inside the Block Memory Generator (unused ECC/reset/sleep ports of a ROM) — harmless.

## Result: PASS

## Evidence
`docs/verification/2026-09-26_top_debug_demo_utilization.rpt`, `docs/verification/2026-09-26_top_debug_demo_timing.rpt`
(host name and build path redacted, DEC-016).

## Notes / follow-up
- The first design-doc estimate was 16 RAMB36. The IP's own estimate in `debug_rom.xci` (`C_COUNT_36K_BRAM = 14`,
  `C_COUNT_18K_BRAM = 1`, Minimum_Area packing incl. parity bits, pointed out by Ömer) matches the post-route result: 14.5 tiles.
- Next: HW-DEBUG-01…05 on the board with `run_debug_demo("COMx")`.
