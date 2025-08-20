#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 <branch|#pr> [--interval 20] [--timeout 1800] [--log FILE]

Poll a PR until it merges (exit 0), closes without merge (exit 1),
or times out (exit 124). Returns 2 immediately if 'needs-rebase' label is present.
Requires GitHub CLI (gh) authentication.
USAGE
}

if [[ $# -lt 1 ]]; then usage; exit 2; fi

TARGET="$1"; shift || true
INTERVAL=20
TIMEOUT=1800
LOG_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --interval) INTERVAL="$2"; shift 2;;
    --timeout) TIMEOUT="$2"; shift 2;;
    --log) LOG_FILE="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

note() { local m="$*"; if [[ -n "$LOG_FILE" ]]; then printf '[%(%H:%M:%S)T] %s\n' -1 "$m" | tee -a "$LOG_FILE"; else printf '[%(%H:%M:%S)T] %s\n' -1 "$m"; fi; }

# Resolve PR number
PR_NUM=""
if [[ "$TARGET" =~ ^#?[0-9]+$ ]]; then
  PR_NUM="${TARGET#'#'}"
else
  PR_NUM=$(gh pr list --state all --search "head:$TARGET" --json number --jq '.[0].number' 2>/dev/null || true)
fi

if [[ -z "$PR_NUM" ]]; then
  note "No PR found for target '$TARGET'"
  exit 2
fi

note "Watching PR #$PR_NUM (interval=${INTERVAL}s, timeout=${TIMEOUT}s)"

ELAPSED=0
while (( ELAPSED <= TIMEOUT )); do
  STATE=$(gh pr view "$PR_NUM" --json state,isDraft,merged,mergeStateStatus,mergeable,labels,url --jq '.state')
  MERGED=$(gh pr view "$PR_NUM" --json merged --jq '.merged')
  LABELS=$(gh pr view "$PR_NUM" --json labels --jq '(.labels // []) | map(.name) | join(",")')
  MSTATE=$(gh pr view "$PR_NUM" --json mergeStateStatus --jq '.mergeStateStatus')
  URL=$(gh pr view "$PR_NUM" --json url --jq '.url')
  note "PR #$PR_NUM status: state=${STATE} merged=${MERGED} mergeState=${MSTATE} labels=${LABELS} url=${URL}"

  if [[ "$LABELS" == *needs-rebase* ]]; then
    note "PR requires rebase (needs-rebase). Exiting with code 2."
    exit 2
  fi
  if [[ "$MERGED" == "true" || "$STATE" == "MERGED" ]]; then
    note "PR merged."
    exit 0
  fi
  if [[ "$STATE" == "CLOSED" ]]; then
    note "PR closed without merge."
    exit 1
  fi
  sleep "$INTERVAL"
  ELAPSED=$((ELAPSED+INTERVAL))
done

note "Timeout waiting for merge."
exit 124


