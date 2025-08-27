# Git Configuration for Crypto Market Project
# Run: source scripts/git-config-setup.sh

# Set pull strategy to avoid divergence issues
git config pull.rebase false  # Use merge strategy for pulls

# Set default branch name for new repositories
git config init.defaultBranch main

# Enable automatic branch cleanup after merge
git config fetch.prune true

# Set up helpful aliases
git config alias.sw 'switch'
git config alias.co 'checkout'  
git config alias.br 'branch'
git config alias.st 'status'
git config alias.cm 'commit -m'
git config alias.ps 'push'
git config alias.pl 'pull'
git config alias.lg 'log --oneline --graph --decorate --all'
git config alias.cleanup-merged '!git branch --merged develop | grep -v develop | grep -v master | grep -v main | xargs -n 1 git branch -d'

# Smart workflow aliases that use our scripts
git config alias.smart-commit '!bash scripts/smart-git.sh commit'
git config alias.smart-feature '!bash scripts/smart-git.sh feature'  
git config alias.smart-develop '!bash scripts/smart-git.sh develop'
git config alias.smart-cleanup '!bash scripts/smart-git.sh cleanup'

echo "✅ Git configuration applied!"
echo ""
echo "🎯 New Git Aliases Available:"
echo "   git smart-commit -m \"message\"  # Safe commit (auto-creates feature branch)"
echo "   git smart-feature <name>        # Create feature branch from latest develop"
echo "   git smart-develop               # Switch to develop and sync safely"
echo "   git smart-cleanup               # Clean up merged branches"
echo ""
echo "📚 Standard aliases:"
echo "   git lg                          # Pretty log graph"
echo "   git cleanup-merged              # Delete locally merged branches"
