#!/bin/bash
# Clawdbot Memory Maintenance Script
# Автоматична підтримка векторної пам'яті

set -e

LOG_FILE="/tmp/clawdbot-memory-maintenance.log"
SQLITE_DB="$HOME/.clawdbot/memory/main.sqlite"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

log "=== Початок перевірки пам'яті ==="

# 1. Перевірка прав на базу
if [ -f "$SQLITE_DB" ]; then
    PERMS=$(stat -f "%Lp" "$SQLITE_DB" 2>/dev/null || stat -c "%a" "$SQLITE_DB" 2>/dev/null)
    if [ "$PERMS" != "666" ]; then
        log "⚠️  Виправляємо права на базу (було: $PERMS)"
        chmod 666 "$SQLITE_DB"
        log "✅ Права виправлено на 666"
    else
        log "✅ Права на базу OK (666)"
    fi
else
    log "❌ База не знайдена: $SQLITE_DB"
    exit 1
fi

# 2. Перевірка кількості векторів vs chunks
CHUNKS=$(sqlite3 "$SQLITE_DB" "SELECT COUNT(*) FROM chunks;" 2>/dev/null || echo "0")
VECTORS=$(sqlite3 "$SQLITE_DB" "SELECT COUNT(*) FROM chunks_vec_rowids;" 2>/dev/null || echo "0")

log "📊 Статистика: Chunks=$CHUNKS, Vectors=$VECTORS"

if [ "$CHUNKS" -ne "$VECTORS" ]; then
    log "🚨 Розбіжність! Chunks ($CHUNKS) ≠ Vectors ($VECTORS)"
    log "🔄 Запускаємо повну реіндексацію..."
    
    # Перевіряємо чи запущений gateway
    if pgrep -f "clawdbot gateway" > /dev/null; then
        clawdbot memory index 2>&1 | tee -a "$LOG_FILE"
        
        # Перевіряємо результат
        NEW_VECTORS=$(sqlite3 "$SQLITE_DB" "SELECT COUNT(*) FROM chunks_vec_rowids;" 2>/dev/null || echo "0")
        log "✅ Реіндексація завершена. Нових векторів: $NEW_VECTORS"
    else
        log "⚠️  Gateway не запущений, пропускаємо реіндексацію"
    fi
else
    log "✅ Векторний індекс синхронізований ($CHUNKS векторів)"
fi

# 3. Перевірка embedding cache
CACHE_ENTRIES=$(sqlite3 "$SQLITE_DB" "SELECT COUNT(*) FROM embedding_cache;" 2>/dev/null || echo "0")
log "📦 Embedding cache: $CACHE_ENTRIES entries"

# 4. Локальна реіндексація (легка) - кожен запуск
if pgrep -f "clawdbot gateway" > /dev/null; then
    log "🔄 Швидка реіндексація..."
    timeout 60 clawdbot memory index 2>&1 | tail -3 | tee -a "$LOG_FILE" || log "⏱️  Таймаут реіндексації (нормально)"
fi

# 5. Перевірка readonly errors в логах
READONLY_ERRORS=$(grep -c "readonly database" /tmp/clawdbot/clawdbot-$(date +%Y-%m-%d).log 2>/dev/null || echo "0")
if [ "$READONLY_ERRORS" -gt 0 ]; then
    log "⚠️  Знайдено $READONLY_ERRORS помилок readonly сьогодні"
else
    log "✅ Помилок readonly немає"
fi

log "=== Перевірка завершена ==="
echo ""
