# Crypto Market Project - Architecture Overview

## Project Summary

**Name:** Crypto Market  
**Type:** Decentralized P2P Cryptocurrency Marketplace  
**Stack:** Flutter + Internet Computer (ICP)  
**Location:** `/Users/vitaliisimko/workspace/projects/other/crypto_market`

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| Frontend | Flutter 3.38+ / Dart 3.4+ | Cross-platform mobile app |
| State Management | flutter_bloc 8.x | Business logic component |
| Backend | ICP Canisters (Motoko) | Smart contract logic |
| Identity | ICP Internet Identity | Decentralized auth |
| Storage | ICP Canister Storage | On-chain data |
| Local Dev | dfx 0.29.1 | ICP development kit |

---

## Canister Architecture

**File:** `crypto_market/dfx.json`

| Canister | Purpose | Dependencies |
|----------|---------|--------------|
| `user_management` | Auth, profiles, reputation | None |
| `marketplace` | Listings, search, trades | user_management |
| `atomic_swap` | Escrow, trade execution | None |
| `price_oracle` | Real-time crypto prices | None |
| `messaging` | P2P trade communication | None |
| `dispute` | Dispute resolution | atomic_swap, user_management |

---

## Project Structure

```
crypto_market/
├── lib/
│   ├── core/
│   │   ├── auth/              # JWT, OAuth, password hashing
│   │   ├── blockchain/        # ICP service layer, Candid
│   │   ├── config/            # AppConfig, constants
│   │   ├── error/             # Result types, error handling
│   │   ├── i18n/              # Localization controller
│   │   ├── logger/            # Centralized logging
│   │   ├── network/           # Dio HTTP client
│   │   ├── routing/           # App router, protected routes
│   │   ├── security/          # Security logger
│   │   └── services/          # Rate limiter, key rotation
│   ├── features/
│   │   ├── auth/              # Auth screens, cubit, providers
│   │   ├── market/            # Marketplace feature
│   │   ├── chat/              # Messaging feature
│   │   ├── payments/          # Payment flows
│   │   └── profile/           # User profile
│   ├── shared/
│   │   ├── models/            # Domain models
│   │   ├── theme/             # App theme
│   │   ├── utils/             # Utilities
│   │   └── widgets/           # Shared widgets
│   ├── l10n/                  # ARB localization files
│   ├── bootstrap.dart         # App initialization
│   └── main.dart              # Entry point
├── canisters/
│   ├── user_management/       # Motoko canister
│   ├── marketplace/
│   ├── atomic_swap/
│   ├── price_oracle/
│   ├── messaging/
│   └── dispute/
├── test/
│   ├── unit/                  # Unit tests
│   ├── integration/           # Integration tests
│   └── e2e/                   # End-to-end tests
└── docs/                      # Comprehensive documentation
```

---

## Key Architectural Patterns

### 1. Feature-First Structure
- Each feature has: `data/`, `domain/`, `presentation/`
- Clear separation of concerns
- Shared components in `lib/shared/`

### 2. Result-Based Error Handling
```dart
// Frontend pattern
Result<User, AuthError> result = await authService.register(...);
result.fold(
  (user) => navigateToHome(),
  (error) => showError(error.message),
);
```

### 3. BLoC/Cubit State Management
```
UI → Cubit → Service → ICP Canister
           ↓
      State updates
           ↓
      UI rebuilds
```

### 4. ICP Service Layer Abstraction
```dart
// ICP service layer pattern
class ICPService {
  final AgentFactory _agentFactory;
  
  Future<Result<User, AuthError>> register(...) async {
    // Call canister via agent_dart
    // Handle Result types
    // Map errors to domain errors
  }
}
```

### 5. Configuration via dart-define
```bash
flutter run \
  --dart-define=CANISTER_ID_MARKETPLACE=xxx \
  --dart-define=CANISTER_ID_USER_MANAGEMENT=xxx \
  --dart-define=JWT_SECRET_KEY=xxx
```

---

## Development Workflow

### Branch Strategy
- `main` - Production, protected
- `develop` - Integration branch
- `story/{id}-{slug}` - Feature branches
- `fix/{topic}` - Bug fixes
- `chore/{topic}` - Maintenance

### Commit Convention
```
feat(story-1.1): add email registration
fix(market): handle null price
refactor(auth): extract validation logic
test(auth): add registration tests
docs: update API spec
```

### CI/CD Pipeline
**File:** `.github/workflows/flutter-ci.yml`

```
PR to develop
    ↓
flutter pub get
    ↓
flutter analyze --fatal-infos --fatal-warnings
    ↓
dart format --output=none --set-exit-if-changed .
    ↓
flutter test --reporter expanded
    ↓
Auto-merge (if qa-approved label)
```

---

## Story Workflow

**Location:** `docs/stories/`

Story format follows BMAD episode structure:
- Status tracking
- Dependencies
- Acceptance Criteria with BDD scenarios
- Tasks/Subtasks with checkboxes
- Dev Notes with architecture guidance
- Dev Agent Record
- Change Log
- QA Results

### Story Status Flow
```
ready-for-dev → in-progress → review → done
```

---

## Documentation Structure

**Location:** `docs/`

| Directory | Purpose |
|-----------|---------|
| `architecture/` | System design, coding standards |
| `frameworks/` | Quick start, troubleshooting |
| `prd/` | Product requirements |
| `stories/` | User stories |
| `ux-ui/` | Design flows |
| `security/` | Security docs |

**Key Docs:**
- `INDEX.md` - Documentation map
- `architecture/coding-standards.md` - Must read before coding
- `architecture/tech-stack.md` - Technology versions
- `frameworks/quick-start.md` - 5-minute setup

---

## CLI Skills Available

### Via Claude Code
| Skill | Purpose |
|-------|---------|
| `/start-app` | One command to start entire app |
| `/deploy-canisters` | Deploy canisters only |
| `/sync-config` | Sync canister IDs to .env |
| `/stop-all` | Clean shutdown |
| `/verify-setup` | Pre-flight checks |

### Via scripts
```bash
# One-command startup
./scripts/crypto-market-startup.sh local

# Story workflow
./scripts/story-flow.sh start 1.1 feature-name
./scripts/story-flow.sh open-pr
```

---

## Testing Strategy

### Test Organization
```
test/
├── unit/              # Business logic tests
│   ├── auth_cubit_test.dart
│   └── ...
├── integration/       # Feature workflow tests
│   └── screens/
└── e2e/              # End-to-end tests
```

### Test Requirements
- Unit tests for all business logic
- Widget tests for UI behaviors
- Integration tests for user flows
- Canister unit tests in Motoko
- All tests must pass before PR merge

### Running Tests
```bash
# All tests
flutter test --reporter expanded

# Specific file
flutter test test/unit/auth_cubit_test.dart

# With coverage
flutter test --coverage
```

---

## Security Considerations

1. **Input Validation** - All inputs validated at boundaries
2. **Principal Validation** - Caller principal checked in canisters
3. **Rate Limiting** - Sensitive flows protected
4. **JWT with Rotation** - Secure authentication
5. **No Anonymous Access** - Anonymous principals rejected
6. **Secure Storage** - Sensitive data in encrypted storage
7. **Audit Logging** - Security events logged

---

## Local Development Setup

### Prerequisites
- Flutter 3.38+
- Dart 3.4+
- dfx 0.29.1
- jq

### Quick Start
```bash
# 1. Start local ICP replica
dfx start --background

# 2. Deploy canisters
dfx deploy

# 3. Sync config
./scripts/sync-canister-ids.sh

# 4. Run Flutter app
flutter run --dart-define=CANISTER_ID_MARKETPLACE=$(jq -r ...)
```

Or use the one-command approach:
```bash
./scripts/crypto-market-startup.sh local
```

---

## Key Configuration Files

| File | Purpose |
|------|---------|
| `dfx.json` | Canister definitions, networks |
| `.env` | Environment variables (not committed) |
| `.env.example` | Template for .env |
| `pubspec.yaml` | Flutter dependencies |
| `analysis_options.yaml` | Dart lint rules |
| `canister_ids.json` | Deployed canister IDs |

---

## Integration Points

### External Services
- OAuth providers (Google, Apple)
- IPFS (via configured gateway)
- Price APIs (Chainlink, CoinGecko)
- KYC provider (configured)

### ICP Integration
- Internet Identity for auth
- Canister-to-canister calls
- Candid interface definitions
- Agent dart for Flutter

---

## Monitoring & Debugging

### Logging
```dart
// Use logger, never print()
Logger().d('Debug message');
Logger().i('Info message');
Logger().e('Error message');
```

### Debug Features
- Flutter DevTools
- ICP canister logs via dfx
- Integration test reports
- Coverage reports

---

## Important Notes

1. **Never commit .env** - Use .env.example as template
2. **Always run tests before PR** - CI will reject failures
3. **Use dart-define for secrets** - Not hardcoded
4. **Follow coding standards** - Enforced via CI
5. **Write tests first** - TDD approach
6. **Update story files** - Track progress in docs/stories/
7. **Use proper logging** - avoid_print lint rule enforced
