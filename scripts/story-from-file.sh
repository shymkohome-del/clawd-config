#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 docs/stories/<id>.<slug>.md" >&2
  exit 1
fi

file="$1"
base="$(basename "$file")"
name="${base%.md}"

# Derive id as everything before the first dot, slug as everything after
id="${name%%.*}"
slug="${name#*.}"

echo "story/${id}-${slug}"

