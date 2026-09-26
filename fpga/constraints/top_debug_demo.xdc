## -----------------------------------------------------------------------------
## top_debug_demo.xdc — Lab-DEBUG demo top level (fpga/rtl/top/top_debug_demo.vhd)
## Pins copied from Digilent Basys-3-Master.xdc (digilent-xdc commit 69d3501, MIT;
## unmodified copy: fpga/constraints/Basys3_Master.xdc), ports renamed (DBG §3).
## Design: docs/architecture/subsystems/top_debug_demo.md §2-§4, INTERFACES.md §1.1
## Author: Eren (eeerenbuyukbas) — AI-assisted (Claude Opus 5.5), AI-0010
## -----------------------------------------------------------------------------

## Clock signal — 100 MHz oscillator
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clock_in]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clock_in]

## Buttons (active high, asynchronous, bouncing) — BTNC = reset, BTNU = start (DEC-018)
set_property -dict { PACKAGE_PIN U18  IOSTANDARD LVCMOS33 } [get_ports reset_in]
set_property -dict { PACKAGE_PIN T18  IOSTANDARD LVCMOS33 } [get_ports start_in]

## USB-RS232 interface — FPGA transmit (RsTx) to the FT2232HQ
set_property -dict { PACKAGE_PIN A18  IOSTANDARD LVCMOS33 } [get_ports txd_out]

## LED LD6 — Lab-DEBUG ready_out
set_property -dict { PACKAGE_PIN U14  IOSTANDARD LVCMOS33 } [get_ports ready_out]

## Asynchronous I/O: the buttons only feed 2-FF synchronisers (sync_2ff), and
## txd_out / ready_out go to asynchronous receivers (UART, LED). No I/O timing
## relationship to clock_in exists, so these paths are not timed.
set_false_path -from [get_ports {reset_in start_in}]
set_false_path -to   [get_ports {txd_out ready_out}]

## Configuration options (from Basys-3-Master.xdc, "can be used for all designs")
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
