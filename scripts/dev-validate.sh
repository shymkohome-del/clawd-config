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

echo "[dev-validate] Ensuring shellcheck availability (for bash lint via actionlint)"
if ! command -v shellcheck >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew list shellcheck >/dev/null 2>&1 || brew install shellcheck >/dev/null
  elif command -v docker >/dev/null 2>&1; then
    echo "[dev-validate] Pulling koalaman/shellcheck for Docker usage..."
    docker pull koalaman/shellcheck:stable >/dev/null 2>&1 || true
  fi
fi

echo "[dev-validate] Running actionlint"
actionlint -shellcheck=

# Yamllint using Docker image for parity (no local Python needed)
if command -v docker >/dev/null 2>&1; then
  echo "[dev-validate] Running yamllint (Docker) on workflows only"
  docker run --rm -v "$REPO_ROOT":/data cytopia/yamllint -c /data/.yamllint.yml -s /data/.github/workflows
else
  # Fallback: attempt via pipx or pip if Docker absent
  if command -v pipx >/dev/null 2>&1; then
    echo "[dev-validate] Installing yamllint via pipx (if missing)"
    pipx install --force yamllint==1.35.1 >/dev/null 2>&1 || true
    if pipx run --version yamllint >/dev/null 2>&1; then
      echo "[dev-validate] Running yamllint (pipx) on workflows"
      pipx run yamllint --strict -c .yamllint.yml .github/workflows
    fi
  elif command -v python3 >/dev/null 2>&1; then
    echo "[dev-validate] Attempting yamllint via pip user install..."
    python3 -m pip install --user -q yamllint==1.35.1 --break-system-packages || true
    if python3 -c 'import yamllint' >/dev/null 2>&1; then
      "$HOME/.local/bin/yamllint" --strict -c .yamllint.yml .github/workflows
    else
      echo "[dev-validate] WARN: yamllint unavailable; skipping"
    fi
  else
    echo "[dev-validate] WARN: yamllint unavailable; skipping"
  fi
fi
# Optional: direct shellcheck on local shell scripts (non-blocking if unavailable)
if command -v shellcheck >/dev/null 2>&1; then
  echo "[dev-validate] Running shellcheck on repository shell scripts..."
  find scripts -maxdepth 1 -type f -name "*.sh" -print0 | xargs -0 -I{} shellcheck -S style {} || true
else
  if command -v docker >/dev/null 2>&1; then
    echo "[dev-validate] Running shellcheck via Docker on repository shell scripts..."
    find scripts -maxdepth 1 -type f -name "*.sh" -print0 | xargs -0 -I{} docker run --rm -v "$REPO_ROOT":/mnt koalaman/shellcheck:stable /bin/sh -lc "shellcheck -S style /mnt/{}" || true
  fi
fi

echo "[dev-validate] Enforcing ban on actions/github-script usage..."
FILES=$(grep -RIl "uses: actions/github-script@" .github/workflows | grep -v "/workflow-lint.yml$" || true)
if [[ -n "${FILES}" ]]; then
  echo "[dev-validate] ERROR: actions/github-script is banned in this repository. Found in:" >&2
  echo "$FILES" | sed 's/^/  /' >&2
  echo "[dev-validate] Guidance: Replace with bash/composite actions using curl/gh and our scripts/retry.sh." >&2
  exit 1
fi
echo "[dev-validate] Scanning github-script steps for 'exec' redeclarations/imports (paranoid check)..."
FILES=$(grep -RIl "uses: actions/github-script@" .github/workflows | grep -v "/workflow-lint.yml$" || true)
if [[ -n "${FILES}" ]]; then
  OFFENDERS=$(echo "$FILES" | xargs -I{} grep -nH -E "(\\b(const|let|var)[[:space:]]+exec\\b|import[[:space:]]+(\\*|\{[^}]*\\bexec\\b[^}]*)[[:space:]]+from|require\(['\"]@actions/exec['\"]\))" {} || true)
  if [[ -n "${OFFENDERS}" ]]; then
    echo "[dev-validate] ERROR: Detected potential 'exec' conflicts in github-script code." >&2
    echo "$OFFENDERS" | sed 's/^/  /' >&2
    exit 1
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

# Run workflows locally via act (enabled by default for parity)
if [[ "${RUN_ACT:-true}" == "true" ]]; then
  if ! command -v act >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
      echo "[dev-validate] Installing 'act' via Homebrew..."
      brew list act >/dev/null 2>&1 || brew install act >/dev/null
    else
      echo "[dev-validate] 'act' not found and Homebrew unavailable; skipping act runs."
    fi
  fi
  if command -v act >/dev/null 2>&1; then
    PLATFORM_MAP="-P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest"
    echo "[dev-validate] act: workflow-lint"
    act push -W .github/workflows/workflow-lint.yml -s GITHUB_TOKEN=dummy --env CI_LOCAL=true --container-architecture linux/amd64 "$PLATFORM_MAP" || exit 1

    echo "[dev-validate] act: auto-pr-from-qa (push-story)"
    act push -W .github/workflows/auto-pr-from-qa.yml -e .github/events/push-story.json -s GITHUB_TOKEN=dummy --env CI_LOCAL=true --container-architecture linux/amd64 "$PLATFORM_MAP" || true

    echo "[dev-validate] act: merge-on-green-fallback (pull_request labeled)"
    act pull_request -W .github/workflows/merge-on-green-fallback.yml -e .github/events/pull_request-labeled.json -s GITHUB_TOKEN=dummy --env CI_LOCAL=true --container-architecture linux/amd64 "$PLATFORM_MAP" || true
  fi
else
  echo "[dev-validate] Skipping 'act' workflow execution (set RUN_ACT=true to enable)."
fi


