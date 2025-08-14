## Local Hooks (Optional but Recommended)

Install pre-commit/pre-push hooks to prevent wrong branches and formatting errors:

1) Pre-commit (format + analyze)
```bash
cat > .git/hooks/pre-commit <<'SH'
#!/usr/bin/env bash
set -euo pipefail
(cd crypto_market && dart format --output=none --set-exit-if-changed .)
(cd crypto_market && flutter analyze --fatal-infos --fatal-warnings)
SH
chmod +x .git/hooks/pre-commit
```

2) Pre-push (branch name policy + tests)
```bash
cat > .git/hooks/pre-push <<'SH'
#!/usr/bin/env bash
set -euo pipefail
branch=$(git rev-parse --abbrev-ref HEAD)
if [[ ! "$branch" =~ ^story/[0-9]+(\.[0-9]+)*-[a-z0-9-]+$ ]]; then
  echo "ERROR: Branch must be story/<id>-<slug> (e.g., story/0.3-config-and-secrets)" >&2
  exit 1
fi
(cd crypto_market && flutter test --no-pub)
SH
chmod +x .git/hooks/pre-push
```

# Enhanced Development Workflow

This is a simple step-by-step guide to help you efficiently manage your development workflow using the BMad Method. Refer to the **[<ins>User Guide</ins>](user-guide.md)** for any scenario that is not covered here.

## Create new Branch

1. **Start new branch**

## Story Creation (Scrum Master)

1. **Start new chat/conversation**
2. **Load SM agent**
3. **Execute**: `*draft` (runs create-next-story task)
4. **Review generated story** in `docs/stories/`
5. **Update status**: Change from "Draft" to "Approved"

## Story Implementation (Developer)

1. **Start new chat/conversation**
2. **Load Dev agent**
3. **Execute**: `*develop-story {selected-story}` (runs execute-checklist task)
4. **Review generated report** in `{selected-story}`

## Story Review (Quality Assurance)

1. **Start new chat/conversation**
2. **Load QA agent**
3. **Execute**: `*review {selected-story}` (runs review-story task)
4. **Review generated report** in `{selected-story}`

## Commit Changes and Push

1. **Commit changes**
2. **Push to remote**

## Open Pull Request (Policy-Driven)

If PRs are required on completion (`policies.git.requirePrOnCompletion = true`) and you have GitHub CLI installed:

```bash
gh pr create \
  --title "story ${id}: ${title}" \
  --body "Implements ${title}. Related to story ${id}." \
  --base main \
  --head story/${id}-${slug}
```

Notes:
- Branch name must match: `story/<id>-<slug>` (e.g., `story/1.1-register-with-email-or-social`)
- PR title or body must contain a story id reference: one of `story ${id}`, `story-${id}`, `story/${id}`, `story: ${id}`

## Repeat Until Complete

- **SM**: Create next story → Review → Approve
- **Dev**: Implement story → Complete → Mark Ready for Review
- **QA**: Review story → Mark done
- **Commit**: All changes
- **Push**: To remote
- **Continue**: Until all features implemented
