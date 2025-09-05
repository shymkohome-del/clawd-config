# OpenAI Codex Cloud Environment — Setup Guide for crypto_market

This document explains how to configure an OpenAI Codex Cloud Environment so Codex agents can run Flutter/Dart and optional Motoko/Rust commands for the `crypto_market` project without "command not found" errors.

## TL;DR
- OpenAI Codex Cloud runs your code in the `universal` container which may not include Flutter/Dart by default
- Add our setup script to the Codex Environment "Setup Script" field to install Flutter SDK
- Optional toggles enable extra language toolchains:
  - `CODEX_SETUP_MOTOKO=true` installs DFX/Motoko
  - `CODEX_SETUP_RUST=true` installs Rust toolchain
- Node.js (>=18) is expected for repo tooling
- After setup, agents can run `dart format`, `flutter analyze`, and `flutter test` in the Codex environment
- Use the ready-to-copy script from [`scripts/codex_setup.sh`](../scripts/codex_setup.sh) and verify with [`scripts/codex_verify.sh`](../scripts/codex_verify.sh)

## Why This Is Needed
OpenAI Codex Cloud Environments run in isolated containers using the `universal` base image. While this image includes many common development tools, Flutter/Dart tooling isn't guaranteed to be present or may be an incompatible version. 

Our setup script ensures:
- Flutter SDK 3.35.1 (matching our CI) is installed
- Node.js and npm are available (>=18)
- Optional DFX/Motoko and Rust toolchains can be installed via environment toggles
- Development tools work consistently
- Project dependencies are available
- Agent can immediately start development work

## What This Configures
- ✅ Install Flutter SDK 3.35.1 to `$HOME/flutter`
- ✅ Add Flutter to PATH and persist in `~/.bashrc`
- ✅ Run `flutter doctor` to verify setup
- ✅ Install project dependencies with `flutter pub get`
- ✅ Test development tools (format, analyze, test)
- ✅ Provide clear status feedback

## How to Apply (Step-by-Step)

### 1. Access Codex Environment Settings
1. Go to [Codex Settings > Environments](https://chatgpt.com/codex/settings/environments)
2. Create a new environment or edit an existing one for this project
3. Name it something like `crypto_market_flutter`

### 2. Add Setup Script
1. In the "Setup Script" field, copy and paste the entire contents of [`scripts/codex_setup.sh`](../scripts/codex_setup.sh)
2. Set optional environment variables in the config to install additional tooling:
   - `CODEX_SETUP_MOTOKO=true` for DFX/Motoko (`dfx` ≥0.15.x)
   - `CODEX_SETUP_RUST=true` for Rust (`rustc`/`cargo`)
3. The script is idempotent and will skip work when tools are already installed
4. Save the environment configuration

### 3. Test the Environment
1. Start a Codex agent session for the `crypto_market` repository
2. The setup script runs automatically before agent execution
3. Look for "=== Codex Cloud Environment Ready ===" in the output
4. Run [`scripts/codex_verify.sh`](../scripts/codex_verify.sh) to confirm versions
5. Agent can now use Flutter commands immediately

## Environment Caching
- Codex caches container state for up to 12 hours after setup
- Setup script only runs once per cache period
- Use "Reset cache" if you update the setup script or change any `CODEX_SETUP_*` toggles
- Cached environments are shared across team members

---

Idempotent Setup Script (Linux-compatible, bash)
Replace `FLUTTER_VERSION` and `PROJECT_DIR` if needed. This script is intentionally conservative so it works in many Codex containers.

```bash
#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
FLUTTER_VERSION="3.32.2"         # Choose a stable version you want to pin
FLUTTER_SDK_DIR="$HOME/flutter"  # Installation target
PROJECT_DIR="/workspace/crypto_market"  # Typical repo path in Codex; adjust if different

# === Optional: install system packages if missing ===
# Uncomment and adapt if the container lacks curl/xz/git
# if command -v apt-get >/dev/null 2>&1; then
#   apt-get update -y && apt-get install -y curl xz-utils git ca-certificates
# fi

# === Download & extract Flutter SDK if not present ===
if [[ ! -d "$FLUTTER_SDK_DIR" ]]; then
  echo "Installing Flutter ${FLUTTER_VERSION} to ${FLUTTER_SDK_DIR}..."
  FLUTTER_TARBALL_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  mkdir -p "$HOME"
  curl -sL "$FLUTTER_TARBALL_URL" | tar -xJ -C "$HOME"
else
  echo "Flutter SDK already present at ${FLUTTER_SDK_DIR}"
fi

# === Ensure PATH for this session and persist to shell startup ===
SHELL_RC="$HOME/.bashrc"
if ! grep -q 'flutter/bin' "$SHELL_RC" 2>/dev/null; then
  echo 'export PATH="$HOME/flutter/bin:$PATH"' >> "$SHELL_RC"
fi
export PATH="$HOME/flutter/bin:$PATH"

# === Verify installation ===
flutter --version || { echo "Flutter not available on PATH"; exit 1; }
if command -v dart >/dev/null 2>&1; then
  dart --version || true
fi

# === Precache a minimal set of artifacts (optional, faster later) ===
# Keep this minimal to avoid long setup times; remove flags if you need other platforms
flutter precache --linux --no-web --no-ios --no-android --no-windows --no-macos || true

# === Optional: work with project (install dependencies) ===
if [[ -d "$PROJECT_DIR" ]]; then
  cd "$PROJECT_DIR"
  echo "Running flutter pub get in ${PROJECT_DIR}..."
  flutter pub get || true

  # Optional quick checks (uncomment as you want the agent to run them at setup time)
  # dart format --output=none --set-exit-if-changed .
  # flutter analyze --fatal-infos --fatal-warnings
  # flutter test --no-pub
fi

echo "Codex environment setup finished." 

```

Alternative: install via git clone (if preferred)

```bash
FLUTTER_SDK_DIR="$HOME/flutter"
if [[ ! -d "$FLUTTER_SDK_DIR" ]]; then
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_SDK_DIR"
  (cd "$FLUTTER_SDK_DIR" && git fetch --tags && git checkout ${FLUTTER_VERSION})
fi
if ! grep -q 'flutter/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/flutter/bin:$PATH"' >> "$HOME/.bashrc"
fi
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
```

Verification after setup
- Check the setup logs for Flutter and Dart version output.
- Run the verification script:

```bash
scripts/codex_verify.sh
```

- Start a session and run these commands (agent or interactive) to validate:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test --no-pub
```

If any of these return "command not found", confirm that `$HOME/flutter/bin` exists and is present in `$SHELL_RC` for the login shell used by Codex.

Tips & limitations
- First run downloads the SDK and may be slow. Later runs are faster due to caching.
- Network access: typically allowed during setup; tests should be runnable without external network after setup.
- Emulators/simulators are not available in Codex environments — unit/widget tests are OK, integration that requires devices is not.
- Avoid heavy precache steps in setup if setup time causes environment timeouts. Prefer running heavier caching on demand.

Troubleshooting
- "flutter: command not found" — check PATH and ensure `$HOME/flutter/bin` exists.
- Slow setup — pin a Flutter version and reduce precache flags.
- Repo not found — verify `PROJECT_DIR` (usual path is `/workspace/<repo-name>`).

Quick checklist for applying this to crypto_market
- Add the setup script to the Codex Cloud Environment settings.
- Pin a Flutter version to ensure reproducible tooling.
- Update `PROJECT_DIR` if the environment mounts the repo at a different path.
- Optional: set `CODEX_SETUP_MOTOKO=true` or `CODEX_SETUP_RUST=true` to install additional toolchains.
- Optionally add `flutter pub get` to the setup script to speed first-run tasks.

After following this guide
Codex agents will be able to run `dart format`, `flutter analyze`, and `flutter test` inside the cloud environment for the `crypto_market` project.

---
If you'd like, I can also add a short example `docs/stories/0.12.codex-cloud-environments.md` pointer (done in the user story) and create a guarded `setup` script file under `scripts/` so you can copy it easily into the Codex UI.
