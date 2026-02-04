# 🔍 AUDIT #2 - Shell Scripts Analysis

**Date:** 2025-01-28  
**Scope:** All `.sh` files in `/Volumes/workspace-drive/projects/other/crypto_market/`  
**Excluded:** `secrets/` folder (as per requirements)

---

## 📊 Summary

| Category | Count | Status |
|----------|-------|--------|
| Critical Issues | 4 | 🔴 |
| High Priority Issues | 7 | 🟠 |
| Medium Priority Issues | 12 | 🟡 |
| Low Priority Issues | 8 | 🟢 |
| Unused Scripts | 6 | ⚪ |

---

## 🔴 CRITICAL ISSUES

### 1. **Hardcoded Canister IDs in run-action.sh**
**File:** `crypto_market/scripts/macos_dashboard/swiftbar/run-action.sh`

```bash
# Lines 75-81
declare -A CANISTERS=(
    ["atomic_swap"]="6p4bg-hiaaa-aaaad-ad6ea-cai"
    ["marketplace"]="6b6mo-4yaaa-aaaad-ad6fa-cai"
    ...
)
```

**Problem:** Hardcoded production canister IDs. This violates the "NO HARDCODING" policy.

**Fix:** Read from `canister_ids.json` or `secrets/canister_ids.json`:
```bash
canister_id=$(jq -r ".${name}.ic" "$PROJECT_ROOT/secrets/canister_ids.json")
```

---

### 2. **Missing Error Handling in Flutter Build Scripts**
**Files:** `scripts/build-android.sh`, `scripts/build-ios.sh`

**Problem:** Both scripts use `set -e` but don't handle specific Flutter build failures gracefully. If `flutter build` fails for one flavor, the entire script stops without cleanup.

**Example:**
```bash
# Line ~88 in build-android.sh
flutter build apk \
    --flavor "$FLAVOR_NAME" \
    -t "$MAIN_ENTRY" \
    $DART_DEFINES \
    --$BUILD_TYPE
# No error handling for partial build failures
```

**Fix:** Add per-flavor error handling with rollback capability.

---

### 3. **Race Condition in spawn-multi-agent-ides.sh**
**File:** `scripts/spawn-multi-agent-ides.sh`

```bash
# Lines 79-80
# Launch VS Code with agent-specific configuration
code "$worktree_path" \
    --new-window \
    --goto "$worktree_path/lib/main.dart:1:1" &

# Wait a moment between launches to prevent resource conflicts
sleep 2
```

**Problem:** Fixed 2-second delay may not be sufficient on slower systems. No verification that VS Code actually started.

**Fix:** Add retry logic and verification:
```bash
for i in {1..3}; do
    if pgrep -f "Code.*$worktree_path" >/dev/null; then
        break
    fi
    sleep 2
done
```

---

### 4. **Potential Command Injection in story-flow.sh**
**File:** `scripts/story-flow.sh`

```bash
# Line 38 - slugify function
slug=$(slugify "$*")
```

**Problem:** The slugify output is used directly in branch names without validation.

**Fix:** Add validation:
```bash
if [[ ! "$slug" =~ ^[a-z0-9-]+$ ]]; then
    echo "Invalid characters in slug" >&2
    exit 1
fi
```

---

## 🟠 HIGH PRIORITY ISSUES

### 5. **Missing dfx Identity Validation in switch-env.sh**
**File:** `crypto_market/scripts/macos_dashboard/swiftbar/switch-env.sh`

**Problem:** The script checks if `ic_user` identity exists but doesn't verify the principal matches expected values from secrets.

```bash
# Lines 75-78
if ! dfx identity list | grep -q "ic_user"; then
    error "ic_user identity not found!"
    exit 1
fi
# Missing: principal verification
```

**Fix:** Add principal verification like in `safety-check.sh`.

---

### 6. **Inconsistent Error Handling Across Scripts**

**Problem:** Different scripts handle errors differently:
- Some use `set -euo pipefail`
- Some use only `set -e`
- Some don't set any error handling flags

**Affected Files:**
- `crypto_market/generate_seed_phrase.sh` - No `set -euo pipefail`
- `crypto_market/run_manual_qa.sh` - Uses `set -e` but not `u` or `o pipefail`
- `scripts/verify-rate-limiting.sh` - No strict mode

**Fix:** Standardize all scripts to use `set -euo pipefail`.

---

### 7. **Hardcoded Values in verify-rate-limiting.sh**
**File:** `scripts/verify-rate-limiting.sh`

```bash
# Lines 15-17
CANISTER_DIR="crypto_market/canisters"
GREEN='\033[0;32m'
RED='\033[0;31m'
```

**Problem:** Hardcoded directory path. Won't work if run from different location.

**Fix:** Use dynamic path detection:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CANISTER_DIR="$SCRIPT_DIR/../crypto_market/canisters"
```

---

### 8. **Unsafe File Operations in cleanup-agents.sh**
**File:** `scripts/cleanup-agents.sh`

```bash
# Lines 15-18
local agent_name=$(basename "$agent_dir" | sed 's/agent-//')
```

**Problem:** Uses `sed` without validation. Could fail with unexpected directory names.

**Fix:** Add validation and error handling.

---

### 9. **Missing Retry Logic in watch-pr.sh**
**File:** `scripts/watch-pr.sh`

**Problem:** If `gh pr view` fails temporarily (network issue), the script exits immediately without retry.

```bash
# Line 45
JSON=$(gh pr view "$PR_NUM" --json ... 2>/dev/null || true)
```

**Fix:** Use the existing `retry.sh` script for API calls.

---

### 10. **Potential Path Issues in start-with-driver.sh**
**File:** `scripts/start-with-driver.sh`

```bash
# Lines 51-60
find_project_root() {
  local current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  while [[ "$current_dir" != "/" && ! -f "$current_dir/crypto_market/pubspec.yaml" ]]; do
    current_dir="$(dirname "$current_dir")"
  done
  ...
}
```

**Problem:** May enter infinite loop if `dirname` behaves unexpectedly on some systems.

**Fix:** Add iteration limit.

---

### 11. **Missing Permission Checks in Multiple Scripts**

**Affected Files:**
- `scripts/setup-agent-worktrees.sh` - No check for git write permissions
- `scripts/setup-git-hooks.sh` - No check for `.git-hooks` directory permissions
- `scripts/install-git-hooks.sh` - No verification that hooks are executable after copy

---

## 🟡 MEDIUM PRIORITY ISSUES

### 12. **Unused Scripts Detected**

| Script | Location | Reason |
|--------|----------|--------|
| `generate_seed_phrase.sh` | `crypto_market/` | Template/demo script, not used in production |
| `coordinate-agents.sh` | `scripts/` | Referenced but minimal implementation |
| `monitor-agent-activity.sh` | `scripts/` | Incomplete real-time monitoring |
| `qa-label.sh` | `scripts/` | Simple wrapper, could be inlined |
| `yaml-format.sh` | `scripts/` | Alternative to yamllint, may be redundant |
| `run-act.sh` | `scripts/` | Requires act tool which may not be installed |

---

### 13. **Inconsistent Project Root Detection**

**Problem:** Different scripts use different methods to find project root:

```bash
# Method 1 (setup-agent-worktrees.sh)
MAIN_BRANCH=$(git branch --show-current)

# Method 2 (start-with-driver.sh)
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Method 3 (codex_setup.sh)
PROJECT_DIR="$(pwd)"

# Method 4 (dev-validate.sh)
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

**Fix:** Standardize on one method, preferably using git or SCRIPT_DIR approach.

---

### 14. **Missing Documentation in Scripts**

**Files without proper header documentation:**
- `scripts/smart-git.sh`
- `scripts/cleanup-merged-branches.sh`
- `scripts/pr-monitor.sh`

---

### 15. **Git CLI Dependency Without Fallback**

**Multiple scripts** assume `gh` CLI is available without graceful degradation:

```bash
# From pr-monitor.sh
if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) not found. Install and authenticate gh." >&2
  exit 3
fi
```

**Problem:** Hard exit with no fallback for manual operation.

---

### 16. **Potential Word Splitting Issues**

**File:** `scripts/preflight-parse.sh`

```bash
# Line 14
slug_part=${BRANCH#story/${story_id}-}
```

**Problem:** No quotes around variable expansion could cause issues with special characters.

---

### 17. **Missing Input Validation in Multiple Scripts**

**Files:**
- `scripts/retry.sh` - Doesn't validate that command is not empty
- `scripts/story-from-file.sh` - Limited validation of filename format
- `scripts/validate-widget-keys.sh` - No check if Flutter is installed

---

### 18. **Temporary Files Not Cleaned Up**

**File:** `scripts/yaml-format.sh`

```bash
# Line 47
tmp_file="$(mktemp)"
```

**Problem:** If script is interrupted, temp file may remain.

**Fix:** Add trap:
```bash
trap 'rm -f "$tmp_file"' EXIT
```

---

### 19. **Color Codes Without TTY Check**

**Multiple scripts** use color codes without checking if output is a terminal:

```bash
# From verify-validation-implementation.sh
GREEN='\033[0;32m'
RED='\033[0;31m'
```

**Problem:** Color codes appear in log files and redirected output.

**Fix:** Check for TTY:
```bash
if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
else
    GREEN=''
fi
```

---

### 20. **Inconsistent Logging Functions**

**Problem:** Each script redefines its own logging functions instead of using a shared library.

**Example patterns found:**
- `log_info()`, `log_success()`, `log_warning()`, `log_error()`
- `note()`, `error()`, `pass_test()`, `fail_test()`
- `log()`, `warn()`, `error()`, `success()`

**Fix:** Create `scripts/lib/log.sh` for shared logging.

---

### 21. **Deprecated GitHub Actions Reference**

**File:** `scripts/dev-validate.sh`

```bash
# Lines 94-100
# Check for banned actions/github-script
FILES=$(grep -RIl "uses: actions/github-script@" .github/workflows ...)
```

**Problem:** The script checks for banned patterns but the check itself may be outdated.

---

### 22. **Hardcoded Flutter Version in codex_setup.sh**
**File:** `scripts/codex_setup.sh`

```bash
# Line 12
FLUTTER_VERSION="3.35.1"
```

**Problem:** Version hardcoded instead of reading from project config.

**Fix:** Read from `pubspec.yaml` or shared config file.

---

### 23. **Missing SECRETS_PATH Validation**

**Files:** `safety-check.sh`, `switch-identity.sh`

**Problem:** Scripts check if secrets file exists but don't validate its contents format:
```bash
if [ -f "$PROJECT_ROOT/secrets/canister_ids.json" ]; then
    # No validation that JSON is valid or has required fields
```

---

## 🟢 LOW PRIORITY ISSUES

### 24. **Shellcheck Warnings**

Several scripts have shellcheck warnings (mostly style-related):
- Quote variables to prevent word splitting
- Use `$(...)` instead of backticks
- Declare and assign separately to avoid masking return values

### 25. **Inconsistent Function Naming**

Some use camelCase, some use snake_case, some use kebab-case in function names.

### 26. **Missing Shebang in Some Scripts**

Most use `#!/bin/bash` or `#!/usr/bin/env bash`, but some inconsistently use `#!/bin/sh`.

### 27. **Trailing Whitespace**

Several scripts have trailing whitespace that should be cleaned up.

### 28. **Inconsistent Indentation**

Mix of 2-space, 4-space, and tab indentation across scripts.

### 29. **Unused Variables**

Some scripts declare variables that are never used.

### 30. **Commented-Out Code**

Several scripts have large blocks of commented-out code that should be removed.

### 31. **Outdated Comments**

Some comments reference files or features that no longer exist.

---

## ⚪ UNUSED/REDUNDANT SCRIPTS

### 32. **Duplicate Scripts in Different Locations**

**Observation:** Scripts exist in multiple locations:
- `.claude/hooks/` - 42 shell scripts
- `_bmad/_config/custom/my-custom-agents/hooks/` - 42 shell scripts
- `_bmad/my-custom-agents/hooks/` - 42 shell scripts

**Problem:** These appear to be duplicates. Any update needs to be applied in multiple places.

**Recommendation:** Use symlinks or a single source of truth.

---

## 📋 RECOMMENDATIONS

### Immediate Actions (This Week)
1. Fix hardcoded canister IDs in `run-action.sh`
2. Add principal validation to `switch-env.sh`
3. Standardize error handling to `set -euo pipefail`

### Short-term (Next 2 Weeks)
4. Create shared library for common functions (logging, path detection)
5. Fix all shellcheck warnings
6. Add proper cleanup for temp files

### Long-term (Next Month)
7. Consolidate duplicate scripts into single location
8. Create comprehensive test suite for shell scripts
9. Document all scripts with usage examples

---

## 🔒 SECURITY NOTES

1. **No secrets found in shell scripts** ✅
2. **Proper use of secrets/ folder** ✅
3. **Good principal verification in safety-check.sh** ✅

---

## ✅ GOOD PRACTICES FOUND

1. **Excellent safety checks in `safety-check.sh`**
2. **Good user confirmation for production operations**
3. **Proper use of secrets/ folder as single source of truth**
4. **Comprehensive logging in most scripts**
5. **Good use of colors for user experience**

---

*Report generated by automated shell script audit*
*Exclude secrets/ folder as per requirements*
