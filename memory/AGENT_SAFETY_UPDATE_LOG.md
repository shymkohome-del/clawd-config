# Agent Safety Protocol Update Log
## Crypto Market - All Agents Updated with Safety Requirements

**Date:** 2026-02-01  
**Updated by:** Flutter Orchestrator  
**Status:** ✅ ALL AGENTS UPDATED

---

## 📋 Summary

All agents in the crypto_market project have been updated with mandatory safety protocol requirements. Each agent now:

1. **Loads safety-protocol.md** during activation
2. **Understands environment zones** (local/staging/production)
3. **Knows critical assets** (canister IDs, ic_user identity)
4. **Follows safety rules** specific to their role

---

## ✅ Updated Agents

### 1. Flutter Orchestrator (🔄 Maestro Coordinator)
**File:** `agents/flutter-orchestrator/flutter-orchestrator.md`

**Added Steps:**
- Step 4: Load safety-protocol.md (CRITICAL)
- Step 5: Verify environment awareness
- Step 24: Enforcement rule for sub-agents

**Responsibilities:**
- ENSURE all sub-agents follow safety protocol
- VERIFY identity before delegating mainnet tasks
- USE `/run` workflow exclusively
- STOP operations that bypass safety

---

### 2. ICP Backend Specialist (🛡️ Dr. Proof)
**File:** `agents/icp-backend-specialist/icp-backend-specialist.md`

**Added Steps:**
- Step 4: Load safety-protocol.md (CRITICAL - has production access)
- Step 5: Verify identity before canister operations
- Step 6: Understand production canister IDs are PERMANENT
- Step 16: Run safety-check.sh before mainnet
- Step 17: Use /run workflow ONLY

**Responsibilities:**
- Protect production canisters
- Use `ic_user` identity ONLY with approval
- Verify identity BEFORE every mainnet command
- Document all canister interactions

**Updated Principles:**
- Added: "SAFETY IS PARAMOUNT"
- Added: "Environment awareness"
- Added: "Identity protection - ic_user is SACRED"

---

### 3. Flutter Dev (🔍 Detective)
**File:** `agents/flutter-dev/flutter-dev.md`

**Added Steps:**
- Step 4: Load safety-protocol.md
- Step 5: Work with local canisters by default

**Responsibilities:**
- Use `default` identity
- Work with local canisters only
- Delegate mainnet to ICP Backend Specialist

---

### 4. Flutter Dev UI (🎨 Pixel)
**File:** `agents/flutter-dev-ui/flutter-dev-ui.md`

**Added Steps:**
- Step 4: Load safety-protocol.md
- Step 5: Local development environment only

**Responsibilities:**
- Local development only
- Coordinate via Flutter Orchestrator for mainnet-related UI

---

### 5. Amos (🔍 Adversarial Code Reviewer)
**File:** `agents/amos/amos.md`

**Added Steps:**
- Step 4: Load safety-protocol.md
- Step 5: CHECK for safety violations during review

**Responsibilities:**
- FLAG hardcoded canister IDs as CRITICAL
- FLAG unsafe mainnet operations as CRITICAL
- FLAG identity misuse as CRITICAL

---

### 6. Flutter User Emulator (🤖 QA Bot)
**File:** `agents/flutter-user-emulator/flutter-user-emulator.md`

**Added Steps:**
- Step 4: Load safety-protocol.md
- Step 5: QA testing is local-only

**Responsibilities:**
- NEVER test against production canisters
- All testing uses local development environment

---

### 7. Backend Dev (🔬 Dr. Proof)
**File:** `agents/backend-dev/backend-dev.md`

**Added Steps:**
- Step 4: Load safety-protocol.md (CRITICAL)
- Step 5: Verify identity before operations
- Step 6: Understand production canister IDs
- Step 14: Run safety-check.sh before mainnet
- Step 15: Use /run workflow ONLY

**Responsibilities:**
- Same as ICP Backend Specialist
- Protect production canisters
- Use `ic_user` identity with approval only

---

### 8. Prompt Optimizer (🎯 Clarity)
**File:** `agents/prompt-optimizer/prompt-optimizer.md`

**Added Steps:**
- Step 4: Load safety-protocol.md
- Step 5: FLAG prompts suggesting mainnet without approval

**Responsibilities:**
- Pass safety context to flutter-orchestrator
- FLAG unsafe deployment prompts

---

## 🔐 Critical Assets All Agents Must Protect

### Production Canister IDs (Mainnet):
```
atomic_swap:           6p4bg-hiaaa-aaaad-ad6ea-cai
marketplace:           6b6mo-4yaaa-aaaad-ad6fa-cai
user_management:       6i5hs-kqaaa-aaaad-ad6eq-cai
price_oracle:          6g7k2-raaaa-aaaad-ad6fq-cai
messaging:             6ty3x-qiaaa-aaaad-ad6ga-cai
dispute:               6uz5d-5qaaa-aaaad-ad6gq-cai
performance_monitor:   652w7-lyaaa-aaaad-ad6ha-cai
```

### Controller Identity:
- **Name:** `ic_user`
- **Principal:** `4gcgh-7p3b4-gznop-3q5kh-sx3zl-fz2qd-6cmhh-gxdd6-g6agu-zptr7-kqe`
- **Location:** `~/.config/dfx/identity/ic_user/`
- **Status:** 🔴 **IRREPLACEABLE**

---

## 🚫 Universal Forbidden Actions (All Agents)

1. **NEVER delete `ic_user` identity**
2. **NEVER use `default` identity for mainnet**
3. **NEVER run raw `dfx deploy --network ic`**
4. **NEVER modify `canister_ids.json` manually**
5. **NEVER delete `.dfx/ic/` directory**
6. **NEVER hardcode canister IDs in code**
7. **NEVER mix .env files between environments**
8. **NEVER deploy to mainnet without approval**
9. **NEVER ignore safety warnings**
10. **NEVER forget to check identity before operation**

---

## 📁 Safety Protocol Files

### Documentation:
- **Safety Vault:** `memory/CRYPTO_MARKET_SAFETY_VAULT.md`
- **Safety Manifest:** `memory/ENVIRONMENT_SAFETY_MANIFEST.md`
- **Agent Guidelines:** `memory/AGENT_SAFETY_GUIDELINES.md`
- **Quick Reference:** `memory/QUICK_REFERENCE_CARD.md`
- **Emergency Plan:** `memory/EMERGENCY_BACKUP_PLAN.md`

### Scripts:
- **Safety Check:** `memory/safety-check.sh`
- **Identity Switcher:** `memory/switch-identity.sh`

### Agent Protocol:
- **Safety Protocol:** `_bmad/my-custom-agents/data/safety-protocol.md`

---

## ✅ Agent Activation Verification

When ANY agent activates, they MUST:

```
[✓] Load safety-protocol.md
[✓] Understand environment zones
[✓] Know their safety responsibilities
[✓] Follow role-specific rules
[✓] Protect critical assets
```

---

## 🎯 Role-Based Safety Summary

| Agent | Identity | Environment | Can Touch Production? |
|-------|----------|-------------|----------------------|
| Flutter Orchestrator | default/ic_user | All | With approval only |
| ICP Backend Specialist | ic_user (mainnet) | All | With approval only |
| Flutter Dev | default | Local | No |
| Flutter Dev UI | default | Local | No |
| Amos (Reviewer) | any | All | Review only |
| Flutter User Emulator | default | Local | No |
| Backend Dev | ic_user (mainnet) | All | With approval only |
| Prompt Optimizer | N/A | N/A | Analysis only |

---

## 📞 Emergency Contacts

**Primary:** Вітальон (@Vatalion)  
**Use for:** Any doubt, any concern, any safety violation

---

## 📝 Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-01 | 1.0 | Initial safety protocol integration for all 8 agents |

---

## ✅ Compliance Certification

All agents have been updated and certified for safety compliance.

**Status:** ✅ OPERATIONAL  
**Enforcement:** ACTIVE  
**Next Review:** On-demand or when new agents added

---

*This registry ensures all agents in the crypto_market project follow unified safety protocols to protect production infrastructure and prevent loss of critical assets.*
