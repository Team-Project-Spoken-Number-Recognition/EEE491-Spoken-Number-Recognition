--------------------------------------------------------------------------------
-- top_debug_demo.vhd
-- Purpose : Basys-3 top level of the Lab-DEBUG demonstration (DBG §2, TA Q-04):
--           BTNU starts one transfer of the 16 384 x 32 demo ROM to MATLAB over
--           the USB-UART (1 Mbaud); LD6 shows ready_out. No Lab-CTRL.
-- Design  : docs/architecture/subsystems/top_debug_demo.md
-- Reqs    : REQ-DEBUG-010, REQ-DEBUG-016, REQ-DEBUG-017, REQ-CTRL-006 (inputs),
--           REQ-HW-002, REQ-IF-002, REQ-IF-006
-- Author  : Eren (eeerenbuyukbas)
-- AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0010
--
-- Pins (fpga/constraints/top_debug_demo.xdc, INTERFACES.md §1.1)
--   clock_in W5 (100 MHz), reset_in U18 (BTNC), start_in T18 (BTNU),
--   txd_out A18 (FT2232HQ RXD), ready_out U14 (LD6)
-- Sub-blocks
--   sync_2ff           reset synchroniser (DEC-007)
--   button_conditioner BTNU -> sync + debounce + 1-clock pulse (DEC-019)
--   debug              Lab-DEBUG (Hande, fpga/rtl/debug/debug.vhd)
--   debug_rom          demo ROM IP, read latency 2 (Ömer, fpga/ip/create_debug_rom.tcl)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity top_debug_demo is
    generic (
        N                 : positive := 14;           -- must equal C_ROM_ADDR_BITS
        G_CLK_FREQ_HZ     : positive := 100_000_000;
        G_BAUD_RATE       : positive := 1_000_000;    -- DEC-005
        G_MEM_LATENCY     : positive := 2;            -- >= debug_rom latency (TB-ROM-01)
        G_DEBOUNCE_CYCLES : positive := 1_000_000     -- 10 ms at 100 MHz (DEC-019)
    );
    port (
        clock_in  : in  std_logic;                    -- W5, 100 MHz
        reset_in  : in  std_logic;                    -- U18, BTNC, raw
        start_in  : in  std_logic;                    -- T18, BTNU, raw
        txd_out   : out std_logic;                    -- A18, UART to PC
        ready_out : out std_logic                     -- U14, LD6: '1' = idle
    );
end entity top_debug_demo;

architecture rtl of top_debug_demo is

    constant C_ROM_ADDR_BITS : positive := 14;        -- debug_rom: 16 384 words
    constant C_WORD_BITS     : positive := 32;        -- Lab-DEBUG word width

    -- Block Memory Generator IP (generated from fpga/ip/debug_rom/debug_rom.xci)
    component debug_rom is
        port (
            clka  : in  std_logic;
            addra : in  std_logic_vector(C_ROM_ADDR_BITS - 1 downto 0);
            douta : out std_logic_vector(C_WORD_BITS - 1 downto 0)
        );
    end component debug_rom;

    signal rst         : std_logic;
    signal start_pulse : std_logic;
    signal mem_addr    : std_logic_vector(N - 1 downto 0);
    signal mem_data    : std_logic_vector(C_WORD_BITS - 1 downto 0);

begin

    assert N = C_ROM_ADDR_BITS
        report "top_debug_demo: N must equal the debug_rom address width (14)"
        severity failure;

    -- BTNC -> synchronous reset; '1' after configuration = 2 reset cycles at power-up
    u_rst_sync : entity work.sync_2ff
        generic map (G_INIT => '1')
        port map (
            clock_in => clock_in,
            async_in => reset_in,
            sync_out => rst
        );

    -- BTNU -> exactly one start pulse per press
    u_start_btn : entity work.button_conditioner
        generic map (G_DEBOUNCE_CYCLES => G_DEBOUNCE_CYCLES)
        port map (
            clock_in  => clock_in,
            reset_in  => rst,
            button_in => start_in,
            pulse_out => start_pulse,
            level_out => open
        );

    u_debug : entity work.debug
        generic map (
            N             => N,
            G_CLK_FREQ_HZ => G_CLK_FREQ_HZ,
            G_BAUD_RATE   => G_BAUD_RATE,
            G_MEM_LATENCY => G_MEM_LATENCY
        )
        port map (
            clock_in     => clock_in,
            reset_in     => rst,
            start_in     => start_pulse,
            mem_addr_out => mem_addr,
            mem_data_in  => mem_data,
            txd_out      => txd_out,
            ready_out    => ready_out
        );

    u_rom : debug_rom
        port map (
            clka  => clock_in,
            addra => mem_addr,
            douta => mem_data
        );

end architecture rtl;
