--------------------------------------------------------------------------------
-- tb_debug.vhd
-- Purpose : Self-checking testbench for Lab-DEBUG (debug + uart_tx),
--           TEST_PLAN.md §1, TB-DEBUG-01 .. TB-DEBUG-09.
--   Three DUT instances, N = 3 (8 words), 10 clocks per bit:
--     DUT 0: G_MEM_LATENCY = 2, memory latency 2   (main tests)
--     DUT 1: G_MEM_LATENCY = 1, memory latency 1   (TB-DEBUG-07)
--     DUT 2: G_MEM_LATENCY = 2, memory latency 1   (TB-DEBUG-07: waiting longer is safe)
--   Memory content contains the delimiter values, 0x00000000, 0xFFFFFFFF and
--   single-bit patterns (TB-DEBUG-08, DEC-010).
-- Reqs    : REQ-DEBUG-003..007, -012..014, -019, REQ-IF-002/003/006/007
-- Output  : "Expected / Actual / PASS|FAIL" per check, final TB_RESULT line (DEC-011)
-- Run     : Vivado "Run Behavioral Simulation", then "Run All" (or Tcl: run all)
-- Author  : Hande Eryilmaz
-- AI      : AI-assisted (Claude Opus 5.5, claude.ai chat, 2026-09-26), AI-0004
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_debug is
end entity tb_debug;

architecture sim of tb_debug is

    ------------------------------------------------------------------ settings
    constant C_N          : positive := 3;                     -- 2^3 = 8 words
    constant C_WORDS      : positive := 2 ** C_N;
    constant C_CLK_FREQ   : positive := 100_000_000;
    constant C_BAUD       : positive := 10_000_000;            -- 10 clocks per bit
    constant C_C          : positive := C_CLK_FREQ / C_BAUD;
    constant C_CLK_PERIOD : time     := 10 ns;
    constant C_FRAME      : positive := 8 + 4 * C_WORDS;       -- bytes per transfer
    constant C_NDUT       : positive := 3;

    type t_nat_arr is array (0 to C_NDUT - 1) of natural;
    constant C_G_LAT   : t_nat_arr := (2, 1, 2);    -- DUT generic G_MEM_LATENCY
    constant C_MEM_LAT : t_nat_arr := (2, 1, 1);    -- latency of the memory model

    ------------------------------------------------------------ memory content
    subtype t_word is std_logic_vector(31 downto 0);
    subtype t_byte is std_logic_vector(7 downto 0);
    type t_words is array (0 to C_WORDS - 1) of t_word;
    constant C_MEM : t_words := (
        x"55AACC03",   -- start delimiter value inside the payload
        x"AA5503CC",   -- end delimiter value inside the payload
        x"00000000",
        x"FFFFFFFF",
        x"00000001",
        x"80000000",
        x"12345678",
        x"89ABCDEF");

    type t_frame is array (0 to C_FRAME - 1) of t_byte;

    function build_expected return t_frame is
        variable f : t_frame;
        constant START_W : t_word := x"55AACC03";
        constant END_W   : t_word := x"AA5503CC";
    begin
        for b in 0 to 3 loop
            f(b)               := START_W(31 - 8 * b downto 24 - 8 * b);
            f(C_FRAME - 4 + b) := END_W(31 - 8 * b downto 24 - 8 * b);
        end loop;
        for k in 0 to C_WORDS - 1 loop
            for b in 0 to 3 loop                        -- MSB byte first
                f(4 + 4 * k + b) := C_MEM(k)(31 - 8 * b downto 24 - 8 * b);
            end loop;
        end loop;
        return f;
    end function build_expected;

    constant C_EXPECTED : t_frame := build_expected;

    function hex(v : t_byte) return string is
        constant H : string(1 to 16) := "0123456789ABCDEF";
        variable r : string(1 to 4);
    begin
        r(1) := '0';
        r(2) := 'x';
        r(3) := H(to_integer(unsigned(v(7 downto 4))) + 1);
        r(4) := H(to_integer(unsigned(v(3 downto 0))) + 1);
        return r;
    end function hex;

    ------------------------------------------------------------------- signals
    type t_addr_arr is array (0 to C_NDUT - 1) of std_logic_vector(C_N - 1 downto 0);
    type t_int_arr  is array (0 to C_NDUT - 1) of integer;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal sim_done : boolean   := false;

    signal start_v  : std_logic_vector(0 to C_NDUT - 1) := (others => '0');
    signal txd_v    : std_logic_vector(0 to C_NDUT - 1);
    signal ready_v  : std_logic_vector(0 to C_NDUT - 1);
    signal addr_v   : t_addr_arr;

    signal addr_chg : t_int_arr := (others => 0);   -- number of address changes
    signal addr_err : t_int_arr := (others => 0);   -- changes that are not +1 and not 0
    signal rdy_rise : t_int_arr := (others => 0);   -- rising edges of ready_out

begin

    clk <= not clk after C_CLK_PERIOD / 2 when not sim_done else '0';

    ------------------------------------------ DUTs, memory models and monitors
    g_dut : for i in 0 to C_NDUT - 1 generate
        signal s1, s2, mem_data : t_word := (others => '0');
    begin

        dut : entity work.debug
            generic map (
                N             => C_N,
                G_CLK_FREQ_HZ => C_CLK_FREQ,
                G_BAUD_RATE   => C_BAUD,
                G_MEM_LATENCY => C_G_LAT(i)
            )
            port map (
                clock_in     => clk,
                reset_in     => rst,
                start_in     => start_v(i),
                mem_addr_out => addr_v(i),
                mem_data_in  => mem_data,
                txd_out      => txd_v(i),
                ready_out    => ready_v(i)
            );

        -- Block-RAM-like read port: latency 1 (s1) or 2 (s2) clock cycles
        mem_model : process (clk)
        begin
            if rising_edge(clk) then
                s1 <= C_MEM(to_integer(unsigned(addr_v(i))));
                s2 <= s1;
            end if;
        end process mem_model;

        mem_data <= s1 when C_MEM_LAT(i) = 1 else s2;

        -- address monitor: every change must be +1 (data phase) or to 0 (start/reset)
        addr_mon : process (addr_v(i))
            variable prev : integer := 0;
            variable cur  : integer;
        begin
            if now > 0 ns then
                cur := to_integer(unsigned(addr_v(i)));
                addr_chg(i) <= addr_chg(i) + 1;
                if cur /= prev + 1 and cur /= 0 then
                    addr_err(i) <= addr_err(i) + 1;
                end if;
                prev := cur;
            end if;
        end process addr_mon;

        ready_mon : process (ready_v(i))
        begin
            if rising_edge(ready_v(i)) then
                rdy_rise(i) <= rdy_rise(i) + 1;
            end if;
        end process ready_mon;

    end generate g_dut;

    watchdog : process
    begin
        wait until sim_done for 3 ms;
        if not sim_done then
            report "TB_RESULT: FAIL (timeout - simulation did not finish)" severity failure;
        end if;
        wait;
    end process watchdog;

    ----------------------------------------------------------------- stimulus
    stim : process

        variable n_pass : natural := 0;
        variable n_fail : natural := 0;
        variable frame1 : t_frame;
        variable frame2 : t_frame;
        variable same   : boolean;

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

        procedure check_sl(name : string; actual : std_logic; expected : std_logic) is
        begin
            check(name, actual = expected, std_logic'image(expected), std_logic'image(actual));
        end procedure check_sl;

        procedure check_int(name : string; actual : integer; expected : integer) is
        begin
            check(name, actual = expected, integer'image(expected), integer'image(actual));
        end procedure check_int;

        procedure clks(k : natural) is
        begin
            for i in 1 to k loop
                wait until rising_edge(clk);
            end loop;
        end procedure clks;

        -- One complete transfer on DUT d with all per-transfer checks.
        -- busy_at >= 0: extra start pulses after byte busy_at and busy_at + 13 (TB-DEBUG-05).
        -- Must be called right after a rising clock edge.
        procedure do_transfer(d : natural; lbl : string; busy_at : integer; frame : out t_frame) is
            variable t_es, t_mid : time;
            variable fr          : t_frame := (others => x"00");
            variable nb, ferr    : natural := 0;
            variable mism        : natural := 0;
            variable a0, e0, r0  : integer;
            variable n           : integer;
        begin
            -- TB-DEBUG-02 handshake
            check_sl(lbl & " ready high before start", ready_v(d), '1');
            r0 := rdy_rise(d);
            start_v(d) <= '1';
            wait until rising_edge(clk);                 -- DUT samples start_in here
            t_es := now;
            check_sl(lbl & " ready still high at the sampling edge", ready_v(d), '1');
            start_v(d) <= '0';
            wait for 1 ns;
            check_sl(lbl & " ready low right after the sampling edge", ready_v(d), '0');
            check_int(lbl & " address = 0 at start", to_integer(unsigned(addr_v(d))), 0);
            a0 := addr_chg(d);
            e0 := addr_err(d);

            wait until txd_v(d) = '0' for 5 * C_C * C_CLK_PERIOD;
            n := (now - t_es) / C_CLK_PERIOD;
            check_int(lbl & " first start bit, clocks after sampling edge", n, 1);

            -- receive the frame (behavioural UART receiver, mid-bit sampling)
            for b in 0 to C_FRAME - 1 loop
                if b > 0 then
                    wait until txd_v(d) = '0' for 30 * C_C * C_CLK_PERIOD;
                    exit when txd_v(d) /= '0';           -- DUT stopped sending
                end if;
                clks(C_C / 2);
                if txd_v(d) /= '0' then ferr := ferr + 1; end if;
                for i in 0 to 7 loop
                    clks(C_C);
                    fr(b)(i) := txd_v(d);
                end loop;
                clks(C_C);
                if txd_v(d) /= '1' then ferr := ferr + 1; end if;
                nb := nb + 1;
                if busy_at >= 0 and (b = busy_at or b = busy_at + 13) then
                    start_v(d) <= '1';                   -- start while busy (TB-DEBUG-05)
                    wait until rising_edge(clk);
                    start_v(d) <= '0';
                end if;
            end loop;
            t_mid := now;                                -- middle of the last stop bit

            -- TB-DEBUG-03 / -08 frame content
            check_int(lbl & " byte count", nb, C_FRAME);
            for b in 0 to C_FRAME - 1 loop
                if fr(b) /= C_EXPECTED(b) then
                    if mism < 3 then
                        report lbl & " byte " & integer'image(b) & " expected " &
                               hex(C_EXPECTED(b)) & " got " & hex(fr(b)) severity warning;
                    end if;
                    mism := mism + 1;
                end if;
            end loop;
            check_int(lbl & " mismatching bytes (header, 8 words MSB first, end word)", mism, 0);
            check_int(lbl & " UART framing errors", ferr, 0);

            -- TB-DEBUG-02 ready returns high 2 clocks after the last stop bit
            check_sl(lbl & " ready still low during the last stop bit", ready_v(d), '0');
            wait until ready_v(d) = '1' for 50 * C_CLK_PERIOD;
            n := (now - t_mid) / C_CLK_PERIOD - C_C / 2;
            check_int(lbl & " ready rises N clocks after the last stop bit", n, 2);

            -- nothing is sent after the end word
            wait until txd_v(d) = '0' for 15 * C_C * C_CLK_PERIOD;
            check_sl(lbl & " line idle after the end word", txd_v(d), '1');

            -- TB-DEBUG-04 address sequence
            check_int(lbl & " address changes (1 .. 2^N-1)", addr_chg(d) - a0, C_WORDS - 1);
            check_int(lbl & " address order errors", addr_err(d) - e0, 0);
            check_int(lbl & " ready rising edges during transfer", rdy_rise(d) - r0, 1);

            frame := fr;
            wait until rising_edge(clk);
        end procedure do_transfer;

    begin
        ------------------------------------------------------------ TB-DEBUG-01
        rst <= '1';
        clks(5);
        for d in 0 to C_NDUT - 1 loop
            check_sl("TB-DEBUG-01 DUT" & integer'image(d) & " reset: txd idle", txd_v(d), '1');
            check_sl("TB-DEBUG-01 DUT" & integer'image(d) & " reset: ready high", ready_v(d), '1');
            check_int("TB-DEBUG-01 DUT" & integer'image(d) & " reset: address 0",
                      to_integer(unsigned(addr_v(d))), 0);
        end loop;
        rst <= '0';
        clks(5);

        --------------------------------------------- TB-DEBUG-02/03/04/08 (DUT 0)
        do_transfer(0, "TB-DEBUG-02/03/04/08", -1, frame1);

        ------------------------------------------------------------ TB-DEBUG-09
        clks(20);
        do_transfer(0, "TB-DEBUG-09 second transfer", -1, frame2);
        same := true;
        for b in 0 to C_FRAME - 1 loop
            if frame1(b) /= frame2(b) then same := false; end if;
        end loop;
        check("TB-DEBUG-09 second frame identical to the first", same, "true", boolean'image(same));

        ------------------------------------------------------------ TB-DEBUG-05
        clks(20);
        do_transfer(0, "TB-DEBUG-05 start pulses while busy", 5, frame2);

        ------------------------------------------------------------ TB-DEBUG-06
        clks(20);
        start_v(0) <= '1';
        wait until rising_edge(clk);
        start_v(0) <= '0';
        clks(10 * (10 * C_C + 2) + 3 * C_C);         -- about 10 bytes into the frame
        rst <= '1';
        clks(2);
        wait for 1 ns;
        check_sl("TB-DEBUG-06 reset mid-transfer: txd idle", txd_v(0), '1');
        check_sl("TB-DEBUG-06 reset mid-transfer: ready high", ready_v(0), '1');
        check_int("TB-DEBUG-06 reset mid-transfer: address 0", to_integer(unsigned(addr_v(0))), 0);
        wait until rising_edge(clk);
        rst <= '0';
        clks(15 * C_C);                              -- let the receiver drop the cut byte
        do_transfer(0, "TB-DEBUG-06 new transfer after reset", -1, frame2);

        ------------------------------------------------------------ TB-DEBUG-07
        clks(20);
        do_transfer(1, "TB-DEBUG-07 latency 1 (G_MEM_LATENCY=1)", -1, frame2);
        clks(20);
        do_transfer(2, "TB-DEBUG-07 memory latency 1, G_MEM_LATENCY=2", -1, frame2);

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
