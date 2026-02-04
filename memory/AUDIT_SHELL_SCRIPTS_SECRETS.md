# 🔒 АУДИТ SHELL СКРИПТІВ - HARDCODED СЕКРЕТИ

**Проєкт:** crypto_market  
**Дата:** 2025-01-21  
**Виконав:** Subagent Audit  
**Загальна кількість скриптів:** 193 (після виключення node_modules/build)

---

## 🚨 КРИТИЧНІ ЗНАХІДКИ (Негайне виправлення!)

### 1. secrets/run-config.yaml - HARDCODED СЕКРЕТИ

**Файл:** `/Volumes/workspace-drive/projects/other/crypto_market/secrets/run-config.yaml`

**Знайдені секрети:**

| Тип | Значення | Рядок |
|-----|----------|-------|
| **PINATA_JWT** | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (повний JWT токен) | staging.app_config.flavors.stg |
| **NOVA_POSHTA_SANDBOX_API_KEY** | `0e2a76e0e87e633e50ed42b207d9c757e062a90c` | dev & staging |
| **UKRPOSHTA_API_KEY** | `test-ukrposhta-key` | dev |
| **MEEST_API_KEY** | `test-meest-key` | dev |
| **OAUTH_GOOGLE_CLIENT_SECRET** | `test-client-secret-dev` | dev |
| **JWT_SECRET_KEY** | `dev-jwt-secret-key-local-32h` | dev |
| **ENCRYPTION_KEY** | `dev-encryption-key-local-32h` | dev |

**Ризик:** КРИТИЧНИЙ  
**Наслідки:**
- JWT токен Pinata може бути використаний для доступу до IPFS сховища
- API ключі поштових сервісів
- Секрети OAuth можуть бути скомпрометовані
- Файл у git історії - видалення не достатньо!

**Рекомендації:**
1. ⚠️ **НЕГАЙНО відкликати всі знайдені секрети:**
   - Видалити JWT токен Pinata та згенерувати новий
   - Відкликати Nova Poshta API ключ
   - Відкликати Google OAuth credentials
2. Використовувати `.env` файли замість YAML для секретів
3. Додати `secrets/` до `.gitignore` (якщо ще не додано)
4. Використовувати git-filter-repo або BFG для видалення з історії
5. Розглянути AWS Secrets Manager, HashiCorp Vault, або 1Password Secrets Automation

---

## ⚠️ ВИСОКИЙ РИЗИК

### 2. safety-check.sh - Hardcoded Production IDs

**Файл:** `/Volumes/workspace-drive/projects/other/crypto_market/crypto_market/scripts/safety/safety-check.sh`

**Знайдено:**
```bash
declare -A PROD_CANISTER_IDS=(
    ["atomic_swap"]="6p4bg-hiaaa-aaaad-ad6ea-cai"
    ["marketplace"]="6b6mo-4yaaa-aaaad-ad6fa-cai"
    ["user_management"]="6i5hs-kqaaa-aaaad-ad6eq-cai"
    ["price_oracle"]="6g7k2-raaaa-aaaad-ad6fq-cai"
    ["messaging"]="6ty3x-qiaaa-aaaad-ad6ga-cai"
    ["dispute"]="6uz5d-5qaaa-aaaad-ad6gq-cai"
    ["performance_monitor"]="652w7-lyaaa-aaaad-ad6ha-cai"
)

PROD_IDENTITY_PRINCIPAL="4gcgh-7p3b4-gznop-3q5kh-sx3zl-fz2qd-6cmhh-gxdd6-g6agu-zptr7-kqe"
LOCAL_IDENTITY_PRINCIPAL="bibc2-doxoe-vtsrh-skwdg-yzeth-le466-hgo3f-ykxin-6woib-pwask-zae"
```

**Ризик:** ВИСОКИЙ  
**Причина:** Це не секрети, але це hardcoded конфігурація, яка має бути винесена в конфігураційний файл.

**Рекомендації:**
1. Перенести canister IDs у `secrets/run-config.yaml` (або окремий конфіг)
2. Перенести principals у конфігураційний файл
3. Скрипт має читати з конфігу, а не мати hardcoded значення

### 3. switch-identity.sh - Hardcoded Production IDs

**Файл:** `/Volumes/workspace-drive/projects/other/crypto_market/crypto_market/scripts/safety/switch-identity.sh`

**Знайдено:**
```bash
PRODUCTION_IDENTITY="ic_user"
PRODUCTION_PRINCIPAL="4gcgh-7p3b4-gznop-3q5kh-sx3zl-fz2qd-6cmhh-gxdd6-g6agu-zptr7-kqe"
LOCAL_IDENTITY="default"
LOCAL_PRINCIPAL="bibc2-doxoe-vtsrh-skwdg-yzeth-le466-hgo3f-ykxin-6woib-pwask-zae"

STAGING_ATOMIC_SWAP="6p4bg-hiaaa-aaaad-ad6ea-cai"
# ... інші canister IDs
```

**Ризик:** ВИСОКИЙ  
**Рекомендації:** Ті ж самі, що й для safety-check.sh

---

## ⚡ СЕРЕДНІЙ РИЗИК

### 4. run_manual_qa.sh - Hardcoded Addresses

**Файл:** `/Volumes/workspace-drive/projects/other/crypto_market/crypto_market/run_manual_qa.sh`

**Знайдено:**
```bash
SOL_ADDRESS="8xaVAq1L897hKrAuyuXgkvJczPFMrQXecM5srpGnMbk9"
ETH_ADDRESS="0xa83b38cf5544fb897b9ab6565c947d81255952c8"
```

**Ризик:** СЕРЕДНІЙ  
**Причина:** Тестові адреси, але краще винести в конфігурацію.

**Рекомендації:**
1. Винести в `.env.test` або `run-config.yaml` в секцію testing
2. Або передавати як аргументи скрипту

### 5. build-android.sh / build-ios.sh - Secrets у Dart Defines

**Файли:**
- `/Volumes/workspace-drive/projects/other/crypto_market/scripts/build-android.sh`
- `/Volumes/workspace-drive/projects/other/crypto_market/scripts/build-ios.sh`

**Проблема:**
```bash
DART_DEFINES="$DART_DEFINES --dart-define=JWT_SECRET_KEY=$JWT_SECRET_KEY"
DART_DEFINES="$DART_DEFINES --dart-define=ENCRYPTION_KEY=$ENCRYPTION_KEY"
DART_DEFINES="$DART_DEFINES --dart-define=OAUTH_GOOGLE_CLIENT_SECRET=$OAUTH_GOOGLE_CLIENT_SECRET"
```

**Ризик:** СЕРЕДНІЙ  
**Причина:** 
- Секрети передаються як `--dart-define` і **вбудовуються в бінарник APK/IPA**
- Будь-хто може декомпілювати APK і витягнути ці значення

**Рекомендації:**
1. ❌ Не передавати секрети через `--dart-define` для production
2. ✅ Для production використовувати:
   - Android Keystore System
   - iOS Keychain
   - Secure storage (flutter_secure_storage)
   - Server-side конфігурацію
3. Для CI/CD використовувати environment variables без запису в код

---

## ✅ ПРАВИЛЬНА РЕАЛІЗАЦІЯ

### Скрипти які правильно читають з secrets/run-config.yaml:

| Скрипт | Опис |
|--------|------|
| `run-sync-config.sh` | Читає конфігурацію через `yq` з YAML |
| `common-utils.sh` | Функції `normalize_network()`, `get_flavor()` читають з YAML |
| `run-configure-canisters.sh` | Читає RPC конфігурацію з YAML |

**Приклад правильного підходу:**
```bash
CONFIG_FILE="$PROJECT_ROOT/secrets/run-config.yaml"
NETWORK=$(yq eval ".environments.$ENVIRONMENT.network" "$CONFIG_FILE")
FLAVOR=$(yq eval ".environments.$ENVIRONMENT.flavor" "$CONFIG_FILE")
```

---

## 📋 ЗВІТ ПО СКРИПТАХ

### Всі проаналізовані скрипти (193 шт.):

| Категорія | Кількість | Статус |
|-----------|-----------|--------|
| Без hardcoded секретів | ~185 | ✅ Безпечні |
| З hardcoded конфігурацією | 4 | ⚠️ Рекомендовано винести в конфіг |
| З hardcoded секретами | 1 (run-config.yaml) | 🚨 Критично |
| З ризиком вбудовування секретів | 2 (build-*.sh) | ⚠️ Потребує уваги |

### Скрипти зі знайденими проблемами:

1. 🚨 **secrets/run-config.yaml** - Hardcoded JWT, API keys
2. ⚠️ **safety-check.sh** - Hardcoded canister IDs, principals
3. ⚠️ **switch-identity.sh** - Hardcoded canister IDs, principals  
4. ⚠️ **run_manual_qa.sh** - Hardcoded test addresses
5. ⚠️ **build-android.sh** - Secrets в dart-define
6. ⚠️ **build-ios.sh** - Secrets в dart-define

---

## 🔧 РЕКОМЕНДОВАНІ ДІЇ (Пріоритет)

### Негайно (Critical):
1. [ ] Відкликати всі секрети з `secrets/run-config.yaml`
2. [ ] Видалити/замінити файл у git історії
3. [ ] Перевірити git logs на наявність інших секретів

### Високий пріоритет:
4. [ ] Винести canister IDs з safety-check.sh в конфіг
5. [ ] Винести principals з switch-identity.sh в конфіг
6. [ ] Перевірити, чи `secrets/` в `.gitignore`

### Середній пріоритет:
7. [ ] Рефакторинг build-android.sh - прибрати secrets з dart-define
8. [ ] Рефакторинг build-ios.sh - прибрати secrets з dart-define
9. [ ] Винести test addresses з run_manual_qa.sh в конфіг

### Профілактика:
10. [ ] Встановити pre-commit hook для перевірки секретів (gitleaks, trufflehog)
11. [ ] Налаштувати GitHub secret scanning
12. [ ] Додати CI перевірку на hardcoded secrets

---

## 📚 КОРИСНІ ІНСТРУМЕНТИ

### Для пошуку секретів:
```bash
# Gitleaks - перевірка на секрети
gitleaks detect --source /path/to/repo

# TruffleHog - пошук секретів в git історії
trufflehog git file://./ --only-verified

# Git-secrets - AWS секрети
git secrets --scan
```

### Для видалення з історії:
```bash
# BFG Repo-Cleaner
bfg --delete-files run-config.yaml

# Або git-filter-repo
git filter-repo --path secrets/run-config.yaml --invert-paths
```

---

## Висновок

Аудит виявив **1 критичну**, **2 високих**, та **3 середніх** ризики. Головна проблема - hardcoded секрети у `secrets/run-config.yaml`. Негайно потрібно відкликати ці секрети та видалити їх з git історії.

Загальна оцінка безпеки скриптів: **🔴 ВИМОГАЄ НЕГАЙНИХ ДІЙ**

---
*Звіт згенеровано автоматично. Для уточнень звертайтесь до провідного розробника безпеки.*
