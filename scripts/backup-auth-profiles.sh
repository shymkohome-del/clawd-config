#!/bin/bash
# Бекап auth-profiles.json при змінах

AUTH_FILE="$HOME/.clawdbot/agents/main/agent/auth-profiles.json"
BACKUP_DIR="$HOME/.clawdbot/backups/auth"

mkdir -p "$BACKUP_DIR"

# Бекап при кожному запуску
if [ -f "$AUTH_FILE" ]; then
    cp "$AUTH_FILE" "$BACKUP_DIR/auth-profiles.json.backup.$(date +%Y%m%d_%H%M%S)"
    # Залишаємо тільки останні 10 бекапів
    ls -t "$BACKUP_DIR"/auth-profiles.json.backup.* 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true
fi

# Перевірка чи є kimi-code і openrouter
if ! grep -q "kimi-code:default" "$AUTH_FILE" 2>/dev/null; then
    echo "⚠️  УВАГА: kimi-code:default відсутній в auth-profiles.json!" >&2
    echo "Відновлюємо з clawdbot.json..." >&2
    
    # Автоматичне відновлення
    KIMI_KEY=$(grep -A2 '"kimi-code:default"' "$HOME/.clawdbot/clawdbot.json" | grep '"key"' | head -1 | sed 's/.*"key": "\([^"]*\)".*/\1/')
    OR_KEY=$(grep -A2 '"openrouter:default"' "$HOME/.clawdbot/clawdbot.json" | grep '"key"' | head -1 | sed 's/.*"key": "\([^"]*\)".*/\1/')
    
    cat > "$AUTH_FILE" << AUTHJSON
{
  "version": 1,
  "profiles": {
    "kimi-code:default": {
      "type": "api_key",
      "provider": "kimi-code",
      "key": "$KIMI_KEY"
    },
    "openrouter:default": {
      "type": "api_key",
      "provider": "openrouter",
      "key": "$OR_KEY"
    }
  },
  "lastGood": {
    "kimi-code": "kimi-code:default",
    "openrouter": "openrouter:default"
  }
}
AUTHJSON
    
    echo "✅ Auth profiles відновлено автоматично" >&2
fi
