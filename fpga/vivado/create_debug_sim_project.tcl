# ------------------------------------------------------------------------------
# create_debug_sim_project.tcl
# Purpose : Vivado GUI project with every Lab-DEBUG source, the debug_rom IP and ALL
#           testbenches, so each simulation can be run and inspected in Vivado:
#             tb_uart_tx, tb_debug, tb_debug_rom, tb_button_conditioner,
#             tb_top_debug_demo (real IP, N = 14, ~1 min), tb_debug_waves (demo waveforms)
# Usage   : Vivado 2025.2 GUI -> Tcl Console:
#             cd C:/dev/<your clone>                 (ASCII path without spaces, DEC-014)
#             source fpga/vivado/create_debug_sim_project.tcl
#           then: Sources window -> Simulation Sources -> sim_1 -> right-click a testbench ->
#           "Set as Top" -> Flow Navigator: Run Simulation -> Run Behavioral Simulation.
#           The simulation runs to the end by itself (runtime = all); the Tcl console shows the
#           "Expected / Actual / PASS|FAIL" lines and the final TB_RESULT line.
# Project : fpga/vivado/build/debug_sim/debug_sim.xpr (git-ignored; re-create any time)
# Author  : Eren (eeerenbuyukbas)
# AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0014
# ------------------------------------------------------------------------------

set part  xc7a35tcpg236-1
set repo  [file normalize [file join [file dirname [info script]] .. ..]]
set pdir  [file join $repo fpga vivado build debug_sim]

if {[regexp {[^\x20-\x7E]| } $repo]} {
    error "Repository path '$repo' contains spaces or non-ASCII characters - Vivado cannot use it.\
           Clone the repository to e.g. C:/dev/EEE491-Spoken-Number-Recognition (DEC-014)."
}

set rtl [list \
    [file join $repo fpga rtl common sync_2ff.vhd] \
    [file join $repo fpga rtl common button_conditioner.vhd] \
    [file join $repo fpga rtl debug uart_tx.vhd] \
    [file join $repo fpga rtl debug debug.vhd] \
    [file join $repo fpga rtl top top_debug_demo.vhd] ]
set tbs [list \
    [file join $repo fpga tb debug tb_uart_tx.vhd] \
    [file join $repo fpga tb debug tb_debug.vhd] \
    [file join $repo fpga tb debug tb_debug_rom.vhd] \
    [file join $repo fpga tb debug tb_button_conditioner.vhd] \
    [file join $repo fpga tb debug tb_top_debug_demo.vhd] \
    [file join $repo fpga tb debug tb_debug_waves.vhd] ]
set xdc [file join $repo fpga constraints top_debug_demo.xdc]
set xci [file join $repo fpga ip debug_rom debug_rom.xci]
set coe [file join $repo fpga ip debug_rom.coe]

foreach f [concat $rtl $tbs [list $xdc $xci $coe]] {
    if {![file exists $f]} { error "missing $f" }
}

create_project -force debug_sim $pdir -part $part
set_property target_language VHDL [current_project]

import_files -norecurse $xci                      ;# copy of the IP inside the project
generate_target simulation [get_ips debug_rom]

add_files -norecurse $rtl
set_property top top_debug_demo [get_filesets sources_1]
add_files -fileset constrs_1 -norecurse $xdc

add_files -fileset sim_1 -norecurse [concat $tbs [list $coe]]   ;# COE: read by the testbenches
set_property top tb_debug [get_filesets sim_1]
set_property -name xsim.simulate.runtime -value all -objects [get_filesets sim_1]
update_compile_order -fileset sim_1

puts ""
puts "INFO: project ready: [file join $pdir debug_sim.xpr]"
puts "INFO: simulation top = tb_debug. To run another testbench: Simulation Sources -> sim_1 ->"
puts "      right-click tb_... -> Set as Top -> Run Simulation -> Run Behavioral Simulation."
puts "      Expected: tb_uart_tx 37/37, tb_debug 97/97, tb_debug_rom 11/11,"
puts "      tb_button_conditioner 22/22, tb_top_debug_demo 15/15 (about 1 minute)."
