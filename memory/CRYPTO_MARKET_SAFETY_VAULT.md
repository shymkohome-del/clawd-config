# 🔐 CRYPTO MARKET SAFETY VAULT
## Critical Assets Registry & Protection System

**Version:** 1.0  
**Created:** 2026-02-01  
**Classification:** CRITICAL - RESTRICTED ACCESS  
**Owner:** Вітальон (sole controller)  
**Last Verified:** 2026-02-01

---

## 🚨 EXECUTIVE SUMMARY

This document contains **ALL critical information** for the crypto_market project. 

**⚠️ WARNING:** Unauthorized modifications can result in:
- Permanent loss of production canisters
- Loss of access to user funds
- Inability to deploy updates
- Total project failure

**✅ ONLY Вітальон can authorize changes to this vault.**

---

## 🎯 TIER 1: CRITICAL ASSETS (IRREPLACEABLE)

### 1. Staging Canisters (Mainnet)

**Network:** `ic` (Internet Computer Mainnet)  
**Status:** ✅ ALL DEPLOYED AND RUNNING  
**Controller:** `ic_user` identity (see below)

| Canister | Canister ID (staging) | Status | Cycles | Purpose |
|----------|-----------------|--------|--------|---------|
| **atomic_swap** | `6p4bg-hiaaa-aaaad-ad6ea-cai` | ✅ Running | 8.4 TC | Escrow & swaps |
| **marketplace** | `6b6mo-4yaaa-aaaad-ad6fa-cai` | ✅ Running | TBD | Listings |
| **user_management** | `6i5hs-kqaaa-aaaad-ad6eq-cai` | ✅ Running | TBD | Users |
| **price_oracle** | `6g7k2-raaaa-aaaad-ad6fq-cai` | ✅ Running | TBD | Prices |
| **messaging** | `6ty3x-qiaaa-aaaad-ad6ga-cai` | ✅ Running | TBD | Chat |
| **dispute** | `6uz5d-5qaaa-aaaad-ad6gq-cai` | ✅ Running | TBD | Disputes |
| **performance_monitor** | `652w7-lyaaa-aaaad-ad6ha-cai` | ✅ Running | TBD | Monitoring |

**Total Value:** These canisters hold the entire production infrastructure.

**Recovery Difficulty:** IMPOSSIBLE without controller identity.

---

### 2. Controller Identity: `ic_user`

**⚠️ THIS IS THE MOST CRITICAL ASSET ⚠️**

| Property | Value |
|----------|-------|
| **Identity Name** | `ic_user` |
| **Principal** | `4gcgh-7p3b4-gznop-3q5kh-sx3zl-fz2qd-6cmhh-gxdd6-g6agu-zptr7-kqe` |
| **Location** | `~/.config/dfx/identity/ic_user/` |
| **Private Key** | `~/.config/dfx/identity/ic_user/identity.pem` |
| **Status** | ✅ ACTIVE CONTROLLER |
| **Access** | SOLE CONTROLLER of ALL production canisters |

**What This Identity Controls:**
- All 7 production canisters
- Ability to deploy updates
- Ability to change canister settings
- Access to canister logs

**IF LOST:**
- ❌ Cannot update canisters
- ❌ Cannot fix bugs
- ❌ Cannot add features
- ❌ Project is FROZEN forever

**PROTECTION LEVEL:** MAXIMUM

---

### 3. All Identity Principals

**Location:** `~/.config/dfx/identity/`

| Identity | Principal | Purpose | Status |
|----------|-----------|---------|--------|
| **ic_user** | `4gcgh-7p3b4-gznop-3q5kh-sx3zl-fz2qd-6cmhh-gxdd6-g6agu-zptr7-kqe` | **PRODUCTION CONTROLLER** | 🔴 CRITICAL |
| default | `bibc2-doxoe-vtsrh-skwdg-yzeth-le466-hgo3f-ykxin-6woib-pwask-zae` | Local development | 🟢 Safe |
| dev.vitalii.shymko | `qo6ux-unhsz-exkcd-gomzf-cr5r5-qabvz-uzo5j-ja3xo-smjbr-5dxkr-7ae` | Development | 🟢 Safe |
| qa_user | `s5tp7-m3vnx-mh3f3-dgsdt-qbp3k-5efca-fmr22-s57sk-ipiq6-kfmce-2ae` | QA testing | 🟢 Safe |
| seller_test | `rxg4u-ikl55-bkwqn-3pvfw-cjrqt-2p7hs-bg7fr-4pk7h-usiwj-dtzdj-kae` | Testing | 🟢 Safe |
| debugging_identity | `7xx42-vh2iz-s6oqf-fqmve-vtmas-ecnux-fbiio-vrqxg-yurb7-ltv4i-2ae` | Debugging | 🟢 Safe |

**Identity Files Structure:**
```
~/.config/dfx/identity/
├── ic_user/                    ← 🔴 CRITICAL - BACKUP IMMEDIATELY
│   ├── identity.pem           ← Private key - NEVER SHARE
│   ├── identity.json          
│   └── wallets.json
├── default/
├── dev.vitalii.shymko/
├── qa_user/
├── seller_test/
└── debugging_identity/
```

---

### 4. Canister IDs Registry

**Master File:** `/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/canister_ids.json`

**Status:** ✅ VERIFIED - All IDs correct

**Contents:**
```json
{
  "atomic_swap": {
    "ic": "6p4bg-hiaaa-aaaad-ad6ea-cai",
    "local": "uxrrr-q7777-77774-qaaaq-cai"
  },
  "marketplace": {
    "ic": "6b6mo-4yaaa-aaaad-ad6fa-cai",
    "local": "u6s2n-gx777-77774-qaaba-cai"
  },
  "user_management": {
    "ic": "6i5hs-kqaaa-aaaad-ad6eq-cai",
    "local": "ulvla-h7777-77774-qaacq-cai"
  },
  "price_oracle": {
    "ic": "6g7k2-raaaa-aaaad-ad6fq-cai",
    "local": "umunu-kh777-77774-qaaca-cai"
  },
  "messaging": {
    "ic": "6ty3x-qiaaa-aaaad-ad6ga-cai",
    "local": "uzt4z-lp777-77774-qaabq-cai"
  },
  "dispute": {
    "ic": "6uz5d-5qaaa-aaaad-ad6gq-cai"
  },
  "performance_monitor": {
    "ic": "652w7-lyaaa-aaaad-ad6ha-cai"
  }
}
```

**Backup Locations:**
- Primary: `crypto_market/canister_ids.json`
- Auto-backup: `crypto_market/.dfx/backups/`
- Manual: `memory/canister_ids.json.backup.*`

---

## 🛡️ TIER 2: IMPORTANT ASSETS

### 5. Environment Configuration Files

| File | Environment | Network | Purpose |
|------|-------------|---------|---------|
| `.env` | Development | local | Flutter local dev |
| `.env.stg` | Staging | ic | Pre-production testing |
| `.env.prod` | Production | ic | Live app config |

**⚠️ CRITICAL:** These files contain API keys, secrets, and canister IDs.

**NEVER:**
- Commit to git
- Share with unauthorized users
- Mix between environments

---

### 6. DFX State Directories

| Directory | Purpose | Protection Level |
|-----------|---------|------------------|
| `.dfx/ic/` | Mainnet WASM files | 🟡 Don't delete |
| `.dfx/local/` | Local canister state | 🟢 Safe to clean |
| `.dfx/backups/` | Automatic backups | 🟡 Keep safe |

---

## 🔒 PROTECTION PROTOCOLS

### 1. Identity Protection

**IMMEDIATE ACTION REQUIRED:**

```bash
# 1. Create encrypted backup of ic_user identity
mkdir -p ~/CryptoMarketBackups/IDENTITIES
cp -r ~/.config/dfx/identity/ic_user ~/CryptoMarketBackups/IDENTITIES/ic_user-backup-$(date +%Y%m%d)

# 2. Verify backup
ls -la ~/CryptoMarketBackups/IDENTITIES/ic_user-backup-*/

# 3. Optional: Encrypt backup
zip -e ~/CryptoMarketBackups/IDENTITIES/ic_user-backup-$(date +%Y%m%d).zip ~/CryptoMarketBackups/IDENTITIES/ic_user-backup-$(date +%Y%m%d)/
```

**Storage Recommendations:**
- Primary: Local encrypted backup
- Secondary: USB drive (offline)
- Tertiary: Password manager (1Password, etc.)
- **NEVER:** Cloud storage without encryption

---

### 2. Canister ID Protection

**Automatic Backups (via /run workflow):**
- Before every deployment
- Stored in `.dfx/backups/`
- Timestamped

**Manual Backup (Weekly):**
```bash
# Create weekly backup
cp crypto_market/canister_ids.json memory/canister_ids.json.backup.$(date +%Y%m%d)
```

---

### 3. Access Control Rules

| Operation | Required Identity | Approval Needed |
|-----------|-------------------|-----------------|
| Local development | `default` or any | No |
| Deploy to local | `default` | No |
| Query mainnet canisters | Any | No |
| Update mainnet canister | `ic_user` | ✅ YES - Вітальон |
| Change canister controllers | `ic_user` | ✅ YES - Вітальон |
| Add cycles to canister | `ic_user` | ✅ YES - Вітальон |

---

## ⚙️ /RUN WORKFLOW INTEGRATION

### How /run Uses This Vault

**Step 1: Environment Selection**
- User specifies: `local`, `staging`, or `production`
- /run validates against vault registry

**Step 2: Identity Verification**
```bash
# For production:
dfx identity use ic_user  # REQUIRED
dfx identity get-principal  # Verify: 4gcgh-7p3b4...
```

**Step 3: Canister ID Validation**
- Read from `canister_ids.json`
- Verify against vault registry
- Alert if mismatch detected

**Step 4: Safety Check Execution**
```bash
./memory/safety-check.sh production
```

**Step 5: User Confirmation**
- Show all canister IDs
- Show identity principal
- Require typed "YES" for mainnet

---

## 🚫 FORBIDDEN ACTIONS (ABSOLUTE)

### NEVER Do These:

1. **NEVER delete `~/.config/dfx/identity/ic_user/`**
   - Result: Permanent loss of production control

2. **NEVER share `ic_user` identity files**
   - Result: Unauthorized access to production

3. **NEVER use `default` identity for mainnet deployment**
   - Result: Insecure, dfx blocks this

4. **NEVER modify `canister_ids.json` manually**
   - Result: Configuration corruption

5. **NEVER delete `.dfx/ic/` directory**
   - Result: Loss of mainnet WASM files

6. **NEVER commit identity files to git**
   - Result: Private keys exposed

7. **NEVER run `dfx identity remove ic_user`**
   - Result: Controller identity destroyed

---

## ✅ AGENT COMPLIANCE RULES

### When Agent Needs to Work on Crypto Market:

**Step 1: Read Safety Vault**
- Location: `memory/CRYPTO_MARKET_SAFETY_VAULT.md`
- Understand: What is critical, what is safe

**Step 2: Identify Operation Type**
| Operation Type | Identity | Workflow |
|----------------|----------|----------|
| Local dev/test | `default` | `/run local` |
| Staging deploy | `ic_user` | `/run staging` |
| Production deploy | `ic_user` | `/run production` |

**Step 3: Execute via /run**
- NEVER use raw `dfx` commands for mainnet
- ALWAYS use `/run [environment]`

**Step 4: If /run Cannot Be Used**
- MUST get explicit approval from Вітальон
- MUST use `ic_user` identity for mainnet
- MUST run safety-check.sh first
- MUST document all actions

---

## 🆘 EMERGENCY PROCEDURES

### Scenario 1: ic_user Identity Lost

**Symptoms:**
- `~/.config/dfx/identity/ic_user/` deleted
- Cannot control production canisters

**Recovery:**
1. Check backups: `~/CryptoMarketBackups/IDENTITIES/`
2. Restore from backup
3. If no backup: CATASTROPHIC - contact DFINITY with proof of ownership

### Scenario 2: Canister IDs Corrupted

**Recovery:**
1. Check: `crypto_market/.dfx/backups/`
2. Check: `memory/canister_ids.json.backup.*`
3. Restore from latest backup
4. Verify against this vault document

### Scenario 3: Accidental Controller Change

**If controller changed to wrong principal:**
1. DON'T PANIC (if still have access)
2. Use current controller to add `ic_user` back
3. If no access: CATASTROPHIC - contact DFINITY

---

## 🔐 TIER 4: SWAP SECRETS MANAGEMENT (NEW)

### Critical Problem Identified: 2026-02-01
**Issue:** Secret for swap `swap_2_1769956232` was lost because it wasn't logged during creation.  
**Impact:** Cannot test `completeSwap` — funds locked permanently.  
**Lesson:** Secrets MUST be logged immediately upon generation.

### Secrets Registry

**Location:** This vault document (below)  
**Format:** Swap ID → Secret (preimage) + Hash  
**Security Level:** Same as identity keys — secrets grant access to funds

### Active Test Swaps

| Swap ID | Secret (Preimage) | Secret Hash | Status | Created | Environment |
|---------|-------------------|-------------|--------|---------|-------------|
| `swap_2_1769956232` | **LOST** ⚠️ | `e6fdaf6d...b54dee` | locked | 2026-02-01 | production |
| `swap_new_epic45` | `test_secret_epic45_1769964645` | `4ad5c29c...3a75b37` | initiated | 2026-02-01 | local |
| `swap_1_1769955481` | `UNKNOWN` | `e6fdaf6d...b54dee` | initiated | 2026-02-01 | production |
| `swap_2_1769956232` | `UNKNOWN` | `e6fdaf6d...b54dee` | locked | 2026-02-01 | production |
| `swap_5_1769965030` | `5d379c25...1538d9` | `271d2519...c2defc` | initiated | 2026-02-01 | production |
| `swap_6_1769965353` | `5d379c25...1538d9` | `271d2519...c2defc` | **completed** ✅ | 2026-02-01 | production |

### Swap Details

#### Swap: swap_1_1769955481 (ACTIVE - READY FOR TESTING)
- **Created:** 2026-02-01 (timestamp: 1769955481)
- **Environment:** production
- **Secret (preimage):** `test_secret`
- **Hash (SHA256):** `e6fdaf6d940c9e5138989f6795271c6bd10b6c51689a03becec6fd2e24b54dee`
- **Status:** initiated → ready for lockFunds → then completeSwap
- **Amount:** 10 SOL (10,000,000 lamports)
- **Price:** $1 USD
- **Purpose:** Testing completeSwap flow
- **Buyer:** ic_user (4gcgh-7p3b4...)
- **Seller:** qa_user (s5tp7-m3vnx...)

#### Swap: swap_2_1769956232 (LOCKED - SECRET LOST ⚠️)
- **Created:** 2026-02-01 (timestamp: 1769956232)
- **Environment:** production
- **Secret (preimage):** `UNKNOWN` — generated by Flutter, not logged ❌
- **Hash (SHA256):** `e6fdaf6d940c9e5138989f6795271c6bd10b6c51689a03becec6fd2e24b54dee`
- **Status:** locked → CANNOT complete (secret lost)
- **Amount:** 5 SOL (5,000,000 lamports)
- **Price:** $1 USD
- **Buyer:** ic_user (4gcgh-7p3b4...)
- **Seller:** qa_user (s5tp7-m3vnx...)
- **Lesson:** ALWAYS log secret before calling lockFunds

#### Swap: swap_5_1769965030 (ACTIVE TEST - CONTROLLED SECRET ✅)
- **Swap ID:** `swap_5_1769965030`
- **Created:** 2026-02-01 18:57 GMT+2
- **Environment:** production
- **Secret (32 bytes, hex):** `5d379c2552f282a762b0fae48bb80fbd738c1cb999a460ed5eda9af0b61538d9`
- **Secret (blob for dfx):** `\x5d\x37\x9c\x25\x52\xf2\x82\xa7\x62\xb0\xfa\xe4\x8b\xb8\x0f\xbd\x73\x8c\x1c\xb9\x99\xa4\x60\xed\x5e\xda\x9a\xf0\xb6\x15\x38\xd9`
- **Hash (SHA256):** `271d2519f5177a2394644b08b4d6b23e561ac6d0d811de2b606de10770c2defc`
- **Status:** handshake_accepted → buyer must submit Solana payment
  - Next: Make real SOL deposit to vault address
  - Then: lockFunds will scan and transition to locked
- **Amount:** 1 SOL (1,000,000 lamports)
- **Price:** $1 USD
- **Lock Time:** 1 hour
- **Buyer:** ic_user (4gcgh-7p3b4...)
- **Seller:** qa_user (s5tp7-m3vnx...)
- **Purpose:** Testing completeSwap flow with KNOWN secret
- **Next Steps:**
  1. Seller accepts handshake
  2. Buyer locks funds
  3. Seller completes swap with secret

#### Swap: swap_6_1769965353 (ACTIVE — 0.1 SOL TEST ✅)
- **Swap ID:** `swap_6_1769965353`
- **Created:** 2026-02-01 19:02 GMT+2
- **Environment:** production
- **Amount:** 0.1 SOL (100,000 lamports)
- **Price:** $1 USD
- **Secret (32 bytes, hex):** `5d379c2552f282a762b0fae48bb80fbd738c1cb999a460ed5eda9af0b61538d9`
- **Hash (SHA256):** `271d2519f5177a2394644b08b4d6b23e561ac6d0d811de2b606de10770c2defc`
- **Vault Address:** `Ep8CgUzZmFZbMNVh5uwWUS4jMpDRdaN7oUq5xonFSvJQ`
- **Status:** ✅ `completed` — swap finished successfully!
- **Buyer:** ic_user (4gcgh-7p3b4...)
- **Seller:** qa_user (s5tp7-m3vnx...)
- **Deposit:** 0.1 SOL (100,000,000 lamports)
- **Payout Breakdown:**
  - Seller receives: 97,000 lamports (0.097 SOL)
  - Platform fee: 2,000 lamports (2%)
  - Security fee: 500 lamports
  - Cycles fee: 500 lamports
- **Result:** ✅ completeSwap тест успішний!

### ⚠️ CRITICAL RULES FOR SECRETS

#### Rule 1: Log BEFORE Lock
```
Create Swap → Log Secret → Lock Funds
```
**NEVER:** Lock funds without logging secret first!

#### Rule 2: Secret Storage Format
```markdown
### Swap: [swap_id]
- **Created:** [timestamp]
- **Environment:** [local/staging/production]
- **Secret (preimage):** `[plaintext secret]`
- **Hash (SHA256):** `[hex hash]`
- **Status:** [initiated/locked/completed/refunded]
- **Buyer:** [principal]
- **Seller:** [principal]
- **Amount:** [value]
```

#### Rule 3: Never Commit Secrets to Git
- Secrets are for testing ONLY
- Production swaps should use secrets known only to users
- Clear secrets from vault after swap completion

#### Rule 4: SECRET/HASH CONSISTENCY CHECK (NEW - 2026-02-01)
**CRITICAL:** Before creating swap, agent MUST verify:
```python
# 1. Generate secret
secret = generate_secure_random_bytes(32)

# 2. Compute hash  
hash = sha256(secret)

# 3. VERIFY consistency BEFORE using
assert hash == sha256(secret), "SECRET/HASH MISMATCH!"

# 4. Log BOTH values
log("Secret: " + secret.hex())
log("Hash: " + hash.hex())

# 5. Only then create swap with hash
```
**NEVER** use secret directly as hash!
**NEVER** skip verification step!

#### Rule 5: Verification Before Lock
Before calling `lockFunds`, agent MUST:
1. Confirm secret is logged in this vault
2. Verify hash matches canister data
3. Only then proceed with lock

#### Rule 6: SWAP CREATION CHECKLIST (MANDATORY)
Before initiating ANY swap:
- [ ] Secret generated (32 random bytes)
- [ ] Hash computed (SHA256)
- [ ] Consistency verified (hash == sha256(secret))
- [ ] Secret logged in Safety Vault
- [ ] Hash logged in Safety Vault
- [ ] Candid blob format prepared
- [ ] Amount verified (> 0)
- [ ] Seller principal verified
- [ ] Refund address set

### Secret Generation for Testing

```bash
# Generate test secret (local/staging only)
SECRET="test_secret_$(date +%s)"
echo "Secret: $SECRET"

# Generate hash (for verification)
echo -n "$SECRET" | sha256sum
```

---

## 📋 VERIFICATION CHECKLIST

### Weekly Verification:

```
[ ] ic_user identity exists: ~/.config/dfx/identity/ic_user/
[ ] Private key readable: ~/.config/dfx/identity/ic_user/identity.pem
[ ] Canister IDs file valid: crypto_market/canister_ids.json
[ ] All 7 production canisters listed
[ ] Backups exist and readable
[ ] No unauthorized changes to identities
```

### Monthly Verification:

```
[ ] Create fresh identity backup
[ ] Test restore procedure (on copy)
[ ] Review access logs
[ ] Verify canister cycles (top up if needed)
[ ] Update this vault document if changes
```

---

## 📞 EMERGENCY CONTACTS

**Primary:** Вітальон (@Vatalion)  
**Context:** This vault document + latest backup location  
**Escalation:** If critical production assets at risk

---

## 📝 CHANGE LOG

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2026-02-01 | 1.0 | Initial vault creation | Flutter Orchestrator |
| 2026-02-01 | 1.1 | Added TIER 4: Swap Secrets Management (after lost secret incident) | Flutter Orchestrator |
| 2026-02-01 | 1.2 | Documented swap_5_1769965030 with controlled secret for testing | Flutter Orchestrator |
| 2026-02-01 | 1.3 | swap_6_1769965353: completed full flow test (initiate → lock → complete) | Flutter Orchestrator |
| 2026-02-01 | 1.4 | Fixed critical bug: lock not released on failed_to_get_blockhash trap | Flutter Orchestrator |
| 2026-02-01 | 1.5 | Fixed all Debug.trap in refundFunds/releaseFunds to properly release locks | Flutter Orchestrator |
| 2026-02-01 | 1.6 | Epic 4.5 Testing COMPLETE - all functions verified | Flutter Orchestrator |

---

## 🔐 FINAL NOTES

**This vault is the single source of truth for crypto_market critical assets.**

**All agents MUST:**
1. Read this document before any operation
2. Follow the protocols exactly
3. Ask Вітальон when in doubt
4. Never assume - always verify

**Remember:**
> The `ic_user` identity is the keys to the kingdom. 
> Lose it = lose everything.
> Protect it at all costs.

---

*This document is classified CRITICAL and is the property of Вітальон.*
