# AI-0013 — Lab-DEBUG waveforms and demo materials

```text
ID:            AI-0013
Date:          2026-09-26
Team Member:   eeerenbuyukbas
AI Tool:       Claude Code, desktop app (Code tab)
Model:         Claude Opus 5.5 (claude-opus-5-5)
Purpose:       "Review PR 8 and merge it. I also want to see the simulation waveforms. Prepare demo materials."
```

## PR #8
Reviewed the content (links, statuses). **Not merged:** PR #8 is authored by `eeerenbuyukbas`; GitHub does not
allow approving one's own PR and `main` requires one approval also for admins → Hande or Ömer must approve.

## AI Output
| File | Content |
|---|---|
| `fpga/tb/debug/tb_debug_waves.vhd` | waveform demo bench: bouncing button → `button_conditioner` → `debug` (N = 2) ← memory model (latency 2), UART byte decoder |
| `fpga/vivado/sim_debug_waves.tcl` | batch: VCD + figures; `-tclargs gui`: XSim GUI with the demo signals |
| `simulation/tools/vcd_to_svg.py` | VCD reader + SVG waveform renderer, Python standard library only (reusable for later labs) |
| `simulation/tools/make_debug_waveforms.py` | the five Lab-DEBUG figures; event times taken from the VCD |
| `simulation/waveforms/debug/debug_w1…w5.{svg,png}` | figures (PNG rendered with headless Edge) |
| `docs/reports/lab-debug-demo/DEMO_GUIDE.md` | demo card mapped to DBG §2, checklist, results, figures, Q&A, fallbacks |

## Checks and corrections made by the AI
- Every figure was rendered to PNG and inspected. Found and fixed: renderer skipped the first value when the
  window started before the first change (showed "X" instead of 0); window allowed negative time; marker
  labels overlapping / cut at the right edge; **W5 marker "last stop bit" pointed at D6** (0xCC ends with
  1,1 + stop), and the first fix (last falling edge) pointed at D4 — final version derives the byte start from
  `tx_done` − 10 bit times, independent of the data.
- Reproducibility: `sim_debug_waves.tcl` from a clean checkout produced byte-identical SVGs.
- Demo guide: the `uart_tx`/`debug` mutation results of AI-0004 are marked as *not logged* instead of being
  presented as evidence.

## Human Review / Final Decision
_PENDING_

## Related Commit
Branch `test/debug-hw` (PR #8).
