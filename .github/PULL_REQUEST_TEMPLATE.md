## What changed

## Why

## Related Requirements
<!-- REQ-IDs; closes #issue -->

## Files changed

## Simulation performed
<!-- testbench name, generics, test IDs -->

## Testbench result
<!-- paste the TB_RESULT line; link log in simulation/results/ -->

## Synthesis result
<!-- errors/critical warnings, utilisation (LUT/FF/BRAM/DSP), WNS -->

## Hardware result
<!-- HW test IDs, or "not applicable: <reason>" -->

## AI usage
<!-- AI-NNNN record(s), or "none" -->

## Known limitations

## Reviewer checklist
- [ ] Functionality matches the requirement(s) and the subsystem design doc
- [ ] Synthesizable; no latches; no gated/derived clocks; async inputs synchronised
- [ ] Reset behaviour defined for every register
- [ ] Timing: met at 100 MHz (or not affected)
- [ ] Numerical accuracy / fixed-point formats as documented in INTERFACES.md §6
- [ ] Interface compatibility (ports, widths, signedness, handshake, latency) — dependants updated
- [ ] Testbench really checks the requirement (self-checking, corner cases, reset)
- [ ] No magic numbers; generics/constants used
- [ ] Docs updated (REQUIREMENTS status, TRACEABILITY_MATRIX, HANDOFF, PROJECT_STATUS)
- [ ] I can explain this code without the author present
