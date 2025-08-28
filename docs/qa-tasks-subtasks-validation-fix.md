# QA Tasks/Subtasks Validation Fix

## Problem Identified
The QA agent was ignoring the Tasks/Subtasks section during story reviews, even though it has the responsibility and authorization to mark tasks as complete [x] when QA validation confirms functionality works.

## Root Cause Analysis
1. **Missing from execution workflow**: The execution-order in qa.chatmode.md didn't include Tasks/Subtasks validation step
2. **Insufficient emphasis**: While permissions existed, the importance wasn't emphasized in the workflow
3. **Missing from review task**: The review-story.md task file had no step for Tasks/Subtasks validation
4. **Incomplete template**: The QA Results template didn't include a Tasks/Subtasks validation section

## Fixes Applied

### 1. Updated QA Chatmode Configuration (`.github/chatmodes/qa.chatmode.md`)

**Added to execution-order**:
```
🚨 MANDATORY: Update Tasks/Subtasks completion status - mark [x] ALL completed tasks based on QA validation 🚨
```

**Enhanced enforcement rules**:
- Added specific "TASKS/SUBTASKS COMPLETION VALIDATION" rule
- Updated systematic review process to include step 4: "Verify and update Tasks/Subtasks completion status"
- Updated core principles to emphasize Tasks/Subtasks responsibility

### 2. Updated Review Task (`.bmad-core/tasks/review-story.md`)

**Added new Step 8: Tasks/Subtasks Completion Validation**:
- Review the Tasks/Subtasks section
- Verify functionality for each task/subtask
- Test implementation and edge cases
- Mark [x] complete ONLY when QA validation confirms it works
- Leave [ ] incomplete if not implemented or not working

**Updated authorization section**:
- Clarified that QA can update TWO things: QA Results AND Tasks/Subtasks completion status
- Added Tasks/Subtasks validation section to QA Results template

### 3. Enhanced QA Results Template

**New Tasks/Subtasks Validation section**:
```markdown
### Tasks/Subtasks Validation
- **Task 1**: [Description] → [✓ Implemented and working / ✗ Not implemented / ⚠️ Partially working]
- **Task 2**: [Description] → [✓ Implemented and working / ✗ Not implemented / ⚠️ Partially working]

**IMPORTANT**: After documenting validation results, update the actual Tasks/Subtasks section to mark [x] completed items.
```

## New QA Workflow
1. Load story file and check current status
2. Execute comprehensive testing against ALL ACs
3. Run all relevant test suites and validation
4. **🆕 Validate Tasks/Subtasks completion** - test each task/subtask individually
5. **🆕 Update Tasks/Subtasks section** - mark [x] completed items based on validation
6. Update QA Results section with comprehensive findings
7. Set Status: Done if all pass, or InProgress if issues found

## Expected Result
QA agents will now:
- ✅ Systematically validate each task/subtask during reviews
- ✅ Mark tasks as [x] complete when QA validation confirms they work
- ✅ Leave tasks as [ ] incomplete when not implemented or not working
- ✅ Document validation results in QA Results section
- ✅ Follow the complete workflow including Tasks/Subtasks updates

This ensures that Tasks/Subtasks completion status accurately reflects QA-validated implementation status, not just developer self-assessment.