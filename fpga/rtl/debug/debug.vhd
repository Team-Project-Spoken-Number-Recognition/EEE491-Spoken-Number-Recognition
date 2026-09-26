--------------------------------------------------------------------------------
-- debug.vhd
-- Purpose : Lab-DEBUG. Reads 2^N 32-bit words from the read-only port of a
--           memory and sends them over UART (8N1) framed by a start word
--           0x55AACC03 and an end word 0xAA5503CC. Every 32-bit word is sent
--           most-significant byte first.
-- Design  : docs/architecture/subsystems/debug.md (v0.2) §6-§15
-- Reqs    : REQ-DEBUG-001..014, REQ-DEBUG-019, REQ-IF-002/003/006/007
-- Author  : Hande Eryilmaz
-- AI      : AI-assisted (Claude Opus 5.5, claude.ai chat, 2026-09-26), AI-0004
--
-- Handshake (INTERFACES.md §2)
--   * ready_out = '1' after reset and while idle, '0' while a transfer runs.
--   * ready_out falls at the rising edge that samples start_in = '1'.
--   * start_in is only evaluated in S_IDLE -> pulses during a transfer are ignored.
--   * ready_out rises two clocks after the last stop bit has ended.
-- Memory timing (debug.md §9, §12)
--   * mem_addr_out is a register and is held constant while a word is sent.
--   * mem_data_in is captured G_MEM_LATENCY + 1 edges after the address update.
--     Waiting longer than the real latency is safe; waiting shorter is not.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debug is
    generic (
        N             : positive := 14;              -- address width -> 2^N words (TA Q-07, DEC-012)
        G_CLK_FREQ_HZ : positive := 100_000_000;     -- clock_in frequency
        G_BAUD_RATE   : positive := 1_000_000;       -- DEC-005
        G_MEM_LATENCY : positive := 2                -- memory read latency in clocks (debug.md §12)
    );
    port (
        clock_in     : in  std_logic;
        reset_in     : in  std_logic;                        -- active high, synchronous
        start_in     : in  std_logic;                        -- 1-cycle pulse
        mem_addr_out : out std_logic_vector(N - 1 downto 0); -- memory read address
        mem_data_in  : in  std_logic_vector(31 downto 0);    -- memory read data
        txd_out      : out std_logic;                        -- UART serial output
        ready_out    : out std_logic                         -- '1' idle, '0' busy
    );
end entity debug;

architecture rtl of debug is

    constant C_CLKS_PER_BIT : positive := (G_CLK_FREQ_HZ + G_BAUD_RATE / 2) / G_BAUD_RATE;
    constant C_START_WORD   : std_logic_vector(31 downto 0) := x"55AACC03";  -- REQ-DEBUG-005
    constant C_END_WORD     : std_logic_vector(31 downto 0) := x"AA5503CC";  -- REQ-DEBUG-006
    constant C_LAST_BYTE    : natural := 3;                                  -- 4 bytes per word
    constant C_LAST_ADDR    : unsigned(N - 1 downto 0) := (others => '1');   -- 2^N - 1

    type t_state is (S_IDLE, S_SEND_BYTE, S_WAIT_BYTE, S_NEXT_WORD, S_MEM_WAIT);
    type t_phase is (PH_HDR, PH_DATA, PH_END);

    signal state     : t_state := S_IDLE;
    signal phase     : t_phase := PH_HDR;
    signal word_reg  : std_logic_vector(31 downto 0) := (others => '0');  -- byte shift register
    signal byte_cnt  : natural range 0 to C_LAST_BYTE := 0;
    signal lat_cnt   : natural range 0 to G_MEM_LATENCY := 0;
    signal addr_reg  : unsigned(N - 1 downto 0) := (others => '0');
    signal ready_reg : std_logic := '1';

    signal tx_start  : std_logic;
    signal tx_done   : std_logic;

begin

    assert C_CLKS_PER_BIT >= 4
        report "debug: G_CLK_FREQ_HZ / G_BAUD_RATE must be >= 4" severity failure;

    ------------------------------------------------------------ word/frame FSM
    fsm : process (clock_in)
    begin
        if rising_edge(clock_in) then
            if reset_in = '1' then
                state     <= S_IDLE;
                phase     <= PH_HDR;
                word_reg  <= (others => '0');
                byte_cnt  <= 0;
                lat_cnt   <= 0;
                addr_reg  <= (others => '0');
                ready_reg <= '1';
            else
                case state is

                    when S_IDLE =>
                        ready_reg <= '1';
                        if start_in = '1' then
                            word_reg  <= C_START_WORD;
                            phase     <= PH_HDR;
                            byte_cnt  <= 0;
                            addr_reg  <= (others => '0');
                            ready_reg <= '0';
                            state     <= S_SEND_BYTE;
                        end if;

                    when S_SEND_BYTE =>              -- tx_start = '1' in this cycle
                        state <= S_WAIT_BYTE;

                    when S_WAIT_BYTE =>
                        if tx_done = '1' then
                            if byte_cnt = C_LAST_BYTE then
                                state <= S_NEXT_WORD;
                            else
                                word_reg <= word_reg(23 downto 0) & x"00";  -- next byte to the top
                                byte_cnt <= byte_cnt + 1;
                                state    <= S_SEND_BYTE;
                            end if;
                        end if;

                    when S_NEXT_WORD =>
                        byte_cnt <= 0;
                        lat_cnt  <= 0;
                        case phase is
                            when PH_HDR =>                   -- header sent, read address 0
                                phase <= PH_DATA;
                                state <= S_MEM_WAIT;
                            when PH_DATA =>
                                if addr_reg = C_LAST_ADDR then  -- last data word sent
                                    word_reg <= C_END_WORD;
                                    phase    <= PH_END;
                                    state    <= S_SEND_BYTE;
                                else
                                    addr_reg <= addr_reg + 1;
                                    state    <= S_MEM_WAIT;
                                end if;
                            when PH_END =>                   -- end word sent
                                ready_reg <= '1';
                                state     <= S_IDLE;
                        end case;

                    when S_MEM_WAIT =>
                        if lat_cnt = G_MEM_LATENCY then
                            word_reg <= mem_data_in;
                            state    <= S_SEND_BYTE;
                        else
                            lat_cnt <= lat_cnt + 1;
                        end if;

                    when others =>
                        state <= S_IDLE;

                end case;
            end if;
        end if;
    end process fsm;

    tx_start <= '1' when state = S_SEND_BYTE else '0';

    ------------------------------------------------------------- byte transmitter
    u_uart_tx : entity work.uart_tx
        generic map (
            G_CLKS_PER_BIT => C_CLKS_PER_BIT
        )
        port map (
            clock_in    => clock_in,
            reset_in    => reset_in,
            tx_start_in => tx_start,
            tx_data_in  => word_reg(31 downto 24),   -- MSB byte first (REQ-DEBUG-007)
            txd_out     => txd_out,
            tx_done_out => tx_done
        );

    mem_addr_out <= std_logic_vector(addr_reg);
    ready_out    <= ready_reg;

end architecture rtl;
