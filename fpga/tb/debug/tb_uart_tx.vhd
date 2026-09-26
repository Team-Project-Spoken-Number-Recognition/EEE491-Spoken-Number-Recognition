--------------------------------------------------------------------------------
-- tb_uart_tx.vhd
-- Purpose : Self-checking testbench for uart_tx (TEST_PLAN.md §1)
--             TB-UART-01  bytes 0x55, 0x00, 0xFF, 0x81: start bit, 8 data bits
--                         LSB first, stop bit, 1-cycle done pulse, idle line
--             TB-UART-02  real divider (100 clocks/bit): every bit period and
--                         the frame length measured in clock cycles
--             TB-UART-03  back-to-back bytes: correct data, stop bit >= 1 bit
-- Reqs    : REQ-DEBUG-008, REQ-DEBUG-009, REQ-PERF-001
-- Output  : one "Expected / Actual / PASS|FAIL" line per check and a final
--           "TB_RESULT: PASS (k/k checks)" or "TB_RESULT: FAIL ..." (DEC-011)
-- Run     : Vivado "Run Behavioral Simulation", then "Run All" (or Tcl: run all)
-- Author  : Hande Eryilmaz
-- AI      : AI-assisted (Claude Opus 5.5, claude.ai chat, 2026-09-26), AI-0004
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart_tx is
end entity tb_uart_tx;

architecture sim of tb_uart_tx is

    constant C_CLK_PERIOD : time     := 10 ns;   -- 100 MHz
    constant C_FAST       : positive := 10;      -- short divider for TB-UART-01/03
    constant C_REAL       : positive := 100;     -- hardware divider for TB-UART-02

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal sim_done : boolean   := false;

    -- DUT A: fast divider
    signal a_start : std_logic := '0';
    signal a_data  : std_logic_vector(7 downto 0) := (others => '0');
    signal a_txd   : std_logic;
    signal a_done  : std_logic;

    -- DUT B: real divider
    signal b_start : std_logic := '0';
    signal b_data  : std_logic_vector(7 downto 0) := (others => '0');
    signal b_txd   : std_logic;
    signal b_done  : std_logic;

    function hex(v : std_logic_vector(7 downto 0)) return string is
        constant H : string(1 to 16) := "0123456789ABCDEF";
        variable r : string(1 to 4);
    begin
        r(1) := '0';
        r(2) := 'x';
        r(3) := H(to_integer(unsigned(v(7 downto 4))) + 1);
        r(4) := H(to_integer(unsigned(v(3 downto 0))) + 1);
        return r;
    end function hex;

begin

    clk <= not clk after C_CLK_PERIOD / 2 when not sim_done else '0';

    dut_a : entity work.uart_tx
        generic map (G_CLKS_PER_BIT => C_FAST)
        port map (
            clock_in    => clk,
            reset_in    => rst,
            tx_start_in => a_start,
            tx_data_in  => a_data,
            txd_out     => a_txd,
            tx_done_out => a_done
        );

    dut_b : entity work.uart_tx
        generic map (G_CLKS_PER_BIT => C_REAL)
        port map (
            clock_in    => clk,
            reset_in    => rst,
            tx_start_in => b_start,
            tx_data_in  => b_data,
            txd_out     => b_txd,
            tx_done_out => b_done
        );

    -- stops a hanging simulation (e.g. no start bit ever appears)
    watchdog : process
    begin
        wait until sim_done for 1 ms;
        if not sim_done then
            report "TB_RESULT: FAIL (timeout - simulation did not finish)" severity failure;
        end if;
        wait;
    end process watchdog;

    stim : process

        type t_bytes is array (natural range <>) of std_logic_vector(7 downto 0);
        constant C_TEST_BYTES : t_bytes(0 to 3) := (x"55", x"00", x"FF", x"81");

        variable n_pass  : natural := 0;
        variable n_fail  : natural := 0;
        variable rx      : std_logic_vector(7 downto 0);
        variable start_b : std_logic;
        variable stop_b  : std_logic;
        variable t0, t1  : time;
        variable t_start : time;
        variable n       : integer;

        procedure check(name : string; ok : boolean; expected : string; actual : string) is
        begin
            if ok then
                n_pass := n_pass + 1;
                report name & "  Expected: " & expected & "  Actual: " & actual & "  PASS"
                    severity note;
            else
                n_fail := n_fail + 1;
                report name & "  Expected: " & expected & "  Actual: " & actual & "  FAIL"
                    severity error;
            end if;
        end procedure check;

        procedure clks(k : natural) is
        begin
            for i in 1 to k loop
                wait until rising_edge(clk);
            end loop;
        end procedure clks;

        -- Drive a 1-cycle start pulse. Must be called right after a rising edge.
        procedure send(signal start : out std_logic;
                       signal data  : out std_logic_vector(7 downto 0);
                       b            : std_logic_vector(7 downto 0)) is
        begin
            data  <= b;
            start <= '1';
            wait until rising_edge(clk);   -- DUT samples start here
            start <= '0';
        end procedure send;

        -- Behavioural UART receiver: samples every bit in its middle.
        -- skip_start_wait = true when the caller has already seen the falling edge.
        procedure uart_receive(signal txd       : in  std_logic;
                               c                : positive;
                               data             : out std_logic_vector(7 downto 0);
                               start_bit        : out std_logic;
                               stop_bit         : out std_logic;
                               skip_start_wait  : boolean := false) is
        begin
            if not skip_start_wait then
                wait until txd = '0';      -- start bit begins
            end if;
            clks(c / 2);                   -- middle of the start bit
            start_bit := txd;
            for i in 0 to 7 loop           -- D0 first (LSB first)
                clks(c);
                data(i) := txd;
            end loop;
            clks(c);                       -- middle of the stop bit
            stop_bit := txd;
        end procedure uart_receive;

    begin
        ------------------------------------------------------------------ reset
        rst <= '1';
        clks(5);
        check("RESET       DUT A line idle", a_txd = '1', "'1'", std_logic'image(a_txd));
        check("RESET       DUT B line idle", b_txd = '1', "'1'", std_logic'image(b_txd));
        rst <= '0';
        clks(5);

        ------------------------------------------------------------ TB-UART-01
        for k in C_TEST_BYTES'range loop
            send(a_start, a_data, C_TEST_BYTES(k));
            uart_receive(a_txd, C_FAST, rx, start_b, stop_b);
            check("TB-UART-01  " & hex(C_TEST_BYTES(k)) & " start bit",
                  start_b = '0', "'0'", std_logic'image(start_b));
            check("TB-UART-01  " & hex(C_TEST_BYTES(k)) & " data     ",
                  rx = C_TEST_BYTES(k), hex(C_TEST_BYTES(k)), hex(rx));
            check("TB-UART-01  " & hex(C_TEST_BYTES(k)) & " stop bit ",
                  stop_b = '1', "'1'", std_logic'image(stop_b));
            wait until rising_edge(clk) and a_done = '1';
            clks(1);
            check("TB-UART-01  " & hex(C_TEST_BYTES(k)) & " done is 1 cycle",
                  a_done = '0', "'0'", std_logic'image(a_done));
            check("TB-UART-01  " & hex(C_TEST_BYTES(k)) & " idle after frame",
                  a_txd = '1', "'1'", std_logic'image(a_txd));
            clks(3);
        end loop;

        ------------------------------------------------------------ TB-UART-03
        send(a_start, a_data, x"00");
        for k in 1 to 3 loop
            uart_receive(a_txd, C_FAST, rx, start_b, stop_b, skip_start_wait => k > 1);
            check("TB-UART-03  byte " & integer'image(k) & " data + framing",
                  rx = x"00" and start_b = '0' and stop_b = '1',
                  "0x00, start '0', stop '1'", hex(rx));
            t0 := now;                                   -- middle of the stop bit
            if k < 3 then
                wait until rising_edge(clk) and a_done = '1';
                send(a_start, a_data, x"00");            -- next byte immediately
                wait until a_txd = '0';                  -- next start bit
                t1 := now;
                -- data 0x00 -> D7 = '0', so the line is high only during the stop bit
                n := (t1 - t0) / C_CLK_PERIOD + C_FAST / 2;
                check("TB-UART-03  stop bit length before byte " & integer'image(k + 1) & " (clocks)",
                      n >= C_FAST, ">= " & integer'image(C_FAST), integer'image(n));
            end if;
        end loop;

        ------------------------------------------------------------ TB-UART-02
        -- 0x55 -> 0 1 0 1 0 1 0 1 0 1 on the line: a transition at every bit boundary
        send(b_start, b_data, x"55");
        wait until b_txd = '0';
        t_start := now;
        t0      := now;
        for i in 1 to 9 loop
            wait on b_txd;
            t1 := now;
            n  := (t1 - t0) / C_CLK_PERIOD;
            check("TB-UART-02  bit period " & integer'image(i) & " (clocks)",
                  n = C_REAL, integer'image(C_REAL), integer'image(n));
            t0 := t1;
        end loop;
        wait until b_done = '1';
        n := (now - t_start) / C_CLK_PERIOD;
        check("TB-UART-02  frame length (clocks)",
              n = 10 * C_REAL, integer'image(10 * C_REAL), integer'image(n));

        --------------------------------------------------------------- summary
        if n_fail = 0 then
            report "TB_RESULT: PASS (" & integer'image(n_pass) & "/" &
                   integer'image(n_pass) & " checks)" severity note;
        else
            report "TB_RESULT: FAIL (" & integer'image(n_fail) & " of " &
                   integer'image(n_pass + n_fail) & " checks failed)" severity error;
        end if;
        sim_done <= true;
        wait;
    end process stim;

end architecture sim;
