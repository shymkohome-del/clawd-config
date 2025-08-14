# QA Intake Checklist

Purpose: Define the first actions QA should take when a story is handed off from Dev.

Preconditions:
- The story status is "Ready for QA" or a PR exists referencing the story id.
- Handoff details are provided in the PR or `templates/qa-handoff.md` copy.

Steps:
1. Identify scope
   - Gather story id `${id}`, title `${title}`, and branch `story/${id}-${slug}`
   - Validate branch name matches `^story/[0-9]+(\.[0-9]+)*-[a-z0-9-]+$`; if not, block QA and notify Dev to rename branch
   - Locate PR (if any) and confirm it references the story id in title or body (acceptable forms: `story ${id}`, `story-${id}`, `story/${id}`, `story: ${id}`)
2. Pull latest changes
   - Run: `git fetch origin && git switch story/${id}-${slug} && git pull`
3. Verify CI status
   - Confirm CI checks are passing for the branch/PR (policy `policies.qa.useCiStatusForGate`)
4. Review handoff details
   - Validate environments, test data, and steps in the handoff document
5. Prepare test plan
   - Derive test cases from Acceptance Criteria and BDD scenarios in the story
6. Execute tests
   - Log results to `.ai/qa-log.md`. Include build hash and timestamps
7. Report outcomes
   - If pass: Mark QA results in the story, signal Ready for Review. If PR was missing required story reference, request Dev to update PR title/body before approval.
   - If fail: Open defects with clear repro steps and link them in `.ai/qa-log.md`

Outcome:
- QA has a clear, repeatable process to begin validation.
