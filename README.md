# Crypto Market

![Flutter CI](https://github.com/Vatalion/crypto_market/actions/workflows/flutter-ci.yml/badge.svg?branch=main)

Repository baseline for a Flutter application with CI.

## Commit Style

Follow Conventional Commits:

- feat: add a new feature
- fix: fix a bug
- docs: documentation only changes
- style: formatting, missing semi colons, etc.; no code change
- refactor: code change that neither fixes a bug nor adds a feature
- test: add or fix tests
- chore: maintenance tasks (build, deps, tooling)

Examples:

- feat(auth): add email sign-up flow
- fix(market): handle null price feed

## Branching

- main: production branch, protected, always green
- develop: integration branch; open PRs from feature branches into `develop`
- feature/<short-topic>: feature work (e.g., feature/market-search)
- fix/<short-topic>: bug fixes
- chore/<short-topic>: maintenance/tooling

Open PRs from feature/fix/chore branches into `develop`. For release, open a PR from `develop` to `main`. CI must pass (analyze, format check, tests) before merge.

## CI

Workflow file: `.github/workflows/flutter-ci.yml` (name: Flutter CI). Triggers on PRs to `main` and runs:

- flutter pub get
- flutter analyze --fatal-infos --fatal-warnings
- dart format --output=none --set-exit-if-changed .
- flutter test

Caching: Flutter SDK and pub packages (`~/.pub-cache`).


## Config & Secrets

- Use the `.env.example` at the repo root as a template. Do not commit a real `.env` file.
- At runtime, values should be provided via `--dart-define` flags or a local `.env` loader used only for development.
- Required keys (subset shown): `OAUTH_GOOGLE_CLIENT_ID`, `OAUTH_GOOGLE_CLIENT_SECRET`, `OAUTH_APPLE_TEAM_ID`, `OAUTH_APPLE_KEY_ID`, `IPFS_NODE_URL`, `IPFS_GATEWAY_URL`, `CANISTER_ID_MARKETPLACE`, `CANISTER_ID_USER_MANAGEMENT`, `CANISTER_ID_ATOMIC_SWAP`, `CANISTER_ID_PRICE_ORACLE`. Optional: `CHAINLINK_API_KEY`, `COINGECKO_API_KEY`, `KYC_PROVIDER_API_KEY`.

Example run (abbreviated):

```bash
flutter run \
  --dart-define=OAUTH_GOOGLE_CLIENT_ID=xxx \
  --dart-define=OAUTH_GOOGLE_CLIENT_SECRET=xxx \
  --dart-define=IPFS_NODE_URL=http://localhost:5001 \
  --dart-define=IPFS_GATEWAY_URL=http://localhost:8080 \
  --dart-define=CANISTER_ID_MARKETPLACE=aaaaa-aa \
  --dart-define=CANISTER_ID_USER_MANAGEMENT=bbbbb-bb \
  --dart-define=CANISTER_ID_ATOMIC_SWAP=ccccc-cc \
  --dart-define=CANISTER_ID_PRICE_ORACLE=ddddd-dd
```

Behavior:

- The config layer `lib/core/config/app_config.dart` enforces required keys. Missing keys cause a typed error which the UI can surface as: "Missing required config: <KEY>".
- `--dart-define` values take precedence. Secrets are not stored in the repo.


