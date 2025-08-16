#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Configure core.hooksPath to use .git-hooks
git config core.hooksPath .git-hooks

# Ensure executables
chmod +x .git-hooks/pre-commit .git-hooks/pre-push .git-hooks/commit-msg 2>/dev/null || true

# Ensure story helper is executable
chmod +x scripts/story-flow.sh 2>/dev/null || true
# Ensure QA label helper is executable
chmod +x scripts/qa-label.sh 2>/dev/null || true

echo "Git hooks installed to .git-hooks and made executable."


