#!/usr/bin/env bash
set -euo pipefail

# Remove macOS AppleDouble (resource fork) artifacts and .DS_Store files
# from the repository working tree to avoid local tooling issues.

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT"

case "$(uname -s)" in
  Darwin)
    # Try dot_clean to merge extended attributes and remove AppleDouble
    command -v dot_clean >/dev/null 2>&1 && dot_clean -m "$ROOT" || true
    ;;
esac

# As a safe fallback, delete AppleDouble files and .DS_Store across the repo
find . -path "./.git" -prune -o -name '._*' -type f -delete 2>/dev/null || true
find . -path "./.git" -prune -o -name '.DS_Store' -type f -delete 2>/dev/null || true

echo "AppleDouble cleanup complete."

