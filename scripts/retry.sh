#!/usr/bin/env bash
set -euo pipefail

# retry.sh: Exponential backoff retry helper with HTTP status/RateLimit handling
# Usage: retry.sh <max_attempts> <base_sleep_seconds> -- <command...>
# Notes:
#   - To enable HTTP-aware retries, the command SHOULD append the token
#     "HTTPSTATUS:<code>" to stdout (e.g. curl -w "HTTPSTATUS:%{http_code}").
#   - To honor Retry-After, include response headers in output (e.g. curl -i)
#     so the script can parse a numeric Retry-After header value.

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
  OUTPUT="$($@ 2>&1)"; rc=$?
  # Parse optional HTTP status and Retry-After hints
  http_code=$(printf '%s' "$OUTPUT" | sed -n 's/^HTTPSTATUS:\([0-9][0-9][0-9]\)$/\1/p' | tail -n1 || true)
  [[ -z "${http_code:-}" ]] && http_code=$(printf '%s' "$OUTPUT" | sed -n 's/^.*HTTPSTATUS:\([0-9][0-9][0-9]\).*$/\1/p' | tail -n1 || true)
  retry_after=$(printf '%s' "$OUTPUT" | sed -n 's/^Retry-After: \([0-9][0-9]*\).*$/\1/p' | head -n1 || true)

  # Determine if this attempt should be considered a failure to trigger retry
  should_retry=0
  if (( rc != 0 )); then
    should_retry=1
  else
    # rc==0 but HTTP indicates transient failure (5xx or 429)
    if [[ -n "${http_code:-}" ]] && { [[ "$http_code" =~ ^5[0-9][0-9]$ ]] || [[ "$http_code" == "429" ]]; }; then
      should_retry=1
    fi
  fi

  if (( should_retry == 0 )); then
    printf '%s\n' "$OUTPUT"
    exit 0
  fi

  if (( attempt >= MAX_ATTEMPTS )); then
    echo "Command failed after ${MAX_ATTEMPTS} attempts (rc=${rc}, http=${http_code:-n/a})." >&2
    printf '%s\n' "$OUTPUT" >&2
    exit "$rc"
  fi

  if [[ -n "${retry_after:-}" ]]; then
    sleep_secs="$retry_after"
  else
    sleep_secs=$(( BASE_SLEEP + attempt * BASE_SLEEP ))
  fi
  echo "Attempt ${attempt}/${MAX_ATTEMPTS} failed (rc=${rc}, http=${http_code:-n/a}). Sleeping ${sleep_secs}s and retrying..." >&2
  sleep "$sleep_secs"
done


