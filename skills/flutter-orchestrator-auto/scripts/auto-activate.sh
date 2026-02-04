#!/bin/bash
# Flutter Orchestrator Auto-Activation Script
# Trigger: /new session, /flutter command, or gateway wake

set -e

echo "🔄 Flutter Orchestrator Auto-Activation Starting..."

# Step 1: Vector Memory Recovery
echo "📡 Recovering context from vector memory..."

# These will be executed by clawdbot memory_search tool
cat << 'EOF'
AUTO_RECOVERY_QUERIES:
1. flutter orchestrator crypto_market статус
2. останній проект статус  
3. правила безпеки canister IDs
4. підопічні агенти sub-agents
5. /run workflow deployment
EOF

# Step 2: Verify Critical Files Exist
echo "📁 Verifying critical files..."

CRITICAL_FILES=(
  "memory/CRYPTO_MARKET_SAFETY_VAULT.md"
  "memory/ENVIRONMENT_SAFETY_MANIFEST.md"
  "memory/AGENT_SAFETY_GUIDELINES.md"
  "_bmad/my-custom-agents/data/safety-protocol.md"
  "_bmad/my-custom-agents/data/flutter-rules.md"
  "_bmad/my-custom-agents/data/flutter-driver-mcp-guide.md"
  "_bmad/my-custom-agents/data/protocols/autonomous_protocol.md"
  "_bmad/my-custom-agents/data/protocols/sub-agent-manifest.yaml"
  "_bmad/my-custom-agents/workflows/run/workflow.md"
)

for file in "${CRITICAL_FILES[@]}"; do
  if [ -f "/Users/vitaliisimko/clawd/$file" ]; then
    echo "  ✓ $file"
  else
    echo "  ⚠ $file (will read via memory_search)"
  fi
done

# Step 3: Status Check
echo ""
echo "🎯 Auto-activation sequence complete!"
echo ""
echo "Next: Load all critical files and embody flutter-orchestrator persona"
