#!/usr/bin/env bash
set -euo pipefail

# QA Watch and Sync: Enhanced PR watching with post-merge develop sync
# Usage: scripts/qa-watch-and-sync.sh <branch|#pr> [--interval 20] [--timeout 1800] [--log FILE]
#
# This script wraps watch-pr.sh and adds automatic develop branch sync after successful merge.
# Behavior:
#   0: PR merged successfully → switches to develop and pulls latest
#   1: PR closed without merge → stays on current branch  
#   2: PR needs rebase → stays on current branch
# 124: timeout → stays on current branch

usage() {
  cat <<USAGE
Usage: $0 <branch|#pr> [--interval 20] [--timeout 1800] [--log FILE]

Enhanced PR watcher that automatically syncs develop branch after successful merge.
Wraps watch-pr.sh with additional post-merge automation for QA workflow.

Exit codes:
  0: PR merged and develop synced successfully
  1: PR closed without merge
  2: PR needs rebase (needs-rebase label detected)
124: Timeout waiting for merge
  3: Git/GitHub CLI not available
 10: Post-merge sync failed (merge was successful)
USAGE
}

if [[ $# -lt 1 ]]; then usage; exit 2; fi

# Handle help before passing to watch-pr.sh
if [[ "${1:-}" =~ ^(-h|--help)$ ]]; then usage; exit 0; fi

# Get the directory of this script to find watch-pr.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WATCH_PR_SCRIPT="$SCRIPT_DIR/watch-pr.sh"

if [[ ! -f "$WATCH_PR_SCRIPT" ]]; then
  echo "ERROR: Cannot find watch-pr.sh at $WATCH_PR_SCRIPT" >&2
  exit 3
fi

note() {
  printf '[%(%H:%M:%S)T] %s\n' -1 "$*"
}

# Store original branch for reference
ORIGINAL_BRANCH=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  ORIGINAL_BRANCH=$(git branch --show-current 2>/dev/null || true)
fi

note "QA Watch and Sync: Starting enhanced PR watch..."
note "Original branch: ${ORIGINAL_BRANCH:-unknown}"

# Run the original watch-pr.sh with all arguments
note "Running watch-pr.sh..."
EXIT_CODE=0
"$WATCH_PR_SCRIPT" "$@" || EXIT_CODE=$?

case $EXIT_CODE in
  0)
    note "PR merged successfully! Syncing develop branch..."
    
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      note "WARNING: Not in a git repository, cannot sync develop branch"
      exit 10
    fi
    
    # Switch to develop and pull latest changes
    note "Switching to develop branch..."
    if ! git checkout develop 2>/dev/null; then
      note "ERROR: Failed to checkout develop branch"
      exit 10
    fi
    
    note "Pulling latest changes from origin/develop..."
    if ! git pull origin develop; then
      note "ERROR: Failed to pull latest changes from develop"
      note "You may need to resolve conflicts manually"
      exit 10
    fi
    
    note "✅ Success! PR merged and develop branch synced"
    note "Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    note "Latest commit: $(git log --oneline -1 2>/dev/null || echo 'unknown')"
    
    exit 0
    ;;
    
  1)
    note "PR was closed without merge - no develop sync needed"
    exit 1
    ;;
    
  2)
    note "PR needs rebase - no develop sync needed"
    note "Please rebase your branch and try again"
    exit 2
    ;;
    
  124)
    note "Timeout waiting for PR merge - no develop sync needed"
    exit 124
    ;;
    
  *)
    note "watch-pr.sh exited with unexpected code: $EXIT_CODE"
    exit $EXIT_CODE
    ;;
esac