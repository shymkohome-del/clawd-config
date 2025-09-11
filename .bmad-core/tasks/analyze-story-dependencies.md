# Analyze Story Dependencies Task

## Purpose

To analyze existing user stories and identify opportunities for parallel development by mapping dependencies, conflicts, and optimization opportunities for Git worktree-based development.

## SEQUENTIAL Task Execution

### 1. Load Existing Stories and Epic Structure

#### 1.1 Scan Current Story Files
- Read all story files from `{devStoryLocation}`
- Extract story metadata: epic number, story number, status, dependencies
- Identify completed vs in-progress vs planned stories

#### 1.2 Load Epic Definitions
- Read corresponding epic files from PRD location
- Map stories back to epic requirements
- Identify any missing stories from epic specifications

### 2. Dependency Analysis Matrix

#### 2.1 Create Story Dependency Graph
For each story, analyze:
- **Technical Dependencies**: Shared data models, APIs, components
- **Business Logic Dependencies**: Features that build on each other
- **Infrastructure Dependencies**: Shared configurations, deployments
- **Testing Dependencies**: Shared test utilities, integration scenarios

#### 2.2 Conflict Detection Analysis
Identify potential conflicts between stories:
- **File Modification Conflicts**: Stories that would modify the same files
- **Database Schema Conflicts**: Competing schema requirements
- **API Contract Conflicts**: Incompatible API definitions
- **Component Interface Conflicts**: Competing component requirements

### 3. Parallelization Opportunity Assessment

#### 3.1 Identify Parallel Story Candidates
Find stories that can be developed simultaneously:
- No shared file modifications
- Independent data model requirements
- Separate component/module boundaries
- Compatible API contract requirements

#### 3.2 Generate Optimization Recommendations
For stories with artificial dependencies:
- **Story Splitting Opportunities**: Large stories that could be divided
- **Dependency Removal**: Dependencies that could be eliminated with minor changes
- **Interface Definition**: Shared contracts that would enable parallel development
- **Module Boundary Adjustments**: Architectural changes to reduce conflicts

### 4. Generate Parallelism Roadmap

#### 4.1 Create Development Wave Structure
Organize stories into development waves:

**Wave 1 (Parallel Development)**
- Stories that can start immediately with no dependencies
- Independent module/component boundaries
- Minimal integration requirements

**Wave 2 (Dependent Development)**  
- Stories that depend on Wave 1 completions
- Integration-heavy stories requiring multiple component coordination
- API coordination and contract finalization

**Wave 3 (Integration & Polish)**
- End-to-end feature integration
- Performance optimization
- User experience polish requiring cross-component coordination

#### 4.2 Worktree Assignment Strategy
For each parallel story:
- Recommended Git worktree branch name
- Primary developer focus area (frontend/backend/full-stack)
- Integration testing strategy
- Merge sequence and conflict resolution plan

### 5. Risk Assessment and Mitigation

#### 5.1 Integration Risk Analysis
Identify potential integration challenges:
- **API Contract Misalignment**: Stories with potentially incompatible API designs
- **Data Model Conflicts**: Competing data structure requirements
- **UI/UX Inconsistency**: Parallel UI development leading to inconsistent experiences
- **Performance Implications**: Parallel features that could impact system performance

#### 5.2 Mitigation Strategies
For each identified risk:
- **Prevention Measures**: Architectural guidelines to prevent conflicts
- **Early Detection**: Integration testing strategies to catch conflicts early
- **Resolution Procedures**: Standard processes for resolving specific conflict types
- **Communication Protocols**: Team coordination requirements for parallel development

### 6. Generate Analysis Report

#### 6.1 Dependency Visualization
Create a text-based dependency map:
```
Story Dependencies:
├── Epic 1
│   ├── Story 1.1 (Independent) ✓ Parallel Candidate
│   ├── Story 1.2 (Independent) ✓ Parallel Candidate  
│   ├── Story 1.3 (Depends: 1.1, 1.2) → Sequential
│   └── Story 1.4 (Depends: 1.3) → Sequential
└── Epic 2
    ├── Story 2.1 (Independent) ✓ Parallel Candidate
    └── Story 2.2 (Depends: 2.1) → Sequential
```

#### 6.2 Parallelization Recommendations
- **Immediate Parallel Opportunities**: Stories ready for parallel development
- **Story Splitting Recommendations**: Large stories that should be divided
- **Architecture Improvements**: Changes to enable more parallelism
- **Team Coordination Requirements**: Communication needs for parallel development
- **Integration Testing Strategy**: Approach for testing parallel story integration

### 7. Action Plan Generation

#### 7.1 Development Sequence Recommendations
- **Phase 1**: Parallel stories to start immediately
- **Phase 2**: Sequential stories dependent on Phase 1
- **Phase 3**: Integration and polish stories

#### 7.2 Implementation Guidelines
- **Worktree Setup Instructions**: Git commands for parallel development setup
- **Code Review Coordination**: Review strategies for parallel development
- **Integration Checkpoints**: Milestones for merging parallel work
- **Quality Assurance Coordination**: Testing strategies across parallel stories
