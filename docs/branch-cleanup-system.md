# Branch Cleanup System

This document describes the automated branch cleanup system that removes merged branches after successful merges to develop.

## Overview

The branch cleanup system provides multiple ways to automatically remove branches after they've been successfully merged:

1. **Automatic cleanup on PR merge** (GitHub Actions)
2. **Enhanced qa-watch-and-sync.sh script** (local cleanup)
3. **Manual cleanup script** (on-demand cleanup)
4. **Bulk cleanup workflow** (scheduled or manual)

## 🚀 Quick Start

### Automatic Cleanup (Recommended)

The system is designed to work automatically:

1. **Create/work on story/feature branches** as usual
2. **Complete QA review** with `*review story/<id>-<slug>`
3. **QA script handles everything** - PR creation, merge, and cleanup
4. **Branches are automatically deleted** after successful merge

### Manual Cleanup

```bash
# Show what would be cleaned up (dry run)
scripts/cleanup-merged-branches.sh --dry-run

# Clean up merged branches older than 7 days
scripts/cleanup-merged-branches.sh

# Clean up branches older than 14 days
scripts/cleanup-merged-branches.sh --days 14

# Clean up specific patterns
scripts/cleanup-merged-branches.sh --pattern "hotfix/** bugfix/**"
```

## 🔧 Components

### 1. GitHub Actions Workflow (`cleanup-merged-branches.yml`)

**Triggers:**
- Automatically when PRs are closed/merged
- Manual trigger for bulk cleanup

**Features:**
- Deletes remote branches immediately after merge
- Only processes `story/**` and `feature/**` branches
- Skips fork PRs (safety)
- Configurable bulk cleanup with age filters

**Usage:**
```yaml
# Automatic - no action needed
# Manual bulk cleanup available in Actions tab
```

### 2. Enhanced QA Watch Script (`qa-watch-and-sync.sh`)

**New Features:**
- Automatically cleans up local merged branch
- Warns if remote cleanup failed
- Provides manual cleanup commands if needed

**Usage:**
```bash
# After setting Status: Done in story file
scripts/qa-watch-and-sync.sh story/123-feature-name
```

**Output Example:**
```
[14:30:15] PR merged successfully! Syncing develop branch...
[14:30:16] Switching to develop branch...
[14:30:17] Pulling latest changes from origin/develop...
[14:30:18] Cleaning up merged branch: story/123-feature-name
[14:30:19] Deleting local branch: story/123-feature-name
[14:30:20] ✅ Remote branch story/123-feature-name was cleaned up automatically
[14:30:21] ✅ Success! PR merged, develop branch synced, and cleanup completed
```

### 3. Manual Cleanup Script (`cleanup-merged-branches.sh`)

**Features:**
- Safe analysis of merged branches
- Multiple safety checks
- Dry-run mode
- Configurable age thresholds
- Pattern matching for branch types
- Confirmation prompts

**Options:**
```bash
--dry-run                 # Show what would be deleted
--days N                  # Age threshold (default: 7)
--pattern "PATTERNS"      # Branch patterns to match
--force                   # Force delete unmerged branches
--remote-only            # Only clean remote branches
--local-only             # Only clean local branches
```

## 🛡️ Safety Features

### Protected Branches
- Never deletes `develop`, `main`, or `master`
- Skips current working branch
- Only processes `story/**` and `feature/**` by default

### Merge Verification
- Only deletes branches fully merged into develop/main
- Verifies merge status before deletion
- Age-based filtering (default: 7 days old)

### Confirmation & Dry-Run
- Interactive confirmation required (unless `--force`)
- Dry-run mode shows what would be deleted
- Detailed logging of all actions

### Fork Protection
- GitHub Actions skips branches from forks
- Local script only affects same repository

## 📋 Configuration

### GitHub Actions Variables

Set in repository settings > Variables:

```yaml
# Disable automatic cleanup (default: enabled)
AUTO_CLEANUP_ENABLED: false

# Change default age threshold (default: 7 days)
CLEANUP_DAYS_OLD: 14

# Change branch patterns (default: "story/** feature/**")
CLEANUP_PATTERNS: "story/** feature/** hotfix/**"
```

### Script Configuration

Modify defaults in `cleanup-merged-branches.sh`:

```bash
# Default age threshold
DAYS_OLD=7

# Default patterns
PATTERNS="story/** feature/**"
```

## 🔄 Workflow Integration

### QA Workflow Integration

The cleanup system is integrated into the QA workflow:

1. **QA Review** → `*review story/123-feature`
2. **Status: Done** → Triggers auto-PR workflow
3. **PR Merge** → GitHub Actions deletes remote branch
4. **qa-watch-and-sync.sh** → Cleans up local branch + syncs develop
5. **Complete** → All branches cleaned, develop synced

### CI/CD Integration

The system works with existing CI/CD:

```yaml
# In your workflows, branches are automatically cleaned
# No manual intervention required
# Integrates with existing auto-merge system
```

## 📊 Monitoring & Troubleshooting

### View Cleanup Activity

**GitHub Actions:**
- Go to Actions tab
- Look for "Cleanup Merged Branches" workflow runs
- Check job summaries for cleanup results

**Local Logs:**
```bash
# Run with dry-run to see what would be cleaned
scripts/cleanup-merged-branches.sh --dry-run

# Check git logs for recent merges
git log --oneline --merges -10
```

### Common Issues

**Remote branch not deleted:**
```bash
# Check if GitHub Actions ran
# Manually delete if needed:
git push origin --delete story/branch-name
```

**Local branch deletion failed:**
```bash
# Branch may have unmerged changes
git branch -D branch-name  # Force delete

# Or check what's unmerged:
git log develop..branch-name
```

**Cleanup not running:**
```bash
# Verify branch patterns match:
echo "story/123-test" | grep -E "^(story/.*|feature/.*)$"

# Check branch age:
git log -1 --format=%ct story/branch-name
```

## 🎯 Best Practices

### For Developers

1. **Use standard branch naming**: `story/123-feature-name`, `feature/new-thing`
2. **Let QA handle cleanup**: Use `*review` command which handles everything
3. **Don't manually delete** until after merge confirmation
4. **Check cleanup status** in qa-watch-and-sync.sh output

### For QA Engineers

1. **Always use qa-watch-and-sync.sh** after setting Status: Done
2. **Wait for script completion** before considering workflow done
3. **Monitor cleanup messages** in script output
4. **Escalate cleanup failures** if branches aren't removed

### For Repository Maintenance

1. **Run bulk cleanup monthly**: Use GitHub Actions manual trigger
2. **Monitor cleanup workflows**: Check Actions tab regularly
3. **Adjust age thresholds** based on team workflow
4. **Review patterns** if new branch types are introduced

## 🔗 Related Documentation

- [QA Workflow Guide](qa-post-merge-workflow-fix.md)
- [Git Workflow Guide](git-worktrees-multi-ide-implementation.md)
- [CI/CD Documentation](github-workflow-optimization-analysis.md)
