# 🛡️ Environment Safety Manifest (ESM)
## Crypto Market - Critical Safety Document

**Version:** 1.0  
**Last Updated:** 2026-02-01  
**Status:** CRITICAL - READ BEFORE ANY OPERATION  
**Owner:** Вітальон  
**Enforced by:** Flutter Orchestrator + All Agents

---

## 🚨 EXECUTIVE SUMMARY

**NEVER FORGET:** ICP mainnet operations are **IRREVERSIBLE** and cost **REAL MONEY**.

This document defines the **ABSOLUTE RULES** for environment management to prevent:
- Accidental mainnet deployment with test code
- Loss of production canister IDs
- Financial loss due to improper testing
- Data corruption across environments

---

## 🎯 ENVIRONMENT ZONES

### 🔴 DANGER ZONE - Production (Mainnet)
**Network:** `ic`  
**Canister IDs:** Live, have real ICP/cycles  
**Cost:** REAL MONEY - every operation costs ICP  
**Access:** RESTRICTED - requires explicit approval

**Mainnet Canister IDs (PRODUCTION - NEVER TOUCH WITHOUT APPROVAL):**
```json
{
  "atomic_swap": "6p4bg-hiaaa-aaaad-ad6ea-cai",
  "marketplace": "6b6mo-4yaaa-aaaad-ad6fa-cai",
  "user_management": "6i5hs-kqaaa-aaaad-ad6eq-cai",
  "price_oracle": "6g7k2-raaaa-aaaad-ad6fq-cai",
  "messaging": "6ty3x-qiaaa-aaaad-ad6ga-cai",
  "dispute": "6uz5d-5qaaa-aaaad-ad6gq-cai",
  "performance_monitor": "652w7-lyaaa-aaaad-ad6ha-cai"
}
```

### 🟡 STAGING ZONE - Staging (Mainnet)
**Network:** `ic` (staging canisters)  
**Purpose:** Pre-production testing on real blockchain  
**Cost:** REAL MONEY but less than prod  
**Access:** CONTROLLED - requires verification

### 🟢 SAFE ZONE - Local Development
**Network:** `local`  
**Canister IDs:** Ephemeral, recreated on each `dfx start --clean`  
**Cost:** FREE - uses local replica  
**Access:** UNRESTRICTED - default for all development

**Current Local Canister IDs (will change on clean):**
```json
{
  "atomic_swap": "uxrrr-q7777-77774-qaaaq-cai",
  "marketplace": "u6s2n-gx777-77774-qaaba-cai",
  "user_management": "ulvla-h7777-77774-qaacq-cai",
  "price_oracle": "umunu-kh777-77774-qaaca-cai",
  "messaging": "ucwa4-rx777-77774-qaada-cai",
  "dispute": "ufxgi-4p777-77774-qaadq-cai"
}
```

---

## 📁 CRITICAL FILES & THEIR PURPOSE

### 1. `canister_ids.json` (Project Root)
**Purpose:** Single source of truth for ALL canister IDs  
**Structure:** Contains BOTH `ic` and `local` keys  
**Protection:** NEVER DELETE, NEVER MODIFY MANUALLY  
**Backup:** Auto-backedup on every deployment

```json
{
  "atomic_swap": {
    "ic": "6p4bg-hiaaa-aaaad-ad6ea-cai",    // ← PRODUCTION
    "local": "uxrrr-q7777-77774-qaaaq-cai"   // ← LOCAL DEV
  },
  "marketplace": {
    "ic": "6b6mo-4yaaa-aaaad-ad6fa-cai",    // ← PRODUCTION
    "local": "u6s2n-gx777-77774-qaaba-cai"   // ← LOCAL DEV
  }
  // ... etc
}
```

### 2. `.env` Files (Per Environment)
**Purpose:** Runtime configuration for Flutter app  
**Rule:** ONE .env file per environment, NEVER mix!

| Environment | File | Network | Canister IDs |
|-------------|------|---------|--------------|
| Local Dev | `.env` or `.env.dev` | local | Local IDs |
| Staging | `.env.stg` | ic | Staging IDs |
| Production | `.env.prod` | ic | Production IDs |

### 3. `.dfx/local/canister_ids.json`
**Purpose:** DFX-managed local canister registry  
**Rule:** AUTO-GENERATED, never manually edit  
**Clean:** Deleted on `dfx start --clean`

### 4. `dfx.json`
**Purpose:** Canister definitions and network configuration  
**Networks:**
- `local` → `127.0.0.1:4943` (ephemeral)
- `staging` → `https://ic0.app` (persistent)
- `ic` → `https://ic0.app` (persistent, PRODUCTION)

---

## ⚠️ ABSOLUTE FORBIDDEN ACTIONS

### 🚫 NEVER DO THESE:

1. **NEVER run `dfx deploy --network ic` without explicit user approval**
   - This deploys to MAINNET (costs real ICP)
   - ALWAYS confirm with Вітальон first

2. **NEVER overwrite `canister_ids.json` without backup**
   - This file contains ALL canister IDs
   - Loss = irreversible loss of production canisters

3. **NEVER mix .env files between environments**
   - `.env.dev` IDs should NEVER be in `.env.prod`
   - Always use run-config.yaml mapping

4. **NEVER delete `.dfx/ic/` directory if it exists**
   - Contains mainnet deployment state
   - Only DFX should manage this

5. **NEVER hardcode canister IDs in code**
   - ALWAYS read from .env or canister_ids.json
   - Hardcoded IDs = environment confusion

6. **NEVER run tests on mainnet without sandbox mode**
   - Tests can consume cycles
   - Use `sandbox` shipping mode for testing

7. **NEVER share production .env files**
   - Contains sensitive configuration
   - Use CI/CD secrets for production

8. **NEVER use `--force` flag on mainnet**
   - Skips safety checks
   - Can cause irreversible damage

---

## ✅ REQUIRED SAFETY CHECKS

### Before ANY Mainnet Operation:

```bash
# 1. Verify current environment
echo "Current environment: $(cat _bmad/_memory/run-checkpoint.yaml | grep environment)"

# 2. Verify network
echo "Network: $(cat _bmad/_memory/run-checkpoint.yaml | grep network)"

# 3. Verify wallet balance
dfx wallet balance --network ic

# 4. Double-check canister IDs
cat crypto_market/canister_ids.json | jq '.atomic_swap.ic'

# 5. Confirm with user
# MUST ask: "This will use REAL ICP. Proceed? (yes/no)"
```

### Safety Checklist (MANDATORY):

- [ ] Environment explicitly set (local/staging/production)
- [ ] Network verified (local/ic)
- [ ] Canister IDs verified against manifest
- [ ] Wallet balance checked (for mainnet)
- [ ] User explicitly confirmed mainnet operation
- [ ] Backup created before any modification
- [ ] Rollback plan ready

---

## 🔄 WORKFLOW SAFETY PROTOCOLS

### /run Workflow Safety:

1. **Step 1 (Env Select):** ALWAYS shows selected environment clearly
2. **Step 2 (Preflight):** Verifies tools, warns about mainnet
3. **Step 3 (DFX Status):** Checks replica, prevents wrong network
4. **Step 4 (Deploy):** 
   - BACKUP canister_ids.json before deploy
   - ATOMIC deployment (all or nothing)
   - ROLLBACK on failure
5. **Step 5 (Sync):** Only syncs to correct .env file per environment

### Agent Operation Rules:

**When Agent is working on:**
- **Flutter UI** → Uses .env.dev (local only)
- **Business Logic** → Uses .env.dev (local only)
- **ICP Backend** → May use local OR mainnet (requires approval)
- **Deployment** → MUST use /run workflow, NEVER manual dfx

---

## 🆘 EMERGENCY PROCEDURES

### If Production Canister IDs Lost:

1. **STOP ALL OPERATIONS**
2. **Check backups:**
   ```bash
   ls -la crypto_market/canister_ids.json.backup.*
   ls -la crypto_market/.dfx/backups/
   ```
3. **Restore from latest backup:**
   ```bash
   cp canister_ids.json.backup.XXXX canister_ids.json
   ```
4. **Verify restored IDs match manifest above**
5. **Contact Вітальон immediately**

### If Accidental Mainnet Deployment:

1. **DO NOT PANIC**
2. **Document what was deployed:**
   ```bash
   dfx canister status <canister> --network ic
   ```
3. **Assess impact:**
   - Is it test code? (can be upgraded)
   - Is it sensitive data? (may need wipe)
4. **Contact Вітальон with full details**

### If .env File Corrupted:

1. **Identify correct environment**
2. **Regenerate from canister_ids.json:**
   ```bash
   # Run sync workflow for specific environment
   /run local  # or staging, or production
   ```
3. **Verify generated .env matches expected values**

---

## 📋 AGENT COMPLIANCE CHECKLIST

Every agent MUST verify before acting:

```
[AGENT SAFETY CHECKLIST]

Environment: [ ] Verified
Network: [ ] Verified  
Canister IDs: [ ] Cross-checked with manifest
User Approval: [ ] Obtained (for mainnet)
Backup Created: [ ] Yes / N/A
Safe to Proceed: [ ] YES / NO
```

**If ANY check fails → STOP and ask Вітальон**

---

## 🔐 ENVIRONMENT COMMAND REFERENCE

### Safe Commands (Local Only):
```bash
# Local development - SAFE
dfx start --background --clean
dfx deploy --network local
dfx canister status <name> --network local
/run local
```

### Dangerous Commands (Require Approval):
```bash
# Mainnet operations - DANGEROUS
dfx deploy --network ic                    # ⚠️ COSTS REAL ICP
dfx canister status <name> --network ic    # Costs cycles
dfx canister call <name> <method> --network ic  # Costs cycles
/run production                            # ⚠️ MAINNET DEPLOYMENT
/run staging                               # ⚠️ REAL BLOCKCHAIN
```

### Never Run (Destructive):
```bash
rm canister_ids.json                       # NEVER
dfx start --clean --network ic             # INVALID (no --clean for ic)
```

---

## 📞 EMERGENCY CONTACTS

**Primary:** Вітальон (Telegram: @Vatalion)  
**Context:** This document, canister_ids.json backups  
**Escalation:** If critical production issue

---

## 📝 CHANGE LOG

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2026-02-01 | 1.0 | Initial safety manifest | Flutter Orchestrator |

---

**⚠️ FINAL WARNING:**

> **Every agent MUST read this document before ANY operation on crypto_market project.**
> 
> **Violation of these rules can result in:**
> - Loss of production canister IDs
> - Unintended ICP expenditure
> - Data corruption
> - Project downtime
> 
> **When in doubt → STOP and ask Вітальон.**

---

*This document is enforced by Flutter Orchestrator. All agents must comply.*
