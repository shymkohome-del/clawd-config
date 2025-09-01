#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <docs/stories/<id>.<slug>.md>" >&2
  exit 1
fi

story_file="$1"
base="$(basename "$story_file")"
name="${base%.md}"
id="${name%.*}"
slug="${name##*.}"
echo "story/${id}-${slug}"
