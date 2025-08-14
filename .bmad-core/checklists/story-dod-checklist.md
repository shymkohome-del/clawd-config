# Story Definition of Done (Extended with Git Completion)

Purpose: Enforce completion gates including commit/push (and optional PR) after all validations pass.

Preconditions:
- All story Tasks/Subtasks checked [x].
- Lint and tests pass locally and in CI (if applicable).

Steps:
1. Verify clean working state
   - Run: `git status --porcelain` (should only show intended changes)
2. Stage and commit with standardized message
   - Run: `git add -A`
   - Run: `git commit -m "feat(story-${id}): ${title}"` (use repo policy commitTemplate)
3. Run local quality gates (must pass before push)
   - Run: `dart format --output=none --set-exit-if-changed .` (fix with `dart format .` if needed)
   - Run: `flutter analyze --fatal-infos --fatal-warnings`
   - Run: `flutter test --no-pub`
4. Push to upstream
   - Run: `git push`
5. PR creation (policy-driven)
   - If `policies.git.requirePrOnCompletion = true` and GitHub CLI available:
     - Run: `gh pr create --fill --base main --head story/${id}-${slug}`
6. Confirm CI status (if PR created)
   - Ensure checks start and are visible on the PR

Outcome:
- Story is ready for review with changes pushed.
- If PR creation is required by policy, a PR exists targeting `main`.
