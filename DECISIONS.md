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
- **Update 2026-09-26:** TA Q-04 — Lab-CTRL is **not required** for the Lab-DEBUG demo; a top module drives `start_in`/`ready_out`. The CTRL manual stays released (Lab-CTRL is next week's lab, Oct 7) but the DEBUG demo no longer depends on it, so CTRL work can proceed independently.
- **Date:** 2026-09-24 · **Status:** ACCEPTED (release) / demo dependency REMOVED by TA Q-04 · **Team:** eeerenbuyukbas

### DEC-004 — Git workflow: protected `main`, feature branches, reviewed PRs
- **Decision:** `main` protected (PR + 1 approving review + no direct push). Branches `feature/<block>`, `fix/<topic>`, `docs/<topic>`, `sim/<topic>`. Conventional commit messages. Squash-merge. A git tag per demonstrated lab (`lab-debug-demo`, `lab-ctrl-v1`, …).
- **Options:** A) GitHub flow with PRs · B) everyone on `main` · C) git-flow with `develop`.
- **Chosen:** A.
- **Reason:** 3 people, weekly deadlines; C adds overhead, B breaks each other's work.
- **Impact:** See `CONTRIBUTING.md`. Tags also satisfy REQ-CTRL-010 (keep CTRL versions).
- **Date:** 2026-09-24 · **Status:** ACCEPTED 2026-09-25 (branch protection enabled on `main`, enforced for admins) · **Team:** eeerenbuyukbas

### DEC-005 — UART / debug protocol
- **Decision:** 8N1, LSB-first bits, **MSB-first bytes** (TA Q-02), start word `55AACC03`, end word `AA5503CC`, fixed length `8 + 4·2^N` bytes, **1 000 000 baud**, used unchanged in every lab.
- **Context:** DBG §1, §3 require ≥ 115 200 baud if supported by the FT2232HQ. The rate itself is left to the team by the instructor.
- **Options:** baud 115 200 / 460 800 / 921 600 / 1 000 000.
- **Chosen:** 1 000 000.
- **Reason:** Same rate as the reference design (DEC-018) → its PC-side tools and experience stay compatible; exact divider (100 MHz / 1 MHz = 100, 0 % error); N = 14 dump in 0.66 s instead of 5.7 s, which matters for large RAM dumps in later labs.
- **History:** 2026-09-24 AI proposed 115 200 first. 2026-09-26 the TA answered "No" to Q-06 ("may we use a rate above 115 200 in later labs?"). The team's interpretation (eeerenbuyukbas): the TA understood the question as *changing* the rate between labs; the instructor leaves the rate to the team, and the team will keep one rate for the whole project. → 1 000 000 chosen; the AI's 115 200 recommendation was not adopted.
- **Risks / verification:** FT2232HQ, Windows VCP driver and MATLAB `serialport` must work at 1 Mbaud (ASSUMPTION-009; the reference design ran at this rate → supporting evidence, not proof) → verify in HW-DEBUG-01 before building on it. If the assistant objects at the demo, the rate is a generic (`G_BAUD_RATE`) — one-line change + re-run of TB-UART-02.
- **Date:** 2026-09-26 · **Status:** ACCEPTED · **Team:** eeerenbuyukbas

### DEC-006 — Clock strategy
- **Decision:** Single 100 MHz clock domain; baud tick and all slower timing via clock-enable pulses; no MMCM/PLL until a manual or timing analysis requires it.
- **Reason:** Avoids CDC problems; matches `clock_in` in all manual IO lists.
- **Risk:** Later blocks (FFT IP) may need timing work at 100 MHz — revisit at FFT stage.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-007 — Reset strategy
- **Decision:** `reset_in` active high, passed through a 2-FF synchroniser in the top level, used synchronously in all clocked processes. Board RESET input → synchroniser → every block (REQ-CTRL-006).
- **Options:** A) synchronous · B) asynchronous · C) async assert / sync de-assert.
- **Chosen:** A (Xilinx 7-series guidance favours synchronous resets; one domain makes A simple).
- **Board input:** RESET = **BTNC** (U18) (TA Q-05: our choice → DEC-018 reference design).
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
- **Update 2026-09-26:** TA Q-07 — intent is that the width is never hard-coded and is changed by editing **N**, defined as a number at the beginning of the code. → Name the parameter literally **`N`** (not `G_ADDR_WIDTH`), declare it at the top of the entity with default **14**, and use `N` for every address width/counter. The same code then runs with small N in simulation.
- **Date:** 2026-09-24 · **Status:** ACCEPTED (TA intent confirmed) · **Team:** eeerenbuyukbas

### DEC-013 — Vivado projects are re-created from Tcl, not committed
- **Decision:** Commit sources, XDC, `.xci`, `.coe` and a `fpga/vivado/create_<design>.tcl` script; ignore `.xpr`, `.runs`, `.cache`, etc.
- **Reason:** Vivado project folders are large, machine-specific and merge-hostile; three people would conflict constantly.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_

### DEC-015 — Host the repository in a GitHub organization with all members as owners
- **Decision:** Transfer the repository from the personal account `eeerenbuyukbas` to the organization `Team-Project-Spoken-Number-Recognition` (free plan); all three members are organization **Owners**.
- **Context:** Every member uses Claude Code on their own PC; each Claude acts with that member's GitHub rights. The team wants every member (and their Claude) to be able to do the same administrative actions. On a personal-account repository only the owner can be admin.
- **Options:** A) organization, all owners · B) personal repo + GitHub Pro (branch protection, single admin) · C) make the repo temporarily public (rejected: does not give equal rights; would irreversibly expose course manuals and our work).
- **Chosen:** A.
- **Trade-offs:** Free organizations have no branch protection for private repositories → the PR-only rule of DEC-004 is enforced by team discipline. Equal owners can also delete/rename the repo or remove members → administrative actions require team agreement first.
- **Date:** 2026-09-24 · **Status:** ACCEPTED — implemented; all three members are organization owners/admins (verified 2026-09-25) · **Team:** eeerenbuyukbas, handeery, omerkutlu1030

### DEC-016 — Repository temporarily public
- **Decision:** The repository is made **public for a limited period**; it will be returned to private later.
- **Context:** Team decision (eeerenbuyukbas, 2026-09-25). Supersedes the rejection of option C in DEC-015.
- **Trade-offs / risks accepted:** Anything pushed while public (including the course manuals, syllabus, lab work and AI records) can be cloned or forked by anyone, and making the repo private later does not remove existing copies. Course-material policy question Q-13 is still open.
- **Mitigation:** Public-repository rules in `TEAM_MANUAL.md` §9 (no secrets, no personal data, no voice recordings without consent). Free branch protection is available while public.
- **Date:** 2026-09-25 · **Status:** ACCEPTED (team) · **Team:** eeerenbuyukbas

### DEC-017 — Weekly Lead/Partner pairs with a rotating off-week
- **Decision:** Each weekly lab is done by two members (Lab Lead + Partner); the third member has an off-week. Rotation: Partner → next Lead, Lead → off, off → Partner. Lab-DEBUG (first week) is recommended as an all-hands week.
- **Context:** Team decision on workload (eeerenbuyukbas, 2026-09-25); one lab deadline per week on Wednesdays.
- **Options:** A) fixed owner per subsystem (CONTRIBUTING §3, original proposal) · B) rotating pairs.
- **Chosen:** B. Supersedes the ownership matrix of CONTRIBUTING §3.
- **Reason:** Continuity (each pair contains someone from the previous lab), no one leads two labs in a row, everyone rests one week in three.
- **Trade-offs:** Knowledge of a lab is concentrated in two people → mandatory Thursday catch-up for the returning member; interface changes need all three.
- **Details:** `TEAM_MANUAL.md` §3–4. Slot mapping: P1 = Eren, P2 = Ömer, P3 = Hande — follows from the team decision "Lab-PCB: Eren Lead, Ömer Partner"; Lab-DEBUG is all-hands.
- **Date:** 2026-09-25 · **Status:** ACCEPTED · **Team:** eeerenbuyukbas

### DEC-018 — Where manuals and the TA leave choices open, follow the reference design
- **Decision:** For choices that neither the released manual nor a TA/instructor answer fixes, adopt the specification of last semester's reference design **Borek-32/EEE491-Spoken-Digit-Recognizer-BASYS3** (public, MIT License).
- **Context:** Instructors accept reusing that project (team, 2026-09-26). Using the same conventions makes later debugging and reuse easier (team rationale).
- **Precedence:** released manual > TA/instructor answer > this decision. Where the reference design conflicts with a manual or TA answer, the manual/TA wins and the conflict is logged (first case: baud rate, DEC-005).
- **Rules for reuse:** keep the MIT copyright/licence notice in any copied file; name the source file + commit in the file header and in the AI/decision log; review it like AI output; re-verify with **our** testbench against **our** REQ-IDs; check interfaces (start/ready, byte order, widths) — the reference project is similar, not identical; do not use its future-stage code before the stage's manual is released.
- **Applied so far (from `constraints/jc_homefab.xdc`, `rtl/debug.vhd`, `rtl/top_module.vhd`):** RESET = BTNC (U18), START = BTNU (T18), `txd_out` = A18, `ready_out` LED = LD6 (U14), clock W5. Also adopted: 1 000 000 baud (DEC-005). Note: their `debug.vhd` is the final multi-RAM debugger, not the Lab-DEBUG 2^N module — use as reference, not as a drop-in.
- **Date:** 2026-09-26 · **Status:** ACCEPTED · **Team:** eeerenbuyukbas

### DEC-019 — Debounce the start button (deviation from the reference design)
- **Decision:** BTNU (start) passes through a 2-FF synchroniser, a counter-based debouncer (level must be stable for `G_DEBOUNCE_CYCLES` = 1 000 000 clocks = 10 ms) and a rising-edge detector that emits a 1-clock pulse. BTNC (reset) is only synchronised (DEC-007).
- **Context:** Button conditioning is the team's choice (TA Q-05). The reference design (DEC-018) only synchronises BTNU and detects its rising edge, without debouncing.
- **Options:** A) sync + edge detect (reference) · B) sync + debounce + edge detect.
- **Chosen:** B.
- **Reason:** Contact bounce produces several edges per press. Inside a transfer they are ignored (REQ-IF-007), but a press held longer than one transfer (0.66 s) can start a second transfer on release/re-press bounce. Debouncing removes this for ≈ 20 flip-flops.
- **Trade-offs:** 10 ms extra start latency (invisible to the operator). Deviates from DEC-018 → logged here as required.
- **Verification:** TB-BTN-01…05, TB-TOPDBG-02, HW-DEBUG-04.
- **Date:** 2026-09-26 · **Status:** PROPOSED (design doc `top_debug_demo.md`) · **Team:** eeerenbuyukbas

### DEC-014 — Repository location outside OneDrive
- **Decision:** Keep the git working copy outside OneDrive-synced folders (e.g. `C:\dev\EEE491-Spoken-Number-Recognition`); GitHub is the sync mechanism.
- **Reason:** OneDrive syncing `.git/` and Vivado run directories causes file-lock errors and corrupted repos.
- **Date:** 2026-09-24 · **Status:** PROPOSED · **Team:** _pending_
