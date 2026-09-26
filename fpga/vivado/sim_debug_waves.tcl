# ------------------------------------------------------------------------------
# sim_debug_waves.tcl
# Purpose : Lab-DEBUG demo waveforms (DBG §2: start, ready, UART transmit signals,
#           transactions). Runs tb_debug_waves (small scale: N = 2, 10 clocks/bit)
#           in XSim and either
#             - batch (default): writes fpga/vivado/build/debug_waves/debug_waves.vcd and
#               the figures simulation/waveforms/debug/debug_w*.svg (needs python on PATH), or
#             - gui:  opens the XSim waveform window with the demo signals already added.
# Usage (repository root, ASCII path without spaces, Vivado 2025.2 bin on PATH):
#   vivado -mode batch -source fpga/vivado/sim_debug_waves.tcl
#   vivado -mode batch -source fpga/vivado/sim_debug_waves.tcl -tclargs gui
# Author  : Eren (eeerenbuyukbas)
# AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0013
# ------------------------------------------------------------------------------

set repo  [file normalize [file join [file dirname [info script]] .. ..]]
set build [file join $repo fpga vivado build debug_waves]
set gui   [expr {[lsearch -exact $argv gui] >= 0}]
set srcs [list \
    [file join $repo fpga rtl common sync_2ff.vhd] \
    [file join $repo fpga rtl common button_conditioner.vhd] \
    [file join $repo fpga rtl debug uart_tx.vhd] \
    [file join $repo fpga rtl debug debug.vhd] \
    [file join $repo fpga tb debug tb_debug_waves.vhd] ]

file delete -force $build
file mkdir $build
cd $build

proc run {args} {
    # run an XSim tool (.bat on Windows) and stop on errors
    set cmd [concat [auto_execok [lindex $args 0]] [lrange $args 1 end]]
    if {[catch {exec {*}$cmd 2>@1} out]} { puts $out; error "failed: $args" }
    return $out
}

run xvhdl {*}$srcs
run xelab -debug typical tb_debug_waves -s tb_debug_waves

set T /tb_debug_waves
set D /tb_debug_waves/u_debug
set bits    [list $T/clk $T/btn_raw $T/btn_level $T/start_pulse $T/ready $T/txd $D/tx_start $D/tx_done]
set buses   [list $T/mem_addr $T/mem_stage $T/mem_data $D/word_reg $T/rx_byte]
set signals [concat $bits $buses]

if {$gui} {
    set f [open waves_gui.tcl w]
    foreach s $bits  { puts $f "add_wave $s" }
    foreach s $buses { puts $f "add_wave -radix hex $s" }
    puts $f "run all"
    close $f
    puts "INFO: opening the XSim GUI (close it to end this script)"
    exec {*}[auto_execok xsim] tb_debug_waves -gui -tclbatch waves_gui.tcl
    return
}

set f [open waves_vcd.tcl w]
puts $f "open_vcd debug_waves.vcd"
foreach s $signals { puts $f "log_vcd $s" }
puts $f "run all\nclose_vcd\nquit"
close $f
puts [run xsim tb_debug_waves -tclbatch waves_vcd.tcl]

set vcd [file join $build debug_waves.vcd]
set out [file join $repo simulation waveforms debug]
if {[catch {exec python [file join $repo simulation tools make_debug_waveforms.py] $vcd $out} msg]} {
    puts "WARNING: figure generation failed ($msg). Run manually:"
    puts "  python simulation/tools/make_debug_waveforms.py $vcd $out"
} else {
    puts $msg
}
