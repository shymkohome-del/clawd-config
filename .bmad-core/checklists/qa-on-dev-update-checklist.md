# QA On Dev Update Checklist

Purpose: Define how QA proceeds when Dev pushes new commits to a story already in QA.

Preconditions:
- The same story is in QA or a PR is open; new commits are pushed to `story/${id}-${slug}` or its PR.

Steps:
1. Detect update
   - Monitor PR or branch for new commits (link stored in `.ai/qa-log.md` or PR)
2. Pull and build
   - Run: `git fetch origin && git switch story/${id}-${slug} && git pull`
   - Rebuild app/tests as needed
3. Scope impact
   - Read commit messages and diffs to identify impacted areas
4. Re-run targeted tests
   - Re-execute only impacted BDD scenarios first
   - If risky change, perform lightweight regression
5. Update QA log
   - Append results with commit hash, timestamp, and impacted areas to `.ai/qa-log.md`
6. Communicate status
   - If pass: comment on PR or notify Dev that QA remains green and set the story `Status: Done`
   - If fail: file/update defects with detailed repro steps, note reason in story Change Log, and set `Status: InProgress`

Outcome:
- QA efficiently responds to Dev updates without restarting the full cycle.
