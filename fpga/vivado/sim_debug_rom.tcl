# ------------------------------------------------------------------------------
# sim_debug_rom.tcl
# Purpose : Run tb_debug_rom (TB-ROM-01..03) against the debug_rom IP in a
#           throw-away Vivado project in fpga/vivado/build/ (git-ignored).
# Reqs    : REQ-DEBUG-016, REQ-DEBUG-019; MT-DEBUG-04 (Vivado side); DEC-011, DEC-013
# Author  : Ömer (omerkutlu1030)
# AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0007
#
# Usage (from the repository root, after fpga/ip/create_debug_rom.tcl):
#   vivado -mode batch -source fpga/vivado/sim_debug_rom.tcl
# Result:
#   TB_RESULT line in the console; simulate.log copied to
#   simulation/results/<date>_tb_debug_rom.log
# If Vivado crashes in launch_simulation (seen with redirected console output):
#   vivado -mode batch -source fpga/vivado/sim_debug_rom.tcl -tclargs scripts_only
#   then run compile.bat, elaborate.bat, simulate.bat in the printed directory.
# Expected: TB_RESULT: PASS (11/11 checks), read latency 2.
# ------------------------------------------------------------------------------

set part     xc7a35tcpg236-1
set repo     [file normalize [file join [file dirname [info script]] .. ..]]
set xci      [file join $repo fpga ip debug_rom debug_rom.xci]
set coe      [file join $repo fpga ip debug_rom.coe]
set tb       [file join $repo fpga tb debug tb_debug_rom.vhd]
# Build inside the repo but git-ignored: Windows may block .bat scripts in %TEMP%.
set build    [file join $repo fpga vivado build sim_debug_rom]

foreach f [list $xci $coe $tb] {
    if {![file exists $f]} { error "missing $f (run fpga/ip/create_debug_rom.tcl first?)" }
}

create_project -force sim_debug_rom $build -part $part
set_property target_language VHDL [current_project]

# import_files copies the IP (and its COE) into the project, so nothing is
# generated inside fpga/ip/.
import_files -norecurse $xci
generate_target simulation [get_ips debug_rom]

add_files -fileset sim_1 -norecurse [list $tb $coe]
set_property top tb_debug_rom [get_filesets sim_1]
set_property -name xsim.simulate.runtime -value all -objects [get_filesets sim_1]

set sim_dir [file join $build sim_debug_rom.sim sim_1 behav xsim]

# "-tclargs scripts_only": only write compile/elaborate/simulate.bat into $sim_dir
# and run them by hand. Needed when Vivado's console is redirected to a file,
# where launch_simulation can crash ("Tcl_Close on channel with refCount > 0").
if {[lsearch -exact $argv scripts_only] >= 0} {
    launch_simulation -mode behavioral -scripts_only
    puts "INFO: scripts written to $sim_dir - run compile.bat, elaborate.bat, simulate.bat there"
    close_project
    return
}

launch_simulation -mode behavioral

set out [file join $repo simulation results "[clock format [clock seconds] -format %Y-%m-%d]_tb_debug_rom.log"]
file copy -force [file join $sim_dir simulate.log] $out
puts "INFO: log copied to $out"
close_sim
close_project
