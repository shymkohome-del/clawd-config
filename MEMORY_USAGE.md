# MEMORY_USAGE.md - How to Use Memory Properly

## ⚠️ THIS IS YOUR BRAIN - USE IT

You have amnesia every session. These files are your continuity. **USE THEM.**

---

## Quick Checklist (Before Every Response)

- [ ] Is user asking about previous work? → **memory_search**
- [ ] Is this about a project? → **memory_search**
- [ ] Is this about decisions/status? → **memory_search**
- [ ] Did I check SESSION_LOG files? → **read them**

---

## Tools Available

### 1. memory_search (PRIMARY)
**Use for:** Finding context about anything from past sessions

```javascript
// Project status
memory_search({query: "crypto_market Epic 4.5 статус", maxResults: 5})

// User's tasks
memory_search({query: "Вітальон поточні задачі", maxResults: 5})

// Recent decisions
memory_search({query: "останні рішення", maxResults: 3})

// Specific topics
memory_search({query: "Tron TRC-20 implementation", maxResults: 5})
```

**When to use:**
- At session start (MANDATORY)
- When user mentions any project name
- Before answering "what's the status?" questions
- Before continuing work on anything

### 2. memory_get (SECONDARY)
**Use for:** Reading specific file snippets after search

```javascript
// After memory_search gives you path and line numbers
memory_get({path: "memory/2026-01-30.md", from: 1, lines: 50})
```

### 3. File Reading (CRITICAL)
**Read these FIRST on every /new or /reset:**
1. `SESSION_LOG_*.md` files (critical project state)
2. `*HANDOFF*.md` files (session continuity)
3. `SOUL.md` (who you are)
4. `USER.md` (who you're helping)
5. `MEMORY.md` (curated long-term memory)
6. `memory/YYYY-MM-DD.md` (today + yesterday)

---

## Common Mistakes (DON'T DO THIS)

❌ **WRONG:**
> User: "Як там наш проект?"
> You: "З чим саме допомогти?" ← ТИ НЕ ЗРОБИВ memory_search!

✅ **CORRECT:**
> User: "Як там наш проект?"
> You: [memory_search: "останній проект статус"]
> You: "Знайшов! Ми працювали над Epic 4.5, Tron готовий, Bitcoin заблоковано через 0 ICP. Що будемо робити?"

❌ **WRONG:**
> User: "Продовжимо crypto_market"
> You: "Окей, що саме робити?" ← ТИ НЕ ПРОЧИТАВ SESSION_LOG!

✅ **CORRECT:**
> User: "Продовжимо crypto_market"
> You: [read: SESSION_LOG_EPIC_4_5_CURRENT.md]
> You: [memory_search: "crypto_market статус"]
> You: "Знайшов статус: Tron TRC-20 готовий, Bitcoin testing заблоковано (0 ICP). Потрібно купити ICP чи працювати над чимось іншим?"

---

## Project-Specific Memory

### crypto_market (Epic 4.5)
**Always search:**
- "Epic 4.5 статус"
- "crypto_market блокер"
- "ICP balance" 
- "Bitcoin testing"

**Critical files:**
- `/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/SESSION_LOG_EPIC_4_5_CURRENT.md`
- `/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/SESSION_LOG_EPIC_4_5.md`
- `PROJECT_STATUS.md`

### ICP Tokens Blocker (PERMANENT until resolved)
```
Status: CRITICAL
Issue: 0 ICP on all identities
Required: 0.5 ICP (~$5-10)
Address: 4gcgh-7p3b4-gznop-3q5kh-sx3zl-fz2qd-6cmhh-gxdd6-g6agu-zptr7-kqe
Action: Buy on Binance/Coinbase
Blocks: Bitcoin, Ethereum, BSC testing
```

---

## Auto-Sync Settings

Vector memory syncs automatically:
- `onSessionStart: true` — sync at /new or /reset
- `onSearch: true` — sync before memory_search  
- `watch: true` — sync on file changes

**BUT:** If files created outside session, may need manual trigger.

---

## Emergency Recovery

**If you have no context:**
1. Run: `memory_search({query: "останній проект статус", maxResults: 10})`
2. Run: `ls -la SESSION_LOG*.md` and read them
3. Run: `cat MEMORY.md | head -100`
4. Ask user: "Знайшов частину контексту, підкажи деталі?"

---

## Summary

**memory_search = YOUR MEMORY**
**Not using it = Being amnesiac**
**Using it = Being helpful**

**Choose wisely.**

---
*Last updated: 2026-01-31*
*Required reading: Every session*
