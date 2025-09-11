#!/usr/bin/env bash
set -euo pipefail

CODEX_SETUP_MOTOKO="${CODEX_SETUP_MOTOKO:-false}"
CODEX_SETUP_RUST="${CODEX_SETUP_RUST:-false}"

status=0

echo "Verifying Flutter/Dart..."
if command -v flutter >/dev/null 2>&1; then
  flutter --version
else
  echo "❌ Flutter not found"
  status=1
fi

if command -v dart >/dev/null 2>&1; then
  dart --version
else
  echo "❌ Dart not found"
  status=1
fi

echo "Verifying Node.js..."
if command -v node >/dev/null 2>&1; then
  node_version=$(node --version)
  node_major=$(echo "${node_version#v}" | cut -d. -f1)
  echo "Node ${node_version}"
  if (( node_major < 18 )); then
    echo "❌ Node version must be >= 18"
    status=1
  fi
else
  echo "❌ Node.js not found"
  status=1
fi

if command -v npm >/dev/null 2>&1; then
  npm --version
else
  echo "❌ npm not found"
  status=1
fi

if [[ "$CODEX_SETUP_MOTOKO" == "true" ]]; then
  echo "Verifying Motoko/DFX..."
  if command -v dfx >/dev/null 2>&1; then
    dfx --version
  else
    echo "⚠ dfx not found"
  fi
  if command -v moc >/dev/null 2>&1; then
    moc --version
  else
    echo "⚠ moc not found"
  fi
fi

if [[ "$CODEX_SETUP_RUST" == "true" ]]; then
  echo "Verifying Rust..."
  if command -v rustc >/dev/null 2>&1; then
    rustc --version
  else
    echo "⚠ rustc not found"
  fi
  if command -v cargo >/dev/null 2>&1; then
    cargo --version
  else
    echo "⚠ cargo not found"
  fi
fi

exit $status
