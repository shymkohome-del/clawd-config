# **Coding Standards**

## **Critical Fullstack Rules**

- **Type Sharing:** Always define types in packages/shared and import from there
- **Canister Calls:** Never make direct HTTP calls to canisters - use the ICP service layer
- **Environment Variables:** Access only through config objects, never process.env directly
- **Error Handling:** All canister calls must handle Result types properly
- **State Updates:** Never mutate state directly - use proper state management patterns
- **Principal Security:** Always validate caller principal in canister functions
- **Input Validation:** Validate all inputs in canisters before processing
- **Rate Limiting:** Implement rate limiting for all user-facing canister functions

## **Naming Conventions**

| Element | Frontend (Flutter) | Backend (Motoko) | Example |
|----------|-------------------|------------------|---------|
| Components | PascalCase | - | `UserProfile` |
| Files | snake_case | snake_case | `user_service.dart` |
| Functions | camelCase | camelCase | `getUserProfile` |
| Variables | camelCase | camelCase | `userName` |
| Constants | UPPER_SNAKE_CASE | UPPER_SNAKE_CASE | `MAX_LISTING_PRICE` |
| Canisters | snake_case | snake_case | `user_management` |
| Types | PascalCase | PascalCase | `UserProfile` |

## Project Baseline Standards (Flutter/Dart)

These rules are vital for this repo and are enforced via CI and review. They are aligned with our current architecture (`lib/core`, `lib/shared`, `lib/features/*`) and service layer patterns.

- Language & Types
  - Use explicit types for public APIs and non-trivial locals; avoid `dynamic`
  - Prefer immutability: `final` for fields, `const` for compile-time values
  - Model domain concepts with classes/enums instead of loose primitives
  - Prefer named parameters with defaults over nullable flags

- Control Flow & Functions
  - Single-responsibility functions; keep bodies small and cohesive
  - Use early returns to avoid deep nesting (aim ≤ 3 levels)
  - Extract complex logic into helpers in `lib/shared/utils/` or feature utils

- State & Error Handling
  - Never mutate state directly; use the project’s state management pattern (see architecture docs)
  - Prefer Result-style error handling for expected failures; reserve exceptions for truly unexpected cases
  - Map service errors to domain errors in the ICP service layer; show friendly UI messages

- Widgets & UI
  - Break large widgets into smaller focused widgets; one clear responsibility each
  - Use `const` constructors where possible to reduce rebuilds
  - Avoid deep widget trees (extract after ~3 levels)
  - Use `Theme.of(context).colorScheme` and theme text styles; avoid hardcoded colors/font sizes
  - Use `SafeArea` near screen edges; prefer `Expanded`/`Flexible` for responsive layouts

- Project Structure
  - Follow feature-first structure under `lib/features/*` with `data/`, `domain/`, `presentation/` as appropriate
  - Keep shared widgets under `lib/shared/widgets/` and cross-cutting utilities under `lib/shared/utils/`
  - One primary class per file; use barrel files judiciously for ergonomics

- Testing & Quality Gates
  - Write unit tests for logic and widget tests for UI behaviors; add integration tests for flows
  - CI must pass: `flutter analyze --fatal-infos --fatal-warnings`, `dart format --output=none --set-exit-if-changed .`, `flutter test`
  - Prefer deterministic tests; avoid time/network flakiness (mock/stub instead)

- Security & Config
  - Validate all inputs (frontend and service layer); enforce principal checks in canister interactions
  - Apply rate limiting guidance for sensitive flows
  - Access configuration through the config layer only; never commit secrets

- Logging & Observability
  - Use the centralized logger API; log at appropriate levels (debug/info/warn/error)
  - Surface user-facing errors via shared UI components (dialogs/snackbars)
  - Append key dev diagnostics to the debug log path in dev builds when applicable

- Workflow & Git
  - Feature branch per story: `story/{id}-{slug}`; conventional commits `feat(story-{id}): <title>`
  - Run analyze/format/test locally before pushing; PRs must reference the story id
  - Code review is mandatory; follow acceptance criteria and BDD scenarios in stories

References: see `docs/architecture/frontend-architecture.md`, `docs/architecture/testing-strategy.md`, and story BDD scenarios under `docs/stories/`.
