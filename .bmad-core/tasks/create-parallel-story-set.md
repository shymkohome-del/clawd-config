# Create Parallel Story Set Task

## Purpose

To analyze epic requirements and create multiple parallel, non-overlapping user stories that can be developed simultaneously using Git worktrees. This task prioritizes parallelism by identifying story boundaries that minimize merge conflicts and maximize development velocity.

## SEQUENTIAL Task Execution (Do not proceed until current Task is complete)

### 0. Load Core Configuration and Epic Analysis

- Load `.bmad-core/core-config.yaml` from the project root
- If the file does not exist, HALT and inform the user: "core-config.yaml not found. This file is required for parallel story creation."
- Extract key configurations: `devStoryLocation`, `prd.*`, `architecture.*`, `workflow.*`

### 1. Identify Epic for Parallel Decomposition

#### 1.1 Epic Selection and Analysis

- Review available epics from PRD sharded location
- If user hasn't specified an epic, present numbered list of available epics for selection
- Load selected epic file and extract:
  - Epic title and description
  - All user stories within the epic
  - Current completion status of stories
  - Dependencies between stories

#### 1.2 Parallelism Feasibility Analysis

For each story in the epic, analyze:
- **Codebase Module Boundaries**: Which modules/components will be affected
- **Data Dependencies**: Shared data models, database schemas, API contracts
- **UI Component Dependencies**: Shared components, styling, or layouts  
- **Integration Points**: External APIs, services, or system integrations
- **Testing Overlaps**: Shared test utilities, fixtures, or integration test scenarios

### 2. Architecture-Based Conflict Analysis

#### 2.1 Read Relevant Architecture Documents

Based on story types identified, read:
- `unified-project-structure.md` - For file/folder organization boundaries
- `components.md` - For UI component dependencies and boundaries
- `data-models.md` - For data structure dependencies
- `backend-architecture.md` - For service layer boundaries
- `frontend-architecture.md` - For UI layer boundaries

#### 2.2 Identify Non-Overlapping Story Boundaries

Create a conflict matrix analyzing each story pair for:
- **File Path Conflicts**: Stories that would modify the same files
- **Database Schema Conflicts**: Stories requiring conflicting schema changes
- **API Contract Conflicts**: Stories defining conflicting API specifications
- **Component Interface Conflicts**: Stories modifying shared component interfaces
- **Configuration Conflicts**: Stories requiring conflicting environment or build configurations

### 3. Generate Parallel Story Set Design

#### 3.1 Create Story Groupings

Based on conflict analysis, organize stories into:

**Parallel Development Set N** (Stories that can run simultaneously):
- Story N-1: [Feature Name] - Branch: feature/story-N-1
- Story N-2: [Feature Name] - Branch: feature/story-N-2  
- Story N-3: [Feature Name] - Branch: feature/story-N-3

**Sequential Stories** (Must complete after Parallel Set N):
- Story N+1: [Feature Name] - Depends on: Stories N-1, N-2, N-3
- Story N+2: [Feature Name] - Depends on: Story N+1

#### 3.2 Dependency Mapping

For each story, document:
- **Dependencies**: Which stories must complete first
- **Parallel-Safe Indicator**: true/false  
- **Module/Area of Codebase Affected**: To minimize conflicts
- **Git Worktree Branch Name**: Following naming convention
- **Merge Order**: Sequence for integrating completed stories

### 4. Create Individual Story Files

#### 4.1 Generate Each Story Using Enhanced Template

For each story in the parallel set:
- Create story file: `{devStoryLocation}/{epicNum}.{storyNum}.story.md`
- Use enhanced story template with parallelism metadata
- Include additional sections:
  - **Parallelism Metadata**: Dependencies, conflicts, merge order
  - **Worktree Information**: Branch name, module focus
  - **Conflict Prevention Notes**: Specific guidance to avoid merge conflicts

#### 4.2 Enhanced Dev Notes for Parallel Development

Each story's Dev Notes section must include:
- **Module Boundaries**: Exact files/folders this story should touch
- **API Contract Boundaries**: Specific endpoints/interfaces to implement
- **Component Boundaries**: UI components to create/modify (with exclusive ownership)
- **Database Boundaries**: Tables/collections this story owns
- **Integration Testing Boundaries**: Test scenarios specific to this story
- **Merge Conflict Prevention**: Specific files/patterns to avoid modifying

### 5. Generate Worktree Development Plan

#### 5.1 Create Git Worktree Strategy Document

Generate a development plan including:
- **Worktree Setup Commands**: Git commands to create each worktree
- **Development Sequence**: Order of story development within parallel sets
- **Integration Strategy**: How to merge completed parallel stories
- **Conflict Resolution Guidelines**: Specific merge conflict resolution patterns

#### 5.2 Quality Assurance Checkpoints

Define QA checkpoints for parallel development:
- **Individual Story QA**: Criteria for each story before merge
- **Integration QA**: Testing strategy when merging parallel stories
- **Regression Prevention**: Tests to ensure parallel stories don't break each other

### 6. Story Set Validation and Completion

#### 6.1 Parallel Story Set Validation

- Verify no two stories in parallel set modify the same files
- Confirm each story has complete, self-contained requirements
- Validate that dependencies are properly sequenced
- Check that each story can be developed in isolation

#### 6.2 Generate Summary Report

Provide user with:
- **Parallel Story Set Created**: List of story files generated
- **Development Strategy**: Overview of parallel vs sequential phases
- **Worktree Plan**: Git worktree setup and workflow
- **Risk Assessment**: Potential integration challenges identified
- **Next Steps**: Recommended order for story development and team assignment

## Output Structure

Structure the output like:
```
## Parallel Development Set 1 (Can run simultaneously in worktrees)
- Story 1-1: [Feature Name] - Branch: feature/story-1-1  
- Story 1-2: [Feature Name] - Branch: feature/story-1-2
- Story 1-3: [Feature Name] - Branch: feature/story-1-3

## Sequential Stories (Must complete after Set 1) 
- Story 2: [Feature Name] - Depends on: Stories 1-1, 1-2, 1-3
- Story 3: [Feature Name] - Depends on: Story 2

Note: These stories are designed for parallel execution using Git worktrees where developers can work simultaneously without conflicts.
```
