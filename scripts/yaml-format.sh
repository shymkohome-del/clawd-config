#!/usr/bin/env bash
set -euo pipefail

# Normalize YAML whitespace across the repository or specified files.
# Rules enforced:
# - Collapse multiple consecutive blank lines to a single blank line
# - Remove leading and trailing blank lines
# - Trim trailing spaces/tabs on each line
# - Ensure a trailing newline at end of file

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

declare -a TARGETS
if [[ $# -gt 0 ]]; then
  # Use passed files
  for f in "$@"; do
    [[ -f "$f" ]] && TARGETS+=("$f")
  done
else
  # Default: all tracked YAML files
  while IFS= read -r -d '' f; do
    TARGETS+=("$f")
  done < <(git ls-files -z | grep -zE '\\.(ya?ml)$')
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  echo "[yaml-format] No YAML files to process"
  exit 0
fi

CHANGED=0
for file in "${TARGETS[@]}"; do
  [[ -f "$file" ]] || continue
  tmp_file="$(mktemp)"
  # awk logic: trim trailing spaces; buffer single blank lines; drop leading/trailing blanks
  awk '
    BEGIN { pending_blank=0; started=0 }
    {
      line=$0
      sub(/[ \t]+$/, "", line)
      if (line ~ /^[ \t]*$/) {
        pending_blank=1
        next
      }
      if (pending_blank==1 && started==1) {
        print ""
      }
      print line
      started=1
      pending_blank=0
    }
    END {
      # If file ends with blanks, we simply do not flush them (so no trailing blank lines)
    }
  ' "$file" > "$tmp_file"

  if ! cmp -s "$file" "$tmp_file"; then
    mv "$tmp_file" "$file"
    echo "[yaml-format] Normalized $file"
    CHANGED=1
  else
    rm -f "$tmp_file"
  fi
done

# Re-stage files if inside a Git repo
if [[ $CHANGED -eq 1 ]] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git add -- "${TARGETS[@]}" 2>/dev/null || true
fi

exit 0


