#!/usr/bin/env bash
set -euo pipefail

# Branch Cleanup Script
# Usage: scripts/cleanup-merged-branches.sh [--dry-run] [--days 7] [--pattern "story/** feature/**"] [--force]
#
# Safely removes local and remote branches that have been merged into develop/main
# and are older than the specified number of days.

usage() {
  cat <<USAGE
Usage: $0 [OPTIONS]

Clean up merged branches that are older than specified days.

OPTIONS:
  --dry-run                Show what would be deleted without actually deleting
  --days N                 Delete branches older than N days (default: 7)
  --pattern "PATTERNS"     Space-separated branch patterns (default: "story/** feature/**")
  --force                  Force delete unmerged branches (dangerous!)
  --remote-only           Only clean remote branches, keep local ones
  --local-only            Only clean local branches, keep remote ones
  -h, --help              Show this help

EXAMPLES:
  $0                                    # Clean story/** and feature/** branches older than 7 days
  $0 --dry-run                         # Show what would be deleted
  $0 --days 14                         # Clean branches older than 14 days
  $0 --pattern "hotfix/** bugfix/**"   # Clean specific patterns
  $0 --remote-only --days 1            # Clean only remote branches older than 1 day

SAFETY:
  - Only deletes branches that are fully merged into develop or main
  - Skips protected branches (develop, main, master)
  - Requires confirmation unless --force is used
  - Always fetches latest before analysis
USAGE
}

# Default values
DRY_RUN=false
DAYS_OLD=7
PATTERNS="story/** feature/**"
FORCE=false
REMOTE_ONLY=false
LOCAL_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --days)
      DAYS_OLD="$2"
      shift 2
      ;;
    --pattern)
      PATTERNS="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --remote-only)
      REMOTE_ONLY=true
      shift
      ;;
    --local-only)
      LOCAL_ONLY=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

# Validation
if [[ "$REMOTE_ONLY" == "true" && "$LOCAL_ONLY" == "true" ]]; then
  echo "ERROR: Cannot specify both --remote-only and --local-only" >&2
  exit 1
fi

if ! [[ "$DAYS_OLD" =~ ^[0-9]+$ ]]; then
  echo "ERROR: --days must be a positive integer" >&2
  exit 1
fi

# Helper functions
note() {
  printf '[%(%H:%M:%S)T] %s\n' -1 "$*"
}

error() {
  printf '[%(%H:%M:%S)T] ERROR: %s\n' -1 "$*" >&2
}

# Check prerequisites
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  error "Not inside a git repository"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  error "git command not found"
  exit 1
fi

note "🔍 Starting branch cleanup analysis..."
note "Days old threshold: $DAYS_OLD"
note "Branch patterns: $PATTERNS"
note "Dry run: $DRY_RUN"
note "Force mode: $FORCE"

# Fetch latest refs
note "Fetching latest refs..."
git fetch --all --prune >/dev/null 2>&1

# Convert patterns to grep regex
GREP_PATTERN=""
for pattern in $PATTERNS; do
  # Convert shell glob to regex
  regex=$(echo "$pattern" | sed 's/\*\*/.*/' | sed 's/\*/[^\/]*/')
  if [[ -z "$GREP_PATTERN" ]]; then
    GREP_PATTERN="^($regex)$"
  else
    GREP_PATTERN="$GREP_PATTERN|^($regex)$"
  fi
done

# Find target branches for main/develop
TARGET_BRANCHES=()
for branch in develop main master; do
  if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    TARGET_BRANCHES+=("origin/$branch")
  fi
done

if [[ ${#TARGET_BRANCHES[@]} -eq 0 ]]; then
  error "No target branches (develop/main/master) found"
  exit 1
fi

note "Target branches for merge detection: ${TARGET_BRANCHES[*]}"

# Function to check if branch is merged
is_merged() {
  local branch="$1"
  local target_branch="$2"
  
  # Check if branch is ancestor of target
  git merge-base --is-ancestor "$branch" "$target_branch" 2>/dev/null
}

# Function to check if branch is old enough
is_old_enough() {
  local branch="$1"
  
  local branch_date
  branch_date=$(git log -1 --format=%ct "$branch" 2>/dev/null || echo "0")
  local cutoff_date=$(($(date +%s) - DAYS_OLD * 86400))
  
  [[ "$branch_date" -lt "$cutoff_date" ]]
}

# Find branches to cleanup
REMOTE_BRANCHES_TO_DELETE=()
LOCAL_BRANCHES_TO_DELETE=()

# Remote branches
if [[ "$LOCAL_ONLY" != "true" ]]; then
  note "🔍 Analyzing remote branches..."
  
  while IFS= read -r branch; do
    [[ -z "$branch" ]] && continue
    
    # Remove origin/ prefix for pattern matching
    branch_name="${branch#origin/}"
    
    # Skip protected branches
    [[ "$branch_name" =~ ^(develop|main|master)$ ]] && continue
    
    # Check pattern
    if echo "$branch_name" | grep -qE "$GREP_PATTERN"; then
      # Check if merged
      is_merged_into_target=false
      for target in "${TARGET_BRANCHES[@]}"; do
        if is_merged "$branch" "$target"; then
          is_merged_into_target=true
          break
        fi
      done
      
      if [[ "$is_merged_into_target" == "true" || "$FORCE" == "true" ]]; then
        if is_old_enough "$branch"; then
          REMOTE_BRANCHES_TO_DELETE+=("$branch_name")
        fi
      fi
    fi
  done < <(git branch -r --format='%(refname:short)' | grep -v HEAD)
fi

# Local branches
if [[ "$REMOTE_ONLY" != "true" ]]; then
  note "🔍 Analyzing local branches..."
  
  while IFS= read -r branch; do
    [[ -z "$branch" ]] && continue
    
    # Skip current branch
    if [[ "$branch" == "$(git branch --show-current)" ]]; then
      continue
    fi
    
    # Skip protected branches
    [[ "$branch" =~ ^(develop|main|master)$ ]] && continue
    
    # Check pattern
    if echo "$branch" | grep -qE "$GREP_PATTERN"; then
      # Check if merged
      is_merged_into_target=false
      for target in "${TARGET_BRANCHES[@]}"; do
        if is_merged "refs/heads/$branch" "$target"; then
          is_merged_into_target=true
          break
        fi
      done
      
      if [[ "$is_merged_into_target" == "true" || "$FORCE" == "true" ]]; then
        if is_old_enough "refs/heads/$branch"; then
          LOCAL_BRANCHES_TO_DELETE+=("$branch")
        fi
      fi
    fi
  done < <(git branch --format='%(refname:short)')
fi

# Report findings
echo
note "📋 Cleanup Summary:"
echo "Remote branches to delete: ${#REMOTE_BRANCHES_TO_DELETE[@]}"
for branch in "${REMOTE_BRANCHES_TO_DELETE[@]}"; do
  echo "  🌐 origin/$branch"
done

echo "Local branches to delete: ${#LOCAL_BRANCHES_TO_DELETE[@]}"
for branch in "${LOCAL_BRANCHES_TO_DELETE[@]}"; do
  echo "  💻 $branch"
done

# Exit if dry run
if [[ "$DRY_RUN" == "true" ]]; then
  echo
  note "🔍 DRY RUN: No branches were deleted"
  exit 0
fi

# Exit if nothing to do
if [[ ${#REMOTE_BRANCHES_TO_DELETE[@]} -eq 0 && ${#LOCAL_BRANCHES_TO_DELETE[@]} -eq 0 ]]; then
  echo
  note "✅ No branches to cleanup"
  exit 0
fi

# Confirmation
if [[ "$FORCE" != "true" ]]; then
  echo
  read -p "❓ Proceed with deletion? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    note "❌ Cleanup cancelled"
    exit 0
  fi
fi

# Perform cleanup
echo
note "🗑️ Starting cleanup..."

# Delete remote branches
if [[ ${#REMOTE_BRANCHES_TO_DELETE[@]} -gt 0 ]]; then
  note "Deleting remote branches..."
  for branch in "${REMOTE_BRANCHES_TO_DELETE[@]}"; do
    echo -n "  Deleting origin/$branch... "
    if git push origin --delete "$branch" >/dev/null 2>&1; then
      echo "✅"
    else
      echo "⚠️ (may already be deleted)"
    fi
  done
fi

# Delete local branches
if [[ ${#LOCAL_BRANCHES_TO_DELETE[@]} -gt 0 ]]; then
  note "Deleting local branches..."
  for branch in "${LOCAL_BRANCHES_TO_DELETE[@]}"; do
    echo -n "  Deleting $branch... "
    if [[ "$FORCE" == "true" ]]; then
      git branch -D "$branch" >/dev/null 2>&1
    else
      git branch -d "$branch" >/dev/null 2>&1
    fi
    echo "✅"
  done
fi

echo
note "🎉 Cleanup completed successfully!"
note "Deleted ${#REMOTE_BRANCHES_TO_DELETE[@]} remote and ${#LOCAL_BRANCHES_TO_DELETE[@]} local branches"
