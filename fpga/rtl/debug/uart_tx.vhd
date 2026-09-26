--------------------------------------------------------------------------------
-- uart_tx.vhd
-- Purpose : One-byte UART transmitter, 8N1 (1 start bit, 8 data bits LSB first,
--           no parity, 1 stop bit). Sub-block of Lab-DEBUG.
-- Design  : docs/architecture/subsystems/debug.md §7, §8, §9
-- Reqs    : REQ-DEBUG-002, REQ-DEBUG-008, REQ-DEBUG-009, REQ-PERF-001
-- Author  : Hande Eryilmaz
-- AI      : AI-assisted (Claude Opus 5.5, claude.ai chat, 2026-09-26), AI-0004
--
-- Behaviour
--   * tx_start_in is sampled only in S_IDLE; pulses while sending are ignored.
--   * Every bit lasts exactly G_CLKS_PER_BIT clock cycles.
--   * tx_done_out is a one-cycle pulse after the stop bit has lasted a full
--     bit period; the transmitter is idle again in that same cycle.
--   * txd_out is a register (glitch-free line), '1' when idle and during reset.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity uart_tx is
    generic (
        G_CLKS_PER_BIT : positive := 100   -- 100 MHz / 1 000 000 baud (DEC-005)
    );
    port (
        clock_in    : in  std_logic;
        reset_in    : in  std_logic;                     -- active high, synchronous
        tx_start_in : in  std_logic;                     -- 1-cycle pulse
        tx_data_in  : in  std_logic_vector(7 downto 0);  -- sampled with tx_start_in
        txd_out     : out std_logic;                     -- serial line, idle '1'
        tx_done_out : out std_logic                      -- 1-cycle pulse, frame finished
    );
end entity uart_tx;

architecture rtl of uart_tx is

    constant C_LAST_BIT : natural := 9;   -- bit index of the stop bit (0 = start bit)

    type t_state is (S_IDLE, S_SENDING);

    signal state     : t_state := S_IDLE;
    -- frame shift register: (9) stop bit, (8 downto 1) data, (0) start bit
    signal shift_reg : std_logic_vector(C_LAST_BIT downto 0) := (others => '1');
    signal clk_cnt   : natural range 0 to G_CLKS_PER_BIT - 1 := 0;
    signal bit_cnt   : natural range 0 to C_LAST_BIT := 0;
    signal txd_reg   : std_logic := '1';
    signal done_reg  : std_logic := '0';

begin

    process (clock_in)
    begin
        if rising_edge(clock_in) then
            done_reg <= '0';                              -- default: no pulse

            if reset_in = '1' then
                state     <= S_IDLE;
                shift_reg <= (others => '1');
                clk_cnt   <= 0;
                bit_cnt   <= 0;
                txd_reg   <= '1';
            else
                case state is

                    when S_IDLE =>
                        txd_reg <= '1';
                        if tx_start_in = '1' then
                            shift_reg <= '1' & tx_data_in & '0';
                            txd_reg   <= '0';                 -- start bit begins now
                            clk_cnt   <= 0;
                            bit_cnt   <= 0;
                            state     <= S_SENDING;
                        end if;

                    when S_SENDING =>
                        if clk_cnt = G_CLKS_PER_BIT - 1 then  -- end of current bit
                            clk_cnt <= 0;
                            if bit_cnt = C_LAST_BIT then      -- stop bit finished
                                txd_reg  <= '1';
                                done_reg <= '1';
                                state    <= S_IDLE;
                            else
                                bit_cnt   <= bit_cnt + 1;
                                shift_reg <= '1' & shift_reg(C_LAST_BIT downto 1);
                                txd_reg   <= shift_reg(1);    -- next bit on the line
                            end if;
                        else
                            clk_cnt <= clk_cnt + 1;
                        end if;

                    when others =>
                        state <= S_IDLE;

                end case;
            end if;
        end if;
    end process;

    txd_out     <= txd_reg;
    tx_done_out <= done_reg;

end architecture rtl;
