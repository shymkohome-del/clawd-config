# Task Templates (Shared)

Standardized task structures for consistent agent execution.

---

## 📋 Template 1: Fix Specific File Errors

**WHEN:** Known file, known errors

```markdown
## Task: Fix [N] errors in [file_path]

## Context
- File: [full_path]
- Error lines: [X, Y, Z]
- Error types: [undefined_method, type_mismatch, etc.]

## BEFORE You Start
1. Read the file: `read({path: "[file]", limit: 50})`
2. Read errors: `flutter analyze [file]`
3. Confirm you understand each error

## Fix ONE error at a time
For each error:
1. Locate the exact line
2. Understand the fix needed
3. Apply fix
4. IMMEDIATELY run: `flutter analyze [file]`
5. Confirm error is gone
6. Move to next error

## Output Format
✅ Fixed: [error_description] at line [N]
✅ Fixed: [error_description] at line [N]
✅ Final: 0 errors in [file]
```

---

## 📋 Template 2: Add Missing Getters/Methods

**WHEN:** Need to add multiple similar items

```markdown
## Task: Add [N] missing getters to [class]

## Context
- Target class: [full_path]
- Missing items: [list]
- Pattern to follow: [existing example]

## Steps
1. Read target file completely
2. Find where similar items are defined
3. Add ALL missing items in ONE edit
4. Run `flutter analyze [file]`
5. Confirm 0 errors

## Output Format
✅ Added: [item1], [item2], ... ([N] total)
✅ Verified: 0 errors
```

---

## 📋 Template 3: Fix Type Mismatches (Result<T,E>)

**WHEN:** Result<T,E> or similar type issues

```markdown
## Task: Fix Result type mismatches in [file]

## Pattern
- Wrong: `Result.ok(value)` or `Result<String>`
- Right: `jwt_service.Result.ok(value)` or `jwt_service.Result<String, Error>`

## Steps
1. Check import: `import '...jwt_service.dart' as jwt_service;`
2. Replace ALL Result references with `jwt_service.Result`
3. Verify type arguments match: `<SuccessType, ErrorType>`
4. Run analyze

## Output Format
✅ Fixed: [N] Result type references
✅ Verified: 0 errors
```

---

## 📋 Template 4: Flutter Feature Implementation

**WHEN:** Implementing new Flutter feature

```markdown
## Task: Implement [feature_name] feature

## Context
- Feature: [description]
- Files to modify: [list]
- Dependencies needed: [list or "none"]

## BEFORE You Start
1. Read existing code patterns in similar features
2. Check docs/development/flutter for patterns
3. Verify no duplicate implementation exists
4. Run `flutter pub get` to update deps

## Implementation Steps
1. Create/Modify [data models]
2. Create/Modify [repository]
3. Create/Modify [cubit/bloc]
4. Create/Modify [UI screens/widgets]
5. Write/update unit tests
6. Run `flutter analyze` and fix errors
7. Run `flutter test` and ensure all pass

## Validation
- [ ] `flutter analyze` returns 0 errors
- [ ] All tests pass
- [ ] No print statements (use logger)
- [ ] Follows existing code patterns
- [ ] Documentation updated

## Output Format
✅ Created: [files created]
✅ Modified: [files modified]
✅ Tests: [N] tests added
✅ Validation: 0 errors, 0 warnings
```

---

## 📋 Template 5: ICP Canister Implementation

**WHEN:** Implementing new canister function

```markdown
## Task: Implement [function_name] in canister [canister_name]

## Context
- Canister: [canister_id or name]
- Function: [description]
- Error cases: [list]

## BEFORE You Start
1. Read existing patterns in same canister
2. Check Motoko style guide
3. Verify dfx is configured

## Implementation Steps
1. Define error types (if needed)
2. Implement function with Result<T,E> return
3. Add proper bounds checks
4. Handle all Option cases
5. Write unit tests
6. Run `dfx build` and fix errors

## Validation
- [ ] `dfx build` completes with 0 errors
- [ ] All operator may trap issues resolved
- [ ] All Option types properly handled
- [ ] All Result cases covered
- [ ] Tests pass

## Output Format
✅ Created: [files/functions created]
✅ Modified: [files modified]
✅ Build: 0 errors, 0 warnings
```

---

## 📋 Template 6: Code Review Task

**WHEN:** Reviewing code for quality/security

```markdown
## Task: Review [file/feature] for [review_type]

## Context
- Target: [file path or feature]
- Review type: [security|performance|logic|style]
- Scope: [specific files or entire feature]

## Review Checklist
### Security
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] Authentication/authorization checks
- [ ] Error messages don't leak internals

### Performance
- [ ] No unnecessary allocations
- [ ] Async operations properly awaited
- [ ] Caching where appropriate
- [ ] No blocking operations

### Logic
- [ ] All cases covered in switch/if
- [ ] Edge cases handled
- [ ] Error states have fallbacks
- [ ] State transitions are valid

### Style
- [ ] Follows project naming conventions
- [ ] Code is documented
- [ ] No commented-out code
- [ ] No TODO comments without JIRA ticket

## Output Format
### Review Summary
- Files reviewed: [N]
- Critical issues: [N]
- Warnings: [N]
- Suggestions: [N]

### Critical Issues
1. [Issue description] - [severity] - [file:line]
   - Impact: [explanation]
   - Fix: [suggested solution]

### Warnings
[...]

### Suggestions
[...]
```

---

## 📋 Template 7: Test-Driven Development

**WHEN:** Implementing with TDD approach

```markdown
## Task: Implement [feature] using TDD

## Context
- Feature: [description]
- Test file: [path to test]
- Implementation file: [path to impl]

## TDD Cycle

### RED - Write Failing Test
1. Write test for expected behavior
2. Run test - should FAIL
3. Confirm test failure is for right reason

### GREEN - Make Test Pass
1. Write minimal implementation
2. Run test - should PASS
3. Commit test + minimal code

### REFACTOR - Improve Code
1. Refactor for clarity/efficiency
2. Ensure tests still pass
3. Remove duplication
4. Improve naming

## Validation
- [ ] All tests pass
- [ ] Code is clean and readable
- [ ] Follows project patterns
- [ ] Documentation updated

## Output Format
✅ Red: [N] tests written
✅ Green: [N] tests passing
✅ Refactor: [changes made]
✅ Final: All tests passing
```

---

## 📋 Template 8: Bug Fix

**WHEN:** Fixing a reported bug

```markdown
## Task: Fix bug: [bug_title]

## Context
- Bug report: [description]
- Reproducible steps: [list]
- Expected behavior: [description]
- Actual behavior: [description]

## Investigation
1. Read relevant code sections
2. Reproduce the issue
3. Identify root cause
4. Document findings

## Fix Implementation
1. Create test that reproduces bug
2. Implement fix
3. Verify test passes
4. Check for similar issues elsewhere

## Validation
- [ ] Bug is fixed (test passes)
- [ ] No regression in related functionality
- [ ] Code analysis passes
- [ ] Documentation updated if needed

## Output Format
✅ Root cause: [explanation]
✅ Fix: [description]
✅ Test: [test added]
✅ Regression check: passed
```

---

## 📋 Template 9: UI Implementation

**WHEN:** Implementing Flutter UI screen/widget

```markdown
## Task: Implement [screen/widget_name] UI

## Context
- Screen/Widget: [name]
- Design source: [link or reference]
- Required widgets: [list]
- Interactive elements: [list]

## BEFORE You Start
1. Review design specifications
2. Check existing UI patterns
3. Verify widget testability requirements
4. Run `flutter analyze` for baseline

## Implementation Steps
1. Create widget following design
2. Add all required interactive elements
3. Implement responsive layout
4. Add proper keys for testing
5. Write widget tests
6. Verify no analyze errors

## Validation
- [ ] Widget renders correctly
- [ ] All interactions work
- [ ] Responsive on different screens
- [ ] `flutter analyze` = 0 errors
- [ ] Widget tests pass
- [ ] Key attributes for QA present

## Output Format
✅ Created: [widget files]
✅ Tests: [N] widget tests
✅ Validation: 0 errors, 0 warnings
```

---

## 📋 Template 10: Database Migration (ICP)

**WHEN:** Modifying canister data structures

```markdown
## Task: Migrate [canister_name] data structure

## Context
- Change: [description]
- Old structure: [description]
- New structure: [description]
- Affected functions: [list]

## Migration Strategy
1. Define upgrade function
2. Handle backward compatibility
3. Test migration with sample data
4. Verify all queries work

## Safety Checks
- [ ] Backup current state
- [ ] Test migration locally
- [ ] Verify no data loss
- [ ] Test rollback procedure

## Validation
- [ ] Migration completes successfully
- [ ] All data preserved
- [ ] Query functions work correctly
- [ ] dfx build passes

## Output Format
✅ Migration: [description]
✅ Data preserved: [verification]
✅ Functions updated: [N]
✅ Validation: 0 errors
```

---

## 🎯 Template Usage Notes

1. **ALWAYS** read the template before starting
2. **FOLLOW** all steps in order
3. **REPORT** progress using the Output Format
4. **VALIDATE** using the Validation checklist
5. **ASK** for clarification if context is unclear

---

## ❌ BAD vs ✅ GOOD Task Examples

### BAD (Vague):
```
Fix the auth errors in the test files
```
**Why bad:** Which files? Which errors? How many?

### GOOD (Specific):
```
## Task: Fix 3 errors in test/unit/auth_test.dart

## Errors to fix:
1. Line 45: "Undefined name 'AuthError'" → import 'package:.../errors.dart'
2. Line 67: "The argument type 'String' can't be assigned to 'int'" → parse to int
3. Line 89: "Missing required parameter 'createdAtMillis'" → add createdAtMillis: 0

## Steps:
1. Read file lines 40-95
2. Fix each error ONE BY ONE
3. After each fix: flutter analyze test/unit/auth_test.dart
4. Report: "Fixed error N at line X: [description]"
```
