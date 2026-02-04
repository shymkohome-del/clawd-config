# BMAD Framework - Comprehensive Documentation

## Overview

**BMAD (Business Model Agent-Driven)** is an AI-powered, agent-driven development framework designed for systematic software project management, planning, and implementation. The framework was discovered in the `crypto_market` project at `/Volumes/workspace-drive/projects/other/crypto_market`.

**Version:** 6.0.0-alpha.23  
**Author:** bmadcode  
**Project URL:** https://github.com/bmadcode/bmad-method

---

## Core Philosophy

BMAD operates on several key principles:

1. **Agent-Driven Development** - AI agents with specific personas handle different aspects of project work
2. **Systematic Workflows** - Structured, step-by-step processes for all activities
3. **Collaborative AI-Human Interaction** - Agents facilitate conversations rather than replace human decision-making
4. **Documentation-First** - All outputs are properly documented and tracked
5. **Modular Architecture** - Framework is composed of independent, composable modules
6. **Runtime Resource Loading** - Resources are loaded just-in-time, never pre-loaded

---

## Framework Architecture

### Module Structure

The BMAD framework is organized into hierarchical modules:

```
_bmad/
├── core/               # Core framework components (OS layer)
├── bmm/                # Business Model Module (project management)
├── bmb/                # BMAD Module Builder (create custom modules)
├── cis/                # Creative Intelligence System (problem-solving)
└── my-custom-agents/   # User-defined custom agents
```

### 1. CORE Module

**Purpose:** The foundational operating system for BMAD workflows

**Location:** `_bmad/core/`

**Components:**
- **Agents:** Master orchestrator (`bmad-master.md`)
- **Workflows:**
  - `advanced-elicitation/` - Deep requirements discovery
  - `brainstorming/` - Ideation workflows
  - `party-mode/` - Collaborative creative sessions
- **Tasks:** Core execution engine (`workflow.xml`)
- **Resources:** Shared utilities and configurations

**Key Files:**
- `_bmad/core/config.yaml` - Core configuration
- `_bmad/core/tasks/workflow.xml` - THE workflow execution engine (CORE OS)

### 2. BMM (Business Model Module)

**Purpose:** Full project lifecycle management from ideation to deployment

**Location:** `_bmad/bmm/`

**Configuration:**
```yaml
project_name: crypto_market
user_skill_level: intermediate
planning_artifacts: "{project-root}/_bmad-output/planning-artifacts"
imlementation_artifacts: "{project-root}/_bmad-output/implementation-artifacts"
project_knowledge: "{project-root}/docs"
```

**Agents (Project Roles):**
| Agent | File | Role | Icon |
|-------|------|------|------|
| PM | `pm.md` | Product Manager | 📋 |
| Dev | `dev.md` | Developer | 💻 |
| Architect | `architect.md` | System Architect | 🏗️ |
| Analyst | `analyst.md` | Business Analyst | 📊 |
| SM | `sm.md` | Scrum Master | 🔄 |
| UX Designer | `ux-designer.md` | UX/UI Designer | 🎨 |
| Tech Writer | `tech-writer.md` | Technical Writer | 📝 |
| TEA | `tea.md` | Test Engineering Agent | 🧪 |
| Quick Flow Solo Dev | `quick-flow-solo-dev.md` | Solo developer mode | 🚀 |

**Workflow Categories:**

#### Phase 1: Analysis (`1-analysis/`)
- Research workflows
- Problem definition
- Solution exploration

#### Phase 2: Planning (`2-plan-workflows/`)
- **PRD Workflow** (`prd/`) - Tri-modal: Create, Validate, Edit Product Requirements Documents
- Product brief creation
- Sprint planning

#### Phase 3: Solutioning (`3-solutioning/`)
- Create epics and stories
- Architecture design
- Implementation readiness review
- Check implementation readiness

#### Phase 4: Implementation (`4-implementation/`)
- **Dev Story** (`dev-story/`) - Execute stories with TDD
- Code review workflow
- Correct course workflow
- Sprint status tracking

#### Supporting Workflows:
- `document-project/` - Generate comprehensive documentation
- `excalidraw-diagrams/` - Create visual diagrams
- `generate-project-context/` - Build project context files
- `testarch/` - Test architecture workflows
- `workflow-status/` - Track workflow execution

### 3. BMB (BMAD Module Builder)

**Purpose:** Create, customize, and extend BMAD components

**Location:** `_bmad/bmb/`

**Components:**
- **Agent Builder** (`agents/agent-builder.md`) - Create new agents
- **Workflow Builder** (`workflows/workflow/`) - Create new workflows
- **Module Builder** (`workflows/module/`) - Create entire modules

**Tri-Modal Workflows:**
All BMB workflows support three modes:
- **Create** - Build from scratch
- **Edit** - Modify existing
- **Validate** - Review and improve

### 4. CIS (Creative Intelligence System)

**Purpose:** Creative problem-solving and innovation

**Location:** `_bmad/cis/`

**Agents:**
- Storyteller
- Creative Problem Solver
- Design Thinking Coach
- Innovation Strategist
- Presentation Master
- Brainstorming Coach

**Workflows:**
- Storytelling
- Design Thinking
- Innovation Strategy
- Problem Solving

---

## Agent Architecture

### Agent File Format

Agents are defined in Markdown with embedded XML:

```markdown
---
name: "agent-name"
description: "Human-readable description"
---

You must fully embody this agent's persona and follow all activation instructions exactly as specified. NEVER break character until given an exit command.

```xml
<agent id="agent-id" name="Human Name" title="Job Title" icon="emoji">
<activation critical="MANDATORY">
  <step n="1">Load persona from this current agent file</step>
  <step n="2">Load and read {project-root}/_bmad/{module}/config.yaml</step>
  <step n="3">Remember user's name is {user_name}</step>
  <step n="4">Show greeting using config values</step>
  <step n="5">Display numbered list of ALL menu items</step>
  <step n="6">STOP and WAIT for user input</step>
  <step n="7">Execute selected menu item</step>
</activation>

<persona>
  <role>Agent's functional role</role>
  <identity>Background and expertise description</identity>
  <communication_style>How the agent communicates</communication_style>
  <principles>Core guiding principles</principles>
</persona>

<menu>
  <item cmd="shortcut" workflow="path/to/workflow.yaml">[XX] Menu description</item>
  <item cmd="shortcut" exec="path/to/instructions.md">[XX] Another option</item>
  <item cmd="shortcut" action="action-id">[XX] Direct action</item>
</menu>

<menu-handlers>
  <handlers>
    <handler type="workflow">Instructions for workflow execution</handler>
    <handler type="exec">Instructions for exec files</handler>
    <handler type="action">Instructions for actions</handler>
  </handlers>
</menu-handlers>

<memories>
  <memory>Key things the agent should remember</memory>
</memories>
```
```

### Agent Activation Flow

1. **Load Persona** - Read the agent file
2. **Load Config** - Read module config.yaml (MANDATORY)
3. **Extract Variables** - Store user_name, communication_language, output_folder
4. **Greeting** - Display welcome message with user's name
5. **Show Menu** - Display numbered menu options
6. **Wait for Input** - Halt for user selection
7. **Execute** - Run selected workflow/exec/action

### Menu Item Types

| Type | Attribute | Purpose |
|------|-----------|---------|
| Workflow | `workflow="path"` | Execute BMAD workflow via workflow.xml |
| Exec | `exec="path"` | Execute markdown instruction file |
| Action | `action="id"` | Execute inline action or prompt |
| Template | `tmpl="path"` | Use template file |
| Data | `data="path"` | Pass data file as context |

---

## Workflow System

### Workflow Execution Engine (CORE OS)

**File:** `_bmad/core/tasks/workflow.xml`

This is the heart of BMAD - it executes all workflows with:
- **Variable resolution** - Replace placeholders with values
- **Step sequencing** - Execute steps in exact order
- **Template processing** - Generate documents from templates
- **User interaction** - Prompt for input at decision points
- **State tracking** - Save progress after each step

### Workflow File Format

**YAML Header (`workflow.yaml`):**
```yaml
name: workflow-name
description: "What this workflow does"
author: "BMAD"

# Critical variables from config
config_source: "{project-root}/_bmad/{module}/config.yaml"
output_folder: "{config_source}:output_folder"
user_name: "{config_source}:user_name"
communication_language: "{config_source}:communication_language"
user_skill_level: "{config_source}:user_skill_level"
document_output_language: "{config_source}:document_output_language"

# Workflow components
installed_path: "{project-root}/_bmad/{module}/workflows/{workflow-name}"
instructions: "{installed_path}/instructions.xml"
validation: "{installed_path}/checklist.md"
```

**XML Instructions (`instructions.xml`):**
```xml
<workflow>
  <critical>MANDATORY rules and constraints</critical>
  
  <step n="1" goal="Step objective" tag="tracking-tag">
    <action>What to do</action>
    <check if="condition">
      <action>Conditional action</action>
    </check>
    <ask>Prompt for user input</ask>
  </step>
  
  <step n="2" goal="Next objective">
    <template-output>Generate and save content</template-output>
  </step>
</workflow>
```

### Supported XML Tags

| Tag | Purpose |
|-----|---------|
| `<step n="X">` | Define numbered step |
| `<action>` | Required action to perform |
| `<check if="condition">` | Conditional block |
| `<ask>` | Prompt user and wait for response |
| `<invoke-workflow>` | Call another workflow |
| `<invoke-task>` | Execute a task |
| `<invoke-protocol>` | Execute reusable protocol |
| `<template-output>` | Save content checkpoint |
| `<goto step="X">` | Jump to step |
| `<for-each>` | Iterate over collection |
| `<critical>` | Non-skippable instruction |

### Execution Modes

1. **Normal Mode** - Full user interaction at every step
2. **YOLO Mode** - Skip confirmations, auto-produce output

---

## The Episode System (Пізоди)

### What are Episodes?

Episodes (пізоди in Ukrainian) are **discrete, trackable units of work** within the BMAD framework. They represent:
- User Stories
- Tasks
- Subtasks
- Review cycles
- Workflow steps

### Episode Structure in Stories

```markdown
## Story
As a [role], I want [feature], so that [benefit].

## Acceptance Criteria
1. Given [context], when [action], then [result]. [Source: doc.md#section]
2. ...

## Tasks / Subtasks
- [ ] Task 1 (AC: 1)
  - [ ] Subtask 1.1 [Source: doc.md#section]
  - [ ] Subtask 1.2
- [ ] Task 2 (AC: 2)

## Dev Notes
### Previous Story Insights
### Data Models
### API Specifications
### Component Specifications
### File Locations
### Testing Requirements
### Technical Constraints
### Core Workflows

## Dev Agent Record
- Implementation Plan:
- Completion Notes List:
- File List:

## Change Log
| Date | Version | Description | Author |

## QA Results
Acceptance review (YYYY-MM-DD):
- AC1 — [Pass/Fail]: Evidence
- AC2 — [Pass/Fail]: Evidence
- Requested changes:
- Recommendations:

## Status
[ready-for-dev | in-progress | review | done]
```

### Episode Tracking with Sprint Status

**File:** `_bmad-output/implementation-artifacts/sprint-status.yaml`

```yaml
epic_status:
  epic-1: in-progress
  epic-2: ready
  epic-3: blocked

development_status:
  1-1-register: review
  1-2-profile: in-progress
  1-3-login: ready-for-dev
```

### Episode Lifecycle

1. **ready-for-dev** - Story created, waiting for developer
2. **in-progress** - Developer actively working
3. **review** - Implementation complete, awaiting QA review
4. **done** - QA approved, story complete

### The Dev Story Workflow (Episode Execution)

The `dev-story` workflow is the primary episode execution mechanism:

1. **Find Next Ready Story** - Scan sprint-status.yaml for `ready-for-dev`
2. **Load Context** - Read story file, project-context.md, Dev Notes
3. **Detect Review Continuation** - Check if resuming after code review
4. **Mark In-Progress** - Update sprint status
5. **Execute Red-Green-Refactor** - For each task/subtask:
   - RED: Write failing tests
   - GREEN: Implement to pass tests
   - REFACTOR: Improve while keeping tests green
6. **Author Comprehensive Tests** - Unit, integration, e2e as needed
7. **Run Validations** - Full test suite, linting, quality checks
8. **Mark Complete** - Only when ALL validation gates pass
9. **Mark for Review** - Update status to `review`
10. **Completion Communication** - Summarize for user

### Red-Green-Refactor Cycle (Inside Episodes)

Every task follows this TDD pattern:

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│     RED     │ →  │    GREEN     │ →  │   REFACTOR  │
│  Write test │    │ Minimal code │    │  Improve    │
│  See it fail│    │ to pass      │    │  structure  │
└─────────────┘    └──────────────┘    └─────────────┘
       ↑                                      │
       └──────────────────────────────────────┘
```

---

## Configuration System

### Module Config (`config.yaml`)

```yaml
# Required fields
user_name: "User Name"
communication_language: "English, Ukrainian"
document_output_language: "English"
output_folder: "{project-root}/_bmad-output"

# BMM-specific
project_name: "project_name"
user_skill_level: beginner|intermediate|advanced
planning_artifacts: "{project-root}/_bmad-output/planning-artifacts"
implementation_artifacts: "{project-root}/_bmad-output/implementation-artifacts"
project_knowledge: "{project-root}/docs"
tea_use_mcp_enhancements: false
tea_use_playwright_utils: false
```

### Variable Resolution

BMAD uses a powerful variable substitution system:

| Pattern | Resolution |
|---------|------------|
| `{project-root}` | Project root directory |
| `{config_source}:key` | Value from config file |
| `{installed_path}` | Workflow installation path |
| `{{variable}}` | Runtime variable from user input |
| `{{date}}` | Current date (system-generated) |

---

## Integration Points

### 1. Gemini Code Assist Integration

**Location:** `.gemini/commands/`

TOML files define commands for Gemini Code Assist:

```toml
description = "BMAD Agent: PM"
prompt = """
<agent-activation CRITICAL="TRUE">
1. LOAD the FULL agent file from @_bmad/bmm/agents/pm.md
2. READ its entire contents
3. Execute ALL activation steps
4. Follow the agent's persona precisely
</agent-activation>
"""
```

### 2. Claude Code Integration

**Location:** `.claude/`

Similar structure for Claude Code with skills support

### 3. Output Directory Structure

```
_bmad-output/
├── planning-artifacts/
│   ├── epics.md
│   ├── stories/
│   │   ├── story-1-1.md
│   │   └── ...
│   └── architecture.md
├── implementation-artifacts/
│   ├── sprint-status.yaml
│   └── retrospectives/
├── bmb-creations/
│   └── validation-reports/
└── Amos/
    └── Amos.agent.yaml
```

---

## Key Patterns & Best Practices

### 1. Documentation Patterns

- **Source Attribution** - Every requirement references source document:
  ```markdown
  [Source: architecture/api-specification.md#icp-candid-interface]
  ```

- **Sharded Documents** - Large documents split into logical sections
- **Index Files** - `INDEX.md` provides navigation
- **Change Logs** - Track all modifications with date/version/author

### 2. Testing Patterns

- **Test-First Development** - Write tests before implementation
- **Three-Level Testing** - Unit, integration, e2e
- **Regression Prevention** - Full suite runs after every task
- **Coverage Requirements** - All paths tested including errors

### 3. Code Quality Patterns

- **No print()** - Use proper logging frameworks
- **Result Types** - Error handling via Result/Option types
- **Input Validation** - Validate at all boundaries
- **Principal Validation** - Always validate caller in canister functions

### 4. Security Patterns

- **Rate Limiting** - All sensitive flows protected
- **JWT with Rotation** - Secure authentication
- **Anonymous Prevention** - Reject anonymous principal access
- **Audit Logging** - Security events logged

---

## Entry Points & Usage

### Starting BMAD

1. **Via Gemini Code Assist:**
   - Use `/bmad-agent-bmm-pm` command
   - Or `/bmad-agent-core-bmad-master` for master agent

2. **Via Claude Code:**
   - Use defined skills in `.claude/`

3. **Direct Agent Loading:**
   - Load agent file from `_bmad/{module}/agents/{agent}.md`
   - Follow activation sequence

### Common Workflows

| Task | Workflow | Entry Point |
|------|----------|-------------|
| Create PRD | PRD Create Mode | PM Agent → [CP] |
| Validate PRD | PRD Validate Mode | PM Agent → [VP] |
| Create Stories | Create Stories | PM Agent → [ES] |
| Implement Story | Dev Story | Dev Agent → [DS] |
| Code Review | Code Review | Dev Agent → [CR] |
| Create Agent | Create Agent | Agent Builder → [CA] |
| Sprint Status | Check Status | Any BMM Agent → [WS] |

---

## Critical Rules (No Exceptions)

1. **ALWAYS load config.yaml BEFORE any output**
2. **NEVER skip workflow steps**
3. **ALWAYS save outputs after EACH template-output**
4. **NEVER use offset/limit when reading workflow files**
5. **ALWAYS stay in character until exit command**
6. **NEVER mark tasks complete unless tests actually pass**
7. **ALWAYS communicate in configured language**
8. **NEVER pre-load future step files**
9. **ALWAYS halt at menus and wait for user input**
10. **NEVER use print() in production code**

---

## Troubleshooting

### Common Issues

1. **Config Not Loading**
   - Verify `{project-root}` resolution
   - Check file exists at `_bmad/{module}/config.yaml`

2. **Workflow Not Found**
   - Verify path in menu item
   - Check workflow.yaml exists

3. **Variable Not Resolving**
   - Use `{config_source}:key` syntax
   - Ensure key exists in config

4. **Agent Not Responding**
   - Check activation sequence completed
   - Verify persona loaded correctly

---

## Summary

BMAD is a comprehensive, production-ready framework for AI-driven software development. It combines:

- **Structured workflows** for consistency
- **Specialized agents** for expertise
- **Episode tracking** for progress visibility
- **Documentation-first** approach for knowledge retention
- **Test-driven development** for quality
- **Modular architecture** for extensibility

The framework enables teams to leverage AI assistants effectively while maintaining human oversight and decision-making throughout the development lifecycle.
