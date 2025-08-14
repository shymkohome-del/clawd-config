# QA Intake Checklist

Purpose: Define the first actions QA should take when a story is handed off from Dev.

Preconditions:
- The story status is "Ready for QA" or a PR exists referencing the story id.
- Handoff details are provided in the PR or `templates/qa-handoff.md` copy.

Steps:
1. Identify scope
   - Gather story id `${id}`, title `${title}`, and branch `story/${id}-${slug}`
   - Locate PR (if any) and confirm it references the story
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
   - If pass: Append QA results in the story and set `Status: Done`
   - If fail: Open defects with clear repro steps, link them in `.ai/qa-log.md`, append a brief reason in the story Change Log, and set `Status: InProgress`

Outcome:
- QA has a clear, repeatable process to begin validation.
