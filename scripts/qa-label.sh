#!/usr/bin/env bash
set -euo pipefail

# Apply a label to a PR using GitHub CLI.
# Usage: scripts/qa-label.sh <pr_number> [label]

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <pr_number> [label]" >&2
  exit 2
fi

PR_NUMBER="$1"
LABEL="${2:-qa-approved}"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) not found. Install gh or label manually on GitHub." >&2
  exit 3
fi

gh pr edit "$PR_NUMBER" --add-label "$LABEL"
echo "Label '$LABEL' added to PR #$PR_NUMBER"


