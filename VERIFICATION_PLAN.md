# Verification & Validation Plan

- **Verification** — *are we building the system right?* Each requirement is checked against the
  design/implementation by inspection, analysis, simulation, or hardware test.
- **Validation** — *are we building the right system?* Does the working system meet the real need:
  recognise spoken numbers reliably in the lab demo, and give the team a usable debug path to MATLAB?

## 1. V-model mapping

```text
 Requirements (REQUIREMENTS.md) ─────────────────────────────── System validation (final demo, recognition rate)
   Architecture (ARCHITECTURE.md) ───────────────────────── Integration test on hardware (tests/)
     Interfaces (INTERFACES.md) ──────────────────────── Integration simulation (top-level TB)
       Block design (docs/architecture/subsystems) ── Subsystem simulation (block TB + stubs)
         RTL / MATLAB code ───────────────────── Unit simulation (self-checking TB / MATLAB unit test)
                         └── Synthesis + implementation (timing met, no critical warnings) ──┘
```

## 2. Verification levels and exit criteria

| Level | Tool | Evidence stored in | Exit criterion |
|---|---|---|---|
| L0 Review | GitHub PR | PR conversation | Reviewer checklist complete (see PR template) |
| L1 Unit simulation | Vivado XSim (primary) | `simulation/results/<block>/`, `simulation/waveforms/<block>/` | `TB_RESULT: PASS`, all checks listed in `TEST_PLAN.md` executed |
| L2 Subsystem simulation | XSim with IP models / stubs | same | PASS; waveforms showing the handshake |
| L3 Synthesis / implementation | Vivado | `docs/verification/<block>_synth.md` (utilisation, timing, warnings summary) | No errors; WNS ≥ 0 at 100 MHz; critical warnings explained |
| L4 Hardware test | Basys-3 + MATLAB | `docs/verification/<block>_hw.md` + MATLAB logs | Test procedure in `TEST_PLAN.md` passes |
| L5 MATLAB comparison | MATLAB | `simulation/results/`, plots | Error vs. golden model within the documented tolerance |
| L6 Validation | Lab demo | `docs/reports/` | Demo accepted by assistant; recognition rate measured |

## 3. Requirement → method (current stage)

| Requirement | I | A | S | H | D | Test IDs |
|---|---|---|---|---|---|---|
| REQ-DEBUG-001 | | | ✔ | ✔ | ✔ | TB-DEBUG-01..08, HW-DEBUG-02 |
| REQ-DEBUG-002 | ✔ | | | | | review |
| REQ-DEBUG-003/004 | ✔ | | ✔ | | | TB-DEBUG-03, TB-DEBUG-04 |
| REQ-DEBUG-005/006/007 | | | ✔ | ✔ | | TB-DEBUG-03, HW-DEBUG-02 |
| REQ-DEBUG-008/009 | | ✔ | ✔ | ✔ | | TB-UART-01..03, HW-DEBUG-01 |
| REQ-DEBUG-010 | ✔ | | | ✔ | | XDC review, HW-DEBUG-01 |
| REQ-DEBUG-011 | ✔ | | | | | entity review |
| REQ-DEBUG-012/013/014 | | | ✔ | | | TB-DEBUG-01, 02, 05, 06 |
| REQ-DEBUG-015 | | | ✔ (MATLAB) | ✔ | | MT-DEBUG-01..03, HW-DEBUG-02 |
| REQ-DEBUG-016/017 | ✔ | | ✔ | ✔ | ✔ | TB-TOPDBG-01, HW-DEBUG-02..04 |
| REQ-DEBUG-019 | | | ✔ | | | TB-DEBUG-07 |
| REQ-PERF-001 | | ✔ | ✔ | | | INTERFACES §3.3 analysis, TB-UART-02 |
| REQ-PERF-002 | | ✔ | | ✔ | | HW-DEBUG-03 |
| REQ-IF-001..003 | | | ✔ | | | TB-DEBUG-02, TB-CTRL-* |
| REQ-CTRL-* | | | ✔ | ✔ | ✔ | TB-CTRL-01..06 (to be detailed with CTRL design) |

## 4. MATLAB reference-model flow (applies from Lab-WINDOW onward — PLANNED)

```text
MATLAB golden model (double)  ──►  MATLAB fixed-point model (bit-true, same formats as RTL)
          │                                   │
          │                                   ├──► test vectors (.coe / .txt) → simulation/reference_data/
          │                                   │                 │
          │                                   │        VHDL TB reads vectors, writes outputs
          │                                   │                 │
          ▼                                   ▼                 ▼
   algorithm accuracy               bit-exact compare  ◄── RTL sim output   (goal: 0 LSB error)
   (recognition rate)                                  ◄── FPGA RAM via Lab-DEBUG (goal: equals RTL sim)
```

Three comparisons per block:
1. **Double vs. fixed-point MATLAB** → quantisation error (documented SNR / max abs error).
2. **Fixed-point MATLAB vs. RTL simulation** → must be bit-exact (or a justified ±1 LSB).
3. **RTL simulation vs. hardware (via Lab-DEBUG)** → must be identical.

The fixed-point formats themselves are defined per stage in `INTERFACES.md` §6 before RTL is written.

## 5. Evidence rules

- Every result used in a report is committed (log + waveform screenshot or exported data).
- File names: `<block>_<testID>_<YYYY-MM-DD>.<ext>`.
- Every evidence file references the git commit hash it was produced from.
- A requirement is **VERIFIED** only when the traceability matrix links it to a passing evidence file.
