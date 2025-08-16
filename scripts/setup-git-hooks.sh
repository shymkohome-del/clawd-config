#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Configure core.hooksPath to use .git-hooks
git config core.hooksPath .git-hooks

# Ensure executables
chmod +x .git-hooks/pre-commit .git-hooks/pre-push

echo "Git hooks installed to .git-hooks and made executable."


