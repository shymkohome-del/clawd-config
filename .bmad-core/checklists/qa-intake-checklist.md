# QA Intake Checklist

Purpose: Define the first actions QA should take when a story is handed off from Dev.

Preconditions:
- The story status is "Review" or a PR exists referencing the story id.
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
   - Append results in the story file's `## QA Results` section. Include build hash and timestamps
7. Report outcomes and watch for merge
   - If pass: Complete the QA Results section, set story Status to `Done`, and push changes. Then run `scripts/qa-watch-and-sync.sh story/${id}-${slug}` to watch for PR merge and automatically sync develop branch when complete.
   - If fail: Open defects with clear repro steps and reference them in the story's QA Results section

Outcome:
- QA has a clear, repeatable process to begin validation.
