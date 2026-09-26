# ------------------------------------------------------------------------------
# build_debug_demo.tcl
# Purpose : Synthesis, implementation and bitstream of the Lab-DEBUG demo top level
#           (top_debug_demo + debug + debug_rom IP) for the Basys-3, in Vivado
#           non-project mode (no project file, no spawned runs, reproducible).
# Reqs    : REQ-DEBUG-016, REQ-DEBUG-017, REQ-HW-002, REQ-VER-001; DEC-013
# Author  : Eren (eeerenbuyukbas)
# AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0010
#
# Usage (from the repository root, Vivado 2025.2 with Artix-7 on PATH):
#   vivado -mode batch -source fpga/vivado/build_debug_demo.tcl
# IMPORTANT: the repository path must be plain ASCII without spaces
#   (e.g. C:\dev\EEE491-Spoken-Number-Recognition). Vivado cannot open files under
#   "...\OneDrive\Masaüstü\EEE391 Project\..." (DEC-014).
# Result (all in fpga/vivado/build/debug_demo/, git-ignored):
#   top_debug_demo.bit                      bitstream for the Hardware Manager
#   post_synth_utilization.rpt, post_route_utilization.rpt,
#   post_route_timing_summary.rpt, post_route_drc.rpt, post_route_methodology.rpt
# Summaries for the repository are copied to
#   docs/verification/<date>_top_debug_demo_{utilization,timing}.rpt
# ------------------------------------------------------------------------------

set part  xc7a35tcpg236-1
set top   top_debug_demo
set repo  [file normalize [file join [file dirname [info script]] .. ..]]
set build [file join $repo fpga vivado build debug_demo]
set date  [clock format [clock seconds] -format %Y-%m-%d]

set rtl [list \
    [file join $repo fpga rtl common sync_2ff.vhd] \
    [file join $repo fpga rtl common button_conditioner.vhd] \
    [file join $repo fpga rtl debug uart_tx.vhd] \
    [file join $repo fpga rtl debug debug.vhd] \
    [file join $repo fpga rtl top top_debug_demo.vhd] ]
set xdc [file join $repo fpga constraints top_debug_demo.xdc]
set xci [file join $repo fpga ip debug_rom debug_rom.xci]
set coe [file join $repo fpga ip debug_rom.coe]

foreach f [concat $rtl [list $xdc $xci $coe]] {
    if {![file exists $f]} { error "missing $f" }
}

# Fresh build folder; the IP is copied there so no output products land in fpga/ip/.
file delete -force $build
file mkdir [file join $build ip debug_rom]
file copy $xci [file join $build ip debug_rom debug_rom.xci]
file copy $coe [file join $build ip debug_rom.coe]    ;# .xci refers to ../debug_rom.coe

create_project -in_memory -part $part
set_property target_language VHDL [current_project]

read_ip [file join $build ip debug_rom debug_rom.xci]
# synthesise the IP together with the design (no out-of-context run to spawn)
set_property generate_synth_checkpoint false [get_files debug_rom.xci]
generate_target all [get_ips debug_rom]

read_vhdl $rtl
read_xdc  $xdc

# ---------------------------------------------------------------- synthesis
synth_design -top $top -part $part
report_utilization -file [file join $build post_synth_utilization.rpt]

# ------------------------------------------------------------ implementation
opt_design
place_design
route_design

report_utilization      -file [file join $build post_route_utilization.rpt]
report_timing_summary   -file [file join $build post_route_timing_summary.rpt]
report_drc              -file [file join $build post_route_drc.rpt]
report_methodology      -file [file join $build post_route_methodology.rpt]

# ----------------------------------------------------------------- bitstream
write_bitstream -force [file join $build ${top}.bit]

# ------------------------------------------------------------------ summary
set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
set whs [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -hold]]
puts "INFO: RESULT WNS = $wns ns, WHS = $whs ns (both must be >= 0)"
file copy -force [file join $build post_route_utilization.rpt] \
    [file join $repo docs verification "${date}_top_debug_demo_utilization.rpt"]
file copy -force [file join $build post_route_timing_summary.rpt] \
    [file join $repo docs verification "${date}_top_debug_demo_timing.rpt"]
puts "INFO: bitstream  [file join $build ${top}.bit]"
puts "INFO: reports copied to docs/verification/${date}_top_debug_demo_*.rpt"
