# Dependency Update Matrix - Story 0.10

## Analysis Results (Generated: 2025-08-28)

### Critical Dependencies Requiring Major Version Updates

| Package | Current | Latest | Breaking Changes | Priority | Strategy |
|---------|---------|---------|------------------|----------|----------|
| **bloc** | 8.1.4 | 9.0.0 | ❌ Major version | High | Phase 3 - Test thoroughly |
| **flutter_bloc** | 8.1.6 | 9.1.1 | ❌ Major version | High | Phase 3 - With bloc |
| **bloc_test** | 9.1.7 | 10.0.0 | ❌ Major version | High | Phase 3 - With bloc |
| **go_router** | 14.8.1 | 16.2.0 | ❌ Major version | High | Phase 5 - Navigation API |
| **web3dart** | 2.7.3 | 3.0.1 | ❌ Major version | Critical | Phase 6 - Blockchain |
| **json_rpc_2** | 3.0.3 | 4.0.0 | ❌ Major version | Medium | Phase 6 - With web3dart |
| **pointycastle** | 3.9.1 | 4.0.0 | ❌ Major version | Medium | Phase 6 - Crypto |

### Safe Minor/Patch Updates

| Package | Current | Latest | Type | Priority | Phase |
|---------|---------|---------|------|----------|-------|
| **retrofit** | 4.7.1 | 4.7.2 | Patch | Low | Phase 1 |
| **retrofit_generator** | 8.2.1 | 10.0.2 | Minor* | High | Phase 4 |
| **flutter_lints** | 5.0.0 | 6.0.0 | Minor* | Medium | Phase 2 |
| **json_serializable** | 6.8.0 | 6.11.0 | Minor | Medium | Phase 4 |
| **build_runner** | 2.4.13 | 2.7.0 | Minor | Medium | Phase 2 |

*May have breaking changes despite minor version

### Platform Dependencies

| Package | Current | Latest | Platform | Risk | Phase |
|---------|---------|---------|----------|------|-------|
| path_provider_android | 2.2.17 | 2.2.18 | Android | Low | Phase 1 |
| path_provider_foundation | 2.4.1 | 2.4.2 | iOS/macOS | Low | Phase 1 |
| shared_preferences_android | 2.4.11 | 2.4.12 | Android | Low | Phase 1 |
| sqflite_android | 2.4.1 | 2.4.2+2 | Android | Low | Phase 1 |

### Framework Core Dependencies

| Package | Current | Latest | Impact | Phase |
|---------|---------|---------|--------|-------|
| meta | 1.16.0 | 1.17.0 | Core Dart | Phase 2 |
| characters | 1.4.0 | 1.4.1 | Text handling | Phase 1 |
| material_color_utilities | 0.11.1 | 0.13.0 | UI colors | Phase 1 |

## Update Strategy Phases

### Phase 1: Safe Minor/Patch Updates
- ✅ Low-risk, non-breaking changes
- ✅ Platform-specific patches
- ✅ Utility and helper libraries
- **Risk**: Very Low
- **Testing**: Basic smoke tests

### Phase 2: Framework & Tooling
- ⚠️ Flutter SDK if available
- ⚠️ Build tools and linters
- ⚠️ Development dependencies
- **Risk**: Low-Medium
- **Testing**: Full test suite

### Phase 3: State Management (Critical)
- ❌ Bloc ecosystem (8.x → 9.x)
- ❌ Requires code changes for new APIs
- ❌ Breaking changes in BlocBuilder, BlocListener
- **Risk**: High
- **Testing**: Comprehensive state management tests

### Phase 4: Networking & Serialization
- ⚠️ Retrofit generator (8.x → 10.x)
- ⚠️ JSON serialization updates
- ⚠️ HTTP client improvements
- **Risk**: Medium
- **Testing**: API integration tests

### Phase 5: Navigation
- ❌ GoRouter (14.x → 16.x)
- ❌ Route configuration API changes
- ❌ Navigation declarative syntax updates
- **Risk**: High
- **Testing**: Navigation flow tests

### Phase 6: Blockchain & Crypto (Most Critical)
- ❌ Web3Dart (2.x → 3.x) - Ethereum compatibility changes
- ❌ Crypto libraries major updates
- ❌ ICP integration validation required
- **Risk**: Critical
- **Testing**: Full blockchain integration tests

## Breaking Change Analysis

### Bloc 8.x → 9.x
- **Key Changes**: 
  - Event handling improvements
  - BlocListener/BlocBuilder API refinements
  - Better error handling patterns
- **Migration**: State classes may need updates
- **Files Affected**: All `*_bloc.dart`, `*_state.dart`, `*_event.dart`

### GoRouter 14.x → 16.x
- **Key Changes**: 
  - Route configuration syntax improvements
  - Better type safety for route parameters
  - Enhanced navigation guards
- **Migration**: Route definitions need updates
- **Files Affected**: `lib/core/router/app_router.dart`

### Web3Dart 2.x → 3.x
- **Key Changes**: 
  - Ethereum London fork compatibility
  - EIP-1559 transaction support
  - Breaking changes in Web3Client API
- **Migration**: Transaction building logic updates
- **Files Affected**: `lib/core/blockchain/`, `lib/features/wallet/`

## Security Vulnerability Assessment

### High Priority (Immediate Update Required)
- **web3dart** 2.7.3 → 3.0.1: Security patches for blockchain operations
- **pointycastle** 3.9.1 → 4.0.0: Cryptographic improvements

### Medium Priority
- **retrofit_generator** 8.2.1 → 10.0.2: Code generation security improvements
- **json_serializable** 6.8.0 → 6.11.0: Serialization security patches

### Low Priority
- Platform-specific patches for path providers and storage

## Performance Impact Predictions

### Bundle Size Impact
- **Estimated Impact**: +2-5% (new features in major updates)
- **Critical Threshold**: Must stay under 50MB mobile target
- **Monitoring**: APK size tracking required

### Runtime Performance
- **Bloc 9.x**: Improved event handling performance (+5-10%)
- **GoRouter 16.x**: Better route resolution performance (+10-15%)
- **Web3Dart 3.x**: Improved transaction processing (+5-10%)

### Startup Time
- **Risk**: Minor increase due to new initialization patterns
- **Target**: Maintain <3 seconds app startup
- **Mitigation**: Profile before/after updates

## Rollback Plan

### Automated Rollback Triggers
1. **Test Failure**: >5% test suite failures
2. **Build Failure**: Any platform build fails
3. **Performance Regression**: >20% startup time increase
4. **Security Issue**: Critical vulnerability introduction

### Manual Rollback Process
1. `git revert` to last working commit
2. `flutter pub get` to restore lock file
3. Full test suite validation
4. Platform build verification
5. Performance benchmark validation

### Recovery Timeline
- **Automated Detection**: <5 minutes
- **Rollback Execution**: <10 minutes  
- **Validation**: <30 minutes
- **Total Recovery**: <45 minutes

## Success Criteria

### Functional Requirements
- ✅ All existing tests pass
- ✅ No new warnings or deprecations
- ✅ All platforms build successfully
- ✅ ICP canister integration works
- ✅ Wallet connectivity maintained

### Performance Requirements
- ✅ Bundle size increase <5%
- ✅ Startup time degradation <10%
- ✅ Memory usage increase <5%
- ✅ API response times maintained

### Security Requirements
- ✅ All known vulnerabilities resolved
- ✅ No new security warnings
- ✅ Crypto operations validated
- ✅ Audit scan passes

## Implementation Order

1. **Phase 1**: Safe patches (1-2 hours)
2. **Phase 2**: Framework tools (2-3 hours)
3. **Phase 3**: State management (4-6 hours) ⚠️ High Risk
4. **Phase 4**: Networking (2-3 hours)
5. **Phase 5**: Navigation (3-4 hours) ⚠️ High Risk
6. **Phase 6**: Blockchain (6-8 hours) ❌ Critical Risk

**Total Estimated Time**: 18-26 hours
**Testing Buffer**: +50% for comprehensive validation
**Rollback Buffer**: +20% for issue resolution

---
*Generated by Dev Agent on 2025-08-28 for Story 0.10*
