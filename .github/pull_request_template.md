### PR Title

- Include a story reference in the title or body: e.g., `story 0.9.3`, `story-0.9.3`, `story/0.9.3`, or `story: 0.9.3`.

### Summary

- What changed and why?

### Story

- Story ID: <!-- e.g., story 0.9.3 -->
- Story file: `docs/stories/<id>.*.md`

### Checklist

- [ ] Story reference present in title or body
- [ ] Branch follows policy (`story/<id>-<slug>` or `feature|fix|chore|patch/<slug>`)
- [ ] Tests updated/passing
- [ ] No secrets committed
- [ ] If `story/*`, ensure the story file exists and Status is updated

### QA

- This PR will be auto-merged when required checks are green and QA applies `qa:approved`.

## PR Title

Use a descriptive title. For story branches, prefer: `Story <id>: <short summary>` (e.g., `Story 1.2: login form validation`). Include a story reference in title or body (e.g., `story 1.2`).

## Story Reference

- Story ID (if applicable): `story <id>`
- Branch: `<auto-filled by GitHub>`

## Summary

Describe what changed and why. Link to docs if relevant.

## Dev Checklist (author)

- [ ] Branch naming follows policy:
  - `story/<id>-<slug>` for story work (e.g., `story/1.2-login-form-validation`)
  - `feature|fix|chore|patch/<slug>` for non-story work
- [ ] Local gates passed: `dart format`, `flutter analyze --fatal-infos --fatal-warnings`, `flutter test`
- [ ] Acceptance Criteria implemented; docs updated if needed
- [ ] For story branches: story file `docs/stories/<id>.*.md` exists
- [ ] Label added automatically: `qa:ready` (QA will later apply `qa:approved`)

## QA Checklist

- [ ] Validate against the story’s Acceptance Criteria
- [ ] If all ACs pass: set story `Status: Done` (already required for auto PR)
- [ ] If any AC fails/partial: set `Status: InProgress` and add brief reasons in the story Change Log

## CI / Merge Policy

- PRs are created automatically on push (for `feature|fix|chore|patch/*`) and when stories are marked `Status: Done` (for `story/*`).
- Auto-approve may occur if `AUTO_APPROVE_ENABLED=true`.
- Auto-merge is gated by QA applying the `qa:approved` label and all required checks being green.
- Merge-on-green fallback will squash-merge when above conditions are met.
- To pause auto-merge, remove the `qa:approved` label or set a repo variable:
  - `AUTO_PR_ENABLED=false` (disables PR creation)
  - `AUTO_MERGE_ENABLED=false` (disables auto-merge)
  - `AUTO_APPROVE_ENABLED=false` (disables auto-approval)

## Screenshots / Notes

Add any relevant screenshots or notes for QA.

## PR Checklist

- [ ] Story reference included (e.g., story 0.3) in title/body
- [ ] Branch name matches `story/<id>-<slug>`
- [ ] Story document updated under `docs/stories/`:
  - [ ] Status updated appropriately
    - Dev: `InProgress` while working; `Ready for Review` when complete
    - QA: `Done` only after acceptance passes; if any AC fails/partial, set `InProgress` and add reason to Change Log
    - If blocked: set `Blocked` and add reason to Change Log
    - If awaiting decision: set `Decision Needed` and note
  - [ ] File List reflects changed/added/removed files
  - [ ] Change Log appended (key notes/decisions)

## Summary

What: 

Why: 

How/Test: 


