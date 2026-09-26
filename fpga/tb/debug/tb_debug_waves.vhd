--------------------------------------------------------------------------------
-- tb_debug_waves.vhd
-- Purpose : Waveform DEMONSTRATION testbench for the Lab-DEBUG demo (DBG §2:
--           "start, ready, UART transmit signals, transactions must be shown
--           clearly on the waveforms"). Small scale so one frame fits in one picture:
--             bouncing button -> button_conditioner (D = 8) -> debug (N = 2,
--             10 clocks/bit, G_MEM_LATENCY = 2) <- memory model (latency 2)
--           plus a behavioural UART receiver that shows each received byte.
--           A second press during the transfer shows that start is ignored.
--           Verification of the same behaviour is done by tb_debug (97 checks),
--           tb_button_conditioner (22) and tb_top_debug_demo (15); this bench has
--           a few sanity checks only.
-- Output  : VCD for simulation/tools/vcd_to_svg.py (script sim_debug_waves.tcl)
-- Author  : Eren (eeerenbuyukbas)
-- AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0013
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_debug_waves is
end entity tb_debug_waves;

architecture sim of tb_debug_waves is

    constant C_CLK_PERIOD : time     := 10 ns;
    constant C_N          : positive := 2;                 -- 4 words -> 24-byte frame
    constant C_BAUD       : positive := 10_000_000;        -- 10 clocks per bit
    constant C_BIT        : time     := 10 * C_CLK_PERIOD;
    constant C_D          : positive := 8;                 -- debounce cycles (demo)
    constant C_FRAME      : positive := 8 + 4 * 2 ** C_N;

    type t_mem is array (0 to 2 ** C_N - 1) of std_logic_vector(31 downto 0);
    -- word 2 / 3 contain the delimiter values on purpose (DEC-010)
    constant C_MEM : t_mem := (x"12345678", x"DEADBEEF", x"55AACC03", x"AA5503CC");

    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal btn_raw     : std_logic := '0';                 -- bouncing BTNU
    signal start_pulse : std_logic;                        -- debug.start_in
    signal btn_level   : std_logic;
    signal ready       : std_logic;                        -- debug.ready_out (LD6)
    signal txd         : std_logic;                        -- debug.txd_out
    signal mem_addr    : std_logic_vector(C_N - 1 downto 0);
    signal mem_data    : std_logic_vector(31 downto 0) := (others => '0');
    signal mem_stage   : std_logic_vector(31 downto 0) := (others => '0');
    signal rx_byte     : std_logic_vector(7 downto 0)  := (others => '0');  -- last byte decoded
    signal rx_count    : natural := 0;
    signal sim_done    : boolean := false;

begin

    clk <= not clk after C_CLK_PERIOD / 2 when not sim_done else '0';

    u_btn : entity work.button_conditioner
        generic map (G_DEBOUNCE_CYCLES => C_D)
        port map (clock_in => clk, reset_in => rst, button_in => btn_raw,
                  pulse_out => start_pulse, level_out => btn_level);

    u_debug : entity work.debug
        generic map (N => C_N, G_CLK_FREQ_HZ => 100_000_000, G_BAUD_RATE => C_BAUD,
                     G_MEM_LATENCY => 2)
        port map (clock_in => clk, reset_in => rst, start_in => start_pulse,
                  mem_addr_out => mem_addr, mem_data_in => mem_data,
                  txd_out => txd, ready_out => ready);

    -- memory model with read latency 2 (like the debug_rom IP with output register)
    mem : process (clk)
    begin
        if rising_edge(clk) then
            mem_stage <= C_MEM(to_integer(unsigned(mem_addr)));
            mem_data  <= mem_stage;
        end if;
    end process mem;

    -- behavioural UART receiver: shows every received byte on rx_byte
    rx : process
        variable b : std_logic_vector(7 downto 0);
    begin
        wait until txd = '0';
        wait for C_BIT / 2;
        for i in 0 to 7 loop
            wait for C_BIT;
            b(i) := txd;
        end loop;
        wait for C_BIT;
        assert txd = '1' report "stop bit missing" severity error;
        rx_byte  <= b;
        rx_count <= rx_count + 1;
    end process rx;

    stim : process
        procedure hold(v : std_logic; t : time) is
        begin
            btn_raw <= v;
            wait for t;
        end procedure hold;
    begin
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 150 ns;
        -- press with contact bounce, held, released with bounce
        hold('1', 30 ns); hold('0', 20 ns); hold('1', 40 ns); hold('0', 10 ns);
        hold('1', 400 ns);
        hold('0', 20 ns); hold('1', 20 ns); hold('0', 10 ns);
        -- second press in the middle of the transfer: must be ignored
        wait for 9 us;
        hold('1', 300 ns); hold('0', 10 ns);
        wait until ready = '1';
        wait for 2 us;
        assert rx_count = C_FRAME
            report "tb_debug_waves: received " & integer'image(rx_count) & " bytes, expected " &
                   integer'image(C_FRAME) severity error;
        report "tb_debug_waves: done, " & integer'image(rx_count) & " bytes received" severity note;
        sim_done <= true;
        wait;
    end process stim;

end architecture sim;
