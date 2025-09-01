#!/usr/bin/env bash
set -euo pipefail

# run-act.sh: Convenience wrapper to mirror key workflows locally with act
# Usage:
#   scripts/run-act.sh core  # Run core required checks locally: workflow-lint, pr-lint, flutter-ci
#   scripts/run-act.sh qa    # Simulate push to story branch → auto-pr-from-qa.yml
#   scripts/run-act.sh mog   # Simulate pull_request labeled → merge-on-green-fallback.yml

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

MODE="${1:-core}"

if ! command -v act >/dev/null 2>&1; then
  echo "[run-act] 'act' not found. Install with: brew install act (macOS)"
  exit 2
fi

# Provide a dummy token by default; real calls will be skipped or fail gracefully
GITHUB_TOKEN_VALUE="${GITHUB_TOKEN:-dummy}"

export CI_LOCAL=true

case "$MODE" in
  core)
    echo "[run-act] Running core required checks (Workflow Lint, PR Lint, Flutter CI)..."
    PLATFORM_MAP="-P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest"
    # Workflow Lint (blocking)
    act push \
      -W .github/workflows/workflow-lint.yml \
      -s GITHUB_TOKEN="${GITHUB_TOKEN_VALUE}" \
      --env CI_LOCAL=true \
      --container-architecture linux/amd64 "$PLATFORM_MAP" || exit 1

    # PR Lint on push to story/** (blocking)
    act push \
      -W .github/workflows/pr-lint.yml \
      -e .github/events/push-story.json \
      -s GITHUB_TOKEN="${GITHUB_TOKEN_VALUE}" \
      --env CI_LOCAL=true \
      --container-architecture linux/amd64 "$PLATFORM_MAP" || exit 1

    # Flutter CI on push to story/** (optional via ACT_RUN_FLUTTER_CI=true)
    if [[ "${ACT_RUN_FLUTTER_CI:-false}" == "true" ]]; then
      act push \
        -W .github/workflows/flutter-ci.yml \
        -e .github/events/push-story.json \
        -s GITHUB_TOKEN="${GITHUB_TOKEN_VALUE}" \
        --env CI_LOCAL=true \
        --container-architecture linux/amd64 "$PLATFORM_MAP" || true
    fi
    ;;
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
    echo "Usage: $0 {core|qa|mog}"
    exit 1
    ;;
esac



