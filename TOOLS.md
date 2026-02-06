# Browser Setup & Usage Guide

## Installation
```bash
clawdbot browser extension install
# Copies extension to ~/.clawdbot/browser/chrome-extension
```

## Chrome Extension Setup (One-time)
1. Open Chrome → chrome://extensions/
2. Enable "Developer mode" (top right)
3. Click "Load unpacked"
4. Select: ~/.clawdbot/browser/chrome-extension
5. Pin "Clawdbot Browser Relay" to toolbar

## Usage Workflow

### CRITICAL: Must attach extension BEFORE using browser tools

1. **Open Chrome manually** (or via `open -a "Google Chrome"`)
2. **Navigate to desired website**
3. **CLICK Clawdbot Browser Relay icon** (badge shows "ON")
4. **THEN use browser tools:**

```javascript
// Open new tab
browser({action:"open", targetUrl:"https://example.com"})

// Get page snapshot
browser({action:"snapshot", targetId:"...", refs:"aria"})

// Click element
browser({action:"act", targetId:"...", request:{kind:"click", ref:"e14"}})
```

## Profiles

### profile="chrome" (recommended)
- Uses your main Chrome with extension
- Requires manual click on extension icon
- Full functionality after attachment

### profile="clawd" (isolated)
- Separate Chrome instance
- No extension needed
- Limited functionality (no snapshot without extension)

## Common Issues

### "Error: Chrome extension relay is running, but no tab is connected"
**Solution:** Click the Clawdbot Browser Relay icon on the active tab (badge must show "ON")

### Extension not loading
**Solution:** Check chrome://extensions/ for errors, reload extension

## Key Points
- Extension requires USER INTERACTION (cannot click programmatically)
- Must attach to EACH tab separately
- Badge "ON" = ready to use
- Profile "chrome" = best experience

## Working Example Flow
```javascript
// 1. Open Chrome manually
exec({command:"open -a 'Google Chrome' https://google.com"})

// 2. User clicks extension icon (badge ON)

// 3. Then use browser tools
browser({action:"snapshot", refs:"aria"})
browser({action:"act", request:{kind:"type", ref:"e14", text:"query"}})
browser({action:"act", request:{kind:"click", ref:"e17"}})
```

---

# Vector Memory (REQUIRED)

## Critical Tool: memory_search

**ALWAYS use memory_search before answering questions about:**
- Prior work, decisions, dates
- People, preferences, todos
- Project status and blockers
- Previous sessions context

### How to use:
```javascript
// Search for project status
memory_search({query: "latest project status", maxResults: 5})

// Search for user's current tasks  
memory_search({query: "Vitalii current tasks", maxResults: 5})

// Search for recent decisions
memory_search({query: "recent decisions", maxResults: 3})
```

### When to use (REQUIRED):
1. **At session start** — query="latest project status"
2. **When user asks about previous work** — search before answering
3. **When resuming projects** — search for project name + status
4. **Before making decisions** — search for related previous decisions

### After search:
- Use memory_get to read specific snippets
- Mention what you found in your response
- If low confidence after search, say you checked

**WARNING:** Not using memory_search = losing context = repeating mistakes

---

# Web Search Alternatives

## Option 1: DuckDuckGo Lite (Recommended - No API Key)
Uses `web_fetch` to search via DuckDuckGo Lite:

```javascript
// Search query
web_fetch({
  url: "https://lite.duckduckgo.com/lite/?q=your+search+query",
  maxChars: 2000
})
```

**Pros:** No API key, fast (~1 sec), good results  
**Cons:** Limited to ~5 results, no advanced filters

## Option 2: Brave Search (Requires API Key)
Official web_search tool:
```javascript
web_search({query: "search term", count: 5})
```
**Setup:** Get API key at https://api.search.brave.com/app/keys

## Option 3: Browser + Google
Open Google in browser and extract results:
```javascript
// 1. Open Google
browser({action:"open", targetUrl:"https://google.com/search?q=query"})

// 2. Get snapshot with results
browser({action:"snapshot", refs:"aria"})
```

**Recommendation:** Use DuckDuckGo Lite for quick searches, Brave for advanced search needs.

---

# Sub-Agents (MiniMax M2.1) — Primary Coding Tool

**This is my PRIMARY tool for code generation.**

## Architecture: Brain vs Hands

```
┌─────────────────────────────────────────────────────────────────┐
│                    MAIN AGENT (Kimi/Claude)                      │
│                    ME - Architect/Orchestrator                   │
│                                                                  │
│  Responsibilities:                                               │
│  - Analyze task from user                                        │
│  - Decompose into sub-tasks                                      │
│  - Choose specialized sub-agent                                  │
│  - Spawn via sessions_spawn()                                    │
│  - Review and integrate results                                  │
└──────────────────────────┬───────────────────────────────────────┘
                           │ sessions_spawn()
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              SUB-AGENT (MiniMax M2.1 - cheap/fast)               │
│                                                                  │
│  Responsibilities:                                               │
│  - Execute specific task                                         │
│  - Isolated session (agent:main:subagent:<uuid>)                │
│  - Receives AGENTS.md + TOOLS.md + project context              │
│  - Announces result back to chat                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Workflow

```
User (coding task)
    ↓
Me (analyze + decompose + design)
    ↓
SPAWN sub-agent (sessions_spawn with MiniMax M2.1)
    ↓
Sub-agent executes in isolated session
    ↓
Me (review + iterate + integrate)
    ↓
Result
```

## Usage

```javascript
// Spawn a sub-agent for specific task
sessions_spawn({
  task: `
## Role: flutter-dev
## Task: Fix compilation errors in lib/auth.dart
## Requirements:
- Fix all type mismatches
- Follow existing code style
- Run flutter analyze after fixes
`,
  runTimeoutSeconds: 300
})
```

## When NOT to use sub-agents:
- ❌ Limits reached (tokens, money)
- ❌ Task requires architectural analysis (complex decisions)
- ❌ Context too specific for auto-generation
- ❌ Critical bug — faster to do myself

## Rules
1. **Architecture first** — I analyze, then give clear prompt
2. **Specific tasks** — not "make it better", but "extract X into separate function Y"
3. **Review** — check before showing result
4. **Iterate** — until quality is high
