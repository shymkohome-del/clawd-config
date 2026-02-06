# Lint Rules for Motoko (ICP Backend)

## 🚨 MANDATORY: Run Validation After Any Canister Code Change

**Перед завершенням роботи ОБОВ'ЯЗКОВО виконай:**

```bash
dfx build
```

**Очікуваний результат:**
```
✅ Validation: 0 errors, 0 warnings
```

---

## 📋 Motoko Lint Rules Catalog

### 1. Critical Errors (Must Fix - Blocking)

| Error Code | Severity | Description | Fix |
|------------|----------|-------------|-----|
| M0001 | Error | Type mismatch | Align types explicitly |
| M0002 | Error | Undefined identifier | Check spelling, imports |
| M0003 | Error | Import not found | Verify canister imports |
| M0004 | Error | Missing method signature | Add required return type |
| M0005 | Error | Invalid expression | Restructure expression |
| M0006 | Error | Operator may trap | Add bounds check |
| M0007 | Error | Division by zero | Check before divide |
| M0008 | Error | Array index out of bounds | Check index validity |
| M0009 | Error | Option value used as non-option | Unwrap or handle None |
| M0010 | Error | Non-exhaustive patterns | Cover all cases in switch |

---

### 2. Warnings (Should Fix - Important)

| Warning Code | Severity | Description | Fix |
|--------------|----------|-------------|-----|
| M0101 | Warning | Unused variable | Remove or use underscore |
| M0102 | Warning | Unused function | Remove or export |
| M0103 | Warning | Unused import | Remove unused import |
| M0104 | Warning | Shadowed variable | Rename variable |
| M0105 | Warning | Type inference ambiguity | Add explicit type |
| M0106 | Warning | Deprecated API usage | Use newer API |
| M0107 | Warning | Performance concern | Optimize operation |
| M0108 | Warning | Unreachable code | Remove dead code |

---

### 3. Style Rules (Best Practice)

| Rule | Severity | Description | Fix |
|------|----------|-------------|-----|
| `module-naming` | Style | Use PascalCase for modules | Rename |
| `type-naming` | Style | Use PascalCase for types | Rename |
| `function-naming` | Style | Use camelCase for functions | Rename |
| `variable-naming` | Style | Use camelCase for variables | Rename |
| `constant-naming` | Style | Use UPPER_SNAKE for constants | Rename |
| `line-length` | Style | Keep lines under 120 chars | Wrap |
| `comment-style` | Style | Use // for single-line comments | Format |

---

## 🔒 Blockchain-Specific Validation

### Critical Safety Rules

#### 1. Overflow/Underflow Prevention

```motoko
// ❌ DANGEROUS - May trap
let result = a - b;

// ✅ SAFE - Explicit check
let result = if (a >= b) { a - b } else { return #err("underflow") };

// ❌ DANGEROUS - Division by zero
let quotient = x / y;

// ✅ SAFE - Check divisor
let quotient = if (y == 0) { return #err("division_by_zero") } else { x / y };
```

#### 2. Array Index Safety

```motoko
// ❌ DANGEROUS - May trap
let item = arr[10];

// ✅ SAFE - Check bounds
let item = if (10 < arr.size()) { arr[10] } else { return #err("index_out_of_bounds") };
```

#### 3. Option Type Handling

```motoko
// ❌ DANGEROUS - Unwrap without check
let value = optVal!;  // May trap

// ✅ SAFE - Pattern match
switch (optVal) {
  case (?v) { process(v) };
  case null { return #err("not_found") };
}

// ✅ SAFE - Alternative with if
if (let ?v = optVal) {
  process(v)
};
```

#### 4. Result<T,E> Pattern

```motoko
// Define custom error types
type SwapError = {
  #insufficientBalance;
  #tokenNotSupported;
  #slippageExceeded;
  #transferFailed;
};

// ✅ Correct Result usage
func swapTokens(amount : Nat) : Result<Bool, SwapError> {
  if (balance < amount) {
    return #err(#insufficientBalance);
  };
  // ... process swap
  return #ok(true);
};

// Pattern matching on result
switch (swapTokens(100)) {
  case (#ok(true)) { "Swap successful" };
  case (#err(#insufficientBalance)) { "Add funds" };
  case (#err(error)) { "Error: " # debug_show(error) };
};
```

---

## 🚫 Print Statement Ban

**❌ FORBIDDEN in Motoko:**

```motoko
// ❌ FORBIDDEN
Debug.print("Debug: " # debug_show(value));
D.print("Value");
```

**✅ REQUIRED - Return errors properly:**

```motoko
// ✅ Return error result
func validateInput(input : Text) : Result<Text, ValidationError> {
  if (input.size() == 0) {
    return #err(#emptyInput);
  };
  #ok(input)
};
```

**Exception:** Debug module for development only:

```motoko
// ⚠️ Only in development, remove before production
import Debug "mo:base/Debug";
Debug.print("DEBUG: temporary debug info"); // Remove!
```

---

## 📦 Canister Management Rules

### Identity Verification

```bash
# ALWAYS verify identity before canister operations
dfx identity whoami

# Expected: ic_user (for mainnet operations)
# Expected: default (for local development)
```

### Environment Zones

| Environment | Identity | Risk Level | Deployment Command |
|-------------|----------|------------|-------------------|
| **Local** | default | 🟢 Safe | `dfx deploy` |
| **Staging** | ic_user | 🟡 Moderate | `./scripts/deploy.sh staging` |
| **Mainnet** | ic_user | 🔴 Critical | Get explicit approval first |

### Never Do

```bash
# ❌ FORBIDDEN - Direct mainnet deployment
dfx deploy --network ic

# ❌ FORBIDDEN - Delete user identity
dfx identity remove ic_user

# ❌ FORBIDDEN - Modify canister_ids.json manually
```

---

## 📋 Pre-Deployment Checklist

- [ ] `dfx build` completes with 0 errors
- [ ] All type errors resolved
- [ ] No operator may trap warnings
- [ ] All Option types properly handled
- [ ] Result<T,E> used for fallible operations
- [ ] Unit tests pass
- [ ] Integration tests pass (local)
- [ ] Code reviewed by amos (if production)
- [ ] Explicit user approval for mainnet

---

## 🧪 Testing Requirements

### Unit Test Pattern

```motoko
import Suite "mo:check_match/Suite";

let suite = Suite.Suite({
  test("should fail with insufficient balance", func() : Bool {
    let result = wallet.withdraw(1000);
    switch (result) {
      case (#err(#insufficientBalance)) { true };
      case (_) { false };
    };
  });
});

if (not Suite.run(suite)) {
  Debug.trap("Tests failed");
};
```

### Test Coverage Requirements

| Category | Minimum Coverage |
|----------|-----------------|
| Core business logic | 90% |
| Error handling paths | 100% |
| Public functions | 100% |

---

## 📊 Validation Command Reference

```bash
# Build with full checks
dfx build --check

# Analyze canister code
moc --check src/canister/main.mo

# Type check specific module
moc -r src/token.mo

# Run tests
dfx test
```

---

## 🚨 Critical Error Examples

### M0006 - Operator May Trap

```motoko
// ❌ WARNING: operator may trap
let result = items[i];

// ✅ FIXED: bounds check
let result = if (i < items.size()) { items[i] } else { return #err("index_oob") };
```

### M0007 - Division by Zero

```motoko
// ❌ WARNING: division by zero
let avg = sum / count;

// ✅ FIXED: check divisor
let avg = if (count == 0) { 0 } else { sum / count };
```

### M0009 - Option Unwrap

```motoko
// ❌ WARNING: unsafe unwrap
let value = optValue!;

// ✅ SAFE: pattern match
switch (optValue) {
  case (?v) { process(v) };
  case null { return #err("none") };
};
```

---

## 📚 Documentation Standards

### Function Documentation

```motoko
/// Performs an atomic swap between two tokens.
///
/// **Security:** Validates all input amounts and prevents front-running attacks.
/// **Preconditions:** 
///   - caller must have approved sufficient tokens
///   - amount must be greater than 0
///
/// Returns:
///   - #ok(true) on successful swap
///   - #err(#insufficientBalance) if balance too low
///   - #err(#allowanceExceeded) if allowance insufficient
///
/// **Panics:** Never. All errors returned as Result.
public func swap(from : TokenId, to : TokenId, amount : Nat) : async Result<Bool, SwapError> {
  // Implementation
};
```

---

## 🎯 Remember

> **"В BLOCKCHAIN НЕМАЄ UNDO"**
>
> - Кожен `!` operator — потенційний trap
> - Кожен Array index — може бути out of bounds
> - Кожне division — може бути division by zero
> - Кожен Result — має бути оброблений
>
> **"WARNING = ERROR"**

**Вітальон довірив мені доступ до canisters з реальними ICP.**

Моя легковажність = реальні збитки реальних людей.

**Завжди перевіряй, ніколи не припускай.**
