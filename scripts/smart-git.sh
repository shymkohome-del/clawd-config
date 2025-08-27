#!/bin/bash
# Smart Git Workflow Helper
# Provides safe commands that enforce proper branching

set -euo pipefail

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
PROTECTED_BRANCHES=("main" "master" "develop" "staging" "production")

# Check if current branch is protected
is_protected_branch() {
    for protected in "${PROTECTED_BRANCHES[@]}"; do
        if [[ "$CURRENT_BRANCH" == "$protected" ]]; then
            return 0
        fi
    done
    return 1
}

# Smart commit function
smart_commit() {
    if is_protected_branch; then
        echo "🚫 Cannot commit directly to protected branch '$CURRENT_BRANCH'"
        echo ""
        echo "✅ Creating feature branch for you..."
        FEATURE_BRANCH="feature/$(date +%Y%m%d-%H%M%S)"
        git checkout -b "$FEATURE_BRANCH"
        echo "   Switched to new branch: $FEATURE_BRANCH"
        echo ""
        echo "🔄 Now committing your changes..."
        git add .
        git commit "$@"
        echo ""
        echo "🚀 Next steps:"
        echo "   git push -u origin $FEATURE_BRANCH"
        echo "   gh pr create --base develop"
    else
        echo "✅ Committing to feature branch '$CURRENT_BRANCH'"
        git add .
        git commit "$@"
    fi
}

# Smart switch to develop with sync
smart_develop() {
    echo "🔄 Switching to develop and syncing..."
    git checkout develop
    git pull origin develop
    echo "✅ Ready for new feature work!"
    echo ""
    echo "🚀 To start new feature:"
    echo "   git checkout -b feature/your-feature-name"
}

# Smart feature branch creation
smart_feature() {
    if [[ $# -eq 0 ]]; then
        echo "❌ Usage: smart-feature <feature-name>"
        echo "   Example: smart-feature user-authentication"
        return 1
    fi
    
    FEATURE_NAME="$1"
    FEATURE_BRANCH="feature/$FEATURE_NAME"
    
    # Ensure we're on latest develop
    echo "🔄 Ensuring latest develop..."
    git checkout develop
    git pull origin develop
    
    # Create and switch to feature branch
    echo "🌿 Creating feature branch: $FEATURE_BRANCH"
    git checkout -b "$FEATURE_BRANCH"
    git push -u origin "$FEATURE_BRANCH"
    
    echo "✅ Ready to work on feature: $FEATURE_NAME"
}

# Clean up merged branches
smart_cleanup() {
    echo "🧹 Cleaning up merged branches..."
    
    # Switch to develop and pull latest
    git checkout develop
    git pull origin develop
    
    # Delete merged local branches
    git branch --merged develop | grep -v develop | grep -v master | grep -v main | while read -r branch; do
        if [[ ! "$branch" =~ ^\* ]]; then
            echo "🗑️  Deleting merged branch: $branch"
            git branch -d "$branch"
        fi
    done
    
    # Prune remote tracking branches
    git remote prune origin
    
    echo "✅ Cleanup complete!"
}

# Main command dispatcher
case "${1:-help}" in
    "commit"|"c")
        shift
        smart_commit "$@"
        ;;
    "develop"|"dev"|"d")
        smart_develop
        ;;
    "feature"|"f")
        shift
        smart_feature "$@"
        ;;
    "cleanup"|"clean")
        smart_cleanup
        ;;
    "help"|*)
        echo "🚀 Smart Git Workflow Helper"
        echo "============================"
        echo ""
        echo "Commands:"
        echo "  commit, c [message]     Smart commit (auto-creates feature branch if needed)"
        echo "  develop, dev, d         Switch to develop and sync"
        echo "  feature, f <name>       Create new feature branch from latest develop"
        echo "  cleanup, clean          Clean up merged branches"
        echo "  help                    Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 feature user-auth"
        echo "  $0 commit -m \"Add user authentication\""
        echo "  $0 develop"
        echo "  $0 cleanup"
        ;;
esac
