# 🔒 Аудит конфігураційних файлів - Розосереджені секрети

**Дата аудиту:** 2025-01-21  
**Проєкт:** crypto_market  
**Аудитор:** Clawdbot Subagent

---

## 📋 Резюме

Знайдено **КРИТИЧНІ** проблеми з розосередженням секретів у проєкті. Багато файлів містять дубльовані API ключі, токени та конфіденційні дані. Частина файлів у git, частина - у .gitignore.

---

## 🚨 Файли з секретами

### 1. ANTHROPIC API KEYS (Критично)

| Файл | Статус Git | Секрети |
|------|-----------|---------|
| `.claude/settings.json` | ✅ **В GIT** | ANTHROPIC_AUTH_TOKEN, ANTHROPIC_API_KEY |
| `.claude/settings.loca.json` | ✅ **В GIT** | ANTHROPIC_AUTH_TOKEN, ANTHROPIC_API_KEY |
| `secrets/external-apis/settings.local.json` | ❌ В .gitignore | ANTHROPIC_AUTH_TOKEN |
| `_bmad/my-custom-agents/settings.local.json` | ❌ В .gitignore | ANTHROPIC_AUTH_TOKEN |
| `_bmad/_config/custom/my-custom-agents/settings.local.json` | ❌ В .gitignore | ANTHROPIC_AUTH_TOKEN |

**Значення що дублюється:**
```
65fc6f4280cb404faca027de5084d7be.HrGbMyjZWAilLEDt
```

**Дублювання:**
- ✅ `.claude/settings.json` - 2 входження (backup + env)
- ✅ `.claude/settings.loca.json` - 2 входження
- ✅ `secrets/external-apis/settings.local.json` - 1 входження
- ✅ `_bmad/my-custom-agents/settings.local.json` - 1 входження
- ✅ `_bmad/_config/custom/my-custom-agents/settings.local.json` - 1 входження

---

### 2. NOVA POSHTA API KEY (Критично)

| Файл | Статус Git | Секрет |
|------|-----------|--------|
| `secrets/run-config.yaml` | ❌ В .gitignore | NOVA_POSHTA_SANDBOX_API_KEY |
| `_bmad/my-custom-agents/workflows/run/config/run-config.yaml` | ❌ В .gitignore | NOVA_POSHTA_SANDBOX_API_KEY |
| `_bmad/_config/custom/my-custom-agents/workflows/run/config/run-config.yaml` | ❌ В .gitignore | NOVA_POSHTA_SANDBOX_API_KEY |
| `crypto_market/.env` | ⚠️ Перевірити | NOVA_POSHTA_SANDBOX_API_KEY |
| `.env` | ⚠️ Перевірити | NOVA_POSHTA_SANDBOX_API_KEY |

**Значення що дублюється:**
```
0e2a76e0e87e633e50ed42b207d9c757e062a90c
```

**Дублювання:** 8+ входжень у різних файлах!

---

### 3. PINATA JWT TOKEN (Критично)

| Файл | Статус Git | Секрет |
|------|-----------|--------|
| `secrets/run-config.yaml` | ❌ В .gitignore | PINATA_JWT |
| `_bmad/my-custom-agents/workflows/run/config/run-config.yaml` | ❌ В .gitignore | PINATA_JWT |
| `_bmad/_config/custom/my-custom-agents/workflows/run/config/run-config.yaml` | ❌ В .gitignore | PINATA_JWT |

**JWT Token:** Довгий JWT токен для Pinata IPFS сервісу (баз64)

---

### 4. CANISTER IDs (Середня важливість)

| Файл | Статус Git | Вміст |
|------|-----------|-------|
| `secrets/canister_ids.json` | ❌ В .gitignore | Canister IDs для staging/local |
| `crypto_market/canister_ids.json` | ⚠️ Перевірити | Canister IDs |
| `crypto_market/.dfx/local/canister_ids.json` | ⚠️ Зазвичай .gitignore | Local canister IDs |
| `crypto_market/.dfx/playground/canister_ids.json` | ⚠️ Зазвичай .gitignore | Playground IDs |

---

### 5. DFX Identity файли (Критично)

| Файл | Статус Git | Вміст |
|------|-----------|-------|
| `secrets/dfx-identities/ic_user/identity.json` | ❌ В .gitignore | Identity конфіг |
| `~/.config/dfx/identity/ic_user/identity.json` | 📁 Зовнішній | Identity конфіг |
| `~/.config/dfx/identity/dev.vitalii.shymko/identity.json` | 📁 Зовнішній | Identity конфіг |

**Примітка:** DFX identity файли знаходяться поза проєктом у `~/.config/dfx/`

---

## 📊 Порівняння з secrets/run-config.yaml

### Дублювання значень з `secrets/run-config.yaml`:

| Ключ | Дублюється у | Кількість |
|------|-------------|-----------|
| `NOVA_POSHTA_SANDBOX_API_KEY` | 3 run-config.yaml + .env файли | 8+ |
| `PINATA_JWT` | 3 run-config.yaml | 3 |
| `ANTHROPIC_AUTH_TOKEN` | 5 JSON файлів | 7+ |

---

## ⚠️ Проблеми безпеки

### 🔴 Критичні (Вимагають негайної дії)

1. **ANTHROPIC ключі у GIT** (`.claude/settings.json`, `.claude/settings.loca.json`)
   - Ризик: Ключі в історії git
   - Дія: Видалити з git, додати до .gitignore, ротувати ключі

2. **Масове дублювання API ключів**
   - NOVA_POSHTA_SANDBOX_API_KEY: 8+ копій
   - ANTHROPIC токени: 7+ копій
   - Ризик: Складність оновлення, розсинхронізація

3. **JWT токен у декількох файлах**
   - PINATA JWT у 3+ файлах

### 🟡 Середні

4. **Розосередження конфігурацій**
   - 3+ копії run-config.yaml у різних директоріях `_bmad/`
   - Невідповідність між копіями (різні значення PINATA_JWT)

5. **Canister IDs**
   - Можливо в git (потрібна перевірка)

---

## 📁 Структура файлів

```
secrets/
├── run-config.yaml                    # Головний (reference)
├── canister_ids.json                  # Canister IDs
├── external-apis/
│   └── settings.local.json            # ANTHROPIC токен
└── dfx-identities/
    └── ic_user/
        └── identity.json              # Identity

.claude/
├── settings.json                      # ❌ В GIT - ANTHROPIC KEYS!
└── settings.loca.json                 # ❌ В GIT - ANTHROPIC KEYS!

_bmad/my-custom-agents/
├── settings.local.json                # ANTHROPIC токен
└── workflows/run/config/run-config.yaml  # Дубль run-config

_bmad/_config/custom/my-custom-agents/
├── settings.local.json                # ANTHROPIC токен
└── workflows/run/config/run-config.yaml  # Дубль run-config
```

---

## ✅ Рекомендації

### Негайно (Критично)

1. **Ротувати всі ANTHROPIC ключі**
   ```bash
   # Ключі що потребують ротації:
   # - 65fc6f4280cb404faca027de5084d7be.HrGbMyjZWAilLEDt
   # - sk-a73c5956995f4696846de41d0fe55b87
   ```

2. **Видалити секрети з git історії**
   ```bash
   git filter-branch --force --index-filter \
   'git rm --cached --ignore-unmatch .claude/settings.json .claude/settings.loca.json' \
   --prune-empty --tag-name-filter cat -- --all
   ```

3. **Додати до .gitignore** (якщо ще не додано)
   ```
   .claude/settings*.json
   .env
   crypto_market/.env
   ```

### Короткострокові

4. **Єдине джерело правди**
   - Залишити тільки `secrets/run-config.yaml`
   - Видалити дублікати:
     - `_bmad/my-custom-agents/workflows/run/config/run-config.yaml`
     - `_bmad/_config/custom/my-custom-agents/workflows/run/config/run-config.yaml`
   - Створити symlink або скрипт копіювання

5. **Автоматична перевірка дублювання**
   ```bash
   # Додати до CI/CD
   grep -r "API_KEY\|TOKEN\|SECRET" --include="*.yaml" --include="*.json" . \
   | grep -v secrets/ | grep -v node_modules
   ```

### Довгострокові

6. **Використовувати secret management**
   - GitHub Secrets для CI/CD
   - Doppler або 1Password Secrets Automation
   - HashiCorp Vault для production

7. **Пре-коміт хуки**
   ```yaml
   # .pre-commit-config.yaml
   - repo: https://github.com/Yelp/detect-secrets
     hooks:
     - id: detect-secrets
   ```

---

## 📈 Статистика

| Показник | Значення |
|----------|----------|
| Всього файлів проскановано | 400+ |
| Файлів з секретами | 12+ |
| Файлів у git з секретами | 2 (КРИТИЧНО) |
| Унікальних секретів | 5+ |
| Кількість дублювань | 20+ |

---

## 🔍 Команди для перевірки

```bash
# Знайти всі файли з секретами
grep -r -l "API_KEY\|SECRET\|TOKEN\|PASSWORD" \
  --include="*.yaml" --include="*.json" --include="*.env" \
  . 2>/dev/null | grep -v node_modules | grep -v ".dart_tool"

# Перевірити дублювання конкретного ключа
grep -r "0e2a76e0e87e633e50ed42b207d9c757e062a90c" \
  --include="*.yaml" --include="*.json" . 2>/dev/null

# Перевірити git статус
git ls-files | grep -E '\.(yaml|json)$' | xargs grep -l "API_KEY\|SECRET" 2>/dev/null
```

---

*Звіт згенеровано автоматично. Вимагає рев'ю інженера безпеки.*
