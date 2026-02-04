#!/bin/bash
# auto-recover.sh: Automatic context recovery after /new or /reset
# This script runs automatically via BOOTSTRAP.md protocol

set -e

MEMORY_DIR="/Users/vitaliisimko/clawd/memory"
DATE=$(date +%Y-%m-%d)

echo "🔄 AUTO-RECOVERY: Starting context restoration..."
echo ""

# Step 1: Find handoff file
echo "📄 Step 1: Finding handoff file..."
HANDOFF_FILE=$(ls -t $MEMORY_DIR/HANDOFF-SESSION-*.md 2>/dev/null | head -1)
LEGACY_HANDOFF=$(ls -t $MEMORY_DIR/HANDOFF-SUPERNEW-*.md 2>/dev/null | head -1)

if [ -n "$HANDOFF_FILE" ]; then
    echo "✅ Found: $HANDOFF_FILE"
elif [ -n "$LEGACY_HANDOFF" ]; then
    echo "⚠️  Found legacy handoff: $LEGACY_HANDOFF"
    HANDOFF_FILE="$LEGACY_HANDOFF"
else
    echo "⚠️  No handoff file found — relying on vector memory only"
fi

echo ""
echo "🧠 Step 2: Vector memory recovery queries"
echo "   Run these memory_search commands:"
echo ""
echo "   memory_search({query: \"job_detective статус налаштування\", maxResults: 5})"
echo "   memory_search({query: \"OpenCode MiniMax M2.1 workflow\", maxResults: 3})"
echo "   memory_search({query: \"сессія відновлення контекст\", maxResults: 3})"
echo "   memory_search({query: \"останній проект статус\", maxResults: 5})"
echo "   memory_search({query: \"поточні задачі\", maxResults: 5})"
echo ""

# Step 3: Check vector memory files
echo "📂 Step 3: Checking vector memory files..."
if [ -f "$MEMORY_DIR/$DATE.md" ]; then
    echo "✅ Today's memory file exists: memory/$DATE.md"
    echo "   Lines: $(wc -l < "$MEMORY_DIR/$DATE.md")"
else
    echo "⚠️  Today's memory file not found: memory/$DATE.md"
fi

if [ -f "/Users/vitaliisimko/clawd/SOUL.md" ]; then
    echo "✅ SOUL.md exists"
fi

if [ -f "/Users/vitaliisimko/clawd/TOOLS.md" ]; then
    echo "✅ TOOLS.md exists"
fi

echo ""
echo "🎯 Step 4: Recovery complete!"
echo ""
echo "📝 GREETING TEMPLATE:"
echo '   "Йоу! 🤙 Відновив контекст після /new.'
echo '    '
echo '    [Коротке резюме знайденого в пам\'яті]'
echo '    '
echo '    Продовжуємо?"'
echo ""

if [ -n "$HANDOFF_FILE" ]; then
    echo "🧹 Step 5: Cleanup"
    echo "   After successful recovery, delete:"
    echo "   rm $HANDOFF_FILE"
fi

echo ""
echo "✅ Auto-recovery protocol complete!"
echo "   Context should now be restored from vector memory."

exit 0