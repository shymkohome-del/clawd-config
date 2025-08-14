# Story Git Init Checklist

Purpose: Ensure development starts on a dedicated feature branch per story with upstream tracking.

Preconditions:
- Current story is selected and not in Draft.
- Extract `${id}`, `${title}` from the story; derive `${slug}` per slug rules.

Steps:
1. Compute identifiers
   - id = story id (e.g., `0.1`)
   - title = short title (e.g., `Repo & CI baseline`)
   - slug = lower-case, spaces→`-`, strip non `[a-z0-9-]` (e.g., `repo-and-ci-baseline`)
2. Create/switch to feature branch (must match policy)
   - Run: `git fetch origin`
   - Run: `git checkout -b story/${id}-${slug} || git switch story/${id}-${slug}`
   - Validate: branch name matches regex `^story/[0-9]+(\.[0-9]+)*-[a-z0-9-]+$`
3. Set upstream to origin
   - Run: `git push -u origin story/${id}-${slug}`
4. Validate policy
   - Current branch name matches template `story/${id}-${slug}`
   - Upstream set: `git rev-parse --abbrev-ref --symbolic-full-name @{u}` returns `origin/story/${id}-${slug}`

Outcome:
- Development proceeds only on the feature branch.
- Any deviation should block `develop-story` until fixed. Rename with `git branch -m story/${id}-${slug}` and push with `git push -u origin story/${id}-${slug}`.
