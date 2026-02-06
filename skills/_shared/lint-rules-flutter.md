# Lint Rules for Flutter (Required Validation)

## 🚨 MANDATORY: Run Validation After Every Code Change

**Перед завершенням роботи ОБОВ'ЯЗКОВО виконай:**

```bash
flutter analyze lib/
```

**Очікуваний результат:**
```
✅ Validation: 0 errors, 0 warnings
```

---

## 📋 Flutter Lint Rules Catalog

### 1. Errors (Must Fix - Blockers)

| Lint Rule | Severity | Description | Fix |
|-----------|----------|-------------|-----|
| `non_constant_identifier_names` | Error | Use `const` for compile-time constants | Add `const` keyword |
| `undefined_method` | Error | Method doesn't exist on type | Check imports, fix typo |
| `undefined_class` | Error | Class doesn't exist | Check imports |
| `argument_type_not_assignable` | Error | Wrong argument type | Verify types |
| `return_of_invalid_type` | Error | Return type mismatch | Fix return type |
| `invalid_assignment` | Error | Assignment type mismatch | Correct types |
| `missing_required_argument` | Error | Required param missing | Add parameter |
| `unchecked_operation` | Error | Unsafe operation | Add type check |
| `strong_mode_implicit_dynamic` | Error | Implicit dynamic type | Explicit type |

---

### 2. Warnings (Must Fix - Critical)

| Lint Rule | Severity | Description | Fix |
|-----------|----------|-------------|-----|
| `unused_import` | Warning | Unused import | Remove import |
| `unused_local_variable` | Warning | Variable not used | Remove or use |
| `unused_field` | Warning | Field not used | Remove or use |
| `unused_element` | Warning | Method not used | Remove or use |
| `dead_code` | Warning | Unreachable code | Remove code |
| `deprecated_member_use` | Warning | Using deprecated API | Use newer API |
| `override_on_non_overriding_member` | Warning | @override on non-override | Remove @override |
| `sdk_version_since` | Warning | Using API before min SDK | Update constraints |

---

### 3. Style Rules (Should Fix - Best Practice)

| Lint Rule | Severity | Description | Fix |
|-----------|----------|-------------|-----|
| `always_put_control_body_on_new_line` | Style | `if` body on new line | Format |
| `always_put_required_named_parameters_first` | Style | Required params first | Reorder params |
| `always_specify_types` | Style | Explicit return types | Add types |
| `annotate_overrides` | Style | Use @override | Add annotation |
| `avoid_annotating_with_dynamic` | Style | Avoid `dynamic` | Use specific type |
| `avoid_as` | Style | Avoid `as` cast | Use `is` + `as` safe |
| `avoid_bool_literals_in_conditional_expressions` | Style | Simplify conditionals | Remove literals |
| `avoid_catching_errors` | Style | Don't catch Error types | Use Exception |
| `avoid_classes_with_only_static_members` | Style | Utility classes | Split or refactor |
| `avoid_empty_else` | Style | Empty else block | Remove |
| `avoid_field_initializers_in_const_classes` | Style | Initializer in const | Use late final |
| `avoid_function_literals_in_foreach_calls` | Style | Use for-loop | Replace |
| `avoid_init_to_null` | Style | Don't init to null | Use late |
| `avoid_null_checks_in_equality_operators` | Style | Null check in == | Use `==` only |

---

## 🔍 Result<T, E> Type Consistency Rules

### Correct Usage Pattern

```dart
// ❌ WRONG - Missing type arguments
Result.ok("success");
Result.error(Exception());

// ✅ CORRECT - Explicit type arguments
jwt_service.Result.ok<String, AuthError>("success");
jwt_service.Result.err<String, AuthError>(AuthError.invalidToken);
```

### Import Alias Required

```dart
// ❌ WRONG - Direct import causes conflicts
import 'package:app/services/result.dart';

// ✅ CORRECT - Use alias
import 'package:app/services/result.dart' as result_service;

// Usage
result_service.Result<String, AuthError> createUser() async {
  return result_service.Result.ok("created");
}
```

### Pattern Matching

```dart
final result = await fetchUserData();

if (result.isOk) {
  final user = result.okValue;
  // Use user
} else {
  final error = result.errorValue;
  logger.e("Error: $error");
}

// Or with pattern matching
switch (result) {
  case Ok(value: final user):
    displayUser(user);
  case Err(error: final error):
    handleError(error);
}
```

---

## 🚫 Print Statement Ban (CRITICAL)

**❌ FORBIDDEN - Never use print()**

```dart
// ❌ FORBIDDEN
print("Debug: $value");
print(user.toJson());
```

**✅ REQUIRED - Use Logger Only**

```dart
import 'package:logger/logger.dart';

final logger = Logger(Level.debug);

// Debug mode only
if (kDebugMode) {
  logger.d("Fetched ${items.length} items");
}

// Info for user actions
logger.i("User logged in: ${user.email}");

// Errors with stacktrace
logger.e("Failed to load data", error: e, stackTrace: stackTrace);

// Warnings
logger.w("Token expires soon");
```

**Exception:** Only in debug conditional is allowed:

```dart
if (kDebugMode) {
  print("DEBUG ONLY: $tempVar"); // Temporarily for debugging
  // Remove before commit!
}
```

---

## 🛡️ Security Lint Rules

### Secrets Detection

```yaml
# analysis_options.yaml
analyzer:
  errors:
    constant_pattern_evaluates_to_null: error
    non_constant_pattern_in_switch_expression: error
  exclude:
    - test/**
```

### Security Rules

| Rule | Severity | Description |
|------|----------|-------------|
| `secure_package` | Error | Validate package integrity |
| `no_hardcoded_secrets` | Error | No API keys in code |
| `avoid_web_url_in_io_code` | Warning | Use HTTP client |
| `use_https_for_devtools` | Warning | HTTPS required |

---

## 📦 Analysis Options Configuration

### Required analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - lib/**/*.g.dart
    - lib/**/*.freezed.dart
    - test/**
  
  errors:
    # Promote to ERROR
    unused_import: error
    unused_local_variable: error
    dead_code: error
    deprecated_member_use: error
    
    # Treat as warning
    todo: warning
    
  strong-mode:
    strict-casts: true
    strict-raw-types: true

linter:
  rules:
    # Error prevention
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_types_as_parameter_names
    - no_duplicate_case_values
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_typing_uninitialized_variables
    
    # Style
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - annotate_overrides
    - prefer_single_quotes
    - sort_constructors_first
    - sort_unnamed_constructors_first
    
    # Performance
    - avoid_function_literals_in_foreach_calls
    - avoid_init_to_null
    - prefer_initializing_formals
```

---

## ✅ Pre-Commit Validation Script

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

echo "Running Flutter analysis..."
flutter analyze lib/ lib/test/

ANALYZE_EXIT=$?

if [ $ANALYZE_EXIT -ne 0 ]; then
  echo "❌ Analysis failed. Fix errors before committing."
  exit 1
fi

echo "✅ Validation passed: 0 errors, 0 warnings"
exit 0
```

---

## 📊 Validation Report Format

**After running `flutter analyze`, report:**

```
=== Validation Report ===
Files analyzed: 15
Errors: 0
Warnings: 0
✅ Validation: 0 errors, 0 warnings
```

**If errors exist:**

```
=== Validation Report ===
Files analyzed: 15
Errors: 3
Warnings: 2

Error Details:
1. lib/models/user.dart:45 - undefined_method (getUsername)
2. lib/services/api.dart:12 - argument_type_not_assignable
3. lib/cubits/auth_cubit.dart:78 - return_of_invalid_type

❌ Validation FAILED - Fix errors before proceeding
```

---

## 🎯 Quick Fix Commands

```bash
# Analyze specific file
flutter analyze lib/path/to/file.dart

# Analyze entire lib
flutter analyze lib/

# Run with verbose output
flutter analyze -v lib/

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Format code
dart format lib/
```

---

## 🚨 Lint Rule Enforcement

| Category | Required Action |
|----------|----------------|
| **Error** | Block commit, must fix immediately |
| **Warning** | Block commit, must fix before merge |
| **Style** | Warning, should fix before merge |
| **Info** | Advisory, fix when convenient |

---

## 📋 Remember

> **"WARNING = ERROR"** in blockchain context
>
> - No unused code
> - No deprecated APIs
> - No print statements
> - Clean type system
> - Zero compromises
