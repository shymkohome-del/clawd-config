# Dependency Management Strategy

Generated: August 27, 2025

## Current Status Analysis

Based on `flutter pub outdated` results, we have several categories of updates:

### Major Version Updates Available (Breaking Changes Expected)
These require careful migration and testing:

- **bloc**: 8.1.4 → 9.0.0 (Major version bump)
- **flutter_bloc**: 8.1.6 → 9.1.1 (Major version bump)  
- **web3dart**: 2.7.3 → 3.0.1 (Major version bump, critical for blockchain features)
- **go_router**: 14.8.1 → 16.2.0 (Major version bump, navigation changes)
- **bloc_test**: 9.1.7 → 10.0.0 (Major version bump for testing)

### Minor/Patch Updates (Safe)
These can be updated with minimal risk:

- **retrofit**: 4.7.1 → 4.7.2 (patch update)
- **build_runner**: 2.4.13 → 2.7.0 (minor update)
- **flutter_lints**: 5.0.0 → 6.0.0 (major linting rules update)

## Context7 MCP Integration Strategy

Use Context7 to research each major dependency before updating:

### Research Commands
```bash
# Research BLoC migration
context7-query "/flutter-community/bloc" --topic="BLoC 9.0 migration guide breaking changes from version 8"

# Research Web3Dart updates  
context7-query "/simolus/web3dart" --topic="Web3Dart 3.0 ethereum compatibility breaking changes"

# Research GoRouter updates
context7-query "/flutter/packages/go_router" --topic="GoRouter 16.x navigation API changes routing configuration"

# General Flutter dependency management
context7-query "/flutter/flutter" --topic="Flutter dependency management pubspec version constraints best practices"
```

## Recommended Update Strategy

### Phase 1: Safe Updates First
```bash
cd crypto_market/

# Update safe dependencies first
flutter pub upgrade retrofit
flutter pub upgrade build_runner 
flutter pub upgrade json_serializable
flutter pub upgrade retrofit_generator

# Run tests to verify
flutter test
```

### Phase 2: Critical Framework Updates
```bash
# Update Flutter SDK to latest stable
flutter upgrade

# Update BLoC ecosystem (requires migration)
flutter pub upgrade --major-versions bloc flutter_bloc bloc_test

# Run tests and fix breaking changes
flutter test
```

### Phase 3: Navigation Updates  
```bash
# Update GoRouter (may require route definition changes)
flutter pub upgrade --major-versions go_router

# Test navigation flows
flutter test test/integration/
```

### Phase 4: Blockchain Updates
```bash
# Update Web3Dart (critical for wallet functionality)
flutter pub upgrade --major-versions web3dart

# Test ICP integration and wallet features
flutter test test/unit/blockchain/
```

## Breaking Changes Research Notes

### BLoC 8.x → 9.x
- [ ] Research Context7: Breaking changes in BLoC 9.0
- [ ] Check event handling changes
- [ ] Verify state management patterns still work
- [ ] Update bloc_test patterns if needed

### Web3Dart 2.x → 3.x  
- [ ] Research Context7: Ethereum API changes in Web3Dart 3.0
- [ ] Check wallet integration compatibility
- [ ] Verify transaction signing methods
- [ ] Test ICP service layer integration

### GoRouter 14.x → 16.x
- [ ] Research Context7: Navigation API changes in GoRouter 16.x
- [ ] Check route definition syntax
- [ ] Verify nested routing patterns
- [ ] Test deep linking functionality

## Testing Checklist

After each phase:
- [ ] All unit tests pass
- [ ] All widget tests pass  
- [ ] All integration tests pass
- [ ] App builds successfully for all platforms
- [ ] ICP canister integration works
- [ ] Wallet connectivity functions
- [ ] Navigation flows work correctly
- [ ] State management remains stable

## Security Validation

### Vulnerability Assessment
```bash
# Run security audit
flutter pub audit

# Check for known vulnerabilities
dart pub deps --json | jq '.packages[] | select(.source == "hosted") | {name, version}'

# Validate dependency sources
flutter pub deps --tree
```

### Security Checklist
- [ ] All critical and high-severity vulnerabilities resolved
- [ ] No malicious or compromised packages detected
- [ ] Dependency sources verified and trusted
- [ ] Supply chain security validated

## Performance Validation

### Benchmarking
```bash
# Measure app bundle size
flutter build apk --analyze-size
flutter build ios --analyze-size

# Profile startup performance
flutter run --profile --trace-startup

# Memory usage profiling
flutter run --profile --enable-dart-profiling
```

### Performance Checklist
- [ ] Bundle size remains under 50MB target
- [ ] Startup time within acceptable thresholds
- [ ] Memory usage stable or improved
- [ ] No performance regressions detected

## Platform Compatibility Testing

### Multi-Platform Validation
```bash
# iOS testing
flutter build ios --release
flutter test integration_test/ -d ios

# Android testing  
flutter build apk --release
flutter test integration_test/ -d android

# Web testing
flutter build web --release
flutter test integration_test/ -d chrome

# Desktop testing (if applicable)
flutter build macos --release
flutter test integration_test/ -d macos
```

## Rollback Plan

If updates cause critical issues:

```bash
# Revert pubspec.yaml changes
git checkout HEAD~1 -- pubspec.yaml pubspec.lock

# Clean and restore
flutter clean
flutter pub get
flutter test

# Verify functionality restored
flutter run
```

### Rollback Decision Criteria
- Critical functionality broken
- Security vulnerabilities introduced
- Performance degraded beyond acceptable thresholds
- Platform compatibility issues
- ICP integration failures

## Automation Setup

### GitHub Actions Workflow
```yaml
name: Dependency Updates
on:
  schedule:
    - cron: '0 10 * * MON'  # Weekly on Monday
  workflow_dispatch:

jobs:
  update-dependencies:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub outdated
      - run: flutter pub upgrade --dry-run
      - run: flutter test
      # Create PR if tests pass
```

### Dependabot Configuration
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "pub"
    directory: "/crypto_market"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 5
    reviewers:
      - "@dev-team"
    labels:
      - "dependencies"
      - "auto-update"
```

## Documentation Updates

### Required Documentation Changes
- [ ] Update README.md with new Flutter/Dart version requirements
- [ ] Update developer setup guides in `docs/development/`
- [ ] Update CI/CD configuration documentation
- [ ] Create dependency update runbook
- [ ] Document Context7 MCP usage for dependency research
- [ ] Update architecture documentation if frameworks change

## Risk Mitigation

### Risk Categories
1. **Breaking Changes**: API changes requiring code modifications
2. **Performance Regressions**: Slower startup, larger bundles, memory issues
3. **Security Issues**: New vulnerabilities or compromised packages
4. **Platform Incompatibility**: Build failures on specific platforms
5. **Integration Failures**: ICP canister or wallet connectivity issues

### Mitigation Strategies
- **Incremental Updates**: Update in phases to isolate issues
- **Feature Flags**: Enable new features gradually
- **Staging Environment**: Full testing before production
- **Automated Testing**: Comprehensive test coverage
- **Quick Rollback**: Prepared rollback procedures

## Next Actions

1. ✅ Start with Phase 1 (safe updates)
2. ⏳ Use Context7 MCP to research breaking changes for major updates
3. ⏳ Create feature branch for dependency updates
4. ⏳ Execute phases incrementally with full testing between each
5. ⏳ Update documentation and CI/CD configuration  
6. ⏳ Set up automated dependency management for future updates

## Context7 MCP Usage Examples

### Researching BLoC Migration
```bash
# Get migration guide
context7-query "/flutter-community/bloc" \
  --topic="BLoC 9.0 migration breaking changes event handling state management" \
  --tokens=3000

# Understand new patterns
context7-query "/flutter-community/bloc" \
  --topic="BLoC 9.0 new features Cubit patterns best practices" \
  --tokens=2000
```

### Web3Dart Research
```bash
# Breaking changes analysis
context7-query "/simolus/web3dart" \
  --topic="Web3Dart 3.0 breaking changes ethereum client compatibility" \
  --tokens=3000

# Migration examples
context7-query "/simolus/web3dart" \
  --topic="Web3Dart 3.0 migration examples wallet integration transaction signing" \
  --tokens=2500
```

### GoRouter Research  
```bash
# API changes
context7-query "/flutter/packages/go_router" \
  --topic="GoRouter 16.x routing API changes navigation configuration" \
  --tokens=3000

# Migration guide
context7-query "/flutter/packages/go_router" \
  --topic="GoRouter 16.x migration examples route definitions nested routing" \
  --tokens=2500
```

This comprehensive plan ensures safe, systematic dependency updates while leveraging Context7 MCP for research and maintaining system stability.