#!/usr/bin/env bash
set -euo pipefail

# run-act.sh: Convenience wrapper to mirror key workflows locally with act
# Usage:
#   scripts/run-act.sh qa    # Simulate push to story branch → auto-pr-from-qa.yml
#   scripts/run-act.sh mog   # Simulate pull_request labeled → merge-on-green-fallback.yml

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

MODE="${1:-qa}"

if ! command -v act >/dev/null 2>&1; then
  echo "[run-act] 'act' not found. Install with: brew install act (macOS)"
  exit 2
fi

# Provide a dummy token by default; real calls will be skipped or fail gracefully
GITHUB_TOKEN_VALUE="${GITHUB_TOKEN:-dummy}"

export CI_LOCAL=true

case "$MODE" in
  qa)
    echo "[run-act] Running auto-pr-from-qa.yml with push-story event..."
    act push \
      -W .github/workflows/auto-pr-from-qa.yml \
      -e .github/events/push-story.json \
      -s GITHUB_TOKEN="${GITHUB_TOKEN_VALUE}" \
      --env CI_LOCAL=true \
      --container-architecture linux/amd64
    ;;
  mog)
    echo "[run-act] Running merge-on-green-fallback.yml with pull_request labeled event..."
    act pull_request \
      -W .github/workflows/merge-on-green-fallback.yml \
      -e .github/events/pull_request-labeled.json \
      -s GITHUB_TOKEN="${GITHUB_TOKEN_VALUE}" \
      --env CI_LOCAL=true \
      --container-architecture linux/amd64
    ;;
  *)
    echo "Usage: $0 {qa|mog}"
    exit 1
    ;;
esac



