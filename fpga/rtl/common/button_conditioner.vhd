--------------------------------------------------------------------------------
-- button_conditioner.vhd
-- Purpose : Turns a raw, bouncing push-button into a clean one-clock pulse:
--           2-FF synchroniser -> counter debouncer -> rising-edge pulse.
-- Design  : docs/architecture/subsystems/top_debug_demo.md §6, §9, §15
-- Reqs    : REQ-IF-002 (start = one-clock pulse), DEC-019 (debounce), DEC-007
-- Author  : Eren (eeerenbuyukbas)
-- AI      : AI-assisted (Claude Opus 5.5, Claude Code desktop, 2026-09-26), AI-0010
--
-- Behaviour
--   * level_out takes a new value only after the synchronised button has shown
--     that value for G_DEBOUNCE_CYCLES consecutive clocks; shorter glitches
--     (contact bounce) are ignored.
--   * pulse_out is '1' for exactly one clock when level_out changes 0 -> 1.
--     A release (1 -> 0) produces no pulse.
--   * Timing: after a clean press, pulse_out is '1' in the clock that follows
--     rising edge number 2 + G_DEBOUNCE_CYCLES (edge 1 = first edge that
--     samples the pressed button).
--   * reset_in (synchronous, active high): level_out = '0', no pulse. A button
--     that is still held when reset ends is seen as a new press.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity button_conditioner is
    generic (
        G_DEBOUNCE_CYCLES : positive := 1_000_000  -- 10 ms at 100 MHz (DEC-019)
    );
    port (
        clock_in  : in  std_logic;
        reset_in  : in  std_logic;                 -- synchronous, active high
        button_in : in  std_logic;                 -- raw button, asynchronous
        pulse_out : out std_logic;                 -- 1-clock pulse on press
        level_out : out std_logic                  -- debounced button level
    );
end entity button_conditioner;

architecture rtl of button_conditioner is

    signal btn_sync   : std_logic;
    signal stable_reg : std_logic := '0';
    signal cnt        : natural range 0 to G_DEBOUNCE_CYCLES - 1 := 0;
    signal pulse_reg  : std_logic := '0';

begin

    u_sync : entity work.sync_2ff
        generic map (G_INIT => '0')
        port map (
            clock_in => clock_in,
            async_in => button_in,
            sync_out => btn_sync
        );

    process (clock_in)
    begin
        if rising_edge(clock_in) then
            pulse_reg <= '0';                              -- default: no pulse

            if reset_in = '1' then
                stable_reg <= '0';
                cnt        <= 0;
            elsif btn_sync = stable_reg then               -- no change or bounce back
                cnt <= 0;
            elsif cnt = G_DEBOUNCE_CYCLES - 1 then         -- new level held long enough
                stable_reg <= btn_sync;
                cnt        <= 0;
                if btn_sync = '1' then                     -- accepted press (0 -> 1)
                    pulse_reg <= '1';
                end if;
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    pulse_out <= pulse_reg;
    level_out <= stable_reg;

end architecture rtl;
