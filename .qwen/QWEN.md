# Qwen Code Context for `crypto_market`

## Project Overview

This directory contains a Flutter application named "Crypto Market". The application is designed to interact with cryptocurrency markets and potentially integrate with blockchain technologies. It serves as a baseline for a Flutter app with Continuous Integration (CI) setup.

### Key Technologies & Frameworks

- **Flutter**: The core framework for building the cross-platform mobile application.
- **Dart**: The programming language used for Flutter development.
- **State Management**:
  - `bloc` & `flutter_bloc`: For predictable state management.
- **Networking**:
  - `dio`: For HTTP client functionality.
  - `retrofit`: For generating type-safe API clients.
- **Blockchain Interaction**:
  - `web3dart`: For interacting with Ethereum-like blockchains.
- **UI & Utilities**:
  - `flutter_screenutil`: For responsive screen adaptation.
  - `cached_network_image`: For efficient image loading and caching.
  - `intl`: For internationalization and localization.
- **Local Storage**:
  - `shared_preferences`: For simple key-value storage.
  - `hive` & `hive_flutter`: For lightweight, fast NoSQL storage.
- **Navigation**:
  - `go_router`: For declarative routing.
- **Development & Testing**:
  - `flutter_lints`: For linting and code style enforcement.
  - `build_runner`, `json_serializable`, `retrofit_generator`: For code generation.
  - `mocktail`, `bloc_test`: For testing utilities.
  - `logger`: For logging information, warnings, and errors.

### Architecture

The project follows a layered architecture, organizing code into `core`, `features`, and `shared` directories within `lib`:

- `lib/core`: Contains fundamental, app-wide functionalities like network clients, storage mechanisms, app configuration, and logging.
- `lib/features`: Houses feature-specific code, suggesting a modular approach (e.g., `auth`, `market`, `payments`).
- `lib/shared`: Includes reusable components like data models, UI themes, utility functions, and common widgets.

## Development Workflow & Conventions

### Commit Style

The project adheres to **Conventional Commits**. Commit messages should be prefixed with:

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Code formatting, missing semicolons, etc. (no logic change)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding or fixing tests
- `chore`: Maintenance tasks (build process, dependency management)

Example: `feat(auth): add email sign-up flow`

### Branching Strategy

- `main`: The production branch, protected and always stable.
- `develop`: The integration branch. Feature, fix, and chore branches are merged here.
- `feature/<short-topic>`: For new feature development.
- `fix/<short-topic>`: For bug fixes.
- `chore/<short-topic>`: For maintenance tasks.

Feature/fix/chore branches are merged into `develop`. Releases are prepared by merging `develop` into `main`. Pull Requests are required, and CI must pass.

### Continuous Integration (CI)

CI is configured via `.github/workflows/flutter-ci.yml`. It triggers on Pull Requests targeting the `main` branch and executes the following steps:

1. `flutter pub get`
2. `flutter analyze --fatal-infos --fatal-warnings`
3. `dart format --output=none --set-exit-if-changed .`
4. `flutter test`

It also caches the Flutter SDK and pub packages for efficiency.

## Building and Running

While explicit build/run scripts weren't found in `package.json` (which seems to be for a different tooling layer, possibly related to `.bmad-core`), standard Flutter commands are used. Ensure the Flutter SDK is installed and configured.

- **Get Dependencies**: `flutter pub get` (Run this first)
- **Analyze Code**: `flutter analyze`
- **Format Code**: `dart format .`
- **Run Tests**: `flutter test`
- **Run App (Development)**: `flutter run` (Requires a connected device or emulator)
