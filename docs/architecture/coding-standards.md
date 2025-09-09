# Coding Standards

This document defines comprehensive coding standards for the Crypto Market project across Flutter/Dart (frontend), Motoko canisters (ICP backend), and supporting JavaScript/TypeScript tooling. It builds on our existing architecture and enforces clarity, safety, and consistency.

Last updated: 2025-08-29

## Critical Fullstack Rules

- Type Sharing: Always define shared types in `lib/shared` (Dart) and `canisters/**/shared` (Motoko) and import from there
- Canister Calls: Never make direct HTTP calls to canisters—use the ICP service layer only
- Environment Variables: Access through config objects only; never read environment directly inside business logic
- Error Handling: All canister calls must handle Result types; never ignore `#err`
- State Updates: Never mutate state directly—use the approved state management patterns
- Principal Security: Always validate caller `Principal` in canister update methods
- Input Validation: Validate and sanitize all inputs at the canister boundary and UI layer
- Rate Limiting: Implement rate-limiting for user-facing canister functions as specified in feature requirements

---

## Naming Conventions

| Element | Flutter/Dart | Motoko | JS/TS (tooling) | Example |
|---|---|---|---|---|
| Files | snake_case.dart | kebab-case.mo | kebab-case.[jt]s | `user_service.dart`, `user-management.mo` |
| Classes/Types | PascalCase | PascalCase | PascalCase | `UserService`, `UserProfile` |
| Enums/Variants | PascalCase (enum), camelCase values | PascalCase type, `#camelCase` variants | PascalCase enum, PascalCase members | `UserStatus.active`, `#active` |
| Functions/Methods | camelCase | camelCase | camelCase | `getUserProfile()` |
| Variables | camelCase | camelCase | camelCase | `userName`, `isActive` |
| Constants | UPPER_SNAKE_CASE | UPPER_SNAKE_CASE | UPPER_SNAKE_CASE | `MAX_LISTING_PRICE` |
| Canister names | snake_case | snake_case | n/a | `user_management`, `marketplace` |
| Private members | `_camelCase` | `private let/var` | `_camelCase` (module-local) | `_cache` |

Notes:
- Prefer descriptive names over abbreviations. Acronyms should be consistently cased (e.g., `HttpClient`, `ICService`).
- In Motoko, use variant labels in lowerCamelCase: `#notFound`, `#alreadyExists`.

---

## Flutter/Dart Standards

These rules align with Effective Dart and Flutter best practices and our folder structure `lib/core`, `lib/shared`, `lib/features/*`.

### Imports and Organization
- Order imports: Dart SDK, Flutter, third-party, internal absolute, then relative.
- Avoid relative imports that cross features; prefer package imports (`package:crypto_market/...`).
- One public type per file; keep files focused.

Example:
```dart
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:crypto_market/core/error/failures.dart';
import 'package:crypto_market/features/user/domain/entities/user.dart';

import '../widgets/user_tile.dart';
```

### Formatting & Style
- Indentation 2 spaces; max line length 80–100 (prefer 80).
- Always add trailing commas in multi-line literals/parameter lists.
- Prefer `final` and `const`. Avoid `dynamic` in public APIs.
- Use named parameters with defaults. Avoid boolean “flag” parameters; use enums.

### Widgets & Composition
- Make widgets `const` when possible to reduce rebuilds.
- Extract subtrees after ~3 nested levels into private helpers or separate widgets.
- Use theme (`Theme.of(context)`) and `ColorScheme`; avoid hard-coded styling.

### State Management (BLoC)
- Events and states extend `Equatable`.
- Use small, focused events; keep effectful work inside handlers.
- Emit domain errors mapped to UI-readable messages. Never expose raw exceptions to the UI.

Snippet:
```dart
abstract class UserEvent extends Equatable { const UserEvent(); @override List<Object?> get props => []; }
class LoadUser extends UserEvent { const LoadUser(this.id); final String id; @override List<Object?> get props => [id]; }

abstract class UserState extends Equatable { const UserState(); @override List<Object?> get props => []; }
class UserLoading extends UserState {}
class UserLoaded extends UserState { const UserLoaded(this.user); final User user; @override List<Object?> get props => [user]; }
class UserError extends UserState { const UserError(this.message); final String message; @override List<Object?> get props => [message]; }

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({required this.repo}) : super(UserLoading()) { on<LoadUser>(_onLoadUser); }
  final UserRepository repo;
  Future<void> _onLoadUser(LoadUser e, Emitter<UserState> emit) async {
    emit(UserLoading());
    final res = await repo.getUser(e.id);
    res.fold((f) => emit(UserError(f.message)), (u) => emit(UserLoaded(u)));
  }
}
```

### Data/Models
- Use `json_serializable` or equivalent for DTOs; keep entities immutable (`const` constructors, `copyWith`).
- Keep conversion at the data layer; domain entities should not depend on JSON.

### Error Handling & Null-safety
- Use `Either<Failure, T>` for recoverable errors in async APIs.
- Prefer null-aware operators; avoid force unwrap `!` unless justified and commented.
- Log unexpected errors via the centralized logger; never swallow exceptions silently.

### Performance
- Use `ListView.builder`, `ValueListenableBuilder`, and memoization when appropriate.
- Avoid heavy work in `build`; move to `initState`/BLoC or use `compute`.

### Testing
- Unit-test business logic and BLoCs with mocks/fakes.
- Write golden/widget tests for critical UI.
- No network/time dependence in tests; stub and use fixed clocks.

---

## Motoko Standards

### Module & Upgrade Safety
- Separate type definitions near the top; keep errors as variants with meaningful names.
- Use stable storage for persisted data and implement `system preupgrade/postupgrade` to serialize/restore.
- Use `HashMap`/`Trie` appropriately; avoid O(n) scans on hot paths.

Example skeleton:
```motoko
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";

actor UserManagement {
  public type User = { id: Principal; username: Text; email: Text; createdAt: Int; isActive: Bool };
  public type CreateUserRequest = { username: Text; email: Text };
  public type UserError = { #notFound; #alreadyExists; #invalidData : Text; #unauthorized };

  private stable var persisted : [(Principal, User)] = [];
  private var users = HashMap.HashMap<Principal, User>(0, Principal.equal, Principal.hash);

  system func preupgrade() { persisted := Iter.toArray(users.entries()); };
  system func postupgrade() { users := HashMap.fromIter(persisted.vals(), persisted.size(), Principal.equal, Principal.hash); persisted := []; };

  public query func getUser(id: Principal) : async Result.Result<User, UserError> {
    switch (users.get(id)) { case null { #err(#notFound) }; case (?u) { #ok(u) } };
  };

  public func createUser(caller: Principal, r: CreateUserRequest) : async Result.Result<User, UserError> {
    if (Principal.isAnonymous(caller)) { return #err(#unauthorized) };
    if (r.username == "" or r.email == "") { return #err(#invalidData("username/email required")) };
    if (existsByEmail(r.email)) { return #err(#alreadyExists) };
    let u : User = { id = caller; username = r.username; email = r.email; createdAt = Time.now(); isActive = true };
    users.put(caller, u); #ok(u)
  };

  private func existsByEmail(email: Text) : Bool {
    for ((_, u) in users.entries()) { if (u.email == email) { return true } }; false
  };
}
```

### Error Handling
- Define domain-specific error variants (e.g., `#validationError : Text`, `#conflict : Text`).
- Always return `Result.Result<T, E>` from public methods; never `trap` for expected failures.

### Authorization & Security
- First line of update methods: reject anonymous principals.
- Enforce access control per resource/action; centralize checks in helpers.
- Sanitize and validate all external inputs; never log secrets or full PII.

### Inter-Canister Calls
- Prefer fire-and-forget (`ignore`) only for non-critical notifications; otherwise propagate errors.
- Minimize cross-canister roundtrips on hot paths.

### Testing
- Keep deterministic behavior (fixed Time values) in tests.
- Provide helper modules for common assertions; avoid `Debug.trap` in production code paths.

---

## JavaScript/TypeScript (Tooling/Scripts)

Used for scripts under `scripts/` and any Node-based utilities.
- Use ES modules and `const`/`let`; avoid `var`.
- Prefer arrow functions, destructuring, template literals, object/array spread.
- Follow widely adopted style (Airbnb or StandardJS). Keep `printWidth` 80–100, 2-space indent.
- Centralize logging; never `console.log` secrets or tokens.

Example:
```ts
import { readFile } from 'node:fs/promises';

export async function loadJson(path: string) {
  const raw = await readFile(path, 'utf8');
  return JSON.parse(raw) as unknown;
}
```

---

## Security Standards

### Input Validation
- UI: validate with clear error messages; never trust client input.
- Canisters: validate length, charset, and structure; reject early with specific errors.
- Sanitize strings (allowlist approach) for identifiers/user-provided labels.

### Secrets & Config
- Never commit secrets. Use platform-specific secret stores.
- Access config via `core/config` (Dart) and dedicated config modules (Motoko/JS).

### Logging
- Log contextual IDs, not raw PII. Use log levels appropriately.
- Avoid logging full request/response bodies unless redacted.

### AuthZ/AuthN
- Check `Principal` on every Motoko update call.
- In Dart, protect routes and sensitive actions with guards and role checks.

---

## Testing & Quality Gates

### Dart/Flutter
- Lints: `flutter analyze --fatal-infos --fatal-warnings` must pass.
- Format: `dart format --output=none --set-exit-if-changed .` must be clean.
- Tests: `flutter test` green with deterministic cases.

### Motoko
- Unit-test pure functions where possible; integration tests for canister flows.
- Validate upgrade hooks with serialization/deserialization roundtrips.

### JS/TS
- Lint with ESLint/Prettier (if configured). Keep scripts small and composable.

---

## Tooling & Configuration

### Dart lints (excerpt)
Place in `analysis_options.yaml` (already present) and extend as needed:
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: true
    prefer_single_quotes: true
    require_trailing_commas: true
```

### Pre-commit (recommended)
Ensure local checks run before commit (hook or CI):
```sh
dart format --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

---

## Code Review Checklist
- Functionality: Works as intended and covered by tests
- Standards: Follows conventions in this document
- Security: Inputs validated; principals checked; no secrets leaked
- Performance: No obvious hot-path regressions; lists and async work optimized
- Readability: Clear naming, small functions, focused files, docs present
- Errors: Result/Either used appropriately; user-friendly messages wired

References: see `docs/architecture/frontend-architecture.md`, `docs/architecture/testing-strategy.md`, and BDD scenarios under `docs/stories/`.
