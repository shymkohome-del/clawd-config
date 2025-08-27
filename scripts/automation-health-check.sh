#!/bin/bash
# Automation Health Check Script
# Verifies that our auto-merge system is properly configured

set -euo pipefail

OWNER="${GITHUB_REPOSITORY_OWNER:-$(git config --get remote.origin.url | sed -n 's#.*github\.com[/:]\\([^/]*\\)/.*#\\1#p')}"
REPO="${GITHUB_REPOSITORY_NAME:-$(basename -s .git $(git config --get remote.origin.url))}"

echo "🔍 Automation Health Check for ${OWNER}/${REPO}"
echo "================================================="

# Check 1: Branch protection rules
echo "📋 Checking branch protection rules..."
EXPECTED_CONTEXTS=(
    "QA Gate / qa-approved"
    "build-and-test" 
    "pr-lint"
    "lint"
)

if command -v gh >/dev/null 2>&1; then
    CURRENT_CONTEXTS=$(gh api repos/"${OWNER}"/"${REPO}"/branches/develop/protection/required_status_checks --jq '.contexts' 2>/dev/null || echo "[]")
    echo "Current required contexts: $CURRENT_CONTEXTS"
    
    # Verify all expected contexts are present
    MISSING=()
    for context in "${EXPECTED_CONTEXTS[@]}"; do
        if ! echo "$CURRENT_CONTEXTS" | jq -e --arg ctx "$context" 'any(. == $ctx)' >/dev/null; then
            MISSING+=("$context")
        fi
    done
    
    if [ ${#MISSING[@]} -eq 0 ]; then
        echo "✅ All required contexts are configured"
    else
        echo "❌ Missing contexts: ${MISSING[*]}"
        echo "🔧 Run this to fix:"
        CONTEXTS_JSON=$(printf '%s\n' "${EXPECTED_CONTEXTS[@]}" | jq -R . | jq -s .)
        echo "echo '{\"strict\":true,\"contexts\":$CONTEXTS_JSON}' | gh api repos/${OWNER}/${REPO}/branches/develop/protection/required_status_checks -X PATCH --input -"
    fi
else
    echo "⚠️  GitHub CLI not available, skipping branch protection check"
fi

# Check 2: Workflow files exist
echo ""
echo "📄 Checking critical workflow files..."
WORKFLOWS=(
    ".github/workflows/qa-gate.yml"
    ".github/workflows/flutter-ci.yml"  
    ".github/workflows/pr-lint.yml"
    ".github/workflows/workflow-lint.yml"
    ".github/workflows/auto-pr-from-qa.yml"
    ".github/workflows/reusable-auto-pr.yml"
)

ALL_PRESENT=true
for workflow in "${WORKFLOWS[@]}"; do
    if [[ -f "$workflow" ]]; then
        echo "✅ $workflow"
    else
        echo "❌ $workflow (MISSING)"
        ALL_PRESENT=false
    fi
done

# Check 3: Agent configurations
echo ""
echo "🤖 Checking agent configurations..."
AGENTS=(
    ".github/chatmodes/qa.chatmode.md"
    ".github/chatmodes/dev.chatmode.md"
)

for agent in "${AGENTS[@]}"; do
    if [[ -f "$agent" ]]; then
        if grep -q "qa:approved" "$agent" 2>/dev/null; then
            echo "✅ $agent (has workflow integration)"
        else
            echo "⚠️  $agent (missing workflow integration)"
        fi
    else
        echo "❌ $agent (MISSING)"
        ALL_PRESENT=false
    fi
done

# Summary
echo ""
echo "🏁 Summary"
echo "=========="
if $ALL_PRESENT; then
    echo "✅ Automation system health check PASSED"
    echo "🚀 Auto-merge should work correctly for QA-approved PRs"
else
    echo "❌ Automation system health check FAILED"  
    echo "🔧 Please fix the missing components above"
    exit 1
fi
