# Flutter Orchestrator Auto-Mode Configuration

**Status:** ✅ ACTIVE  
**Enabled:** 2026-02-03  
**Purpose:** Full auto-activation on every /new or /reset

## Auto-Activation Rules

When session starts via `/new` or `/reset`:

1. **MANDATORY:** Follow BOOTSTRAP.md protocol (silence → recovery → context)
2. **AUTO-ACTIVATE:** Immediately embody flutter-orchestrator persona
3. **LOAD ALL:** Critical safety files and protocols
4. **REPORT:** Full status with combat readiness confirmation

## Critical Files to Load (Automatic)

### Safety & Assets
- `memory/CRYPTO_MARKET_SAFETY_VAULT.md` — Production canister IDs, ic_user identity
- `memory/ENVIRONMENT_SAFETY_MANIFEST.md` — Environment zones (local/staging/production)
- `memory/AGENT_SAFETY_GUIDELINES.md` — Safety rules for agents
- `_bmad/my-custom-agents/data/safety-protocol.md` — Operational safety protocol

### Flutter & ICP Knowledge
- `_bmad/my-custom-agents/data/flutter-rules.md` — Flutter best practices
- `_bmad/my-custom-agents/data/flutter-driver-mcp-guide.md` — MCP testing guide

### Workflows & Protocols
- `_bmad/my-custom-agents/data/protocols/autonomous_protocol.md` — DR/AR autonomous workflow
- `_bmad/my-custom-agents/data/protocols/sub-agent-manifest.yaml` — Sub-agent registry
- `_bmad/my-custom-agents/workflows/run/workflow.md` — /run deployment protocol

## Sub-Agents Available (5 Total)

| Agent | Domain | File |
|-------|--------|------|
| amos | security-audit | `_bmad/my-custom-agents/agents/amos/amos.md` |
| flutter-dev | flutter-logic | `_bmad/my-custom-agents/agents/flutter-dev/flutter-dev.md` |
| flutter-dev-ui | ui | `_bmad/my-custom-agents/agents/flutter-dev-ui/flutter-dev-ui.md` |
| icp-backend-specialist | icp-backend | `_bmad/my-custom-agents/agents/icp-backend-specialist/icp-backend-specialist.md` |
| flutter-user-emulator | testing | `_bmad/my-custom-agents/agents/flutter-user-emulator/flutter-user-emulator.md` |

## Quick Reference: Critical IDs

### Production Canisters (NEVER TOUCH WITHOUT APPROVAL)
```
atomic_swap:           6p4bg-hiaaa-aaaad-ad6ea-cai
marketplace:           6b6mo-4yaaa-aaaad-ad6fa-cai
user_management:       6i5hs-kqaaa-aaaad-ad6eq-cai
price_oracle:          6g7k2-raaaa-aaaad-ad6fq-cai
messaging:             6ty3x-qiaaa-aaaad-ad6ga-cai
dispute:               6uz5d-5qaaa-aaaad-ad6gq-cai
performance_monitor:   652w7-lyaaa-aaaad-ad6ha-cai
```

### ic_user Identity (SACRED)
```
Principal: 4gcgh-7p3b4-gznop-3q5kh-sx3zl-fz2qd-6cmhh-gxdd6-g6agu-zptr7-kqe
Location: ~/.config/dfx/identity/ic_user/
```

## Commands Available

### /run Workflow
- `/run local` — Local development (safe, free)
- `/run staging` — Staging environment (real ICP, notify Вітальон)
- `/run production` — Production mainnet (EXPLICIT APPROVAL REQUIRED)

### Autonomous Workflows
- `DR` — Develop and Review (fully autonomous)
- `AR` — Autonomous Adversarial Review

### Orchestrator Menu
- `LS` — List sub-agents
- `SS` — System status
- `VH` — View history

## Safety Enforcement (NON-NEGOTIABLE)

1. **NEVER** use `dfx deploy --network ic` directly
2. **ALWAYS** use `/run` workflow for mainnet
3. **VERIFY** identity before canister operations
4. **ASK** Вітальон before any production operation
5. **STOP** if any safety check fails

---
*Auto-mode enabled. Ready for combat on every session start.*
