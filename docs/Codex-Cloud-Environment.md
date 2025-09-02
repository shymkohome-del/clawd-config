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

## Verification after Setup
- Check the setup logs for Flutter and Dart version output.
- Run the verification script:

```bash
scripts/codex_verify.sh
```

- Start a session and run these commands to validate:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test --no-pub
```

If any command is missing, ensure `$HOME/flutter/bin` is on your PATH and rerun the setup script.

## Troubleshooting
- "flutter: command not found" — confirm the SDK installed and PATH includes `$HOME/flutter/bin`.
- Slow setup — pin a specific Flutter version and reduce precache flags.
- Repo not found — verify `PROJECT_DIR` and reset the Codex cache after changes.
