# ------------------------------------------------------------------------------
# sim_top_debug_demo.tcl
# Purpose : Run tb_top_debug_demo (TB-TOPDBG-01..03) against the real debug_rom IP
#           in a throw-away Vivado project in fpga/vivado/build/ (git-ignored).
#           Same structure as sim_debug_rom.tcl (Ömer).
# Reqs    : REQ-DEBUG-016, REQ-IF-002/006/007; DEC-011, DEC-013
# Author  : Eren (eeerenbuyukbas)
# AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0010
#
# Usage (from the repository root, Vivado 2025.2 on PATH):
#   vivado -mode batch -source fpga/vivado/sim_top_debug_demo.tcl
# Result:
#   TB_RESULT line in the console; simulate.log copied to
#   simulation/results/<date>_tb_top_debug_demo.log
# If launch_simulation cannot spawn its scripts (seen when Vivado's bin is not
# on PATH, or with redirected console output):
#   vivado -mode batch -source fpga/vivado/sim_top_debug_demo.tcl -tclargs scripts_only
#   then run compile.bat, elaborate.bat, simulate.bat in the printed directory.
# Run time: ~2 x 6.8 M clock cycles (two full N = 14 frames at 10 clocks/bit).
# ------------------------------------------------------------------------------

set part   xc7a35tcpg236-1
set repo   [file normalize [file join [file dirname [info script]] .. ..]]
set xci    [file join $repo fpga ip debug_rom debug_rom.xci]
set coe    [file join $repo fpga ip debug_rom.coe]
set rtl    [list \
    [file join $repo fpga rtl common sync_2ff.vhd] \
    [file join $repo fpga rtl common button_conditioner.vhd] \
    [file join $repo fpga rtl debug uart_tx.vhd] \
    [file join $repo fpga rtl debug debug.vhd] \
    [file join $repo fpga rtl top top_debug_demo.vhd] ]
set tb     [file join $repo fpga tb debug tb_top_debug_demo.vhd]
set build  [file join $repo fpga vivado build sim_top_debug_demo]

foreach f [concat [list $xci $coe $tb] $rtl] {
    if {![file exists $f]} { error "missing $f" }
}

create_project -force sim_top_debug_demo $build -part $part
set_property target_language VHDL [current_project]

# import_files copies the IP (and its COE) into the project: nothing is generated in fpga/ip/
import_files -norecurse $xci
generate_target simulation [get_ips debug_rom]

add_files -norecurse $rtl
set_property top top_debug_demo [get_filesets sources_1]
add_files -fileset sim_1 -norecurse [list $tb $coe]
set_property top tb_top_debug_demo [get_filesets sim_1]
set_property -name xsim.simulate.runtime -value all -objects [get_filesets sim_1]

set sim_dir [file join $build sim_top_debug_demo.sim sim_1 behav xsim]

if {[lsearch -exact $argv scripts_only] >= 0} {
    launch_simulation -mode behavioral -scripts_only
    puts "INFO: scripts written to $sim_dir - run compile.bat, elaborate.bat, simulate.bat there"
    close_project
    return
}

launch_simulation -mode behavioral
set out [file join $repo simulation results "[clock format [clock seconds] -format %Y-%m-%d]_tb_top_debug_demo.log"]
file copy -force [file join $sim_dir simulate.log] $out
puts "INFO: log copied to $out"
close_sim
close_project
