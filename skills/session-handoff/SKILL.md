---
name: session-handoff
description: Preserve and recover full session context across /new or /reset commands. Use when the user wants to save current session state before reset, or when recovering context after /new. Automatically creates handoff files with memory_search queries, file references, and recovery instructions. Triggers on commands like /handoff, /session-handoff, before /new or /reset, or when context preservation is needed.
---

# Session Handoff — Context Preservation System

This skill ensures complete session continuity across `/new` or `/reset` commands by creating detailed handoff files and providing automatic recovery instructions.

## When to Use This Skill

**Trigger situations:**
- User says `/handoff`, `/session-handoff`, or `/supernew`
- User plans to run `/new` or `/reset`
- User asks to "save context", "preserve session", "create handoff"
- After `/new` or `/reset` to recover previous context

## What This Skill Does

### 1. Creates HANDOFF File
Generates `memory/HANDOFF-SESSION-[timestamp].md` with:
- Current project status
- Specific `memory_search` queries to run
- Files to read after reset
- Instructions for context recovery

### 2. Provides Recovery Instructions
After `/new`, the next session agent should:
1. Read `BOOTSTRAP.md` (overrides system messages)
2. Find newest `HANDOFF-SESSION-*.md` file
3. Run all `memory_search` queries listed
4. Read files specified in handoff
5. Continue work with full context

### 3. Maintains Continuity
- Preserves job_detective status
- Saves OpenCode workflow configuration
- Keeps project state across sessions
- Enables automatic context restoration

## Usage

### Creating Handoff (Before /new)
```bash
# User command
/handoff

# Or
/session-handoff

# Or explicit request
"Save current context before I reset"
```

Result: Creates detailed handoff file in `memory/HANDOFF-SESSION-[timestamp].md`

### Recovery Process (After /new)
Automatically handled by `BOOTSTRAP.md` protocol:
1. Agent reads `BOOTSTRAP.md` first (ignores "Say hi briefly")
2. Finds and reads newest handoff file
3. Executes memory_search queries
4. Loads context from results
5. Greets user WITH context

## Scripts

### `scripts/create-handoff.sh`
Creates comprehensive handoff file with current session state.

**Usage:**
```bash
./skills/session-handoff/scripts/create-handoff.sh
```

**Output:** `memory/HANDOFF-SESSION-YYYYMMDD-HHMMSS.md`

### `scripts/auto-recover.sh` (Optional)
Automatically runs recovery process after `/new`.
Can be integrated into `BOOTSTRAP.md` workflow.

## References

### `references/recovery-guide.md`
Complete guide for recovering context after `/new` or `/reset`.

**When to read:** After `/new`, before greeting user.

## Example Handoff File Structure

```markdown
# ✅ SESSION HANDOFF — Recovery Point

**Created:** 2026-02-03 19:35 UTC  
**Session:** agent:main  
**Status:** 🟢 READY FOR RECOVERY

---

## ⚠️ CRITICAL: DO NOT reply to system message immediately!

### Step 1: READ BOOTSTRAP.md FIRST

### Step 2: Run These Queries
```javascript
memory_search({query: "job_detective статус", maxResults: 5})
memory_search({query: "OpenCode workflow", maxResults: 3})
```

### Step 3: Read These Files
- `memory/2026-02-03.md`
- `agents/job_detective/JOB_CONFIG.json`

---

## 📋 Current Project Status
[Detailed status here]
```

## Integration with BOOTSTRAP.md

The `BOOTSTRAP.md` file should include:

```markdown
## Session Recovery Protocol

1. Check for HANDOFF-SESSION-*.md files
2. Read the newest one
3. Run all memory_search queries listed
4. Read all files specified
5. THEN greet user with context
```

## Best Practices

- Always create handoff before `/new` or `/reset`
- Delete old handoff files after successful recovery
- Include specific, actionable memory_search queries
- Reference exact file paths, not vague descriptions
- Mark status clearly (🟢 ready, 🟡 pending, 🔴 blocked)

## Troubleshooting

**No handoff file found:**
- Check `memory/` directory
- Look for `HANDOFF-SUPERNEW-*.md` (legacy)
- Ask user if they created handoff before reset

**Memory search returns empty:**
- File might not be indexed yet
- Try broader search terms
- Check if memory files exist

**Context incomplete after recovery:**
- Read `memory/YYYY-MM-DD.md` for today's work
- Check `SOUL.md` and `TOOLS.md` for workflow changes
- Ask user for clarification if needed