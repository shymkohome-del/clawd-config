# Long-Term Memory

## ⚠️ FOR NEW AGENTS: READ SESSION_LOG FIRST!

**When continuing work on Epic 4.5 or any ongoing project:**
- **CHECK:** `/Volumes/workspace-drive/projects/other/crypto_market/crypto_market/SESSION_LOG_EPIC_4_5_CURRENT.md`
- This contains the CURRENT state — swap IDs, amounts, errors, next steps
- **NEVER start work without reading the session log first!**

---

## Epic 4.5 Transaction Broadcasting - QA Test Plan (PERMANENT)

**Location:** `/Volumes/workspace-drive/projects/other/crypto_market/crypto_market/TEST_PLAN_EPIC_4_5_FINAL.md`

**SESSION LOG:** `/Volumes/workspace-drive/projects/other/crypto_market/crypto_market/SESSION_LOG_EPIC_4_5.md` - READ THIS FIRST!

### ⚠️ CRITICAL LESSONS FROM 2025-01-30 SESSION

**What Went Wrong:**
- Created swap_2 with UNKNOWN secret hash
- Wasted 3.02 SOL on failed attempts
- Never completed end-to-end test
- User extremely frustrated

**NEVER DO THIS:**
- Never assume secret without verification
- Never spend >0.1 SOL without explicit user approval
- Never create multiple swaps unnecessarily
- Never proceed if secret hash is not verified

---

### Test Identities (Fixed)
| Role | Identity | Principal |
|------|----------|-----------|
| Seller | default | bibc2-doxoe-vtsrh-skwdg-yzeth-le466-hgo3f-ykxin-6woib-pwask-zae |
| Buyer | qa_user | s5tp7-m3vnx-mh3f3-dgsdt-qbp3k-5efca-fmr22-s57sk-ipiq6-kfmce-2ae |

### Wallet Address (Fixed)
- **Solana Devnet:** `8xaVAq1L897hKrAuyuXgkvJczPFMrQXecM5srpGnMbk9`
- **Current Balance:** ~6.97 SOL (after 3.02 SOL wasted)
- **Status:** Active, Devnet mode

### Test Amounts (CRITICAL)
**⚠️ ALWAYS USE MINIMUM AMOUNTS:**
- **SOL:** 0.1 SOL (100,000,000 lamports) — enough for deposit + rent/fees
- **ETH:** 0.001 ETH minimum
- **Maximum:** 0.5 SOL / 0.01 ETH per test
- **Reason:** Conserve test coins, faucet cooldowns, failed tests waste resources

### Current Test Status (2026-01-30) - UPDATED

| Swap | ID | SOL | State | Blocker |
|------|-----|-----|-------|---------|
| swap_1 | swap_1_1769778609 | 2.01 | locked | Expired - can refund |
| swap_2 | swap_2_1769780756 | 1.01 | locked | UNKNOWN SECRET - DO NOT USE |

**NEW: Tron TRC-20 Implementation COMPLETED (2026-01-30)**
- Files: TronTransactionBuilder.mo (25KB), TronTransactionTest.mo (15KB)
- Status: Code reviewed, QA passed (8/8 tests), compiled successfully
- Phase 1: External signing approach
- Next: Phase 2 optional (on-chain signing)

**Epic 4.5 Blockchain Status:**
| Chain | Implementation | Testing | Status |
|-------|---------------|---------|--------|
| Solana | ✅ Complete | ✅ Tested | Done |
| Tron | ✅ Complete | ✅ QA Passed | Ready for testnet |
| Bitcoin | ✅ Complete | ⏳ Pending | BLOCKED - needs ICP |
| Ethereum | ✅ Complete | ⏳ Pending | BLOCKED - needs ICP |
| BSC | ✅ Complete | ⏳ Pending | BLOCKED - needs ICP |

**BLOCKER FOR BITCOIN TESTING:**
- NO ICP on any identity (all balances: 0 ICP)
- Required: 0.5 ICP (~$5-10) for IC mainnet deployment
- Action needed: Purchase ICP on Binance/Coinbase

**Path to Completion:**
1. **Option A (Current):** Purchase ICP → Deploy to IC Mainnet → Test Bitcoin/Ethereum/BSC
2. **Option B:** Continue with Tron testnet testing (lower priority)

### Verified Working Secret (For New Swaps)
```
Secret: "Epic45Pass"
Hash: [230, 253, 175, 109, 148, 12, 158, 81, 56, 152, 159, 103, 149, 39, 28, 107, 209, 11, 108, 81, 104, 154, 3, 190, 206, 198, 253, 46, 36, 181, 77, 238]
ASCII: [69, 112, 105, 99, 52, 53, 80, 97, 115, 115]
```

### Procedure for New Agents
1. **READ** `SESSION_LOG_EPIC_4_5.md`
2. **READ** `Next_session.md`
3. **GET USER APPROVAL** before spending ANY SOL
4. Use ONLY 0.1 SOL for new tests
5. Verify secret BEFORE creating swap
6. Document everything

**⚠️ WARNING:** User is frustrated. Be careful, precise, and professional.

---

## Infrastructure & Setup

### Vector Memory System (Second-Level Memory)
**Status:** ✅ FULLY OPERATIONAL (Enhanced 2026-01-30)

**Implementation:**
- **Engine:** Ollama 0.15.2 with nomic-embed-text model
- **Endpoint:** http://localhost:11434/v1
- **Configuration:** `~/.clawdbot/clawdbot.json`
- **Model:** `hf:ggml-org/embeddinggemma-300M-GGUF/embeddinggemma-300M-Q8_0.gguf` (768 dims)

**Features:**
- ✅ Semantic search across memory files + session history
- ✅ Hybrid search (vector 0.7 + BM25 keyword 0.3)
- ✅ SQLite-vec acceleration for fast vector queries
- ✅ Auto-sync on session start, search, and file watch
- ✅ 256 token chunks with 32 token overlap
- ✅ Embedding cache (50K entries limit)
- ✅ Auto memory flush before compaction

**Indexed Sources:**
| Source | Files | Chunks |
|--------|-------|--------|
| MEMORY.md + memory/*.md | 13 | 95 |
| Session transcripts | 13+ | 32 |

**Fix Applied (2026-01-30):**
- Changed provider from `"openai"` to `"local"` in config
- Now correctly routes to Ollama instead of OpenRouter
- Verified working: semantic search returns results with scores ~0.7-0.8

**Config Enhancements (2026-01-30):**
- Enabled `experimental.sessionMemory` — indexes session history
- Added `memoryFlush` — auto-saves before compaction
- Added `cache` config — 50K entry limit
- Added `candidateMultiplier: 4` for hybrid search

**Usage:** Automatic via `memory_search` tool when asked about prior work

---

## Research & Documentation

### BMAD Framework
Discovered and thoroughly researched BMAD (Business Model Agent-Driven) framework in crypto_market project.

**⭐ PRIMARY REFERENCE:**
- 📄 [BMAD Summary - 2026-01-29](/Users/vitaliisimko/clawd/memory/2026-01-29-bmad-summary.md) - **START HERE** - Concise complete overview

**Complete Documentation:**
- 📘 [BMAD Framework Complete Guide](/Users/vitaliisimko/clawd/memory/bmad-framework-complete-guide.md) - Comprehensive documentation covering architecture, agents, workflows, patterns
- 📋 [BMAD Quick Reference](/Users/vitaliisimko/clawd/memory/bmad-quick-reference.md) - Quick commands, patterns, and cheat sheet
- 🎯 [BMAD Episodes System](/Users/vitaliisimko/clawd/memory/bmad-episodes-system.md) - Deep dive into episode (пізод) system

**Key Points:**
- Version 6.0.0-alpha.23 by bmadcode
- AI-powered development framework with specialized agents
- Episode-based work tracking (stories, tasks, subtasks)
- Red-Green-Refactor TDD cycle embedded in workflow
- Tri-modal workflows (Create, Edit, Validate)
- Core execution engine: `_bmad/core/tasks/workflow.xml`

### Crypto Market Project
Analyzed Flutter + ICP decentralized marketplace project.

**Documentation:**
- 🏗️ [Crypto Market Architecture](/Users/vitaliisimko/clawd/memory/crypto-market-project-architecture.md) - Full project structure, canisters, patterns

**Key Points:**
- Flutter 3.38+ frontend with flutter_bloc
- 6 ICP canisters: user_management, marketplace, atomic_swap, price_oracle, messaging, dispute
- Feature-first architecture
- Result-based error handling
- Comprehensive BMAD integration

---

## Current Project Status (crypto_market)

### ✅ Story 5.2: Trade Notifications — COMPLETE
- Backend: Trade status tracking with events and history
- Frontend: TradesDashboardScreen, TradeDetailScreen, TradeTimelineWidget
- Push notifications with FCM integration and deep linking
- Code review: All issues fixed
- QA: PASSED
- Build: All compilation errors resolved
- **Commit:** `f702a2b5` — fix(5.2): Fix build issues for Story 5.2

### Epic 6: Dispute Resolution & Reputation — ✅ COMPLETE
- **Status:** ✅ ALL STORIES DONE
- **Stories Completed:**
  - 6.1 Dual-Role Reputation ✅
  - 6.2 Global Liability State ✅ (commit `0a6fa7ed`)
  - 6.3 Cross-Collateral Seizure ✅ (commit `b2702589`)
  - 6.4 Dispute Canister & Queue ✅ (commit `0a6fa7ed`)
  - 6.5 Profile UI Update ✅
  - 6.6 Context-Aware Chat UI ✅
  - 6.7 Dispute Queue UI ✅

### Epic 4.5: Omnichain Non-Custodial Escrow — ✅ CODE READY (Needs ICP for Test)
- **Status:** ✅ CODE COMPLETE, BLOCKED BY RESOURCES (2026-01-30)
- **Scope:** Multi-chain escrow with transaction broadcast
- **Implementation:** 
  - TransactionBroadcaster.mo (SOL, BTC, ETH, BSC)
  - TronBroadcaster.mo (TRC-20)
  - Integrated into releaseFunds() and refundSwap()
  - Transform function implemented and working
  - All canisters compile successfully
- **Testing:** 
  - ✅ Build verified, no errors
  - ✅ Local flow works (create, lock, complete)
  - ❌ HTTP outcall requires real IC network
  - ❌ Playground: canister too large (~3MB)
  - **SESSION LOG:** `/Volumes/workspace-drive/projects/other/crypto_market/crypto_market/SESSION_LOG_EPIC_4_5_CURRENT.md`
  - **GUIDE:** `/Volumes/workspace-drive/projects/other/crypto_market/crypto_market/HUMAN_GUIDE.md`
  - **To complete:** Need ICP tokens (~$5-10) for IC deployment

### Story 6.4: Dispute Priority Queue — COMPLETE
- **Status:** ✅ DONE
- **Location:** `/Volumes/workspace-drive/projects/other/crypto_market/crypto_market`
- **Changes:**
  - Added priority score calculation based on user reputation
  - Updated queue position logic to use priorityScore
  - Created comprehensive Motoko unit tests
  - Added story documentation to `docs/stories/6.4.dispute-priority-queue.md`
- **Tests:** All 7 test suites pass
- **Build:** Successful, no errors

### 🎯 NEXT PRIORITIES
When user says "Продовжуй роботу":
1. **Epic 4.5: Omnichain Non-Custodial Escrow** — In Progress, multi-chain support
2. **Epic 2: Listings** — 60% complete, remaining search/filter enhancements
3. **Production Hardening** — Security audit, performance optimization

### Next Actions
1. Read `Next_session.md` in project root
2. Ask user which priority to pursue
3. Activate appropriate BMAD agent
4. Run: `[DR] X.X` (Develop-Review autonomous mode)

---

## 🔐 CRYPTO MARKET SAFETY VAULT (NEW - 2026-02-01)

**⚠️ CRITICAL: This section is for crypto_market project ONLY**

### 📖 PRIMARY DOCUMENTS (Read These First!)

| Document | Purpose | Priority |
|----------|---------|----------|
| 🔐 **[SAFETY VAULT](/Users/vitaliisimko/clawd/memory/CRYPTO_MARKET_SAFETY_VAULT.md)** | Complete asset registry, identities, canister IDs | **START HERE** |
| 🛡️ [Safety Manifest](/Users/vitaliisimko/clawd/memory/ENVIRONMENT_SAFETY_MANIFEST.md) | Environment safety rules | Secondary |
| 📋 [Agent Guidelines](/Users/vitaliisimko/clawd/memory/AGENT_SAFETY_GUIDELINES.md) | Agent compliance rules | Reference |
| 💾 [Backup Plan](/Users/vitaliisimko/clawd/memory/EMERGENCY_BACKUP_PLAN.md) | Recovery procedures | Emergency |
| 📝 [Agent Update Log](/Users/vitaliisimko/clawd/memory/AGENT_SAFETY_UPDATE_LOG.md) | All agents safety status | Tracking |

### 🤖 AGENT SAFETY STATUS (ALL UPDATED - 2026-02-01)

**All 8 agents updated with mandatory safety protocol:**

| Agent | Icon | Safety Status | Can Access Production? |
|-------|------|---------------|----------------------|
| Flutter Orchestrator | 🔄 | ✅ Protected | With approval |
| ICP Backend Specialist | 🛡️ | ✅ Protected | With approval (ic_user) |
| Flutter Dev | 🔍 | ✅ Protected | No (local only) |
| Flutter Dev UI | 🎨 | ✅ Protected | No (local only) |
| Amos (Reviewer) | 🔍 | ✅ Protected | Review only |
| Flutter User Emulator | 🤖 | ✅ Protected | No (local QA) |
| Backend Dev | 🔬 | ✅ Protected | With approval (ic_user) |
| Prompt Optimizer | 🎯 | ✅ Protected | Analysis only |

**Safety Protocol Location:** `_bmad/my-custom-agents/data/safety-protocol.md`

### 🚨 CRITICAL ASSETS (From Safety Vault)

**Production Canister IDs (Mainnet - LIVE):**
```
atomic_swap:      6p4bg-hiaaa-aaaad-ad6ea-cai
marketplace:      6b6mo-4yaaa-aaaad-ad6fa-cai
user_management:  6i5hs-kqaaa-aaaad-ad6eq-cai
price_oracle:     6g7k2-raaaa-aaaad-ad6fq-cai
messaging:        6ty3x-qiaaa-aaaad-ad6ga-cai
dispute:          6uz5d-5qaaa-aaaad-ad6gq-cai
performance_monitor: 652w7-lyaaa-aaaad-ad6ha-cai
```

**Controller Identity (MOST CRITICAL):**
- **Name:** `ic_user`
- **Principal:** `4gcgh-7p3b4-gznop-3q5kh-sx3zl-fz2qd-6cmhh-gxdd6-g6agu-zptr7-kqe`
- **Location:** `~/.config/dfx/identity/ic_user/`
- **Controls:** ALL 7 production canisters
- **Status:** 🔴 **IRREPLACEABLE - BACKUP IMMEDIATELY**

### 🔧 Safety Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| `memory/safety-check.sh` | Pre-flight validation | Run before mainnet ops |
| `memory/switch-identity.sh` | Identity switching | Switch to correct identity |

### ✅ Agent Workflow for Crypto Market

**Before ANY operation on crypto_market:**

1. **Read Safety Vault** → `memory/CRYPTO_MARKET_SAFETY_VAULT.md`
2. **Identify environment** → local / staging / production
3. **Switch identity** → `./memory/switch-identity.sh [env]`
4. **Run safety check** → `./memory/safety-check.sh [env]` (for mainnet)
5. **Use /run workflow** → `/run [environment]` (NEVER raw dfx for mainnet)

### 🎯 Identity-to-Environment Mapping

| Environment | Network | Identity | Principal | Safe? |
|-------------|---------|----------|-----------|-------|
| Local | local | `default` | `bibc2-doxoe...` | ✅ Safe |
| Staging | ic | `ic_user` | `4gcgh-7p3b4...` | ⚠️ Costs ICP |
| Production | ic | `ic_user` | `4gcgh-7p3b4...` | 🚨 CRITICAL |

### 🚫 ABSOLUTE FORBIDDEN

1. **NEVER delete** `~/.config/dfx/identity/ic_user/`
2. **NEVER share** `ic_user` private key
3. **NEVER use** `default` identity for mainnet
4. **NEVER modify** `canister_ids.json` manually
5. **NEVER delete** `.dfx/ic/` directory

### ⚡ Emergency Commands

```bash
# Verify current identity
dfx identity whoami
dfx identity get-principal

# Switch to correct identity (recommended way)
./memory/switch-identity.sh production

# Check canister status (production)
dfx canister status atomic_swap --network ic

# Create emergency backup
cp ~/.config/dfx/identity/ic_user ~/ic_user-backup-$(date +%Y%m%d) -r
```

### 📞 When in Doubt

> **STOP immediately and contact Вітальон (@Vatalion)**

---

## 🛡️ Environment Safety (Legacy - See Safety Vault Above)

---

## Critical Working Rules

### 📋 Documentation Maintenance Rule (Вітальон's Directive)
**ALL project documentation must be kept in sync with actual implementation:**
- Story files — always reflect current implementation status
- Epic summaries — updated when stories complete
- Index files — synchronized with all stories
- Supporting docs (Next_session.md, etc.) — updated with every status change
- **Rule:** Update docs immediately when code changes, not as an afterthought

### 🛡️ Environment Safety Rule (NEW - 2026-02-01)
**ALL agents must:**
- Read safety manifest before crypto_market work
- Verify environment before any canister operation
- Use `/run` workflow instead of raw dfx commands
- Get explicit approval for mainnet operations
- **Violation = immediate stop + report to Вітальон**

## Session History

*See daily memory files for session-by-session logs.*
