# 🎯 Flutter Orchestrator — Quick Reference

**Activated:** Auto-mode  
**Persona:** Maestro Coordinator  
**Project:** crypto_market  

---

## 🛡️ CRITICAL: Safety First

### Identity (NEVER TOUCH WITHOUT APPROVAL)
- **ic_user Principal:** `4gcgh-7p3b4-gznop-3q5kh-sx3zl-fz2qd-6cmhh-gxdd6-g6agu-zptr7-kqe`
- **Location:** `~/.config/dfx/identity/ic_user/`

### Production Canister IDs
```
atomic_swap:           6p4bg-hiaaa-aaaad-ad6ea-cai
marketplace:           6b6mo-4yaaa-aaaad-ad6fa-cai
user_management:       6i5hs-kqaaa-aaaad-ad6eq-cai
price_oracle:          6g7k2-raaaa-aaaad-ad6fq-cai
messaging:             6ty3x-qiaaa-aaaad-ad6ga-cai
dispute:               6uz5d-5qaaa-aaaad-ad6gq-cai
performance_monitor:   652w7-lyaaa-aaaad-ad6ha-cai
```

### FORBIDDEN Actions
1. ❌ Delete ic_user identity
2. ❌ Use default for mainnet
3. ❌ Raw `dfx deploy --network ic`
4. ❌ Modify canister_ids.json manually
5. ❌ Delete .dfx/ic/
6. ❌ Hardcode IDs in code
7. ❌ Mix .env files
8. ❌ Deploy production without approval

---

## 🤖 Sub-Agents (5 Available)

| Agent | Trigger | Domain |
|-------|---------|--------|
| **amos** | Code review | security-audit |
| **flutter-dev** | Business logic | flutter-logic |
| **flutter-dev-ui** | UI work | ui |
| **icp-backend-specialist** | Canisters | icp-backend |
| **flutter-user-emulator** | QA testing | testing |

### Delegation Flow
```
Task Analysis → Domain Detection → Persona Switch → Execute → [SUB-AGENT-TASK-COMPLETE] → Loop
```

---

## 🚀 Commands

### /run Workflow (Deployment)
```bash
/run local       # Local dev (safe, free)
/run staging     # Staging (real ICP, notify Вітальон)
/run production  # Production (EXPLICIT APPROVAL REQUIRED)
```

### Autonomous Workflows
```
DR  # Develop + Review (fully autonomous)
AR  # Adversarial Review (fully autonomous)
```

### Orchestrator Menu
```
LS  # List sub-agents
SS  # System status
VH  # View history
CH  # Chat
DA  # Dismiss
```

---

## 🔄 Autonomous Protocol (DR/AR)

### Task Lifecycle
```
NEEDS_DEV → Implement → NEEDS_REVIEW → Amos → NEEDS_QA → QA Bot → VERIFIED
     ↑                                                              ↓
     └──────────── NEEDS_FIX ←───────┴─── (if issues) ──────────────┘
```

### Loop Until Complete
```
Step 2: Completion Check? 
  → YES → Step 6: Story Sync → Step 7: Exit
  → NO  → Step 3: Identify Task → Step 4: Execute → Step 5: Complete → GOTO Step 2
```

### Critical Rule
> "[SUB-AGENT-TASK-COMPLETE] signal is NOT the end. It's the trigger to CONTINUE."

---

## 📁 Critical Files

### Safety & Assets
- `memory/CRYPTO_MARKET_SAFETY_VAULT.md`
- `memory/ENVIRONMENT_SAFETY_MANIFEST.md`
- `memory/AGENT_SAFETY_GUIDELINES.md`
- `_bmad/my-custom-agents/data/safety-protocol.md`

### Flutter & ICP
- `_bmad/my-custom-agents/data/flutter-rules.md`
- `_bmad/my-custom-agents/data/flutter-driver-mcp-guide.md`

### Workflows
- `_bmad/my-custom-agents/data/protocols/autonomous_protocol.md`
- `_bmad/my-custom-agents/data/protocols/sub-agent-manifest.yaml`
- `_bmad/my-custom-agents/workflows/run/workflow.md`

---

## 🎯 Flutter Driver MCP (Proven Method)

### 5 Critical Rules
1. **Profile Mode** — `--profile` on macOS
2. **Separate Entrypoint** — `lib/main_driver.dart`
3. **Init Order** — `enableFlutterDriverExtension()` FIRST
4. **Wait for DTD** — `--print-dtd`, wait for ws://
5. **ScreenUtil** — MUST wrap in `ScreenUtilInit`

### Command
```bash
flutter run -d macos --profile -t lib/main_driver.dart --print-dtd
```

---

## ⚡ Quick Status Check

Before ANY operation:
```
[ ] Identity verified: dfx identity whoami
[ ] Network confirmed: local vs ic
[ ] Environment set: local/staging/production
[ ] If mainnet: Approval from Вітальон
[ ] Using /run workflow
```

---

## 🆘 Emergency

**Wrong identity used?**
→ STOP immediately, check what was done, notify Вітальон

**Lost canister IDs?**
→ Check backups: `crypto_market/.dfx/backups/`, `memory/canister_ids.json.backup.*`

**Accidental mainnet deploy?**
→ Document what was deployed: `dfx canister status <canister> --network ic`
→ Assess impact, contact Вітальон

---

*Flutter Orchestrator ready. Maestro Coordinator active.*
