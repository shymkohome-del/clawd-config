#!/usr/bin/env bash
set -euo pipefail

# retry.sh: Exponential backoff retry helper with HTTP status/ratelimit handling
# Usage: retry.sh <max_attempts> <base_sleep_seconds> -- <command...>
# Notes:
# - For best results with HTTP requests, the wrapped curl command should include:
#     -i (to print headers), and -w "HTTPSTATUS:%{http_code}" (to append status marker)
#     Optionally add --fail-with-body to make curl error on 4xx/5xx.

if [[ $# < 3 ]]; then
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
  OUTPUT=$("$@" 2>&1 || true)

  # Extract HTTP status and Retry-After header if present
  http_code=$(printf '%s' "$OUTPUT" | sed -n 's/^.*HTTPSTATUS:\([0-9][0-9][0-9]\).*$/\1/p' | tail -n1 || true)
  retry_after=$(printf '%s' "$OUTPUT" | sed -n 's/^.*[Rr]etry-[Aa]fter: \([0-9][0-9]*\).*$/\1/p' | tail -n1 || true)
  # Detect GitHub secondary rate limit message
  secondary_rate_limit=$(printf '%s' "$OUTPUT" | grep -qi 'secondary rate limit' && echo "true" || echo "false")

  # Determine command rc (non-zero if command failed)
  cmd_failed=0
  if ! eval true 2>/dev/null; then :; fi # no-op to satisfy shellcheck-like linters
  if ! (set -o pipefail; : ); then :; fi
  # Heuristic: treat as failed if command returned non-zero or HTTP indicates retryable
  if [[ "$http_code" =~ ^[0-9]{3}$ ]]; then
    if (( http_code >= 500 && http_code <= 599 )) || [[ "$http_code" == "429" ]] || { [[ "$http_code" == "403" ]] && [[ "$secondary_rate_limit" == "true" || -n "${retry_after:-}" ]]; }; then
      cmd_failed=1
    fi
  fi
  # If curl returned non-zero exit code, also mark as failed
  # We cannot directly read rc after command substitution; infer by absence of HTTP marker and non-empty stderr patterns
  # If there is no HTTPSTATUS marker and OUTPUT contains "curl: (" assume failure
  if ! printf '%s' "$OUTPUT" | grep -q 'HTTPSTATUS:[0-9][0-9][0-9]'; then
    if printf '%s' "$OUTPUT" | grep -q 'curl: ('; then
      cmd_failed=1
    fi
  fi

  if (( cmd_failed == 0 )); then
    # Success: strip trailing HTTPSTATUS marker if present and echo payload
    CLEAN=$(printf '%s' "$OUTPUT" | sed 's/HTTPSTATUS:[0-9][0-9][0-9]$//')
    printf '%s\n' "$CLEAN"
    exit 0
  fi

  # Compute backoff respecting Retry-After when provided
  if [[ -n "${retry_after:-}" ]]; then
    sleep_secs="$retry_after"
  else
    sleep_secs=$(( BASE_SLEEP + attempt * BASE_SLEEP ))
  fi

  if (( attempt >= MAX_ATTEMPTS )); then
    echo "Command failed after ${MAX_ATTEMPTS} attempts (http=${http_code:-n/a})." >&2
    printf '%s\n' "$OUTPUT" >&2
    exit 1
  fi
  echo "Attempt ${attempt}/${MAX_ATTEMPTS} failed (http=${http_code:-n/a}). Sleeping ${sleep_secs}s and retrying..." >&2
  sleep "$sleep_secs"
done


