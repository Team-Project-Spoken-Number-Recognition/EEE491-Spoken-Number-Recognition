--------------------------------------------------------------------------------
-- tb_debug_rom.vhd
-- Purpose : Self-checking testbench for the Lab-DEBUG demo ROM IP "debug_rom"
--           (Block Memory Generator, Single Port ROM, 16384 x 32, always enabled).
--   TB-ROM-01  read latency: clock edges from an address change until douta
--              shows the new word (must equal G_MEM_LATENCY of debug = 2)
--   TB-ROM-02  content: all 2^14 words equal the COE file (MT-DEBUG-04, part 2:
--              Vivado accepted the COE and the ROM holds exactly its content)
--   TB-ROM-03  special test-pattern addresses printed as Expected / Actual
-- Reqs    : REQ-DEBUG-016, REQ-DEBUG-019; ASSUMPTION-011
-- Output  : "Expected / Actual / PASS|FAIL" per check, final TB_RESULT line (DEC-011)
-- Run     : vivado -mode batch -source fpga/vivado/sim_debug_rom.tcl
-- Author  : Ömer (omerkutlu1030)
-- AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0007
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_debug_rom is
    generic (
        G_COE_FILE         : string   := "debug_rom.coe";  -- copied into the sim directory
        G_ADDR_BITS        : positive := 14;
        G_EXPECTED_LATENCY : positive := 2                  -- debug.vhd G_MEM_LATENCY default
    );
end entity tb_debug_rom;

architecture sim of tb_debug_rom is

    constant C_CLK_PERIOD : time     := 10 ns;             -- 100 MHz
    constant C_DEPTH      : positive := 2 ** G_ADDR_BITS;
    constant C_MAX_WAIT   : positive := 8;                 -- latency search limit
    constant C_MAX_LISTED : positive := 10;                -- mismatches printed in full

    type t_mem is array (0 to C_DEPTH - 1) of std_logic_vector(31 downto 0);

    component debug_rom is
        port (
            clka  : in  std_logic;
            addra : in  std_logic_vector(G_ADDR_BITS - 1 downto 0);
            douta : out std_logic_vector(31 downto 0)
        );
    end component debug_rom;

    signal clk   : std_logic := '0';
    signal addra : std_logic_vector(G_ADDR_BITS - 1 downto 0) := (others => '0');
    signal douta : std_logic_vector(31 downto 0);
    signal done  : boolean := false;

    function hex(v : std_logic_vector) return string is
        constant C_DIGITS : string(1 to 16) := "0123456789ABCDEF";
        variable result   : string(1 to v'length / 4);
        variable nibble   : std_logic_vector(3 downto 0);
    begin
        for i in result'range loop
            nibble := v(v'left - 4 * (i - 1) downto v'left - 4 * (i - 1) - 3);
            if is_x(nibble) then
                result(i) := 'X';
            else
                result(i) := C_DIGITS(to_integer(unsigned(nibble)) + 1);
            end if;
        end loop;
        return result;
    end function hex;

begin

    dut : debug_rom
        port map (
            clka  => clk,
            addra => addra,
            douta => douta
        );

    clk_gen : process
    begin
        while not done loop
            clk <= '0';  wait for C_CLK_PERIOD / 2;
            clk <= '1';  wait for C_CLK_PERIOD / 2;
        end loop;
        wait;                                               -- simulation ends
    end process clk_gen;

    stimulus : process
        file     coe_file : text;
        variable l        : line;
        variable word     : std_logic_vector(31 downto 0);
        variable good     : boolean;
        variable in_data  : boolean := false;
        variable n_read   : natural := 0;
        variable mem      : t_mem;
        variable latency  : natural := 0;
        variable n_pass   : natural := 0;
        variable n_fail   : natural := 0;
        variable n_bad    : natural := 0;

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

        procedure read_at(a : natural) is                  -- apply address, wait the latency
        begin
            addra <= std_logic_vector(to_unsigned(a, G_ADDR_BITS));
            for i in 1 to G_EXPECTED_LATENCY loop
                wait until rising_edge(clk);
            end loop;
            wait for 1 ns;                                  -- after the output register update
        end procedure read_at;

        type t_nat_array is array (natural range <>) of natural;
        constant C_SPECIAL : t_nat_array := (0, 1, 2, 3, 4, 5, C_DEPTH - 2, C_DEPTH - 1);

    begin
        ------------------------------------------------------------- load COE
        file_open(coe_file, G_COE_FILE, read_mode);
        while not endfile(coe_file) loop
            readline(coe_file, l);
            if in_data then
                if l'length >= 8 then
                    hread(l, word, good);
                    if good and n_read < C_DEPTH then
                        mem(n_read) := word;
                    end if;
                    n_read := n_read + 1;
                end if;
            elsif l'length >= 28 and l(l'low to l'low + 27) = "MEMORY_INITIALIZATION_VECTOR" then
                in_data := true;
            end if;
        end loop;
        file_close(coe_file);
        check("COE word count", n_read = C_DEPTH, integer'image(C_DEPTH), integer'image(n_read));

        --------------------------------------------- TB-ROM-01 read latency
        addra <= (others => '0');
        for i in 1 to 4 loop                                -- let address 0 settle
            wait until rising_edge(clk);
        end loop;
        wait until rising_edge(clk);
        addra <= std_logic_vector(to_unsigned(5, G_ADDR_BITS));   -- word differs from address 0
        for k in 1 to C_MAX_WAIT loop
            wait until rising_edge(clk);
            wait for 1 ns;
            if douta = mem(5) then
                latency := k;
                exit;
            end if;
        end loop;
        check("TB-ROM-01 read latency (clock edges)", latency = G_EXPECTED_LATENCY,
              integer'image(G_EXPECTED_LATENCY), integer'image(latency));

        ------------------------------------ TB-ROM-03 special addresses (readable)
        for i in C_SPECIAL'range loop
            read_at(C_SPECIAL(i));
            check("TB-ROM-03 addr " & integer'image(C_SPECIAL(i)), douta = mem(C_SPECIAL(i)),
                  hex(mem(C_SPECIAL(i))), hex(douta));
        end loop;

        ------------------------------------------------ TB-ROM-02 all words
        for a in 0 to C_DEPTH - 1 loop
            read_at(a);
            if douta /= mem(a) then
                n_bad := n_bad + 1;
                if n_bad <= C_MAX_LISTED then
                    report "TB-ROM-02 addr " & integer'image(a) & "  Expected: " & hex(mem(a)) &
                           "  Actual: " & hex(douta) & "  FAIL" severity error;
                end if;
            end if;
        end loop;
        check("TB-ROM-02 words equal to COE", n_bad = 0,
              integer'image(C_DEPTH) & " match", integer'image(C_DEPTH - n_bad) & " match");

        ------------------------------------------------------------- summary
        if n_fail = 0 then
            report "TB_RESULT: PASS (" & integer'image(n_pass) & "/" &
                   integer'image(n_pass) & " checks)" severity note;
        else
            report "TB_RESULT: FAIL (" & integer'image(n_fail) & " of " &
                   integer'image(n_pass + n_fail) & " checks failed)" severity error;
        end if;
        done <= true;
        wait;
    end process stimulus;

end architecture sim;
