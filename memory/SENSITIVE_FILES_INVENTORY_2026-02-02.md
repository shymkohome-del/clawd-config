# СПИСОК ЧУТЛИВИХ ФАЙЛІВ (Sensitive Files Inventory)
# Створено: 2026-02-02
# Призначення: Бекап перед реструктуризацією

## 🔴 КРИТИЧНО: Головний конфіг (єдина точка правди)

### 1. run-config.yaml (ОСНОВНИЙ файл з усіма секретами)
```
/Users/vitaliisimko/workspace/projects/other/crypto_market/_bmad/my-custom-agents/workflows/run/config/run-config.yaml
```
**Містить:**
- PINATA_JWT (Pinata токен)
- NOVA_POSHTA_SANDBOX_API_KEY
- UKRPOSHTA_API_KEY
- MEEST_API_KEY
- OAUTH_GOOGLE_CLIENT_SECRET
- JWT_SECRET_KEY
- ENCRYPTION_KEY
- OAUTH_APPLE_KEY_ID

### 2. Шаблон (не чутливий, але важливий)
```
/Users/vitaliisimko/workspace/projects/other/crypto_market/_bmad/my-custom-agents/workflows/run/config/run-config.yaml.example
```

---

## 🟡 DFX Identity файли (ключі для блокчейну)

### 3. ic_user (Staging identity)
```
~/.config/dfx/identity/ic_user/identity.json
~/.config/dfx/identity/ic_user/wallets.json
~/.config/dfx/identity/ic_user/identity.pem (якщо є)
```

### 4. default (Local identity)
```
~/.config/dfx/identity/default/identity.pem
~/.config/dfx/identity/default/wallets.json
~/.config/dfx/identity/default/identity.json
```

### 5. Інші identities
```
~/.config/dfx/identity/dev.vitalii.shymko/identity.json
~/.config/dfx/identity/dev.vitalii.shymko/wallets.json
~/.config/dfx/identity/seller_test/identity.json
~/.config/dfx/identity/seller_test/identity.pem
~/.config/dfx/identity/seller_test/wallets.json
~/.config/dfx/identity/qa_user/identity.json
~/.config/dfx/identity/qa_user/identity.pem
~/.config/dfx/identity/qa_user/wallets.json
~/.config/dfx/identity/debugging_identity/identity.json
~/.config/dfx/identity/debugging_identity/wallets.json
```

### 6. Головний dfx конфіг
```
~/.config/dfx/identity.json
~/.config/dfx/config.json
```

---

## 🟠 .env файли (згенеровані, але містять секрети)

### 7. Поточні .env файли
```
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.stg
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.prod
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.dev
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.staging
```

### 8. Кореневі .env
```
/Users/vitaliisimko/workspace/projects/other/crypto_market/.env
/Users/vitaliisimko/workspace/projects/other/crypto_market/.env.example
```

---

## 🔵 Інші API токени

### 9. Anthropic/BMAD налаштування
```
/Users/vitaliisimko/workspace/projects/other/crypto_market/_bmad/my-custom-agents/settings.local.json
/Users/vitaliisimko/workspace/projects/other/crypto_market/_bmad/_config/custom/my-custom-agents/settings.local.json
```

### 10. Canister IDs (не чутливі але важливі)
```
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/canister_ids.json
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.dfx/local/canister_ids.json
```

---

## ⚠️ СТАРІ БЕКАПИ (можна видалити після реструктуризації)

### 11. .env бекапи (займають місце)
```
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_154628
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_154753
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_155043
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_155056
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_155105
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_160544
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_161407
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_164544
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_171405
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_171431
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_172109
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_172124
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_180412
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_180422
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_181132
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_181149
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_191913
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.backup.20260202_192747
```

### 12. run-config бекапи
```
/Users/vitaliisimko/workspace/projects/other/crypto_market/_bmad/my-custom-agents/workflows/run/config/run-config.yaml.backup.20260202_164612
/Users/vitaliisimko/workspace/projects/other/crypto_market/_bmad/my-custom-agents/workflows/run/config/run-config.yaml.bak
/Users/vitaliisimko/workspace/projects/other/crypto_market/_bmad/my-custom-agents/workflows/run/config/run-config.yaml.bak.bak
```

### 13. Інші бекапи
```
/Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env.fixed
```

---

## 📝 КОМАНДА ДЛЯ БЕКАПУ

Запусти це щоб створити бекап директорію:

```bash
mkdir -p ~/Desktop/crypto-market-secrets-backup-2026-02-02

# 1. run-config.yaml
cp /Users/vitaliisimko/workspace/projects/other/crypto_market/_bmad/my-custom-agents/workflows/run/config/run-config.yaml ~/Desktop/crypto-market-secrets-backup-2026-02-02/

# 2. DFX identities
cp -r ~/.config/dfx/identity ~/Desktop/crypto-market-secrets-backup-2026-02-02/
cp ~/.config/dfx/identity.json ~/Desktop/crypto-market-secrets-backup-2026-02-02/
cp ~/.config/dfx/config.json ~/Desktop/crypto-market-secrets-backup-2026-02-02/

# 3. .env файли
mkdir ~/Desktop/crypto-market-secrets-backup-2026-02-02/env-files
cp /Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/.env* ~/Desktop/crypto-market-secrets-backup-2026-02-02/env-files/
cp /Users/vitaliisimko/workspace/projects/other/crypto_market/.env* ~/Desktop/crypto-market-secrets-backup-2026-02-02/env-files/

# 4. API settings
cp /Users/vitaliisimko/workspace/projects/other/crypto_market/_bmad/my-custom-agents/settings.local.json ~/Desktop/crypto-market-secrets-backup-2026-02-02/

# 5. Canister IDs
cp /Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market/canister_ids.json ~/Desktop/crypto-market-secrets-backup-2026-02-02/

echo "Бекап готовий в: ~/Desktop/crypto-market-secrets-backup-2026-02-02/"
```

---

## ⚡ ПРІОРИТЕТИ (що ОБОВ'ЯЗКОВО зберегти)

**🔴 КРИТИЧНО (відновити неможливо):**
1. `~/.config/dfx/identity/ic_user/` - ключі для staging
2. `~/.config/dfx/identity/default/identity.pem` - ключі для local
3. `run-config.yaml` - всі API ключі та конфігурація

**🟡 ВАЖЛИВО (можна відновити але складно):**
4. Canister IDs - щоб не шукати заново
5. Інші .env файли - для історії

**🟢 НЕ ОБОВ'ЯЗКОВО (згенерується заново):**
6. Бекапи (.env.backup.*)
7. Кеші та тимчасові файли
