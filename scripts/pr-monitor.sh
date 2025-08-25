#!/usr/bin/env bash
set -euo pipefail

# PR Monitor: watch a PR's checks and update story Change Log on failure
# Usage:
#   scripts/pr-monitor.sh <branch|#pr> [--interval 20] [--timeout 1800] [--once]
#
# Behavior:
# - Resolves PR number for branch or uses provided #pr
# - Polls GitHub checks; if any failing/conclusion!=success, summarizes
# - If branch is story/<id>-<slug> and story file exists, appends Change Log entry with routing
# - Heuristics to route to agent: build/test->dev; workflow/yaml->dev; qa label gate->qa; rebase->dev; unknown->dev
# - Exits:
#    0: PR merged or all checks successful within timeout
#    1: PR closed without merge
#    2: needs-rebase label detected
#  124: timeout

usage() {
  cat <<USAGE
Usage: $0 <branch|#pr> [--interval 20] [--timeout 1800] [--once]
USAGE
}

if [[ $# -lt 1 ]]; then usage; exit 2; fi

TARGET="$1"; shift || true
INTERVAL=20
TIMEOUT=1800
RUN_ONCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --interval) INTERVAL="$2"; shift 2;;
    --timeout) TIMEOUT="$2"; shift 2;;
    --once) RUN_ONCE=true; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

note() { printf '[%(%H:%M:%S)T] %s\n' -1 "$*"; }

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) not found. Install and authenticate gh." >&2
  exit 3
fi

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

note "Monitoring PR #$PR_NUM for checks and status..."

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

append_story_log() {
  local branch="$1"; shift
  local summary="$1"; shift
  local route_agent="$1"; shift

  if [[ "$branch" =~ ^story/([0-9]+(\.[0-9]+)*)- ]]; then
    local id="${BASH_REMATCH[1]}"
    local story_file
    story_file=$(find docs/stories -maxdepth 1 -type f -name "${id}.*.md" | head -n1 || true)
    if [[ -n "$story_file" ]]; then
      local date
      date=$(date +%F)
      # version reserved for future use; kept for clarity
      local version
      version="auto"
      # Append a Change Log row; keep simple increment note
      {
        echo ""
        echo "| ${date} | auto | PR monitor: ${summary} → Routed to ${route_agent} | Dev |"
      } >> "$story_file"
      note "Story Change Log updated in $story_file"
    else
      note "Story file docs/stories/${id}.*.md not found; skipping story update"
    fi
  fi
}

route_agent_for() {
  local name="$1"
  local conclusion="$2"
  local status="$3"
  # Basic heuristics
  if [[ "$name" =~ (build|test|Flutter CI|build-and-test) ]]; then echo "dev"; return; fi
  if [[ "$name" =~ (Workflow Lint|actionlint|yamllint|workflow) ]]; then echo "dev"; return; fi
  if [[ "$name" =~ (PR Lint|pr-lint|Label Guard|label) ]]; then echo "dev"; return; fi
  if [[ "$name" =~ (QA Gate|qa-approved|qa) ]]; then echo "qa"; return; fi
  echo "dev"
}

branch_name=$(gh pr view "$PR_NUM" --json headRefName --jq '.headRefName')

elapsed=0
while (( elapsed <= TIMEOUT )); do
  pr_json=$(gh pr view "$PR_NUM" --json state,mergedAt,labels,headRefName,commits,url 2>/dev/null || true)
  state=$(printf '%s' "$pr_json" | jq -r '.state // ""')
  mergedAt=$(printf '%s' "$pr_json" | jq -r '.mergedAt // empty')
  labels=$(printf '%s' "$pr_json" | jq -r '(.labels // []) | map(.name) | join(",")')
  url=$(printf '%s' "$pr_json" | jq -r '.url // ""')
  sha=$(printf '%s' "$pr_json" | jq -r '.commits.nodes[-1].commit.oid // empty')

  note "PR #$PR_NUM state=${state} mergedAt=${mergedAt:-""} labels=${labels}"

  if [[ "$labels" == *needs-rebase* ]]; then
    note "PR needs rebase."
    append_story_log "$branch_name" "needs-rebase detected on $url" "dev"
    exit 2
  fi
  if [[ -n "$mergedAt" || "$state" == "MERGED" ]]; then
    note "PR merged."
    exit 0
  fi
  if [[ "$state" == "CLOSED" ]]; then
    note "PR closed without merge."
    append_story_log "$branch_name" "PR closed without merge $url" "dev"
    exit 1
  fi

  if [[ -n "$sha" ]]; then
    checks_json=$(gh api -H "Accept: application/vnd.github+json" "/repos/{owner}/{repo}/commits/$sha/check-runs" 2>/dev/null || echo '{}')
    failing=$(printf '%s' "$checks_json" | jq -rc '[.check_runs[] | select((.conclusion!=null and .conclusion!="success") or (.status=="completed" and .conclusion!="success"))][0] // empty')
    if [[ -n "$failing" ]]; then
      name=$(printf '%s' "$failing" | jq -r '.name')
      concl=$(printf '%s' "$failing" | jq -r '.conclusion // ""')
      status=$(printf '%s' "$failing" | jq -r '.status // ""')
      summary=$(printf '%s' "$failing" | jq -r '.output.summary // .output.title // ""')
      route=$(route_agent_for "$name" "$concl" "$status")
      short="Check '${name}' ${concl:-$status}. ${summary}"
      note "Detected failing check: ${short}"
      append_story_log "$branch_name" "$short" "$route"
      if [[ "$RUN_ONCE" == true ]]; then exit 0; fi
    fi
  fi

  if [[ "$RUN_ONCE" == true ]]; then exit 0; fi
  sleep "$INTERVAL"
  elapsed=$((elapsed+INTERVAL))
done

note "Timeout waiting for green/merge."
exit 124


