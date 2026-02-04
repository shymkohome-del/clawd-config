#!/bin/bash
# Швидка перевірка стану пам'яті

echo "🧠 Clawdbot Memory Status"
echo "========================="

# Статус
echo ""
clawdbot memory status 2>/dev/null | grep -E "Indexed|Dirty|Vector|cache" | head -5

# Перевірка векторів
SQLITE_DB="$HOME/.clawdbot/memory/main.sqlite"
CHUNKS=$(sqlite3 "$SQLITE_DB" "SELECT COUNT(*) FROM chunks;" 2>/dev/null)
VECTORS=$(sqlite3 "$SQLITE_DB" "SELECT COUNT(*) FROM chunks_vec_rowids;" 2>/dev/null)

echo ""
echo "📊 Chunks: $CHUNKS | Vectors: $VECTORS"

if [ "$CHUNKS" -eq "$VECTORS" ]; then
    echo "✅ Синхронізовано"
else
    echo "🚨 Потрібна реіндексація! Запусти: ckfix"
fi

echo ""
echo "Останні помилки readonly: $(grep -c 'readonly database' /tmp/clawdbot/clawdbot-$(date +%Y-%m-%d).log 2>/dev/null || echo 0)"
