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

- main: protected, always green
- feature/<short-topic>: feature work (e.g., feature/market-search)
- fix/<short-topic>: bug fixes
- chore/<short-topic>: maintenance/tooling

Open PRs from feature/fix/chore branches into main. CI must pass (analyze, format check, tests) before merge.

## CI

Workflow file: `.github/workflows/flutter-ci.yml` (name: Flutter CI). Triggers on PRs to `main` and runs:

- flutter pub get
- flutter analyze --fatal-infos --fatal-warnings
- dart format --output=none --set-exit-if-changed .
- flutter test

Caching: Flutter SDK and pub packages (`~/.pub-cache`).


