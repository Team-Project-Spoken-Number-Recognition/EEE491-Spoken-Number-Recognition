# Traceability Matrix

Chain: **Manual requirement → REQ-ID → implementation file → test → simulation result → hardware result → commit/PR**.
Fill each column as work progresses. A requirement becomes VERIFIED only when the result columns link
to committed evidence.

| REQ-ID | Manual ref. | Implementation file(s) | Test ID(s) | Simulation result | Hardware result | Commit / PR | Status |
|---|---|---|---|---|---|---|---|
| REQ-DEBUG-001 | DBG §1 ¶1 | fpga/rtl/debug/debug.vhd, uart_tx.vhd | TB-DEBUG-03, HW-DEBUG-02 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | PASS 2026-09-26 ([HW-DEBUG](../verification/2026-09-26_HW-DEBUG.md)) | PR #4 (`d6bdd94`) | IMPLEMENTED — NOT VERIFIED (demo open) |
| REQ-DEBUG-002 | DBG §1 ¶1 | | review | | | | OPEN |
| REQ-DEBUG-003 | DBG §1 ¶2 | fpga/rtl/debug/debug.vhd, uart_tx.vhd | TB-DEBUG-04 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | n/a | PR #4 (`d6bdd94`) | IMPLEMENTED — NOT VERIFIED (inspection in PR review) |
| REQ-DEBUG-004 | DBG §1 ¶2 | fpga/rtl/debug/debug.vhd, uart_tx.vhd | TB-DEBUG-03/04 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | n/a | PR #4 (`d6bdd94`) | IMPLEMENTED — NOT VERIFIED (inspection in PR review) |
| REQ-DEBUG-005 | DBG §1 ¶3 | fpga/rtl/debug/debug.vhd, uart_tx.vhd | TB-DEBUG-03 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | PASS 2026-09-26 ([HW-DEBUG](../verification/2026-09-26_HW-DEBUG.md)) | PR #4 (`d6bdd94`) | VERIFIED |
| REQ-DEBUG-006 | DBG §1 ¶3 | fpga/rtl/debug/debug.vhd, uart_tx.vhd | TB-DEBUG-03 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | PASS 2026-09-26 ([HW-DEBUG](../verification/2026-09-26_HW-DEBUG.md)) | PR #4 (`d6bdd94`) | VERIFIED |
| REQ-DEBUG-007 | DBG §1 ¶3 | fpga/rtl/debug/debug.vhd, uart_tx.vhd | TB-DEBUG-03, HW-DEBUG-02 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | PASS 2026-09-26 ([HW-DEBUG](../verification/2026-09-26_HW-DEBUG.md)) | PR #4 (`d6bdd94`) | VERIFIED |
| REQ-DEBUG-008 | DBG §3 | fpga/rtl/debug/uart_tx.vhd | TB-UART-01/03 | PASS 2026-09-26, [tb_uart_tx log](../../simulation/results/2026-09-26_tb_uart_tx.log) | PASS 2026-09-26 ([HW-DEBUG](../verification/2026-09-26_HW-DEBUG.md)) | PR #4 (`d6bdd94`) | VERIFIED |
| REQ-DEBUG-009 | DBG §1 ¶5 | fpga/rtl/debug/debug.vhd, uart_tx.vhd | TB-UART-02, HW-DEBUG-01 | PASS 2026-09-26, [tb_uart_tx log](../../simulation/results/2026-09-26_tb_uart_tx.log) | PASS 2026-09-26 ([HW-DEBUG](../verification/2026-09-26_HW-DEBUG.md)) | PR #4 (`d6bdd94`) | VERIFIED |
| REQ-DEBUG-010 | DBG §1 ¶5 | fpga/constraints/top_debug_demo.xdc (A18) | HW-DEBUG-01 | n/a (pin checked vs. official XDC) | PASS 2026-09-26 ([HW-DEBUG](../verification/2026-09-26_HW-DEBUG.md)) | PR #7 | VERIFIED |
| REQ-DEBUG-011 | DBG §1 ¶6 | | review | n/a | n/a | | OPEN |
| REQ-DEBUG-012 | DBG §1 ¶6 | fpga/rtl/debug/debug.vhd, uart_tx.vhd | TB-DEBUG-01/06, HW-DEBUG-05 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | PASS 2026-09-26 ([HW-DEBUG](../verification/2026-09-26_HW-DEBUG.md)) | PR #4 (`d6bdd94`) | VERIFIED (sim + HW) |
| REQ-DEBUG-013 | DBG §1 ¶6 | fpga/rtl/debug/debug.vhd, uart_tx.vhd | TB-DEBUG-02/05, HW-DEBUG-04 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | PASS 2026-09-26 ([HW-DEBUG](../verification/2026-09-26_HW-DEBUG.md)) | PR #4 (`d6bdd94`) | VERIFIED (sim + HW) |
| REQ-DEBUG-014 | DBG §1 ¶6 | fpga/rtl/debug/debug.vhd, uart_tx.vhd | TB-DEBUG-02 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | n/a | PR #4 (`d6bdd94`) | VERIFIED (sim) |
| REQ-DEBUG-015 | DBG §1 ¶4 | matlab/debug/decode_debug_frame.m | MT-DEBUG-01..03, HW-DEBUG-02 | PASS 2026-09-26, [mt_debug log](../../simulation/results/2026-09-26_mt_debug.log) | PASS 2026-09-26 ([HW-DEBUG](../verification/2026-09-26_HW-DEBUG.md)) | PR #5 | VERIFIED |
| REQ-DEBUG-016 | DBG §2 | fpga/rtl/top/top_debug_demo.vhd, fpga/rtl/common/{sync_2ff,button_conditioner}.vhd, fpga/constraints/top_debug_demo.xdc; fpga/ip/debug_rom/debug_rom.xci, fpga/ip/create_debug_rom.tcl, fpga/ip/debug_rom.coe | TB-TOPDBG-01..03, TB-BTN-01..05, TB-ROM-01..03, MT-DEBUG-04, SYN-TOPDBG | PASS 2026-09-26: [tb_top_debug_demo log](../../simulation/results/2026-09-26_tb_top_debug_demo.log), [tb_button_conditioner log](../../simulation/results/2026-09-26_tb_button_conditioner.log), [tb_debug_rom log](../../simulation/results/2026-09-26_tb_debug_rom.log); synthesis/implementation [reports](../verification/) | PASS 2026-09-26 ([HW-DEBUG](../verification/2026-09-26_HW-DEBUG.md)) | PR #5, PR #7 | IMPLEMENTED — NOT VERIFIED (demo open) |
| REQ-DEBUG-017 | DBG §2 | top_debug_demo.bit (build_debug_demo.tcl) + matlab/debug/run_debug_demo.m | HW-DEBUG-02/03 | n/a | PASS 2026-09-26 ([HW-DEBUG](../verification/2026-09-26_HW-DEBUG.md)) | PR #7 + test/debug-hw PR | IMPLEMENTED — NOT VERIFIED (demo open) |
| REQ-DEBUG-018 | DBG §1 ¶8 | | later stages | | | | OPEN |
| REQ-DEBUG-019 | DBG §3 | fpga/rtl/debug/debug.vhd | TB-DEBUG-07 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | n/a | PR #4 (`d6bdd94`) | VERIFIED (sim) |
| REQ-DEBUG-020 | DBG §3 | | review | n/a | n/a | | OPEN |
| REQ-CTRL-001 … 010 | CTRL §1–3 | | TB-CTRL-01..06 | | | | OPEN |
| REQ-IF-001, 004, 005 | CTRL §1, DBG §1 | | review, TB-CTRL-05 | | | | OPEN |
| REQ-IF-002 / 003 | CTRL §1 | fpga/rtl/debug/debug.vhd (Lab-DEBUG only) | TB-DEBUG-02 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | | PR #4 (`d6bdd94`) | IN PROGRESS (other sub-systems open) |
| REQ-IF-006 | TA Q-03 | fpga/rtl/debug/debug.vhd (Lab-DEBUG only) | TB-DEBUG-01 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | | PR #4 (`d6bdd94`) | IN PROGRESS (other sub-systems open) |
| REQ-IF-007 | TA Q-03 | fpga/rtl/debug/debug.vhd (Lab-DEBUG only) | TB-DEBUG-05 | PASS 2026-09-26, [tb_debug log](../../simulation/results/2026-09-26_tb_debug.log) | | PR #4 (`d6bdd94`) | IN PROGRESS (other sub-systems open) |
| REQ-PERF-001 | DERIVED | fpga/rtl/debug/uart_tx.vhd, debug.vhd | TB-UART-02 (+ analysis INTERFACES §3.3) | PASS 2026-09-26, [tb_uart_tx log](../../simulation/results/2026-09-26_tb_uart_tx.log) | | PR #4 (`d6bdd94`) | VERIFIED (A, sim) |
