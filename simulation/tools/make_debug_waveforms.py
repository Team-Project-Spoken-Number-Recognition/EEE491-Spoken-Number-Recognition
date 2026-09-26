"""make_debug_waveforms.py — Lab-DEBUG demo figures from the tb_debug_waves VCD.

Usage:  python simulation/tools/make_debug_waveforms.py <debug_waves.vcd> <output_dir>
Figures (SVG):
  debug_w1_overview.svg     whole transfer: button, start pulse, LD6/ready, txd, address, received bytes
  debug_w2_handshake.svg    start sampled -> ready low -> first start bit of 0x55 (bit by bit)
  debug_w3_button.svg       contact bounce -> debounced level -> one-clock start pulse
  debug_w4_memory_read.svg  address change -> data after 2 clocks -> captured into the byte shift register
  debug_w5_end_of_frame.svg last byte 0xCC of the end word -> ready high 2 clocks after the stop bit
Event times are taken from the VCD, so the figures stay correct if the simulation changes.

Author : Eren (eeerenbuyukbas) — AI-assisted (Claude Opus 5.5, Claude Code), AI-0013
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from vcd_to_svg import Vcd, render  # noqa: E402

vcd_path, out_dir = sys.argv[1], sys.argv[2]
os.makedirs(out_dir, exist_ok=True)
v = Vcd(vcd_path)
T = "tb_debug_waves."
D = T + "u_debug."
CLK = 10.0                                                    # ns

t_start = v.edges(T + "start_pulse", "1")                    # start pulses (ns)
t_rdy_lo = v.edges(T + "ready", "0")[0]
t_rdy_hi = [t for t in v.edges(T + "ready", "1") if t > t_rdy_lo][0]
t_press = v.edges(T + "btn_raw", "1")
t_addr1 = [t for t in v.edges(T + "mem_addr") if t > t_rdy_lo][0]   # first address change 0 -> 1
t_txd_first = [t for t in v.edges(T + "txd", "0") if t >= t_rdy_lo][0]
t_stop_end = [t for t in v.edges(D + "tx_done", "1") if t < t_rdy_hi][-1]  # tx_done: last stop bit ended
BIT = 10 * CLK                                               # 10 clocks per bit in tb_debug_waves
t_last_byte = t_stop_end - 10 * BIT                          # start bit of the last byte (10 bits back)
second_press = [t for t in t_press if t > t_rdy_lo + 1000][0]

files = []
files.append(render(v, [
    (T + "btn_raw", "BTNU (raw, bouncing)", "bit"),
    (T + "start_pulse", "start_in (1 clock)", "bit"),
    (T + "ready", "ready_out = LD6", "bit"),
    (T + "txd", "txd_out (UART)", "bit"),
    (T + "mem_addr", "mem_addr_out", "bus"),
    (T + "mem_data", "mem_data_in", "bus"),
    (T + "rx_byte", "byte received (PC)", "bus"),
], t_press[0] - 300, t_rdy_hi + 800, os.path.join(out_dir, "debug_w1_overview.svg"),
    title="Lab-DEBUG — one complete transfer (N = 2: start word, 4 data words, end word = 24 bytes)",
    caption="tb_debug_waves: 10 clocks/bit, memory latency 2. Words 2 and 3 contain the delimiter values "
            "55AACC03 / AA5503CC on purpose; the second press during the transfer is ignored.",
    markers=[(t_start[0], "start pulse"), (second_press, "press during transfer -> ignored"),
             (t_rdy_hi, "LD6 on again")]))

files.append(render(v, [
    (T + "clk", "clock_in", "clock"),
    (T + "start_pulse", "start_in", "bit"),
    (T + "ready", "ready_out", "bit"),
    (D + "tx_start", "uart tx_start (int)", "bit"),
    (T + "txd", "txd_out", "bit"),
    (T + "rx_byte", "byte received (PC)", "bus"),
], t_start[0] - 60, t_start[0] + 1130, os.path.join(out_dir, "debug_w2_handshake.svg"),
    title="Handshake and first UART byte 0x55 (8N1, LSB first, 10 clocks per bit)",
    caption="ready_out is cleared at the rising edge that samples start_in = '1' (REQ-DEBUG-014); "
            "the start bit follows; 0x55 = 1,0,1,0,1,0,1,0 LSB first; stop bit '1'.",
    markers=[(t_start[0] + CLK, "start sampled / ready low"), (t_txd_first, "start bit")],
    notes=[(t_txd_first + 50 + 100 * i, "txd_out", lab)
           for i, lab in enumerate(["S", "D0=1", "D1=0", "D2=1", "D3=0", "D4=1", "D5=0", "D6=1", "D7=0", "P"])]))

files.append(render(v, [
    (T + "clk", "clock_in", "clock"),
    (T + "btn_raw", "BTNU raw", "bit"),
    (T + "btn_level", "debounced level", "bit"),
    (T + "start_pulse", "start pulse", "bit"),
], t_press[0] - 40, t_start[0] + 80, os.path.join(out_dir, "debug_w3_button.svg"),
    title="Start button: contact bounce -> debounce (D = 8 clocks here, 10 ms on the board) -> one-clock pulse",
    caption="Glitches shorter than D clocks are ignored; the pulse comes 2 + D edges after the press is stable "
            "(sync_2ff + button_conditioner, DEC-019).",
    markers=[(t_start[0], "start pulse")]))

files.append(render(v, [
    (T + "clk", "clock_in", "clock"),
    (D + "tx_done", "uart tx_done (int)", "bit"),
    (T + "mem_addr", "mem_addr_out", "bus"),
    (T + "mem_stage", "ROM internal stage", "bus"),
    (T + "mem_data", "mem_data_in", "bus"),
    (D + "word_reg", "byte shift reg (int)", "bus"),
    (D + "tx_start", "uart tx_start (int)", "bit"),
], t_addr1 - 40, t_addr1 + 90, os.path.join(out_dir, "debug_w4_memory_read.svg"),
    title="Memory read: address 0 -> 1, data valid 2 clocks later, captured with G_MEM_LATENCY = 2",
    caption="The address is held while the word is sent; waiting longer than the real latency is safe, "
            "shorter would shift every word by one (REQ-DEBUG-019, TB-DEBUG-07, TB-ROM-01).",
    markers=[(t_addr1, "address 1"), (t_addr1 + 2 * CLK, "data valid")]))

files.append(render(v, [
    (T + "clk", "clock_in", "clock"),
    (T + "txd", "txd_out", "bit"),
    (T + "rx_byte", "byte received (PC)", "bus"),
    (D + "tx_done", "uart tx_done (int)", "bit"),
    (T + "ready", "ready_out = LD6", "bit"),
], t_last_byte - 150, t_rdy_hi + 120, os.path.join(out_dir, "debug_w5_end_of_frame.svg"),
    title="End of frame: last byte 0xCC of the end word AA5503CC, then ready_out = '1'",
    caption="0xCC = 0,0,1,1,0,0,1,1 LSB first. tx_done marks the end of the last stop bit; ready_out rises "
            "two clocks later (debug.md §9, REQ-DEBUG-014).",
    markers=[(t_stop_end, "stop bit ends (tx_done)"), (t_rdy_hi, "ready high (+2 clocks)")],
    notes=[(t_last_byte + 50 + 100 * i, "txd_out", lab)
           for i, lab in enumerate(["S", "D0=0", "D1=0", "D2=1", "D3=1", "D4=0", "D5=0", "D6=1", "D7=1", "P"])]))

for f in files:
    print("wrote", f)
