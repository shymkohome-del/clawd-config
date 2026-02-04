# BMAD Episodes (Пізоди) System - Deep Dive

## What is an Episode?

In BMAD, an **episode** (пізод) is a discrete, trackable unit of work with:
- Clear definition
- Acceptance criteria
- Implementation tasks
- Quality gates
- Status tracking

Episodes are the atomic building blocks of BMAD-driven development.

---

## Episode Types

### 1. Story Episodes
User-facing features with acceptance criteria

**Location:** `docs/stories/story-{epic}-{number}.md`

**Example:** `story-1-1.md` = Epic 1, Story 1

### 2. Task Episodes
Individual implementation units within a story

**Format:**
```markdown
- [ ] Task description (AC: 1)
  - [ ] Subtask 1.1
  - [ ] Subtask 1.2
```

### 3. Workflow Episodes
Steps within a BMAD workflow

**Format:** XML `<step n="X">` in `instructions.xml`

### 4. Review Episodes
Code review cycles with action items

**Format:**
```markdown
### Senior Developer Review (AI)
**Review Outcome:** Changes Requested
**Action Items:**
- [ ] [HIGH] Fix input validation
- [ ] [MED] Add error handling
```

---

## Story Episode Structure (Complete)

```markdown
# Story {EPIC}.{NUM}: {Title}

## Status
{Ready for Review | In Progress | Ready for Dev | Done}

## Dependencies
- {story-id} - Description
- {epic-id} - Description

## Story
As a {role}, I want {feature}, so that {benefit}.

## Acceptance Criteria
1. Given {context}, when {action}, then {result}. [Source: doc.md#section]
2. ...

### BDD Scenarios
- Scenario: {name}
  - Given {context}
  - When {action}
  - Then {result}

## Tasks / Subtasks
- [ ] Task 1 (AC: 1)
  - [ ] Subtask 1.1 [Source: doc.md#section]
  - [ ] Subtask 1.2
- [ ] Task 2 (AC: 2)

### Review Follow-ups (AI)
- [ ] [AI-Review] [HIGH] Fix validation issue

## Dev Notes

### Previous Story Insights
Learnings from earlier stories in epic.

### Data Models
Required data structures.

### API Specifications
Interface definitions.

### Component Specifications
UI/UX component details.

### File Locations
Where to implement.

### Testing Requirements
Test coverage expectations.

### Technical Constraints
Must-follow rules.

### Core Workflows
Relevant workflow documentation.

## Related Files
- `path/to/file.dart` - Description

## Testing
Review
- [ ] Unit tests for X
- [ ] Integration tests for Y

## Change Log
| Date | Version | Description | Author |
|------|---------|-------------|--------|
| YYYY-MM-DD | 0.1 | Initial | Role |
| YYYY-MM-DD | 0.2 | Update | Role |

## Dev Agent Record
- Implementation Plan:
  - Approach overview
- Completion Notes List:
  - What was implemented
  - Decisions made
- File List:
  - Modified files

## QA Results
Acceptance review (YYYY-MM-DD):
- AC1 — {Pass/Fail}: Evidence
- AC2 — {Pass/Fail}: Evidence
  - Requested changes:
    - Item 1
  - Recommendations:
    - Suggestion 1
```

---

## Episode Lifecycle

### Status Values

| Status | Meaning | Who Sets |
|--------|---------|----------|
| `ready-for-dev` | Story defined, awaiting developer | PM/SM |
| `in-progress` | Developer actively working | Dev Agent |
| `review` | Implementation done, awaiting QA | Dev Agent |
| `done` | QA approved, complete | QA |
| `blocked` | Impediment preventing work | Any |

### State Transitions

```
┌─────────────────────────────────────────────────────────────┐
│                        EPISODE LIFECYCLE                    │
└─────────────────────────────────────────────────────────────┘

    [Story Creation]
           ↓
    ┌──────────────┐
    │ ready-for-dev│ ←────────┐
    └──────────────┘          │
           ↓                  │
    ┌──────────────┐          │
    │  in-progress │ ────┐    │ (rejected)
    └──────────────┘     │    │
           ↓             │    │
    ┌──────────────┐     │    │
    │    review    │ ────┘    │
    └──────────────┘          │
           ↓                  │
    ┌──────────────┐          │
    │     done     │──────────┘
    └──────────────┘
```

---

## Dev Story Workflow (Episode Execution)

**File:** `_bmad/bmm/workflows/4-implementation/dev-story/`

### Step-by-Step Execution

#### Step 1: Find Next Ready Story
```xml
<step n="1" goal="Find next ready story and load it">
  <check if="{{story_path}} is provided">
    <action>Use provided path</action>
  </check>
  <check if="{{sprint_status}} file exists">
    <action>Find FIRST story with status="ready-for-dev"</action>
    <action>Read COMPLETE sprint-status.yaml</action>
  </check>
</step>
```

**Key Logic:**
- If story_path provided: Use it
- Else: Scan sprint-status.yaml for `ready-for-dev` stories
- Read from top to bottom (preserves priority)

#### Step 2: Load Project Context
```xml
<step n="2" goal="Load project context">
  <action>Load project-context.md</action>
  <action>Parse story sections</action>
  <action>Extract Dev Notes guidance</action>
</step>
```

**Loads:**
- Project-wide standards
- Story-specific requirements
- Technical constraints
- Previous learnings

#### Step 3: Detect Review Continuation
```xml
<step n="3" goal="Detect review continuation">
  <check if="Senior Developer Review section exists">
    <action>Set review_continuation = true</action>
    <action>Extract review outcome</action>
    <action>Count pending action items</action>
  </check>
</step>
```

**Purpose:** Resume work after code review feedback

#### Step 4: Mark In-Progress
```xml
<step n="4" goal="Mark story in-progress">
  <check if="sprint_status file exists">
    <action>Update status: ready-for-dev → in-progress</action>
  </check>
</step>
```

**Tracks:** Work has officially started

#### Step 5: Implement (Red-Green-Refactor)
```xml
<step n="5" goal="Implement task following red-green-refactor">
  <critical>FOLLOW TASKS/SUBTASKS SEQUENCE EXACTLY</critical>
  
  <!-- RED PHASE -->
  <action>Write FAILING tests first</action>
  <action>Confirm tests fail</action>
  
  <!-- GREEN PHASE -->
  <action>Implement MINIMAL code to pass</action>
  <action>Run tests to confirm pass</action>
  
  <!-- REFACTOR PHASE -->
  <action>Improve code structure</action>
  <action>Keep tests green</action>
</step>
```

**MANDATORY:** Never skip the RED phase!

#### Step 6: Author Tests
```xml
<step n="6" goal="Author comprehensive tests">
  <action>Unit tests for business logic</action>
  <action>Integration tests for interactions</action>
  <action>E2E tests for critical flows</action>
  <action>Edge cases and errors</action>
</step>
```

**Coverage Requirements:**
- All business logic paths
- Error conditions
- Integration points

#### Step 7: Run Validations
```xml
<step n="7" goal="Run validations and tests">
  <action>Run ALL existing tests</action>
  <action>Run NEW tests</action>
  <action>Run linting</action>
  <action>Validate acceptance criteria</action>
  
  <action if="regression tests fail">STOP and fix</action>
  <action if="new tests fail">STOP and fix</action>
</step>
```

**Quality Gates:**
- No regressions allowed
- New tests must pass
- Linting clean
- ACs satisfied

#### Step 8: Mark Complete
```xml
<step n="8" goal="Validate and mark task complete">
  <critical>NEVER mark complete unless ALL conditions met</critical>
  
  <action>Verify tests EXIST and PASS 100%</action>
  <action>Confirm implementation matches task spec</action>
  <action>Validate acceptance criteria</action>
  <action>Run full regression suite</action>
  
  <check if="ALL validation gates pass">
    <action>Mark task checkbox [x]</action>
    <action>Update File List</action>
    <action>Add Completion Notes</action>
  </check>
</step>
```

**CRITICAL:** Honest completion - no lying about tests!

#### Step 9: Mark for Review
```xml
<step n="9" goal="Story completion and mark for review">
  <action>Verify ALL tasks marked [x]</action>
  <action>Run full regression suite</action>
  <action>Execute definition-of-done validation</action>
  <action>Update status to "review"</action>
</step>
```

**Definition of Done Checklist:**
- [ ] All tasks/subtasks complete
- [ ] All ACs satisfied
- [ ] Unit tests added/updated
- [ ] Integration tests added
- [ ] All tests pass
- [ ] Code quality checks pass
- [ ] File List complete
- [ ] Dev Agent Record updated
- [ ] Change Log updated

#### Step 10: Completion Communication
```xml
<step n="10" goal="Completion communication">
  <action>Summarize accomplishments</action>
  <action>Provide story file path</action>
  <action>Suggest next steps</action>
  <action>Offer explanations</action>
</step>
```

**Output:**
- Story ID and title
- Key changes made
- Tests added
- Files modified
- Current status

---

## Sprint Status Tracking

**File:** `_bmad-output/implementation-artifacts/sprint-status.yaml`

```yaml
meta:
  project: crypto_market
  last_updated: "2026-01-26T10:00:00Z"
  current_sprint: "Sprint 1"

epic_status:
  epic-1-user-identity: in-progress
  epic-2-marketplace: ready
  epic-3-payments: blocked

development_status:
  # Format: epic-story-key: status
  1-1-register: review
  1-2-profile: in-progress
  1-3-login: ready-for-dev
```

**Auto-Updated by:**
- Dev Story workflow
- Sprint planning workflows
- Manual updates (if needed)

---

## Review Episode Pattern

### Code Review Workflow

**Trigger:** Dev Agent → [CR] or story completion

**Output:** Story file updated with:

```markdown
### Senior Developer Review (AI)
**Review Date:** 2026-01-26
**Reviewer:** Senior Developer Agent
**Review Outcome:** {Approve | Changes Requested | Blocked}
**Total Action Items:** 5 (2 High, 2 Med, 1 Low)

**Action Items:**
- [ ] [HIGH] Fix input validation in register form
- [ ] [HIGH] Add rate limiting to OAuth callback
- [ ] [MED] Extract validation logic to helper
- [ ] [MED] Add comment explaining principal mapping
- [ ] [LOW] Rename variable for clarity

**Praise:**
- Good separation of concerns in service layer
- Comprehensive test coverage

**Recommendations:**
- Consider caching for price lookups
```

**Review Follow-ups in Tasks:**
```markdown
### Review Follow-ups (AI)
- [ ] [AI-Review] [HIGH] Fix input validation
- [ ] [AI-Review] [HIGH] Add rate limiting
```

### Handling Review Feedback

When resuming after review:

1. **Detect Review Context** (Step 3)
2. **Prioritize [AI-Review] Tasks**
3. **Fix Each Item:**
   - Mark task checkbox [x]
   - Mark corresponding action item [x]
   - Add to Completion Notes
4. **Continue with Remaining Tasks**

---

## Episode Anti-Patterns

### ❌ DON'T

1. **Skip Red Phase** - Never implement without failing test
2. **Batch Task Completion** - Mark tasks only when truly done
3. **Lie About Tests** - Never mark done if tests don't exist/pass
4. **Skip Regression** - Always run full suite
5. **Ignore Dev Notes** - Follow the guidance provided
6. **Reorder Tasks** - Execute in order specified
7. **Pause Without HALT** - Continue until complete or HALT condition

### ✅ DO

1. **Write Test First** - RED phase is mandatory
2. **Minimal Implementation** - Just enough to pass
3. **Refactor Cleanly** - Improve structure
4. **Verify Everything** - Tests, lint, ACs
5. **Update Documentation** - File List, Change Log, Completion Notes
6. **Be Honest** - Accurate status reporting
7. **Iterate Autonomously** - Fix errors without asking

---

## Episode Success Metrics

| Metric | Target |
|--------|--------|
| Test Coverage | >80% |
| Red-Green-Refactor Cycle | Every task |
| Tasks Completed per Session | All in story |
| Regression Failures | 0 |
| Review Cycles | <2 |
| Documentation Updates | All required sections |

---

## Episode Commands Quick Reference

### Finding Episodes
```
# Via Dev Agent
[DS] Dev Story - Auto-finds next ready episode

# Via Sprint Status
Check _bmad-output/implementation-artifacts/sprint-status.yaml
```

### Executing Episodes
```
# Start development
[DS] → Executes dev-story workflow

# After review
[DS] → Detects review context, resumes with fixes

# Code review
[CR] → Runs code-review workflow
```

### Tracking Episodes
```yaml
# sprint-status.yaml
development_status:
  1-1-story-key: ready-for-dev  # Ready to start
  1-2-story-key: in-progress    # Currently working
  1-3-story-key: review         # Done, awaiting QA
  1-4-story-key: done           # Complete
```

---

## Summary

The Episode System (Пізоди) is BMAD's core work unit:

1. **Stories** define what to build
2. **Tasks** define how to build it
3. **Red-Green-Refactor** ensures quality
4. **Status tracking** provides visibility
5. **Reviews** ensure standards
6. **Documentation** preserves knowledge

Every episode follows the same disciplined pattern, ensuring consistent, high-quality output regardless of complexity.
