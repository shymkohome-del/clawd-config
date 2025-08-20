#!/usr/bin/env bash
set -euo pipefail

# Story development automation helper
# Commands:
#   init-hooks                  → configure local hooks and make them executable
#   start <id> <slug>           → checkout latest develop, create story/<id>-<slug>, set upstream, push
#   watch-rebase [seconds]      → periodically rebase current story/* branch onto origin/develop (default 300s)
#   stop-watch                  → stop the running rebase watcher
#   open-pr [title] [body]      → create PR (story/* → develop) and enable auto-merge if available
#   status                      → show branch + ahead/behind + watcher status

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ -z "${REPO_ROOT}" ]]; then
  echo "This script must be run inside a git repository" >&2
  exit 1
fi
cd "${REPO_ROOT}"

WATCH_PID_FILE=".git/.story-rebase-watch.pid"

slugify() {
  # lowercase, spaces/underscores → hyphens, remove invalid chars
  printf '%s' "$*" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[ _]+/-/g; s/[^a-z0-9-]//g; s/-+/-/g; s/^-|-$//g'
}

ensure_branch() {
  local branch="$1"
  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    git checkout "${branch}"
  else
    git checkout -b "${branch}"
  fi
}

cmd_init_hooks() {
  if [[ -x scripts/setup-git-hooks.sh ]]; then
    scripts/setup-git-hooks.sh
  else
    # Fallback minimal hooksPath config
    git config core.hooksPath .git-hooks
    chmod +x .git-hooks/* 2>/dev/null || true
    echo "Git hooks configured."
  fi
}

cmd_start() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 start <id> <slug>" >&2
    exit 2
  fi
  local id="$1"; shift
  local slug=$(slugify "$*")
  local story_branch="story/${id}-${slug}"

  echo "Fetching latest..."
  git fetch origin
  echo "Syncing develop..."
  ensure_branch develop
  git pull --ff-only origin develop

  echo "Creating/switching to ${story_branch}..."
  ensure_branch "${story_branch}"
  git push -u origin "${story_branch}" 2>/dev/null || true

  echo "Branch ready: ${story_branch}"
  echo "Tip: start rebase watcher with: $0 watch-rebase &"
}

cmd_watch_rebase() {
  local interval="${1:-300}"
  if [[ -f "${WATCH_PID_FILE}" ]] && kill -0 "$(cat "${WATCH_PID_FILE}")" 2>/dev/null; then
    echo "Watcher already running with PID $(cat "${WATCH_PID_FILE}")"
    exit 0
  fi

  (
    echo "[watch-rebase] starting (interval=${interval}s)"
    while true; do
      current_branch=$(git rev-parse --abbrev-ref HEAD)
      if [[ "${current_branch}" =~ ^story/ || "${current_branch}" =~ ^feature/ ]]; then
        git fetch origin >/dev/null 2>&1 || true
        # Check if branch is behind origin/develop
        if git show-ref --verify --quiet refs/remotes/origin/develop; then
          behind_ahead=$(git rev-list --left-right --count "${current_branch}...origin/develop" 2>/dev/null || echo "0 0")
          behind=$(echo "${behind_ahead}" | awk '{print $1}')
          if [[ "${behind}" -gt 0 ]]; then
            echo "[watch-rebase] Rebase ${current_branch} onto origin/develop (behind ${behind})"
            if ! git rebase --autostash origin/develop; then
              echo "[watch-rebase] CONFLICT during rebase. Please resolve manually and restart watcher."
              exit 1
            fi
          fi
        fi
      fi
      sleep "${interval}"
    done
  ) &
  echo $! > "${WATCH_PID_FILE}"
  disown || true
  echo "Rebase watcher running in background (PID $(cat "${WATCH_PID_FILE}"))"
}

cmd_stop_watch() {
  if [[ -f "${WATCH_PID_FILE}" ]]; then
    local pid=$(cat "${WATCH_PID_FILE}")
    if kill -0 "${pid}" 2>/dev/null; then
      kill "${pid}" || true
      echo "Stopped watcher (PID ${pid})"
    fi
    rm -f "${WATCH_PID_FILE}"
  else
    echo "No watcher PID file found"
  fi
}

cmd_open_pr() {
  local title="${1:-}"; shift || true
  local body="${1:-}"; shift || true
  local branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ ! "${branch}" =~ ^story/ ]]; then
    echo "Current branch is not a story/* branch: ${branch}" >&2
    exit 2
  fi
  local id=$(printf '%s' "${branch}" | sed -E 's#^story/([0-9]+(\.[0-9]+)*)-.*#\1#')
  if [[ -z "${title}" ]]; then
    title="story ${id}: ${branch#story/}"
  fi
  if ! command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI (gh) not found. Create PR manually on GitHub with base=develop and head=${branch}." >&2
    exit 3
  fi
  # Ensure remote branch exists
  git push -u origin "${branch}" || true
  gh pr create --title "${title}" --body "${body}"
  # Try to set base to develop if not default
  gh pr edit --base develop || true
  # Enable auto-merge (squash) to merge when checks pass and approvals received
  gh pr merge --auto --squash || true
  echo "PR created and auto-merge requested (if repository settings allow)."
}

cmd_status() {
  local branch=$(git rev-parse --abbrev-ref HEAD)
  echo "Branch: ${branch}"
  if git show-ref --verify --quiet refs/remotes/origin/develop; then
    local counts=$(git rev-list --left-right --count "HEAD...origin/develop" 2>/dev/null || echo "0 0")
    echo "Ahead/Behind vs origin/develop (HEAD...origin/develop): ${counts}"
  fi
  if [[ -f "${WATCH_PID_FILE}" ]] && kill -0 "$(cat "${WATCH_PID_FILE}")" 2>/dev/null; then
    echo "Watcher: running (PID $(cat "${WATCH_PID_FILE}"))"
  else
    echo "Watcher: not running"
  fi
}

usage() {
  cat <<USAGE
Usage: $0 <command> [args]

Commands:
  init-hooks                  Configure local git hooks
  start <id> <slug>           Create/switch to story/<id>-<slug> from latest develop
  watch-rebase [seconds]      Background rebase of story branch onto origin/develop
  stop-watch                  Stop rebase watcher
  open-pr [title] [body]      Create PR to develop and request auto-merge
  status                      Show repo status and watcher info
USAGE
}

cmd="${1:-}"; shift || true
case "${cmd}" in
  init-hooks)     cmd_init_hooks "$@" ;;
  start)          cmd_start "$@" ;;
  watch-rebase)   cmd_watch_rebase "$@" ;;
  stop-watch)     cmd_stop_watch "$@" ;;
  open-pr)        cmd_open_pr "$@" ;;
  status)         cmd_status "$@" ;;
  *)              usage; exit 1 ;;
esac


