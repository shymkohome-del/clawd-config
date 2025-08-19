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

# Yamllint using Docker image for parity (no local Python needed)
if command -v docker >/dev/null 2>&1; then
  echo "[dev-validate] Running yamllint (Docker) on workflows"
  docker run --rm -v "$REPO_ROOT":/data cytopia/yamllint -c /data/.yamllint.yml -s /data/.github/workflows
else
  # Fallback: attempt via pipx or pip if Docker absent
  if command -v pipx >/dev/null 2>&1; then
    echo "[dev-validate] Installing yamllint via pipx (if missing)"
    pipx install --force yamllint==1.35.1 >/dev/null 2>&1 || true
    if pipx run --version yamllint >/dev/null 2>&1; then
      echo "[dev-validate] Running yamllint (pipx)"
      pipx run yamllint --strict .github/workflows
    fi
  elif command -v python3 >/dev/null 2>&1; then
    echo "[dev-validate] Attempting yamllint via pip user install..."
    python3 -m pip install --user -q yamllint==1.35.1 --break-system-packages || true
    if python3 -c 'import yamllint' >/dev/null 2>&1; then
      "$HOME/.local/bin/yamllint" --strict .github/workflows
    else
      echo "[dev-validate] WARN: yamllint unavailable; skipping"
    fi
  else
    echo "[dev-validate] WARN: yamllint unavailable; skipping"
  fi
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
# Optional local workflow execution with 'act' (disabled by default)
if [[ "${RUN_ACT:-false}" == "true" ]]; then
  if ! command -v act >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
      echo "[dev-validate] Installing 'act' via Homebrew..."
      brew list act >/dev/null 2>&1 || brew install act >/dev/null
    else
      echo "[dev-validate] 'act' not found and Homebrew unavailable; skipping act runs."
    fi
  fi
  if command -v act >/dev/null 2>&1; then
    echo "[dev-validate] Running workflow-lint via act (CI_LOCAL=true)"
    export CI_LOCAL=true
    act push -W .github/workflows/workflow-lint.yml -s GITHUB_TOKEN=dummy --container-architecture linux/amd64 || exit 1
    unset CI_LOCAL

    echo "[dev-validate] Running flutter-ci via act"
    act push -W .github/workflows/flutter-ci.yml --container-architecture linux/amd64 || exit 1
  fi
else
  echo "[dev-validate] Skipping 'act' workflow execution (set RUN_ACT=true to enable)."
fi


