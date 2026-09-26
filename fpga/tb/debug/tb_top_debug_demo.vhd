--------------------------------------------------------------------------------
-- tb_top_debug_demo.vhd
-- Purpose : Self-checking testbench for the Lab-DEBUG demo top level with the real
--           debug_rom IP (N = 14, 16 384 words) and the committed COE file.
--             TB-TOPDBG-01  bouncing BTNU press -> exactly one frame of
--                           8 + 4*2^14 bytes: start word, all ROM words MSB
--                           byte first (expected values read from the COE),
--                           end word; 8N1 framing; LD6 low during / high after
--             TB-TOPDBG-02  button held beyond the end of the transfer and
--                           released with bounce -> no second frame
--             TB-TOPDBG-03  second press -> second identical frame; a press
--                           during the transfer is ignored (REQ-IF-007)
-- Design  : docs/architecture/subsystems/top_debug_demo.md §15, §17
-- Reqs    : REQ-DEBUG-016, REQ-DEBUG-001, REQ-DEBUG-005..007, REQ-IF-002,
--           REQ-IF-006, REQ-IF-007, DEC-019
-- Output  : "Expected / Actual / PASS|FAIL" per check, final TB_RESULT line (DEC-011)
-- Run     : vivado -mode batch -source fpga/vivado/sim_top_debug_demo.tcl
-- Settings: 10 clocks/bit (G_BAUD_RATE = 10 MHz) and G_DEBOUNCE_CYCLES = 50 to keep
--           the run short; everything else as in hardware (N = 14, latency 2).
-- Author  : Eren (eeerenbuyukbas)
-- AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0010
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_top_debug_demo is
    generic (
        G_COE_FILE : string := "debug_rom.coe"          -- copied into the sim directory
    );
end entity tb_top_debug_demo;

architecture sim of tb_top_debug_demo is

    constant C_CLK_PERIOD   : time     := 10 ns;          -- 100 MHz
    constant C_N            : positive := 14;
    constant C_WORDS        : positive := 2 ** C_N;
    constant C_CLK_HZ       : positive := 100_000_000;
    constant C_BAUD         : positive := 10_000_000;     -- simulation only
    constant C_CLKS_PER_BIT : positive := C_CLK_HZ / C_BAUD;
    constant C_BIT_TIME     : time     := C_CLKS_PER_BIT * C_CLK_PERIOD;
    constant C_D            : positive := 50;             -- debounce cycles (simulation)
    constant C_FRAME_BYTES  : positive := 8 + 4 * C_WORDS;
    constant C_START_WORD   : std_logic_vector(31 downto 0) := x"55AACC03";
    constant C_END_WORD     : std_logic_vector(31 downto 0) := x"AA5503CC";
    -- one frame: 10 bits + 2 clocks per byte, plus the memory wait per word, with margin
    constant C_FRAME_TIME   : time := (C_FRAME_BYTES * (10 * C_CLKS_PER_BIT + 2) + C_WORDS * 4)
                                      * C_CLK_PERIOD * 11 / 10;

    type t_mem is array (0 to C_WORDS - 1) of std_logic_vector(31 downto 0);

    -- reads the data values of a Block Memory Generator COE file (radix 16)
    impure function load_coe(name : string) return t_mem is
        file     f     : text open read_mode is name;
        variable l     : line;
        variable w     : std_logic_vector(31 downto 0);
        variable good  : boolean;
        variable m     : t_mem := (others => (others => 'U'));
        variable k     : natural := 0;
        variable is_kw : boolean;
    begin
        while not endfile(f) and k < C_WORDS loop
            readline(f, l);
            is_kw := false;                               -- skip "...RADIX=16;" / "...VECTOR="
            for i in l'range loop
                if l(i) = '=' then
                    is_kw := true;
                end if;
            end loop;
            if not is_kw and l'length >= 8 then
                hread(l, w, good);
                if good then
                    m(k) := w;
                    k    := k + 1;
                end if;
            end if;
        end loop;
        assert k = C_WORDS
            report "tb_top_debug_demo: COE file " & name & " has " & integer'image(k) &
                   " words, expected " & integer'image(C_WORDS)
            severity failure;
        return m;
    end function load_coe;

    function hex(v : std_logic_vector) return string is
        constant C_DIGITS : string(1 to 16) := "0123456789ABCDEF";
        variable r        : string(1 to v'length / 4);
        variable nib      : std_logic_vector(3 downto 0);
    begin
        for i in r'range loop
            nib := v(v'left - 4 * (i - 1) downto v'left - 4 * (i - 1) - 3);
            if is_x(nib) then
                r(i) := 'X';
            else
                r(i) := C_DIGITS(to_integer(unsigned(nib)) + 1);
            end if;
        end loop;
        return r;
    end function hex;

    signal mem       : t_mem := load_coe(G_COE_FILE);

    signal clk       : std_logic := '0';
    signal reset_btn : std_logic := '0';
    signal start_btn : std_logic := '0';
    signal txd       : std_logic;
    signal ready     : std_logic;
    signal sim_done  : boolean   := false;

    -- UART receiver results (single driver: process rx)
    signal rx_bytes      : natural := 0;                   -- bytes received in total
    signal rx_data_err   : natural := 0;                   -- bytes different from expected
    signal rx_frame_err  : natural := 0;                   -- bad start or stop bit
    signal first_err_pos : integer := -1;                  -- byte index of the first error
    signal first_err_exp : std_logic_vector(7 downto 0) := (others => '0');
    signal first_err_act : std_logic_vector(7 downto 0) := (others => '0');

begin

    clk <= not clk after C_CLK_PERIOD / 2 when not sim_done else '0';

    dut : entity work.top_debug_demo
        generic map (
            N                 => C_N,
            G_CLK_FREQ_HZ     => C_CLK_HZ,
            G_BAUD_RATE       => C_BAUD,
            G_MEM_LATENCY     => 2,
            G_DEBOUNCE_CYCLES => C_D
        )
        port map (
            clock_in  => clk,
            reset_in  => reset_btn,
            start_in  => start_btn,
            txd_out   => txd,
            ready_out => ready
        );

    -- Behavioural UART receiver (8N1, sampled in the middle of each bit). Every
    -- byte is compared with the expected byte at its position in the frame.
    rx : process
        variable b    : std_logic_vector(7 downto 0);
        variable pos  : natural;
        variable w    : std_logic_vector(31 downto 0);
        variable e    : std_logic_vector(7 downto 0);
        variable bi   : natural;
    begin
        wait until txd = '0';                              -- falling edge of the start bit
        wait for C_BIT_TIME / 2;
        if txd /= '0' then
            rx_frame_err <= rx_frame_err + 1;
        end if;
        for i in 0 to 7 loop                               -- LSB first (REQ-DEBUG-008)
            wait for C_BIT_TIME;
            b(i) := txd;
        end loop;
        wait for C_BIT_TIME;                               -- middle of the stop bit
        if txd /= '1' then
            rx_frame_err <= rx_frame_err + 1;
        end if;

        pos := rx_bytes mod C_FRAME_BYTES;                 -- position inside its frame
        if pos < 4 then
            w := C_START_WORD;
        elsif pos >= C_FRAME_BYTES - 4 then
            w := C_END_WORD;
        else
            w := mem((pos - 4) / 4);
        end if;
        bi := pos mod 4;                                   -- 0 = most significant byte
        e  := w(31 - 8 * bi downto 24 - 8 * bi);
        if b /= e then
            rx_data_err <= rx_data_err + 1;
            if first_err_pos < 0 then
                first_err_pos <= rx_bytes;
                first_err_exp <= e;
                first_err_act <= b;
            end if;
        end if;
        rx_bytes <= rx_bytes + 1;
    end process rx;

    watchdog : process
    begin
        wait until sim_done for 5 * C_FRAME_TIME;
        if not sim_done then
            report "TB_RESULT: FAIL (timeout - simulation did not finish)" severity failure;
        end if;
        wait;
    end process watchdog;

    stim : process

        type t_step is record
            value  : std_logic;
            cycles : positive;
        end record;
        type t_steps is array (natural range <>) of t_step;

        variable n_pass : natural := 0;
        variable n_fail : natural := 0;
        variable b0     : natural;

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
            wait for 1 ns;
        end procedure clks;

        procedure drive(signal s : out std_logic; steps : t_steps) is
        begin
            for i in steps'range loop
                s <= steps(i).value;
                clks(steps(i).cycles);
            end loop;
        end procedure drive;

        function img(v : integer) return string is
        begin
            return integer'image(v);
        end function img;

        -- report the content result of the frames received so far
        procedure check_frames(name : string; frames : natural) is
        begin
            check(name & " bytes received", rx_bytes = frames * C_FRAME_BYTES,
                  img(frames * C_FRAME_BYTES), img(rx_bytes));
            check(name & " 8N1 framing errors", rx_frame_err = 0, "0", img(rx_frame_err));
            if rx_data_err = 0 then
                check(name & " bytes different from COE/header/footer", true, "0", "0");
            else
                check(name & " bytes different from COE/header/footer", false, "0",
                      img(rx_data_err) & " (first at byte " & img(first_err_pos) &
                      ": expected " & hex(first_err_exp) & ", got " & hex(first_err_act) & ")");
            end if;
        end procedure check_frames;

    begin
        -------------------------------------------------------------- reset (BTNC)
        drive(reset_btn, (('1', 20), ('0', 20)));
        check("RESET        txd idle", txd = '1', "'1'", std_logic'image(txd));
        check("RESET        LD6 (ready) on", ready = '1', "'1'", std_logic'image(ready));

        ------------------------------------------------------------- TB-TOPDBG-01
        -- bouncing press, then the button stays pressed (used again in TB-TOPDBG-02)
        drive(start_btn, (('1', 3), ('0', 2), ('1', 4), ('0', 1)));
        start_btn <= '1';
        wait until ready = '0' for 20 * C_D * C_CLK_PERIOD;
        check("TB-TOPDBG-01 LD6 off after press (transfer started)", ready = '0', "'0'",
              std_logic'image(ready));
        wait until ready = '1' for C_FRAME_TIME;
        check("TB-TOPDBG-01 LD6 on again after the transfer", ready = '1', "'1'",
              std_logic'image(ready));
        check("TB-TOPDBG-01 LD6 stayed off until the last byte", rx_bytes = C_FRAME_BYTES,
              img(C_FRAME_BYTES) & " bytes when LD6 turns on", img(rx_bytes));
        clks(20 * C_CLKS_PER_BIT);
        check_frames("TB-TOPDBG-01", 1);

        ------------------------------------------------------------- TB-TOPDBG-02
        -- still held after the transfer; release with bounce -> no new transfer
        b0 := rx_bytes;
        clks(10 * C_D);
        drive(start_btn, (('0', 3), ('1', 2), ('0', 4), ('1', 1), ('0', 10 * C_D)));
        clks(30 * C_CLKS_PER_BIT);
        check("TB-TOPDBG-02 bytes after hold + bouncing release", rx_bytes - b0 = 0, "0",
              img(rx_bytes - b0));
        check("TB-TOPDBG-02 LD6 still on", ready = '1', "'1'", std_logic'image(ready));

        ------------------------------------------------------------- TB-TOPDBG-03
        -- second press; during the transfer the button is released and pressed again
        drive(start_btn, (('1', 2), ('0', 3), ('1', 5 * C_D), ('0', 5 * C_D)));
        check("TB-TOPDBG-03 second transfer started", ready = '0', "'0'", std_logic'image(ready));
        drive(start_btn, (('1', 5 * C_D), ('0', 5 * C_D)));      -- press while busy
        check("TB-TOPDBG-03 still busy after the press during transfer", ready = '0', "'0'",
              std_logic'image(ready));
        wait until ready = '1' for C_FRAME_TIME;
        clks(30 * C_CLKS_PER_BIT);
        check_frames("TB-TOPDBG-03", 2);                    -- exactly two frames in total

        ------------------------------------------------------------------ summary
        if n_fail = 0 then
            report "TB_RESULT: PASS (" & img(n_pass) & "/" & img(n_pass) & " checks)" severity note;
        else
            report "TB_RESULT: FAIL (" & img(n_fail) & " of " & img(n_pass + n_fail) &
                   " checks failed)" severity error;
        end if;
        sim_done <= true;
        wait;
    end process stim;

end architecture sim;
