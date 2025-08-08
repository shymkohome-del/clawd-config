# Crypto Market

![Flutter CI](https://github.com/Vatalion/crypto_market/actions/workflows/flutter-ci.yml/badge.svg?branch=main)

Repository baseline for a Flutter application with CI.

## App Structure and Routing

This repo follows a feature-first Flutter structure, aligned with the project architecture guidance.

```
lib/
  core/
    blockchain/          # ICP client and blockchain-related services
    config/              # runtime configuration and constants
    network/             # HTTP/Dio client wrappers
    logger/              # logging setup (placeholder)
    storage/             # local storage abstractions (placeholder)
  features/
    auth/                # auth feature (providers/services, UI screens)
    market/              # marketplace feature and providers
    chat/
    payments/
    profile/
  shared/
    models/
    theme/
    utils/
    widgets/
  main.dart              # app entry; base routes: /login, /register, /home
```

- Base routes are defined in `lib/main.dart` with placeholders for `LoginScreen`, `RegisterScreen`, and `HomeScreen`.
- Directory layout aligns with the guidance in the architecture docs.

References:
- Frontend structure and routing: `docs/architecture/frontend-architecture.md`
- Monorepo structure guidance: `docs/architecture/unified-project-structure.md`

### Deltas from Monorepo Guidance

- This repository is a single Flutter app (not a monorepo). Module boundaries are represented by `lib/` directories (`core/`, `features/`, `shared/`) instead of separate packages.
- Providers/services live within their respective `features/*/providers` directories. Shared UI and utilities live under `shared/`.
- Naming normalization: the feature folder is `market/` (avoids `marketplace/` to keep names concise).
- State management note: project standard is `flutter_bloc` (Bloc/Cubit). Older docs that referenced Riverpod have been aligned to Bloc.

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

Workflow file: `.github/workflows/flutter-ci.yml` (name: Flutter CI). Triggers on PRs to `develop` and pushes to `story/*` and runs:

- flutter pub get
- flutter analyze --fatal-infos --fatal-warnings
- dart format --output=none --set-exit-if-changed .
- flutter test --reporter expanded --no-pub

### Automated Story Flow

Use `scripts/story-flow.sh` to automate the Dev ↔ QA flow.

Examples:

```bash
# One-time: install hooks
scripts/story-flow.sh init-hooks

# Start a new story branch from latest develop
scripts/story-flow.sh start 0.5 icp-service-layer-bootstrap

# Optional: auto-rebase your story branch onto origin/develop every 5 minutes
scripts/story-flow.sh watch-rebase 300 &

# Create a PR to develop and request auto-merge (requires GitHub CLI `gh`)
scripts/story-flow.sh open-pr

# Stop watcher
scripts/story-flow.sh stop-watch
```

Commit policy and quality gates are enforced via `.git-hooks` and CI workflows:
- Commit messages on `story/*` must reference the story id (e.g., `story 0.5: ...`).
- Pre-commit formats Dart code; pre-push runs format check, `flutter analyze`, and tests.
- GitHub Actions run format/analyze/tests on PRs to `develop` and pushes to `story/*`.
- Apply the `qa-approved` label on the PR to enable auto-merge (squash) when checks pass.

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


### Environment conventions

- Local: developer machines. Use a local `.env` (not committed) or pass values with `--dart-define` when running locally.
- Dev: shared integration environment. Inject secrets via CI/CD variables or the platform secret manager. Do not use `.env` files on servers.
- Prod: production environment. Inject secrets via the secret manager only. Audit access and changes.

### Rotation strategy

- Triggers: suspected exposure, team changes, scheduled rotation (e.g., quarterly), vendor-required rotations.
- Owners: feature area owners (OAuth: Auth; IPFS: Infra; Price/KYC APIs: respective service owners).
- Procedure:
  1. Create a new key/secret in the provider.
  2. Update CI/CD secret or secret manager entries with the new value. Keep the old value temporarily if dual-key is supported.
  3. Deploy to Dev and verify functionality.
  4. Promote to Prod and verify.
  5. Revoke the old key and document the rotation in change logs/audit.

## Testing

- Folders:
  - `test/unit/` for unit and widget tests
  - `test/integration/` for integration tests
  - `test/e2e/` for end-to-end tests (optional for now)

- Run locally:
  - Analyze and format check: `flutter analyze --fatal-infos --fatal-warnings && dart format --output=none --set-exit-if-changed .`
  - Tests (expanded reporter): `flutter test --no-pub --reporter expanded`

- Sample test:
  - `test/unit/widgets/sample_widget_test.dart`
