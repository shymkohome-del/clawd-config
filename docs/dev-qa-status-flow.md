Dev ↔ QA Status Flow (Quick Reference)

High-level lifecycle

- SM: Draft -> Approved
- Dev: InProgress -> Ready for Review (or Blocked / Decision Needed)
- QA: Ready for Review -> Done (or back to InProgress with reasons)
- Loop Dev <-> QA until QA sets Done

Roles and ownership

- Scrum Master (SM)
  - Owns initial Status: Draft -> Approved
- Developer (Dev)
  - May set Status: InProgress, Ready for Review, Blocked, Decision Needed
  - Updates: Tasks/Subtasks checkboxes, Dev Agent Record (and subsections), File List, Change Log, Status (per above)
  - Never sets Status: Done
- QA
  - May set Status: Done (if all ACs pass) or InProgress (if any AC fails/partial)
  - Updates: QA Results, Change Log (brief reasons for fail/partial), Status (Done/InProgress)
  - Does not edit Story, Acceptance Criteria, Dev Notes, Testing, or Dev Agent Record

Status transitions

- Draft -> Approved (by SM)
- Approved -> InProgress (by Dev, start of implementation)
- InProgress -> Ready for Review (by Dev, all validations pass)
- Ready for Review -> Done (by QA, all ACs pass)
- Ready for Review -> InProgress (by QA, add reason in Change Log if fail/partial)
- Any time (by Dev):
  - InProgress -> Blocked (add reason in Change Log)
  - InProgress -> Decision Needed (note in Change Log)

Dev checklist (each cycle)

- Work on branch: `story/<id>-<slug>` with upstream set
- Implement tasks/subtasks; update Tasks/Subtasks checkboxes
- Run local gates: `dart format .`, `flutter analyze --fatal-infos --fatal-warnings`, `flutter test --no-pub`
- Update Dev Agent Record -> File List
- Set Status: Ready for Review and HALT

QA checklist (each cycle)

- Execute tests against ACs and PR/branch
- If pass:
  - Append QA Results; set Status: Done; Commit and Push the change on the same `story/<id>-<slug>` branch
- If fail/partial:
  - Append QA Results; note brief reason(s) in Change Log; set Status: InProgress

PR / CI notes

- Dev may create PR at Ready for Review per repo policy
- CI should pass before QA approval/merge
- Automation behavior (effective now):
  - For `story/<id>-<slug>` branches: After QA sets `Status: Done` and pushes, the system auto-creates (or reuses) a PR to `develop`, auto-labels `automerge-candidate` and `automerge-ok`, may auto-approve if `AUTO_APPROVE_ENABLED=true`, and merges on green via fallback if repo auto-merge is unavailable. Source branch is deleted if allowed by repo settings.
  - For `feature|fix|chore|patch/*` branches: A PR to `develop` is auto-created on push with the same labels and merge-on-green behavior.
  - Feature flags (repo variables):
    - `AUTO_PR_ENABLED` (default true): gates PR creation/labeling logic.
    - `AUTO_MERGE_ENABLED` (default true): gates auto-merge fallback behavior.
    - `AUTO_APPROVE_ENABLED` (default true): gates bot auto-approval.
  - Normal case: Neither Dev nor QA need to create PRs or press Merge. Removing the `automerge-ok` label (or turning flags off) will pause auto-merge if needed.

Related checklists

- `.bmad-core/checklists/qa-intake-checklist.md`
- `.bmad-core/checklists/qa-on-dev-update-checklist.md`

