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
  - Append QA Results; set Status: Done
- If fail/partial:
  - Append QA Results; note brief reason(s) in Change Log; set Status: InProgress

PR / CI notes

- Dev may create PR at Ready for Review per repo policy
- CI should pass before QA approval/merge
- After QA sets Done, proceed with merge as per standard process

Related checklists

- `.bmad-core/checklists/qa-intake-checklist.md`
- `.bmad-core/checklists/qa-on-dev-update-checklist.md`

