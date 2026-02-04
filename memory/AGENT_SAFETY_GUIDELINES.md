# Agent Environment Safety Guidelines
## For All Agents Working on Crypto Market Project

**Version:** 1.1  
**Updated:** 2026-02-01  
**Enforced by:** Flutter Orchestrator

**Changes in v1.1:**
- Added BLOCKCHAIN OPERATIONS SAFETY section
- Added mandatory secret/hash consistency verification
- Added pre-flight checklist for atomic swaps
- Added blob format verification rules

---

## 🎯 QUICK REFERENCE (Read This First!)

### The Golden Rule:
> **When in doubt about environment → STOP and ask Вітальон**

### Environment Quick Guide:

| What You Need | Environment | Network | Command | Safe? |
|--------------|-------------|---------|---------|-------|
| Test Flutter UI | Local | local | `/run local` | ✅ Safe |
| Test Business Logic | Local | local | `/run local` | ✅ Safe |
| Deploy new canisters | Local | local | `/run local` | ✅ Safe |
| Pre-prod testing | Staging | ic | `/run staging` | ⚠️ Costs ICP |
| Production deploy | Production | ic | `/run production` | 🚨 MUST ASK FIRST |

---

## 🚨 CRITICAL RULES (Memorize These!)

### BLOCKCHAIN OPERATIONS SAFETY (NEW - 2026-02-01)

#### Rule B1: SECRET/HASH CONSISTENCY IS MANDATORY
**❌ NEVER use secret directly as hash:**
```dart
// WRONG - This causes swap failure!
secretHash = secret  // secret is 32 bytes, hash is SHA256(secret)
```

**✅ ALWAYS compute hash from secret:**
```python
# CORRECT
secret = generate_random_bytes(32)
hash = sha256(secret)  // Compute hash!
verify(hash == sha256(secret))  // MANDATORY CHECK
```

#### Rule B2: VERIFY BEFORE USE
**Before creating swap:**
1. Generate secret (32 random bytes)
2. Compute SHA256 hash
3. **VERIFY:** hash == sha256(secret)
4. Log BOTH values to Safety Vault
5. Only then use hash in initiateSwap

**❌ NEVER skip verification step**

#### Rule B3: LOG BEFORE LOCK
**Before calling lockFunds:**
- [ ] Secret logged in Safety Vault
- [ ] Hash logged in Safety Vault  
- [ ] Hash verified against canister data
- [ ] Amount verified
- [ ] All parties confirmed

#### Rule B4: DOUBLE-CHECK ALL BLOB FORMATS
**Candid blob format must be exact:**
```
// WRONG
blob "\x5d\x37..."  // Python style

// CORRECT  
blob "\5d\37..."     // Motoko/dfx style (no 'x')
```

**Always test format before mainnet use.**

---

### 1. NEVER Hardcode Canister IDs

**❌ WRONG:**
```dart
// NEVER do this!
final marketplaceCanister = "6b6mo-4yaaa-aaaad-ad6fa-cai";
```

**✅ CORRECT:**
```dart
// ALWAYS read from environment
final marketplaceCanister = const String.fromEnvironment('CANISTER_ID_MARKETPLACE');
```

### 2. NEVER Mix Environment Files

**❌ WRONG:**
- Using `.env.dev` values in production
- Copying local canister IDs to `.env.prod`
- Hardcoding any canister ID in code

**✅ CORRECT:**
- Use `/run local` → generates correct `.env`
- Use `/run staging` → generates correct `.env.stg`
- Use `/run production` → generates correct `.env.prod`

### 3. NEVER Deploy to Mainnet Without Approval

**❌ WRONG:**
```bash
dfx deploy --network ic  # NEVER run this directly!
```

**✅ CORRECT:**
```bash
/run production  # Uses safety checks + requires confirmation
```

### 4. ALWAYS Check Environment Before Operation

**Before ANY canister operation, verify:**
1. What environment am I working in?
2. What network will this use?
3. Will this cost real ICP?
4. Do I have user approval (for mainnet)?

---

## 📋 AGENT WORKFLOW CHECKLIST

### Before Starting Work:

```
[ ] Read Environment Safety Manifest (memory/ENVIRONMENT_SAFETY_MANIFEST.md)
[ ] Verify current environment (local/staging/production)
[ ] Check if operation affects canisters
[ ] Confirm safe to proceed
```

### When Working on Flutter Code:

```
[ ] Use local environment (default)
[ ] Read canister IDs from .env file
[ ] Never hardcode IDs in Dart code
[ ] Test with local canisters first
```

### When Working on ICP Backend:

```
[ ] Local development: Safe to experiment
[ ] Any mainnet call: MUST get approval
[ ] Document all canister interactions
[ ] Use /run workflow for deployment
```

### When Creating Atomic Swaps (CRITICAL):

```
PRE-FLIGHT CHECKLIST (MANDATORY):
[ ] Secret generated (32 random bytes)
[ ] Hash computed (SHA256 of secret)
[ ] CONSISTENCY VERIFIED: hash == sha256(secret)
[ ] Secret logged in Safety Vault
[ ] Hash logged in Safety Vault
[ ] Candid blob format verified (Motoko style: \xx not \x)
[ ] Amount > 0 verified
[ ] Seller principal correct
[ ] Refund address set
[ ] Lock time appropriate (1-168 hours)

FAILURE TO CHECK = SWAP FAILURE
```

### When Asked to Deploy:

```
[ ] Verify target environment
[ ] Run safety checks
[ ] If mainnet: Get explicit YES from Вітальон
[ ] Use /run workflow only
[ ] Never use raw dfx commands
```

---

## 🔄 ENVIRONMENT-SPECIFIC GUIDELINES

### Local Development (SAFE ZONE)

**Characteristics:**
- Network: `local`
- Cost: FREE
- Canister IDs: Change on `dfx start --clean`
- File: `.env` or `.env.dev`

**Agent Actions Allowed:**
- ✅ Deploy canisters freely
- ✅ Test all functionality
- ✅ Delete and recreate canisters
- ✅ Experiment with code

**No Restrictions** - Full freedom to experiment

### Staging (CONTROLLED ZONE)

**Characteristics:**
- Network: `ic` (mainnet)
- Cost: REAL ICP (but less than prod)
- Canister IDs: Persistent staging IDs
- File: `.env.stg`

**Agent Actions Allowed:**
- ⚠️ Deploy only with safety checks
- ⚠️ Test with caution
- ⚠️ Monitor cycle usage
- ❌ Never delete canisters

**Requires:** Safety check + user notification

### Production (DANGER ZONE)

**Characteristics:**
- Network: `ic` (mainnet)
- Cost: REAL ICP
- Canister IDs: **CRITICAL - NEVER LOSE THESE**
- File: `.env.prod`

**Agent Actions Allowed:**
- 🚨 **MUST ask Вітальон before ANY operation**
- 🚨 Deploy only via /run workflow
- 🚨 Verify 3x before executing
- ❌ NEVER experiment
- ❌ NEVER delete
- ❌ NEVER modify without approval

**Requires:** Explicit user confirmation + safety checks

---

## 📁 IMPORTANT FILES TO KNOW

### `canister_ids.json` (Project Root)
**What:** Single source of truth for ALL canister IDs  
**Contains:** Both `ic` (mainnet) and `local` IDs  
**Rule:** NEVER modify manually, NEVER delete  
**Backup:** Auto-created on every deployment

### `.env` Files
**What:** Runtime configuration for Flutter  
**Rule:** One file per environment, NEVER mix  
**Generated:** By `/run` workflow automatically

### `dfx.json`
**What:** Canister definitions  
**Networks:**
- `local` → localhost
- `ic` → mainnet (⚠️ costs ICP)

### `.dfx/` Directory
**What:** DFX state and canister data  
**Rule:**
- `.dfx/local/` → Safe to delete
- `.dfx/ic/` → **NEVER DELETE** (mainnet state)

---

## 🆘 EMERGENCY SCENARIOS

### Scenario 1: Accidental Mainnet Call

**You ran:**
```bash
dfx canister call marketplace getListings --network ic
```

**What to do:**
1. Don't panic - it's just a query call (probably)
2. Check if it was a query or update
3. Notify Вітальон: "I may have made a mainnet call"
4. Document what you did

### Scenario 2: Wrong Environment Deploy

**You think you:**
- Deployed to local
- Actually deployed to ic

**What to do:**
1. STOP immediately
2. Check current environment:
   ```bash
   cat _bmad/_memory/run-checkpoint.yaml
   ```
3. Notify Вітальон IMMEDIATELY
4. Don't make any more changes

### Scenario 3: Corrupted .env File

**Symptom:** Flutter can't connect to canisters

**What to do:**
1. Don't guess - don't manually edit
2. Run: `/run local` (or appropriate environment)
3. Let the workflow regenerate .env
4. Verify canister IDs match expected values

---

## 🧠 MEMORY AIDS

### Remember This Pattern:
```
LOCAL = FREE TO EXPERIMENT
STAGING = CAREFUL - COSTS ICP
PRODUCTION = ASK FIRST - ALWAYS
```

### Quick Checks:
- Does the ID start with 'u'? → Probably local ✅
- Does the ID look random? → Could be mainnet ⚠️
- Am I using `--network ic`? → STOP and verify 🚨

### Safety Questions to Ask Yourself:
1. "Will this cost real ICP?"
2. "Could this break production?"
3. "Do I know which environment I'm in?"
4. "Should I ask Вітальон first?"

If answer to any is "yes" or "not sure" → **ASK FIRST**

---

## 📞 WHEN TO CONTACT ВІТАЛЬОН

**Always ask before:**
- Any `--network ic` operation
- Deploying to production
- Modifying `canister_ids.json`
- Deleting any `.dfx/` directory
- Running commands you're unsure about

**Contact immediately if:**
- You accidentally ran a mainnet command
- You see unexpected canister IDs
- You get "out of cycles" errors
- Anything feels wrong

---

## ✅ AGENT COMPLIANCE CERTIFICATION

Before working on crypto_market, every agent must acknowledge:

```
I have read and understand:
[ ] Environment Safety Manifest
[ ] Agent Safety Guidelines
[ ] Critical Rules section
[ ] Emergency procedures

I agree to:
[ ] Ask before mainnet operations
[ ] Never hardcode canister IDs
[ ] Use /run workflow for deployment
[ ] Verify environment before operations
[ ] Contact Вітальон when in doubt

Agent: ________________
Date: ________________
```

---

## 📝 SUMMARY

**Five Things to Never Forget:**

1. **Local = Safe, Mainnet = Dangerous**
2. **When in doubt, ask Вітальон**
3. **Use /run workflow, never raw dfx for mainnet**
4. **ALWAYS verify secret/hash consistency before swap**
5. **NEVER use secret directly as hash - compute SHA256!**

**Critical Errors to Avoid:**
- Using secret as hash (causes invalid_secret)
- Wrong blob format (causes parsing errors)
- Skipping verification (causes swap failures)
- Not logging values (can't recover secret)

**One File to Always Check:**
- `memory/ENVIRONMENT_SAFETY_MANIFEST.md`

**One Command to Always Use:**
- `/run [environment]` instead of raw `dfx deploy`

---

*These guidelines protect the project and Вітальон's ICP. Follow them strictly.*
