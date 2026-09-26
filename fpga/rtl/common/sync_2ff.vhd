--------------------------------------------------------------------------------
-- sync_2ff.vhd
-- Purpose : Two-flip-flop synchroniser for one asynchronous input bit
--           (push-buttons, switches) into the clock_in domain.
-- Design  : docs/architecture/subsystems/top_debug_demo.md §5, §7
-- Reqs    : REQ-CTRL-006 (board inputs), DEC-007 (reset synchronised)
-- Author  : Eren (eeerenbuyukbas)
-- AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0010
--
-- Behaviour
--   * sync_out follows async_in with a delay of two rising edges.
--   * No reset input on purpose: the reset itself is synchronised with this
--     block. G_INIT sets the value after FPGA configuration ('1' for a reset
--     synchroniser = two reset cycles after power-up).
--   * ASYNC_REG keeps both flip-flops close together (Vivado placement) and
--     marks the first one as a possible metastability point.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity sync_2ff is
    generic (
        G_INIT : std_logic := '0'           -- value of both stages after configuration
    );
    port (
        clock_in : in  std_logic;
        async_in : in  std_logic;           -- asynchronous input
        sync_out : out std_logic            -- synchronised to clock_in
    );
end entity sync_2ff;

architecture rtl of sync_2ff is

    signal meta_reg : std_logic := G_INIT;  -- first stage, may go metastable
    signal sync_reg : std_logic := G_INIT;  -- second stage, safe to use

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of meta_reg : signal is "TRUE";
    attribute ASYNC_REG of sync_reg : signal is "TRUE";

begin

    process (clock_in)
    begin
        if rising_edge(clock_in) then
            meta_reg <= async_in;
            sync_reg <= meta_reg;
        end if;
    end process;

    sync_out <= sync_reg;

end architecture rtl;
