#!/usr/bin/env bash
set -euo pipefail

# retry.sh: Exponential backoff retry helper with optional HTTP status/Ratelimit handling
# Usage: retry.sh <max_attempts> <base_sleep_seconds> -- <command...>
# Example: retry.sh 5 2 -- curl -sS https://api.github.com

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <max_attempts> <base_sleep_seconds> -- <command...>" >&2
  exit 2
fi

MAX_ATTEMPTS="$1"; shift
BASE_SLEEP="$1"; shift
if [[ "$1" != "--" ]]; then
  echo "Missing -- delimiter before command" >&2
  exit 2
fi
shift

attempt=0
while (( attempt < MAX_ATTEMPTS )); do
  attempt=$((attempt+1))
  if OUTPUT=$("$@" 2>&1); then
    printf '%s\n' "$OUTPUT"
    exit 0
  fi
  rc=$?
  # Simple detection for HTTP status and Retry-After header in output
  http_code=$(printf '%s' "$OUTPUT" | sed -n 's/^.*HTTPSTATUS:\([0-9][0-9][0-9]\).*$/\1/p' | tail -n1 || true)
  retry_after=$(printf '%s' "$OUTPUT" | sed -n 's/^.*Retry-After: \([0-9][0-9]*\).*$/\1/p' | tail -n1 || true)
  if [[ -n "${retry_after:-}" ]]; then
    sleep_secs="$retry_after"
  else
    sleep_secs=$(( BASE_SLEEP + attempt * BASE_SLEEP ))
  fi
  if (( attempt >= MAX_ATTEMPTS )); then
    echo "Command failed after ${MAX_ATTEMPTS} attempts (rc=${rc}, http=${http_code:-n/a})." >&2
    printf '%s\n' "$OUTPUT" >&2
    exit "$rc"
  fi
  echo "Attempt ${attempt}/${MAX_ATTEMPTS} failed (rc=${rc}, http=${http_code:-n/a}). Sleeping ${sleep_secs}s and retrying..." >&2
  sleep "$sleep_secs"
done


