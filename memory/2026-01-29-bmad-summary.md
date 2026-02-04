# BMAD Framework - Executive Summary

**Date Researched:** 2026-01-29  
**Project:** crypto_market  
**Version:** 6.0.0-alpha.23  
**Author:** bmadcode (https://github.com/bmadcode/bmad-method)

---

## What is BMAD?

**BMAD (Business Model Agent-Driven)** is an AI-powered development framework that uses specialized agents with defined personas to manage software projects through systematic workflows. It combines project management, implementation guidance, and quality assurance into an integrated system.

---

## Core Architecture

BMAD consists of 4 hierarchical modules:

### 1. CORE Module (`_bmad/core/`)
The framework's operating system.

**Key Files:**
- `_bmad/core/config.yaml` - Core configuration
- `_bmad/core/tasks/workflow.xml` - **THE workflow execution engine (CORE OS)**
- `_bmad/core/agents/bmad-master.md` - Master orchestrator agent

**Workflows:**
- `advanced-elicitation/` - Deep requirements discovery
- `brainstorming/` - Ideation workflows
- `party-mode/` - Collaborative creative sessions

### 2. BMM - Business Model Module (`_bmad/bmm/`)
Full project lifecycle management.

**Config:** `_bmad/bmm/config.yaml`
```yaml
project_name: crypto_market
user_skill_level: intermediate
planning_artifacts: "{project-root}/_bmad-output/planning-artifacts"
imlementation_artifacts: "{project-root}/_bmad-output/implementation-artifacts"
project_knowledge: "{project-root}/docs"
```

**Agents (9 specialized roles):**
| Agent | Role | Icon |
|-------|------|------|
| PM | Product Manager | 📋 |
| Dev | Developer | 💻 |
| Architect | System Architect | 🏗️ |
| Analyst | Business Analyst | 📊 |
| SM | Scrum Master | 🔄 |
| UX Designer | UX/UI Designer | 🎨 |
| Tech Writer | Technical Writer | 📝 |
| TEA | Test Engineering Agent | 🧪 |
| Quick Flow Solo Dev | Solo developer mode | 🚀 |

**Workflow Categories:**
- `1-analysis/` - Research and problem definition
- `2-plan-workflows/` - PRD creation, sprint planning
- `3-solutioning/` - Epics, stories, architecture
- `4-implementation/` - Dev stories, code review, course correction

### 3. BMB - BMAD Module Builder (`_bmad/bmb/`)
Tools for creating custom BMAD components.

**Purpose:** Build new agents, workflows, and modules

**Tri-Modal Pattern:**
- **Create** - Build from scratch
- **Edit** - Modify existing
- **Validate** - Review and improve

**Key Workflows:**
- `agent/` - Create/edit/validate agents
- `workflow/` - Create/edit/validate workflows
- `module/` - Create complete modules

### 4. CIS - Creative Intelligence System (`_bmad/cis/`)
Creative problem-solving and innovation.

**Agents:** Storyteller, Creative Problem Solver, Design Thinking Coach, Innovation Strategist, Presentation Master, Brainstorming Coach

---

## Workflow System

### Core Execution Engine

**File:** `_bmad/core/tasks/workflow.xml`

This is the heart of BMAD. It:
- Resolves variables from config
- Executes steps in exact order
- Handles user prompts
- Saves template outputs
- Manages state

### Workflow File Structure

```yaml
# workflow.yaml
name: workflow-name
description: "What this workflow does"
config_source: "{project-root}/_bmad/{module}/config.yaml"
output_folder: "{config_source}:output_folder"
installed_path: "{project-root}/_bmad/{module}/workflows/{name}"
instructions: "{installed_path}/instructions.xml"
standalone: true
```

```xml
<!-- instructions.xml -->
<workflow>
  <critical>MANDATORY rules</critical>
  
  <step n="1" goal="Step objective">
    <action>What to do</action>
    <check if="condition">
      <action>Conditional action</action>
    </check>
    <ask>Prompt user and wait</ask>
  </step>
  
  <step n="2" goal="Next objective">
    <template-output>Generate content</template-output>
  </step>
</workflow>
```

### Supported XML Tags

| Tag | Purpose |
|-----|---------|
| `<step n="X">` | Numbered step |
| `<action>` | Required action |
| `<check if="condition">` | Conditional block |
| `<ask>` | User input prompt |
| `<invoke-workflow>` | Call another workflow |
| `<template-output>` | Save content checkpoint |
| `<goto step="X">` | Jump to step |
| `<critical>` | Non-skippable instruction |

### Execution Modes

- **Normal** - Full user interaction at each step
- **YOLO** - Skip confirmations, auto-produce output

---

## Episode System (Пізоди)

**Episodes** are discrete, trackable work units.

### Types

1. **Story Episodes** - User-facing features (`docs/stories/story-{epic}-{num}.md`)
2. **Task Episodes** - Implementation units within stories
3. **Workflow Episodes** - Steps within workflows
4. **Review Episodes** - Code review cycles

### Story File Structure

```markdown
# Story X.Y: Title

## Status
{ready-for-dev | in-progress | review | done}

## Dependencies
- story-id - Description

## Story
As a [role], I want [feature], so that [benefit].

## Acceptance Criteria
1. Given [context], when [action], then [result]. [Source: doc.md#section]

## Tasks / Subtasks
- [ ] Task 1 (AC: 1)
  - [ ] Subtask 1.1

## Dev Notes
### Data Models
### API Specifications
### Testing Requirements

## Dev Agent Record
- Implementation Plan:
- Completion Notes:
- File List:

## Change Log
| Date | Version | Description | Author |

## QA Results
- AC1 — {Pass/Fail}: Evidence
```

### Status Lifecycle

```
ready-for-dev → in-progress → review → done
```

| Status | Meaning |
|--------|---------|
| `ready-for-dev` | Defined, awaiting developer |
| `in-progress` | Actively being worked |
| `review` | Done, awaiting QA |
| `done` | QA approved, complete |

### Sprint Status Tracking

**File:** `_bmad-output/implementation-artifacts/sprint-status.yaml`

```yaml
epic_status:
  epic-1: in-progress
  epic-2: ready

development_status:
  1-1-register: review
  1-2-profile: in-progress
  1-3-login: ready-for-dev
```

### Dev Story Workflow (Episode Execution)

**Location:** `_bmad/bmm/workflows/4-implementation/dev-story/`

**10-Step Process:**

1. **Find Story** - Locate next `ready-for-dev` story
2. **Load Context** - Read story, project-context.md
3. **Detect Review** - Check if resuming after review
4. **Mark In-Progress** - Update sprint status
5. **Implement** - Red-Green-Refactor cycle
6. **Author Tests** - Unit, integration, e2e
7. **Run Validations** - Full test suite
8. **Mark Complete** - Only when ALL gates pass
9. **Mark for Review** - Update status
10. **Completion** - Summarize for user

### Red-Green-Refactor Cycle

**Every task follows TDD:**

```
RED: Write failing test
     ↓
GREEN: Write minimal code to pass
     ↓
REFACTOR: Improve structure while tests green
     ↓
REPEAT for next task
```

**MANDATORY:** Never skip the RED phase!

---

## Agent Architecture

### Agent File Format

Agents are Markdown with embedded XML:

```markdown
---
name: "agent-id"
description: "Description"
---

You must fully embody this agent's persona...

```xml
<agent id="agent-id" name="Name" title="Title" icon="emoji">
<activation critical="MANDATORY">
  <step n="1">Load persona</step>
  <step n="2">Load config.yaml (CRITICAL)</step>
  <step n="3">Remember user name</step>
  <step n="4">Show greeting + menu</step>
  <step n="5">Wait for input</step>
  <step n="6">Execute selection</step>
</activation>

<persona>
  <role>Functional role</role>
  <identity>Background/expertise</identity>
  <communication_style>How to communicate</communication_style>
  <principles>Guiding principles</principles>
</persona>

<menu>
  <item cmd="XX" workflow="path">[XX] Description</item>
  <item cmd="YY" exec="path">[YY] Description</item>
  <item cmd="ZZ" action="action-id">[ZZ] Description</item>
</menu>

<menu-handlers>
  <handlers>
    <handler type="workflow">How to execute workflows</handler>
    <handler type="exec">How to execute files</handler>
    <handler type="action">How to handle actions</handler>
  </handlers>
</menu-handlers>
```

### Activation Sequence

1. Load agent file
2. **Load config.yaml (MANDATORY)**
3. Extract variables (user_name, communication_language, output_folder)
4. Show greeting with user's name
5. Display numbered menu
6. **WAIT for user input**
7. Execute selected item

### Menu Item Types

| Type | Attribute | Purpose |
|------|-----------|---------|
| Workflow | `workflow="path"` | Execute via workflow.xml |
| Exec | `exec="path"` | Execute markdown file |
| Action | `action="id"` | Execute inline action |
| Template | `tmpl="path"` | Use template |
| Data | `data="path"` | Pass context |

### Universal Shortcuts

| Cmd | Action |
|-----|--------|
| `MH` | Menu Help |
| `CH` | Chat with Agent |
| `PM` | Party Mode |
| `DA` | Dismiss Agent |

---

## Configuration System

### Module Config (`config.yaml`)

```yaml
# Required
user_name: "User Name"
communication_language: "English, Ukrainian"
document_output_language: "English"
output_folder: "{project-root}/_bmad-output"

# BMM-specific
project_name: "project_name"
user_skill_level: beginner|intermediate|advanced
planning_artifacts: "{project-root}/_bmad-output/planning-artifacts"
imlementation_artifacts: "{project-root}/_bmad-output/implementation-artifacts"
project_knowledge: "{project-root}/docs"
```

### Variable Resolution

| Pattern | Example | Resolves To |
|---------|---------|-------------|
| `{project-root}` | `{project-root}/_bmad` | Absolute path |
| `{config_source}:key` | `{config_source}:user_name` | Config value |
| `{installed_path}` | `{installed_path}/file.xml` | Workflow path |
| `{{variable}}` | `{{story_path}}` | Runtime variable |
| `{{date}}` | Output files | Current timestamp |

---

## Using BMAD for Development

### Entry Points

**Via Gemini Code Assist:**
```
/bmad-agent-core-bmad-master    # Master orchestrator
/bmad-agent-bmm-pm              # Product Manager
/bmad-agent-bmm-dev             # Developer
/bmad-workflow-bmm-create-story # Create story
```

**Via Claude Code:**
```
/start-app          # One command startup
/deploy-canisters   # Deploy only
/sync-config        # Sync canister IDs
/stop-all           # Clean shutdown
```

### Common Workflows

| Task | Agent | Command | Workflow |
|------|-------|---------|----------|
| Create PRD | PM | `CP` | PRD Create Mode |
| Validate PRD | PM | `VP` | PRD Validate Mode |
| Create Stories | PM | `ES` | Create Epics & Stories |
| Check Readiness | PM | `IR` | Implementation Readiness |
| Implement Story | Dev | `DS` | Dev Story |
| Code Review | Dev | `CR` | Code Review |
| Sprint Status | Any | `WS` | Workflow Status |

### Development Flow

```
1. PM Agent: Create PRD
        ↓
2. PM Agent: Create Epics & Stories
        ↓
3. Dev Agent: Execute Dev Story
   - Finds next ready story
   - Implements with R-G-R
   - Marks for review
        ↓
4. Dev Agent: Code Review
   - Review with fresh context
   - Creates action items
        ↓
5. Dev Agent: Resume Dev Story
   - Fixes review items
   - Completes story
        ↓
6. Repeat from step 3
```

---

## Key Patterns & Best Practices

### Documentation Patterns

- **Source Attribution:** `[Source: doc.md#section]`
- **Sharded Documents:** Split large docs logically
- **Index Files:** `INDEX.md` for navigation
- **Change Logs:** Track all modifications

### Code Quality Patterns

- **No print():** Use proper logging
- **Result Types:** Error handling via Result/Option
- **Input Validation:** At all boundaries
- **Principal Validation:** In canister functions

### Testing Patterns

- **Test-First:** RED phase mandatory
- **Three Levels:** Unit, integration, e2e
- **Regression Prevention:** Full suite runs always
- **Coverage:** All paths including errors

---

## Critical Rules (No Exceptions)

1. **ALWAYS load config.yaml BEFORE any output**
2. **NEVER skip workflow steps**
3. **ALWAYS save outputs after EACH template-output**
4. **NEVER use offset/limit reading workflow files**
5. **ALWAYS stay in character until exit**
6. **NEVER mark tasks complete unless tests pass**
7. **ALWAYS communicate in configured language**
8. **NEVER pre-load future step files**
9. **ALWAYS halt at menus and wait for input**
10. **NEVER lie about test status**

---

## File Locations

### Framework
```
_bmad/
├── core/
│   ├── config.yaml
│   ├── tasks/workflow.xml
│   ├── agents/bmad-master.md
│   └── workflows/
├── bmm/
│   ├── config.yaml
│   ├── agents/{pm,dev,architect,...}.md
│   └── workflows/{1-analysis,2-plan,3-solutioning,4-implementation}/
├── bmb/
│   ├── config.yaml
│   ├── agents/agent-builder.md
│   └── workflows/{agent,workflow,module}/
└── cis/
    ├── config.yaml
    ├── agents/
    └── workflows/
```

### Output
```
_bmad-output/
├── planning-artifacts/
│   ├── epics.md
│   └── stories/
├── implementation-artifacts/
│   ├── sprint-status.yaml
│   └── retrospectives/
└── bmb-creations/
```

### Integration
```
.gemini/commands/           # Gemini Code Assist
.claude/                    # Claude Code
_bmad-output/               # Generated artifacts
docs/stories/               # Story files
docs/prd/                   # Product requirements
```

---

## Summary

BMAD is a comprehensive framework for AI-driven software development combining:

- **Structured workflows** for consistency
- **Specialized agents** for expertise
- **Episode tracking** for visibility
- **Documentation-first** approach
- **Test-driven development** for quality
- **Modular architecture** for extensibility

The framework enables systematic, high-quality software development with clear accountability, comprehensive documentation, and integrated quality assurance.
