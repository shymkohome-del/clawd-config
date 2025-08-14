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
4. Ensure story file is fully updated
   - Confirm `Status` is set to `Review`
   - Confirm `Dev Agent Record` contains:
     - Agent Model Used
     - Debug Log References (e.g., `.ai/debug-log.md`)
     - Completion Notes List (concise bullet points)
     - File List (every added/modified/deleted file)
   - Add a `Change Log` entry for the developer completion
5. Push to upstream
   - Run: `git push`
5. PR creation (policy-driven)
   - Validate branch name policy before creating a PR
     - Current branch must match `^story/[0-9]+(\.[0-9]+)*-[a-z0-9-]+$`
     - If it does not, HALT and fix:
       - Run: `git branch -m story/${id}-${slug}`
       - Run: `git push -u origin story/${id}-${slug}`
   - Create the PR with explicit story reference in title/body
     - If `policies.git.requirePrOnCompletion = true` and GitHub CLI is available, run:
       - `gh pr create --title "story ${id}: ${title}" --body "Implements ${title}. Related to story ${id}." --base main --head story/${id}-${slug}`
   - Enforcement: The PR title OR body must include a story id reference (one of: `story ${id}`, `story-${id}`, `story/${id}`, `story: ${id}`). If missing, update the PR:
     - `gh pr edit --title "story ${id}: ${title}" --body "Implements ${title}. Related to story ${id}."`
6. Confirm CI status (if PR created)
   - Ensure checks start and are visible on the PR

Outcome:
- Story is ready for review with changes pushed.
- If PR creation is required by policy, a PR exists targeting `main`.
