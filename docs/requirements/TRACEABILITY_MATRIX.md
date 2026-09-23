# Traceability Matrix

Chain: **Manual requirement → REQ-ID → implementation file → test → simulation result → hardware result → commit/PR**.
Fill each column as work progresses. A requirement becomes VERIFIED only when the result columns link
to committed evidence.

| REQ-ID | Manual ref. | Implementation file(s) | Test ID(s) | Simulation result | Hardware result | Commit / PR | Status |
|---|---|---|---|---|---|---|---|
| REQ-DEBUG-001 | DBG §1 ¶1 | | TB-DEBUG-03, HW-DEBUG-02 | | | | OPEN |
| REQ-DEBUG-002 | DBG §1 ¶1 | | review | | | | OPEN |
| REQ-DEBUG-003 | DBG §1 ¶2 | | TB-DEBUG-04 | | | | OPEN |
| REQ-DEBUG-004 | DBG §1 ¶2 | | TB-DEBUG-03/04 | | | | OPEN |
| REQ-DEBUG-005 | DBG §1 ¶3 | | TB-DEBUG-03 | | | | OPEN |
| REQ-DEBUG-006 | DBG §1 ¶3 | | TB-DEBUG-03 | | | | OPEN |
| REQ-DEBUG-007 | DBG §1 ¶3 | | TB-DEBUG-03, HW-DEBUG-02 | | | | OPEN |
| REQ-DEBUG-008 | DBG §3 | | TB-UART-01/03 | | | | OPEN |
| REQ-DEBUG-009 | DBG §1 ¶5 | | TB-UART-02, HW-DEBUG-01 | | | | OPEN |
| REQ-DEBUG-010 | DBG §1 ¶5 | XDC | HW-DEBUG-01 | n/a | | | OPEN |
| REQ-DEBUG-011 | DBG §1 ¶6 | | review | n/a | n/a | | OPEN |
| REQ-DEBUG-012 | DBG §1 ¶6 | | TB-DEBUG-01/06, HW-DEBUG-05 | | | | OPEN |
| REQ-DEBUG-013 | DBG §1 ¶6 | | TB-DEBUG-02/05, HW-DEBUG-04 | | | | OPEN |
| REQ-DEBUG-014 | DBG §1 ¶6 | | TB-DEBUG-02 | | | | OPEN |
| REQ-DEBUG-015 | DBG §1 ¶4 | matlab/debug/ | MT-DEBUG-01..03, HW-DEBUG-02 | | | | OPEN |
| REQ-DEBUG-016 | DBG §2 | top, IP, COE | TB-TOPDBG-01, MT-DEBUG-04 | | | | OPEN |
| REQ-DEBUG-017 | DBG §2 | | HW-DEBUG-02/03 | n/a | | | OPEN |
| REQ-DEBUG-018 | DBG §1 ¶8 | | later stages | | | | OPEN |
| REQ-DEBUG-019 | DBG §3 | | TB-DEBUG-07 | | | | OPEN |
| REQ-DEBUG-020 | DBG §3 | | review | n/a | n/a | | OPEN |
| REQ-CTRL-001 … 010 | CTRL §1–3 | | TB-CTRL-01..06 | | | | OPEN |
| REQ-IF-001 … 005 | CTRL §1, DBG §1 | | TB-DEBUG-02, TB-CTRL-05 | | | | OPEN |
