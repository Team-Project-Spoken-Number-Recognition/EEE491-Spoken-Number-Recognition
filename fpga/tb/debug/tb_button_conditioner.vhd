--------------------------------------------------------------------------------
-- tb_button_conditioner.vhd
-- Purpose : Self-checking testbench for button_conditioner (and sync_2ff)
--             TB-BTN-01  clean press: exactly 1 pulse, 1 clock wide, after
--                        2 + D rising edges; press of exactly D clocks accepted
--             TB-BTN-02  press with bounce (glitches < D) -> exactly 1 pulse
--             TB-BTN-03  release with bounce -> 0 pulses; idle glitches of
--                        D/2 and D-1 clocks -> 0 pulses
--             TB-BTN-04  long hold (10 D) -> exactly 1 pulse
--             TB-BTN-05  press during reset -> no pulse while in reset; still
--                        held when reset ends -> 1 pulse (top_debug_demo.md §15)
-- Design  : docs/architecture/subsystems/top_debug_demo.md §6, §9, §17
-- Reqs    : REQ-IF-002, DEC-019, DEC-007
-- Output  : "Expected / Actual / PASS|FAIL" per check, final TB_RESULT line (DEC-011)
-- Run     : xvhdl sync_2ff.vhd button_conditioner.vhd tb_button_conditioner.vhd
--           xelab tb_button_conditioner -s tb_btn ; xsim tb_btn -R
-- Author  : Eren (eeerenbuyukbas)
-- AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0010
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity tb_button_conditioner is
end entity tb_button_conditioner;

architecture sim of tb_button_conditioner is

    constant C_CLK_PERIOD : time     := 10 ns;
    constant C_D          : positive := 20;           -- debounce cycles in simulation
    constant C_LATENCY    : positive := 2 + C_D;      -- edges from press to pulse

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal btn       : std_logic := '0';
    signal pulse     : std_logic;
    signal level     : std_logic;
    signal sim_done  : boolean   := false;

    signal pulse_cnt : natural   := 0;                -- pulses seen so far
    signal wide_cnt  : natural   := 0;                -- pulses longer than 1 clock
    signal rst_pulse : natural   := 0;                -- pulses while rst = '1'

begin

    clk <= not clk after C_CLK_PERIOD / 2 when not sim_done else '0';

    dut : entity work.button_conditioner
        generic map (G_DEBOUNCE_CYCLES => C_D)
        port map (
            clock_in  => clk,
            reset_in  => rst,
            button_in => btn,
            pulse_out => pulse,
            level_out => level
        );

    -- counts pulses, pulses wider than one clock and pulses during reset
    monitor : process (clk)
        variable prev : std_logic := '0';
    begin
        if rising_edge(clk) then
            if pulse = '1' then
                pulse_cnt <= pulse_cnt + 1;
                if prev = '1' then
                    wide_cnt <= wide_cnt + 1;
                end if;
                if rst = '1' then
                    rst_pulse <= rst_pulse + 1;
                end if;
            end if;
            prev := pulse;
        end if;
    end process monitor;

    watchdog : process
    begin
        wait until sim_done for 1 ms;
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
        variable c0     : natural;
        variable n      : natural;

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
            wait for 1 ns;                                -- read after the registers update
        end procedure clks;

        -- apply a sequence of button levels, each for a number of clocks
        procedure drive(steps : t_steps) is
        begin
            for i in steps'range loop
                btn <= steps(i).value;
                clks(steps(i).cycles);
            end loop;
        end procedure drive;

        function img(v : natural) return string is
        begin
            return integer'image(v);
        end function img;

    begin
        --------------------------------------------------------------- reset
        rst <= '1';
        clks(5);
        check("RESET       pulse low", pulse = '0', "'0'", std_logic'image(pulse));
        check("RESET       level low", level = '0', "'0'", std_logic'image(level));
        rst <= '0';
        clks(5);

        --------------------------------------------------------- TB-BTN-01
        c0  := pulse_cnt;
        btn <= '1';                                       -- changes just after an edge
        n   := 0;
        loop
            wait until rising_edge(clk);
            n := n + 1;
            wait for 1 ns;
            exit when pulse = '1' or n > 3 * C_LATENCY;
        end loop;
        check("TB-BTN-01   latency press -> pulse (edges)", n = C_LATENCY,
              img(C_LATENCY), img(n));
        clks(1);
        check("TB-BTN-01   pulse is 1 clock wide", pulse = '0', "'0'", std_logic'image(pulse));
        clks(3 * C_D);
        check("TB-BTN-01   pulses for one clean press", pulse_cnt - c0 = 1, "1", img(pulse_cnt - c0));
        check("TB-BTN-01   debounced level high", level = '1', "'1'", std_logic'image(level));
        c0 := pulse_cnt;
        btn <= '0';
        clks(3 * C_D);
        check("TB-BTN-01   no pulse on clean release", pulse_cnt - c0 = 0, "0", img(pulse_cnt - c0));
        check("TB-BTN-01   debounced level low", level = '0', "'0'", std_logic'image(level));

        -- boundary: a press of exactly D clocks is accepted
        c0 := pulse_cnt;
        drive((('1', C_D), ('0', 4 * C_D)));
        check("TB-BTN-01   press of exactly D clocks -> pulses", pulse_cnt - c0 = 1, "1",
              img(pulse_cnt - c0));

        --------------------------------------------------------- TB-BTN-02
        c0 := pulse_cnt;
        drive((('1', 3), ('0', 2), ('1', 5), ('0', 1), ('1', 4), ('0', 3), ('1', 4 * C_D)));
        check("TB-BTN-02   bouncing press -> pulses", pulse_cnt - c0 = 1, "1", img(pulse_cnt - c0));
        check("TB-BTN-02   debounced level high", level = '1', "'1'", std_logic'image(level));

        --------------------------------------------------------- TB-BTN-03
        c0 := pulse_cnt;
        drive((('0', 3), ('1', 4), ('0', 2), ('1', 6), ('0', 1), ('1', 2), ('0', 4 * C_D)));
        check("TB-BTN-03   bouncing release -> pulses", pulse_cnt - c0 = 0, "0", img(pulse_cnt - c0));
        check("TB-BTN-03   debounced level low", level = '0', "'0'", std_logic'image(level));
        c0 := pulse_cnt;
        drive((('1', C_D / 2), ('0', 4 * C_D)));
        check("TB-BTN-03   idle glitch of D/2 clocks -> pulses", pulse_cnt - c0 = 0, "0",
              img(pulse_cnt - c0));
        c0 := pulse_cnt;
        drive((('1', C_D - 1), ('0', 4 * C_D)));
        check("TB-BTN-03   idle glitch of D-1 clocks -> pulses", pulse_cnt - c0 = 0, "0",
              img(pulse_cnt - c0));
        check("TB-BTN-03   debounced level still low", level = '0', "'0'", std_logic'image(level));

        --------------------------------------------------------- TB-BTN-04
        c0 := pulse_cnt;
        drive((('1', 10 * C_D), ('0', 4 * C_D)));
        check("TB-BTN-04   long hold (10 D) -> pulses", pulse_cnt - c0 = 1, "1", img(pulse_cnt - c0));

        --------------------------------------------------------- TB-BTN-05
        c0  := pulse_cnt;
        rst <= '1';
        drive((0 => ('1', 4 * C_D)));
        check("TB-BTN-05   press during reset -> pulses", pulse_cnt - c0 = 0, "0", img(pulse_cnt - c0));
        check("TB-BTN-05   level low during reset", level = '0', "'0'", std_logic'image(level));
        rst <= '0';                                       -- button still held
        clks(3 * C_D);
        check("TB-BTN-05   held through reset release -> pulses", pulse_cnt - c0 = 1, "1",
              img(pulse_cnt - c0));
        btn <= '0';
        clks(3 * C_D);

        ------------------------------------------------------ global checks
        check("ALL         pulses wider than 1 clock", wide_cnt = 0, "0", img(wide_cnt));
        check("ALL         pulses while reset = '1'", rst_pulse = 0, "0", img(rst_pulse));

        --------------------------------------------------------------- summary
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
