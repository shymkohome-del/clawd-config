#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 docs/stories/<id>.<slug>.md" >&2
  echo "  - <id>: dotted numbers, e.g. 0.9.10" >&2
  echo "  - <slug>: lowercase, [a-z0-9-] only" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

file="$1"

# Must be a file and live under docs/stories
if [[ ! -f "$file" ]]; then
  echo "Error: file not found: $file" >&2
  usage
  exit 1
fi

case "$file" in
  */docs/stories/*|docs/stories/*) ;;
  *)
    echo "Error: path must be under docs/stories: $file" >&2
    usage
    exit 1
    ;;
esac

base="$(basename "$file")"

# Must end with .md
if [[ "$base" != *.md ]]; then
  echo "Error: not a Markdown file: $base" >&2
  usage
  exit 1
fi

name="${base%.md}"

# Require a dot separating <id> and <slug>
if [[ "$name" != *.* ]]; then
  echo "Error: filename must be <id>.<slug>.md, got: $base" >&2
  usage
  exit 1
fi

# Derive id as everything before the last dot; slug as everything after
id="${name%.*}"
slug="${name##*.}"

# Validate id: dotted numbers
if [[ ! "$id" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
  echo "Error: invalid id '$id' (expected dotted numbers like 0.9.10)" >&2
  exit 1
fi

# Validate slug: lowercase and [a-z0-9-]
if [[ ! "$slug" =~ ^[a-z0-9-]+$ ]]; then
  echo "Error: invalid slug '$slug' (allowed: lowercase [a-z0-9-])" >&2
  exit 1
fi

echo "story/${id}-${slug}"
