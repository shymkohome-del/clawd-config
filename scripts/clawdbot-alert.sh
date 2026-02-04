#!/bin/bash
# Сповіщення про критичні проблеми з пам'яттю

SQLITE_DB="$HOME/.clawdbot/memory/main.sqlite"
ALERT_LOG="/tmp/clawdbot-alerts.log"

# Перевірка чи є критичні проблеми
CHUNKS=$(sqlite3 "$SQLITE_DB" "SELECT COUNT(*) FROM chunks;" 2>/dev/null || echo "0")
VECTORS=$(sqlite3 "$SQLITE_DB" "SELECT COUNT(*) FROM chunks_vec_rowids;" 2>/dev/null || echo "0")
READONLY_ERRORS=$(grep -c "readonly database" /tmp/clawdbot/clawdbot-$(date +%Y-%m-%d).log 2>/dev/null || echo "0")

ALERT_MSG=""

if [ "$CHUNKS" -ne "$VECTORS" ] && [ "$CHUNKS" -gt 0 ]; then
    ALERT_MSG="🚨 Векторний індекс не синхронізований! Chunks: $CHUNKS, Vectors: $VECTORS"
fi

if [ "$READONLY_ERRORS" -gt 10 ]; then
    ALERT_MSG="$ALERT_MSG\n⚠️ Багато помилок readonly: $READONLY_ERRORS"
fi

if [ -n "$ALERT_MSG" ]; then
    echo -e "[$$(date '+%Y-%m-%d %H:%M:%S')] $ALERT_MSG" >> "$ALERT_LOG"
    # Можна додати відправку в Telegram через clawdbot
    # echo "$ALERT_MSG" | clawdbot message send --channel telegram --target @Vatalion 2>/dev/null || true
fi
