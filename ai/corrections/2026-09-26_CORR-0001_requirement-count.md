# CORR-0001 — Wrong requirement total in the initialisation report

```text
Date:            2026-09-26        Member: eeerenbuyukbas (session)     Related AI record: AI-0001
File(s):         docs/reports/2026-09-24_PROJECT_INITIALIZATION_REPORT.md (and the chat report of AI-0001)
Found by:        review — the AI itself, while re-counting requirements after adding three new ones (AI-0003)
```

## What the AI produced
"64 requirements: SYS 5, DEBUG 20, CTRL 10, IF 5, PERF 3, HW 3, SW 3, VER 4, DOC 3, PROC 5".

## What was wrong
The listed per-area counts sum to **61**, not 64. The per-area counts were correct; only the total was wrong.

## How it was detected
`grep -c "^| REQ-" REQUIREMENTS.md` on the initial commit `1680976` returns 61.

## Correction applied
Report corrected to 61 (with a note); current total after the TA answers is 64
(+REQ-SYS-006, REQ-IF-006, REQ-IF-007).

## Verification of the correction
Per-area count via `grep -oE '^\| REQ-[A-Z]+-[0-9]+' REQUIREMENTS.md | cut -d- -f2 | sort | uniq -c`.

## Lesson
Derive totals from the file with a command instead of summing by hand.
