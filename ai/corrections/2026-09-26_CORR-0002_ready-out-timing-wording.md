# CORR-0002 — Wrong `ready_out` timing wording in INTERFACES §2

```text
Date:            2026-09-26        Member: eeerenbuyukbas (review of PR #3)   Related AI record: AI-0001 (origin), AI-0005 (fix)
File(s):         INTERFACES.md §2, TEST_PLAN.md TB-DEBUG-02
Found by:        review — Hande's design document (debug.md §9, AI-0004) pointed out the mismatch
```

## What the AI produced (AI-0001)
"`ready_out` is low from the first rising edge after the edge that sampled `start_in` = '1'
(i.e. registered, 1-cycle response)."

## What was wrong
Read literally, this delays `ready_out` by one extra clock: the register would be cleared one edge
*after* the sampling edge. The manual waveforms (DBG §1, CTRL §1) show `ready_out` falling when
`start_in` falls, i.e. at the edge that samples `start_in` = '1'. A registered FSM naturally does this.
The text contradicted its own parenthesis ("registered, 1-cycle response").

## How it was detected
Design review: `debug.md` §9 derived the timing from the manual waveform and flagged the difference.

## Correction applied
INTERFACES §2 now states that `ready_out` is cleared at the same rising edge that samples
`start_in` = '1' (low one clock after `start_in` rose). TEST_PLAN TB-DEBUG-02 wording aligned.

## Verification of the correction
Pending — TB-DEBUG-02 must check the exact cycle once the RTL exists.

## Lesson
Describe handshake timing by naming the edge ("the edge that samples X") and check it against the
manual waveform, not by prose alone.
