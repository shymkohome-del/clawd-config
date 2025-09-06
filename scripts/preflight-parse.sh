#!/usr/bin/env bash
set -euo pipefail

# preflight-parse.sh: Validate branch naming and story file presence locally (no network calls)
# Usage: preflight-parse.sh <branch>

BRANCH=${1:-${GITHUB_REF_NAME:-}}
if [[ -z "$BRANCH" ]]; then
  echo "Usage: $0 <branch>" >&2
  exit 2
fi

echo "[preflight] Branch: $BRANCH"

reason=""
qa_done="false"
story_id=""
story_file=""

if [[ "$BRANCH" =~ ^story/([0-9]+(\.[0-9]+)*)- ]]; then
  story_id="${BASH_REMATCH[1]}"
<<<<<<< HEAD
  # Extract the slug part after the story ID
  slug_part=${BRANCH#story/${story_id}-}
  
  # First try to find exact match with slug
  story_file=$(find docs/stories -maxdepth 1 -type f -name "${story_id}.${slug_part}.md" 2>/dev/null | head -n1 || true)
  
  # If no exact match, try pattern matching but prefer longer matches (epics over individual stories)
  if [[ -z "${story_file:-}" ]]; then
    story_file=$(find docs/stories -maxdepth 1 -type f -name "${story_id}.*.md" 2>/dev/null | sort -r | head -n1 || true)
  fi
  
=======
  # find story file by id prefix
  story_file=$(ls docs/stories/${story_id}.*.md 2>/dev/null | head -n1 || true)
>>>>>>> origin/story/0.9.3-auto-merge
  if [[ -z "${story_file:-}" ]]; then
    reason="story-file-missing"
  else
    status_line=$(grep -iE '^Status:' "$story_file" || true)
    if echo "$status_line" | grep -qi 'Done'; then
      qa_done="true"
    else
      reason="status-not-done"
    fi
  fi
elif [[ "$BRANCH" =~ ^(feature|fix|chore|patch)/ ]]; then
  qa_done="true"
else
  reason="unsupported-branch"
fi

echo "qa_done=${qa_done}"
echo "story_id=${story_id}"
echo "story_file=${story_file}"
echo "reason=${reason}"

if [[ "$qa_done" != "true" ]]; then
  echo "[preflight] Not eligible for auto PR: reason=${reason}" >&2
fi



