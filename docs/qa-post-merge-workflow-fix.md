# QA Post-Merge Workflow Fix

## Problem Fixed
Previously, after QA approved a story and watched the PR merge successfully, there was no automatic step to switch to the develop branch and pull the latest changes. This meant QA's local develop branch was outdated.

## Solution
Created `scripts/qa-watch-and-sync.sh` - an enhanced PR watcher that:

1. **Watches PR status** (same as old `watch-pr.sh`)
2. **On successful merge**: Automatically switches to develop branch and pulls latest changes
3. **On other outcomes**: Stays on current branch (no changes)

## New QA Workflow

After setting `Status: Done` and pushing:

```bash
# Old way (missing develop sync)
scripts/watch-pr.sh story/1.2-feature-branch

# New way (includes develop sync)
scripts/qa-watch-and-sync.sh story/1.2-feature-branch
# or via story-flow.sh
scripts/story-flow.sh qa-watch story/1.2-feature-branch
```

## Exit Codes
- `0`: PR merged successfully + develop synced ✅
- `1`: PR closed without merge (no sync needed)
- `2`: PR needs rebase (fix and retry)
- `124`: Timeout waiting for merge
- `10`: Merge succeeded but develop sync failed

## What Happens on Success
```
[12:34:56] QA Watch and Sync: Starting enhanced PR watch...
[12:34:56] Original branch: story/1.2-feature-branch
[12:34:56] Running watch-pr.sh...
[12:35:45] PR merged successfully! Syncing develop branch...
[12:35:45] Switching to develop branch...
[12:35:45] Pulling latest changes from origin/develop...
[12:35:46] ✅ Success! PR merged and develop branch synced
[12:35:46] Current branch: develop
[12:35:46] Latest commit: 1a2b3c4 Merge pull request #123 from story/1.2-feature-branch
```

## Updated Documentation
- QA agent instructions updated to use new script
- QA intake checklist updated
- Development workflow docs updated
- Story-flow.sh includes new `qa-watch` command

## Backward Compatibility
- Old `watch-pr.sh` still works for basic PR watching
- New script wraps the old one, preserving all functionality
- All existing arguments/options work the same way