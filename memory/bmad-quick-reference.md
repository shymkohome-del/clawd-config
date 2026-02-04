# BMAD Framework - Quick Reference Card

## Instant Commands

### Agent Shortcuts (Universal)
| Cmd | Action |
|-----|--------|
| `MH` | Redisplay Menu Help |
| `CH` | Chat with Agent |
| `PM` | Start Party Mode |
| `DA` | Dismiss Agent |

### PM Agent Shortcuts
| Cmd | Action |
|-----|--------|
| `WS` | Workflow Status |
| `CP` | Create PRD |
| `VP` | Validate PRD |
| `EP` | Edit PRD |
| `ES` | Create Epics & Stories |
| `IR` | Implementation Readiness |
| `CC` | Course Correction |

### Dev Agent Shortcuts
| Cmd | Action |
|-----|--------|
| `DS` | Dev Story (execute story) |
| `CR` | Code Review |

### Agent Builder Shortcuts
| Cmd | Action |
|-----|--------|
| `CA` | Create Agent |
| `EA` | Edit Agent |
| `VA` | Validate Agent |

---

## Workflow Invocation Pattern

```
Agent Menu Selection
       ↓
Load workflow.xml (CORE OS)
       ↓
Load workflow.yaml (config)
       ↓
Load instructions.xml (steps)
       ↓
Execute steps in order
       ↓
Save outputs after each checkpoint
```

---

## File Structure Template

### New Agent File
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
  <step n="2">Load config.yaml</step>
  <step n="3">Remember user name</step>
  <step n="4">Show greeting + menu</step>
  <step n="5">Wait for input</step>
</activation>
<persona>
  <role>Role description</role>
  <identity>Background</identity>
  <communication_style>Style</communication_style>
  <principles>Principles</principles>
</persona>
<menu>
  <item cmd="XX" workflow="path">[XX] Description</item>
</menu>
</agent>
```
```

### New Workflow

**workflow.yaml:**
```yaml
name: workflow-name
description: "Description"
config_source: "{project-root}/_bmad/{module}/config.yaml"
output_folder: "{config_source}:output_folder"
installed_path: "{project-root}/_bmad/{module}/workflows/{name}"
instructions: "{installed_path}/instructions.xml"
standalone: true
```

**instructions.xml:**
```xml
<workflow>
  <critical>Critical rules</critical>
  <step n="1" goal="Goal">
    <action>Do something</action>
  </step>
</workflow>
```

---

## Episode (Story) Status Flow

```
ready-for-dev → in-progress → review → done
      ↑                            ↓
      └────────────────────── rejected
```

---

## Red-Green-Refactor Cycle

```
RED: Write failing test
     ↓
GREEN: Write minimal code to pass
     ↓
REFACTOR: Improve structure
     ↓
REPEAT for next task
```

---

## Critical Variable Patterns

| Pattern | Example | Resolves To |
|---------|---------|-------------|
| `{project-root}` | `{project-root}/_bmad` | Absolute project path |
| `{config_source}:key` | `{config_source}:user_name` | Config value |
| `{installed_path}` | `{installed_path}/instructions.xml` | Workflow path |
| `{{variable}}` | `{{story_path}}` | Runtime variable |
| `{{date}}` | Output files | Current timestamp |

---

## Common Config Keys

```yaml
user_name: "Name"
communication_language: "English"
document_output_language: "English"
output_folder: "{project-root}/_bmad-output"
project_name: "project"
user_skill_level: intermediate
planning_artifacts: "{project-root}/_bmad-output/planning-artifacts"
imlementation_artifacts: "{project-root}/_bmad-output/implementation-artifacts"
project_knowledge: "{project-root}/docs"
```

---

## Directory Quick Reference

```
_bmad/
├── core/           # Framework OS
│   ├── agents/bmad-master.md
│   ├── tasks/workflow.xml  ← CORE OS
│   └── workflows/
├── bmm/            # Project management
│   ├── agents/     # PM, Dev, Architect, etc.
│   └── workflows/  # 1-analysis, 2-plan, 3-solutioning, 4-implementation
├── bmb/            # Build modules/agents
│   ├── agents/agent-builder.md
│   └── workflows/agent/, workflow/, module/
├── cis/            # Creative problem solving
│   ├── agents/
│   └── workflows/
└── my-custom-agents/  # Your custom agents

_bmad-output/
├── planning-artifacts/
│   ├── epics.md
│   └── stories/
├── implementation-artifacts/
│   └── sprint-status.yaml
└── bmb-creations/
```

---

## Never Forget

1. ✅ ALWAYS load config.yaml first
2. ✅ NEVER skip workflow steps
3. ✅ ALWAYS save after template-output
4. ✅ NEVER use print() in production
5. ✅ ALWAYS write tests first (RED)
6. ✅ NEVER mark done unless tests pass
7. ✅ ALWAYS stay in character
8. ✅ NEVER pre-load future steps
9. ✅ ALWAYS halt at menus
10. ✅ NEVER lie about test status
