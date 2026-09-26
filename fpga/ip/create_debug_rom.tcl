# ------------------------------------------------------------------------------
# create_debug_rom.tcl
# Purpose : (Re)create the Lab-DEBUG demo ROM IP "debug_rom" from debug_rom.coe:
#           Block Memory Generator, Single Port ROM, 16384 x 32 bit, always
#           enabled, primitive output register ON (read latency 2 clocks).
# Design  : docs/architecture/subsystems/debug.md §12 (demo ROM)
# Reqs    : REQ-DEBUG-016, REQ-DEBUG-019; ASSUMPTION-011; DEC-008 (Vivado 2025.2), DEC-013
# Author  : Ömer (omerkutlu1030)
# AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0007
#
# Usage (from the repository root):
#   vivado -mode batch -source fpga/ip/create_debug_rom.tcl
# Result:
#   fpga/ip/debug_rom/debug_rom.xci   (committed; generated products are git-ignored)
# Regenerate the COE first if the test pattern changes:
#   matlab -batch "addpath('matlab/debug'); generate_debug_coe('fpga/ip/debug_rom.coe', 14)"
# ------------------------------------------------------------------------------

set ip_name   debug_rom
set part      xc7a35tcpg236-1                 ;# Basys-3 (ASSUMPTION-001)
set addr_bits 14                              ;# N = 14 (REQ-DEBUG-016)
set data_bits 32

set ip_root [file normalize [file dirname [info script]]]
set coe     [file join $ip_root ${ip_name}.coe]
set ip_dir  [file join $ip_root $ip_name]

if {![file exists $coe]} {
    error "COE file not found: $coe (run generate_debug_coe in MATLAB first)"
}
if {[file exists $ip_dir]} {
    file delete -force $ip_dir                ;# start clean, the script is the source of truth
}

create_project -in_memory -part $part
create_ip -name blk_mem_gen -vendor xilinx.com -library ip \
          -module_name $ip_name -dir $ip_root

set_property -dict [list \
    CONFIG.Interface_Type                             {Native} \
    CONFIG.Memory_Type                                {Single_Port_ROM} \
    CONFIG.Write_Width_A                              $data_bits \
    CONFIG.Read_Width_A                               $data_bits \
    CONFIG.Write_Depth_A                              [expr {1 << $addr_bits}] \
    CONFIG.Enable_A                                   {Always_Enabled} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {true} \
    CONFIG.Use_RSTA_Pin                               {false} \
    CONFIG.Load_Init_File                             {true} \
    CONFIG.Coe_File                                   $coe \
] [get_ips $ip_name]

set ip [get_ips $ip_name]
puts "INFO: created [get_property IPDEF $ip] -> [get_property IP_FILE $ip]"
foreach p {Memory_Type Write_Depth_A Read_Width_A Enable_A Register_PortA_Output_of_Memory_Primitives Coe_File} {
    puts [format "INFO:   %-44s = %s" $p [get_property CONFIG.$p $ip]]
}
