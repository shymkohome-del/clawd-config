---
name: session-handoff
description: Preserve and recover full session context across /new or /reset commands. Use when the user wants to save current session state before reset, or when recovering context after /new. Automatically creates handoff files with memory_search queries, file references, and recovery instructions. Triggers on commands like /handoff, /session-handoff, before /new or /reset, or when context preservation is needed.
---

# Session Handoff — Context Preservation System

This skill ensures complete session continuity across `/new` or `/reset` commands by creating detailed handoff files and providing automatic recovery instructions.

## Smart Handoff Principle

**Critical:** `/handoff` ALWAYS saves FULL context, regardless of `/compact` state.
- `/compact` = UI cleanup (creates summary for display only)
- `/handoff` = Persistence (saves complete context for recovery)
- Handoff reads **original files**, not summary
- Context restored after `/new` is always complete

## When to Use This Skill

**Trigger situations:**
- User says `/handoff`, `/session-handoff`, or `/supernew`
- User plans to run `/new` or `/reset`
- User asks to "save context", "preserve session", "create handoff"
- After `/new` or `/reset` to recover previous context

**IMPORTANT:** Even if `/compact` was used, still save FULL context in handoff.

## What This Skill Does

### 1. Smart Handoff Protocol
When user runs `/handoff`:

```javascript
// Step 1: Check if session was compacted
const wasCompacted = checkForSummaryInHistory();

// Step 2: Read ORIGINAL files (not summary!)
read("SOUL.md")
read("AGENTS.md") 
read("TOOLS.md")
read("memory/YYYY-MM-DD.md")
// + any project-specific files mentioned in session

// Step 3: Generate specific memory_search queries
// Based on ACTUAL work done, not generic templates
const queries = generateQueriesFromContext();

// Step 4: Create handoff file with full context
// Step 5: Update memory/YYYY-MM-DD.md (with dedup)
```

### 2. Creates HANDOFF File
Generates `memory/HANDOFF-SESSION-[timestamp].md` with:
- Current project status (from original files, not summary)
- Specific `memory_search` queries based on actual work
- Files to read after reset
- Recovery instructions
- **was_compacted** flag (for logging only)

### 2. Provides Recovery Instructions
After `/new`, the next session agent should:
1. Read `BOOTSTRAP.md` (overrides system messages)
2. Find newest `HANDOFF-SESSION-*.md` file
3. Run all `memory_search` queries listed
4. Read files specified in handoff
5. Continue work with full context

### 3. Handles /compact Correctly
**Smart Handoff ignores `/compact` summary:**
- Summary is for UI only (displays truncated history)
- Handoff reads original source files
- Full context preserved even after `/compact`
- No data loss guaranteed

### 4. Deduplication
Before appending to `memory/YYYY-MM-DD.md`:
- Check if similar entry exists (last 1 hour)
- If yes: update existing entry
- If no: append new entry
- Prevent duplicate handoff records

### 5. Maintains Continuity
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
**was_compacted:** true/false (for logging only - full context preserved)

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
[Detailed status here - from ORIGINAL files, not summary]
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

### Smart Handoff Rules
- **ALWAYS read original files** — never use summary as source
- **ALWAYS save full context** — regardless of `/compact` state
- **Generate specific queries** — based on actual work, not templates
- **Check was_compacted** — log it, but ignore for saving
- **Deduplicate memory writes** — prevent duplicate entries

### General Practices
- Always create handoff before `/new` or `/reset`
- Delete old handoff files after successful recovery
- Include specific, actionable memory_search queries
- Reference exact file paths, not vague descriptions
- Mark status clearly (🟢 ready, 🟡 pending, 🔴 blocked)

## Implementation for AI

When user runs `/handoff`, AI must:

```javascript
// 1. Detect if session was compacted
const sessionHistory = getSessionHistory();
const wasCompacted = sessionHistory.includes("<summary>");

// 2. Read ORIGINAL source files (NOT summary!)
const soul = read("SOUL.md");
const agents = read("AGENTS.md");
const tools = read("TOOLS.md");
const todayMemory = read("memory/YYYY-MM-DD.md");

// 3. Generate context-specific queries
const queries = [];
if (soul.includes("OpenCode")) {
  queries.push("OpenCode MiniMax workflow configuration");
}
if (todayMemory.includes("crypto_market")) {
  queries.push("crypto_market project status");
}

// 4. Create handoff with FULL context
writeHandoffFile({
  wasCompacted, // log only
  queries,
  filesToRead: ["SOUL.md", "AGENTS.md", "memory/YYYY-MM-DD.md"],
  fullContext: true // always true
});

// 5. Update memory with dedup
deduplicatedAppend("memory/YYYY-MM-DD.md", handoffInfo);
```

**Key point:** was_compacted is ONLY for logging. Full context always saved.

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