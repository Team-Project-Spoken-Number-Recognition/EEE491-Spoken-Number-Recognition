# AI-0002 — GitHub setup and Team Manual

```text
ID:            AI-0002
Date:          2026-09-24 … 2026-09-25
Team Member:   eeerenbuyukbas
AI Tool:       Claude Code, desktop app (Code tab)
Model:         Claude Opus 5.5 (claude-opus-5-5)
Purpose:       Create the GitHub repository, give teammates access, write the team usage manual.
```

## Prompts (summary — verbatim text in the session export)
1. Open the repository for the team; the other two members and their Claude sessions must be able to change it.
2. Add `handeery` and `omerkutlu1030`.
3. Should a shared Google Drive be connected?
4. Teammates see "admin access needed" for Claude → how to give equal rights.
5. Make the repo temporarily public / close the organization (later: keep the organization, option A).
6. Transfer gave a gh "Validation Failed" error — check it.
7. Everyone is owner/admin now; repo made public temporarily; one lab deadline per Wednesday, first on
   Sep 30; two members per lab with a rotating off-week → write a manual on how we use the repo.

## AI Output
- Initial commit `1680976`, private repo created under `eeerenbuyukbas`, collaborators invited (write).
- Advice: Drive only as a complement for large binaries (not a mirror of the repo).
- Diagnosis: personal-account repos have a single admin → recommended a GitHub organization (DEC-015).
- Recommended **against** making the repo public (does not give equal rights; irreversible exposure of
  course material). The team later decided to make it public anyway (DEC-016) — documented, not re-argued.
- The repo-transfer command was **blocked by Claude Code's permission classifier**; the user performed the
  transfer. The 422 "cannot be transferred to the original owner" error was diagnosed as harmless
  (repo had already been transferred; old URL redirects).
- Local `origin` updated to the organization URL.
- `TEAM_MANUAL.md` written; CONTRIBUTING §3 superseded by rotation (DEC-017); PROJECT_TIMELINE switched to
  Wednesday deadlines with an all-hands DEBUG week; README, CLAUDE.md, PROJECT_STATUS (R-13, R-14),
  ASSUMPTIONS (ASSUMPTION-013 partially verified), INSTRUCTOR_QUESTIONS (Q-01 answered), HANDOFF updated.

## Items the team must review (AI choices, not facts)
- Rotation pattern (Partner → next Lead, Lead → off) and the proposed P1/P2/P3 assignment of labs.
- All-hands recommendation for Lab-DEBUG; early PCB start in the Oct 28 buffer week.
- Wednesday dates after Sep 30 are syllabus Saturday dates − 3 days (unconfirmed).
- Rule: raw voice recordings stay out of the public repo.

## Human Review / Detected Issues / Correction / Final Decision
_PENDING — to be filled by the team._

## Verification
Documentation and GitHub configuration: repo location, visibility and org roles checked via GitHub API
(2026-09-25: public; eeerenbuyukbas, handeery, omerkutlu1030 = admin).

Branch protection enabled on `main` via GitHub API on request (PR, 1 approval, dismiss stale reviews,
conversation resolution, enforce for admins, no force-push/deletion).

## Related Commit
Branch `docs/team-manual` (first pull request).
