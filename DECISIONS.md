# Technical Decision Log

Status per decision: **PROPOSED** (AI or member suggestion, not yet agreed) → **ACCEPTED** (team agreed,
names recorded) → **SUPERSEDED by DEC-xxx**. A PROPOSED decision must not be treated as final.

Decisions still to be made (recorded as they arise): sampling frequency, frame length, window function,
FFT size, MEL filter count, DCT coefficient count, fixed-point formats, classification method,
memory architecture, Vivado IP usage beyond the manuals.

---

### DEC-001 — Repository is the single engineering record
- **Decision:** One private GitHub repository holds code, documentation, verification evidence and AI-usage records.
- **Context:** Syllabus requires reports, verification results and complete GenAI documentation.
- **Options:** A) repo only · B) repo for code + shared drive for docs · C) per-member folders.
- **Chosen:** A.
- **Reason:** One history, one traceability chain (requirement → file → test → commit).
- **Trade-offs:** Binary files (PDF, images) increase repo size; acceptable at this scale.
- **Impact:** All documents in Markdown; evidence files committed.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-002 — Deviations from the initially proposed directory layout
- **Decision:** Add the following to the proposed layout:
  - `docs/manuals/` + `docs/manuals/pending/` — implements the staged-manual rule physically (released vs. not released).
  - `docs/manual_analysis/` — one NEW MANUAL ANALYSIS record per released manual.
  - `docs/architecture/subsystems/` — per-block design documents (minimum documentation set).
  - `docs/requirements/TRACEABILITY_MATRIX.md` — requirement → file → test → result → commit.
  - `fpga/rtl/common/`, `fpga/tb/common/` — shared packages (constants, types, sync/debounce) and testbench helpers (UART receiver model) to avoid duplication and magic numbers.
  - `matlab/debug/` — PC-side UART receiver; it is a tool used by every stage, not part of the recognition model.
  - `ai/sessions/` — full unedited chat exports (syllabus GenAI policy item 3); `ai/AI_USAGE_LOG.md` index and `ai/TOOLS_AND_MODELS.md`.
  - `CONTRIBUTING.md` (GitHub recognises it) — branch/PR/VHDL rules and ownership matrix.
  - `CLAUDE.md` — loaded automatically by Claude Code so every member's AI session follows the same workflow.
- **Context:** The proposed structure did not contain places for manuals, analyses, subsystem docs or raw chat logs.
- **Chosen:** Additive changes only; nothing from the proposal was removed.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-003 — Release Lab-CTRL together with Lab-DEBUG
- **Decision:** Treat Lab-CTRL as part of the current stage (moved to `docs/manuals/`), while ADC/WINDOW/PCB/MATLAB/FFT/MEL stay in `docs/manuals/pending/`.
- **Context:** DBG §2 requires "a demo design in which Lab-DEBUG is integrated with the Lab-CTRL". CTRL is due one week after DEBUG (Oct 10) and defines the start/ready handshake that DEBUG must obey.
- **Options:** A) release CTRL now · B) build DEBUG demo with an ad-hoc controller, release CTRL later.
- **Chosen:** A.
- **Reason:** Option B would create a throw-away controller and risk handshake mismatch.
- **Trade-offs:** Slightly larger current scope. Only the CTRL subset needed for the DEBUG demo is built first; full framing follows for the Oct 10 demo.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-004 — Git workflow: protected `main`, feature branches, reviewed PRs
- **Decision:** `main` protected (PR + 1 approving review + no direct push). Branches `feature/<block>`, `fix/<topic>`, `docs/<topic>`, `sim/<topic>`. Conventional commit messages. Squash-merge. A git tag per demonstrated lab (`lab-debug-demo`, `lab-ctrl-v1`, …).
- **Options:** A) GitHub flow with PRs · B) everyone on `main` · C) git-flow with `develop`.
- **Chosen:** A.
- **Reason:** 3 people, weekly deadlines; C adds overhead, B breaks each other's work.
- **Impact:** See `CONTRIBUTING.md`. Tags also satisfy REQ-CTRL-010 (keep CTRL versions).
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-005 — UART / debug protocol
- **Decision:** 8N1, LSB-first bits, MSB-first bytes, start word `55AACC03`, end word `AA5503CC`, fixed length `8 + 4·2^N` bytes. Start at **115 200 baud**; evaluate a higher rate (e.g. 1 000 000, exact divider 100) only after the 115 200 demo path works.
- **Context:** DBG §1, §3. Byte order derived from the header table (ASSUMPTION-006).
- **Options:** baud 115 200 / 460 800 / 921 600 / 1 000 000.
- **Chosen:** 115 200 for first bring-up and demo; higher rate is a later, separately verified change.
- **Reason:** Manual minimum; guaranteed support; 5.7 s transfer is acceptable for N = 14.
- **Trade-offs:** Slow for large RAM dumps in later labs.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-006 — Clock strategy
- **Decision:** Single 100 MHz clock domain; baud tick and all slower timing via clock-enable pulses; no MMCM/PLL until a manual or timing analysis requires it.
- **Reason:** Avoids CDC problems; matches `clock_in` in all manual IO lists.
- **Risk:** Later blocks (FFT IP) may need timing work at 100 MHz — revisit at FFT stage.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-007 — Reset strategy
- **Decision:** `reset_in` active high, passed through a 2-FF synchroniser in the top level, used synchronously in all clocked processes. Board RESET input → synchroniser → every block (REQ-CTRL-006).
- **Options:** A) synchronous · B) asynchronous · C) async assert / sync de-assert.
- **Chosen:** A (Xilinx 7-series guidance favours synchronous resets; one domain makes A simple).
- **Open:** Which Basys-3 input is RESET (button vs. switch) — INSTRUCTOR_QUESTIONS Q-05.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-008 — Tool versions pinned team-wide
- **Decision:** All members use the same Vivado and MATLAB versions. Observed on one PC: Vivado 2023.2, MATLAB R2023b.
- **Reason:** Vivado projects/IP (.xci) are version-specific; mixed versions force IP upgrades.
- **Action:** Every member reports their versions; lab PC version to be checked.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-009 — Debug path separation
- **Decision:** Lab-DEBUG only reads RAM read ports. A port-B address mux selects between the next functional block and Lab-DEBUG; Lab-CTRL runs Lab-DEBUG only while the pipeline is idle.
- **Reason:** Keeps the functional path unchanged when debug is attached/detached.
- **Status:** PROPOSED — final decision at the Lab-ADC stage (first real dual-port RAM).
- **Date:** 2026-09-24 · **Team:** _pending_

### DEC-010 — MATLAB receiver reads a fixed length
- **Decision:** Read exactly `8 + 4·2^N` bytes; check the start/end words; never search for the end word inside the payload.
- **Reason:** The payload may legitimately contain `AA5503CC` or `55AACC03`; searching would truncate data. The test COE deliberately contains these values.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-011 — Self-checking testbenches with a common report format
- **Decision:** Each testbench prints `Expected / Actual / PASS|FAIL` per check and a final summary line `TB_RESULT: PASS (k/k checks)` or `TB_RESULT: FAIL`; stores the log in `simulation/results/`.
- **Reason:** Objective evidence; "No Simulation: x0.0" grading factor.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-012 — Generics for manual constants
- **Decision:** Implement the manual's "N defined in a constant" as a generic with default 14, plus generics for clock frequency, baud rate and memory latency.
- **Reason:** Same RTL runs at small N / fast baud in simulation and N = 14 in hardware; satisfies "constant definition" because the top level fixes the value in a package constant.
- **Verify:** Confirm with assistant that a generic set from a package constant satisfies the manual (INSTRUCTOR_QUESTIONS Q-07).
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-013 — Vivado projects are re-created from Tcl, not committed
- **Decision:** Commit sources, XDC, `.xci`, `.coe` and a `fpga/vivado/create_<design>.tcl` script; ignore `.xpr`, `.runs`, `.cache`, etc.
- **Reason:** Vivado project folders are large, machine-specific and merge-hostile; three people would conflict constantly.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-014 — Repository location outside OneDrive
- **Decision:** Keep the git working copy outside OneDrive-synced folders (e.g. `C:\dev\EEE491-Spoken-Number-Recognition`); GitHub is the sync mechanism.
- **Reason:** OneDrive syncing `.git/` and Vivado run directories causes file-lock errors and corrupted repos.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_
