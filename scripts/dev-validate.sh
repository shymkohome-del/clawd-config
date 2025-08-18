#!/usr/bin/env bash
set -euo pipefail

# Run all local validations expected by CI before pushing

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

echo "[dev-validate] Repo: $REPO_ROOT"

# Ensure local bin path
BIN_DIR="$REPO_ROOT/.bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# Install pinned actionlint if missing
ACTIONLINT_VERSION="1.7.1"
if ! command -v actionlint >/dev/null 2>&1; then
  echo "[dev-validate] Installing actionlint v${ACTIONLINT_VERSION} to ${BIN_DIR}..."
  curl -sSfL https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash \
    | bash -s -- "${ACTIONLINT_VERSION}" "$BIN_DIR"
fi

echo "[dev-validate] Running actionlint (YAML only)"
actionlint -shellcheck=

# Install and run yamllint if available
if command -v python3 >/dev/null 2>&1; then
  echo "[dev-validate] Ensuring yamllint==1.35.1 is available..."
  python3 -m pip install --user -q yamllint==1.35.1 || true
  if python3 -c 'import yamllint' >/dev/null 2>&1; then
    YAMLLINT_BIN="$HOME/.local/bin/yamllint"
    if [[ -x "$YAMLLINT_BIN" ]]; then
      echo "[dev-validate] Running yamllint on workflows"
      "$YAMLLINT_BIN" --strict .github/workflows
    else
      echo "[dev-validate] WARN: yamllint binary not found; skipping"
    fi
  else
    echo "[dev-validate] WARN: yamllint module not installed; skipping"
  fi
else
  echo "[dev-validate] WARN: python3 not available; skipping yamllint"
fi

# Flutter/Dart gates (same as pre-push)
APP_DIR=""
for cand in "crypto_market/crypto_market" "." "crypto_market"; do
  if [[ -f "$cand/pubspec.yaml" ]] && grep -q "^environment:" "$cand/pubspec.yaml" >/dev/null 2>&1; then
    APP_DIR="$cand"
    break
  fi
done

if [[ -n "$APP_DIR" ]]; then
  pushd "$APP_DIR" >/dev/null
  echo "[dev-validate] Dart format check..."
  dart format --output=none --set-exit-if-changed .
  echo "[dev-validate] Flutter analyze..."
  flutter analyze --fatal-infos --fatal-warnings
  echo "[dev-validate] Flutter tests..."
  flutter test --no-pub
  popd >/dev/null
else
  echo "[dev-validate] WARN: Could not locate Flutter app directory; skipping Flutter gates."
fi

echo "[dev-validate] All local checks passed."

# Optional: run workflows locally via act if installed
if command -v act >/dev/null 2>&1; then
  echo "[dev-validate] Running selected workflows locally with act (CI_LOCAL=true)"
  export CI_LOCAL=true
  # Minimal matrix: run lint and CI flows; skip network PR operations
  act push -W .github/workflows/workflow-lint.yml -s GITHUB_TOKEN=dummy || exit 1
  act push -W .github/workflows/flutter-ci.yml || exit 1
  # Trigger open-pr job for branch detection, but API steps are gated by CI_LOCAL
  act push -W .github/workflows/auto-pr-from-qa.yml || exit 1
  act workflow_run -W .github/workflows/merge-on-green-fallback.yml || true
  unset CI_LOCAL
else
  echo "[dev-validate] Hint: install 'act' (https://github.com/nektos/act) to run workflows locally."
fi


