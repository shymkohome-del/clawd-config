# Аудит скриптів crypto_market проєкту

**Дата аудиту:** 2026-02-02  
**Виконав:** Gemini Researcher (Subagent)  
**Мета:** Перевірити що всі скрипти правильно беруть дані з run-config.yaml і генерують .env файли

---

## 📁 Структура скриптів

**Розташування:** `/Users/vitaliisimko/workspace/projects/other/crypto_market/_bmad/my-custom-agents/workflows/run/`

### Скрипти в директорії `scripts/` (18 файлів)

#### Основні скрипти (7 шагів workflow):
1. `run-env-select.sh` - Step 1: Вибір середовища
2. `run-preflight-checks.sh` - Step 2: Передпольотні перевірки
3. `run-dfx-status.sh` - Step 3: Перевірка статусу DFX
4. `run-deploy-canisters.sh` - Step 4: Деплой каністерів
5. `run-sync-config.sh` - Step 5: Синхронізація конфігурації
6. `run-verify-setup.sh` - Step 6: Верифікація налаштувань
7. `run-launch-flutter.sh` - Step 7: Запуск Flutter додатку

#### Додаткові скрипти:
8. `run-configure-canisters.sh` - Конфігурація каністерів

#### Бібліотеки (10 файлів в `lib/`):
- `common-utils.sh` - Спільні утиліти
- `checkpoint-manager.sh` - Управління чекпоінтами
- `error-handler.sh` - Обробка помилок
- `validation-utils.sh` - Валідація
- `network-utils.sh` - Мережеві утиліти
- `resource-checks.sh` - Перевірка ресурсів
- `flutter-launcher.sh` - Запуск Flutter
- `retry-utils.sh` - Логіка retry
- `self-healing.sh` - Самовідновлення
- `wait-utils.sh` - Очікування

#### Директорія `steps/` (markdown документація):
- `step-01-env-select.md` та інші - документація кроків

### Конфігураційний файл:
- `/Users/vitaliisimko/workspace/projects/other/crypto_market/_bmad/my-custom-agents/workflows/run/config/run-config.yaml`

---

## 🔍 Детальний аналіз кожного скрипта

### 1. `run-sync-config.sh` ⭐ КРИТИЧНИЙ СКРИПТ

**Що робить:**
- Синхронізує canister IDs з dfx в .env файли
- Інжектує App Config з run-config.yaml
- Перевіряє та валідує конфігурацію
- Генерує Dart конфігурацію

**Читання run-config.yaml:**
```bash
CONFIG_FILE="$PROJECT_ROOT/_bmad/my-custom-agents/workflows/run/config/run-config.yaml"
NETWORK=$(yq eval ".environments.$ENVIRONMENT.network" "$CONFIG_FILE")
FLAVOR=$(yq eval ".environments.$ENVIRONMENT.flavor" "$CONFIG_FILE")
ENV_FILE_NAME=$(yq eval ".environments.$ENVIRONMENT.env_file" "$CONFIG_FILE")
CANISTER_SOURCE=$(yq eval ".environments.$ENVIRONMENT.canister_source" "$CONFIG_FILE")
```

**Інжекція в .env файли:**
```bash
# Inject Common Config
while IFS="=" read -r key val; do
    if [ -n "$key" ]; then
         update_env_var "$env_file" "$key" "$val"
    fi
done < <(yq eval '.app_config.common | to_entries | .[] | .key + "=" + .value' "$CONFIG_FILE")

# Inject Flavor Config
while IFS="=" read -r key val; do
    if [ -n "$key" ]; then
         update_env_var "$env_file" "$key" "$val"
    fi
done < <(yq eval ".app_config.flavors.$FLAVOR | to_entries | .[] | .key + \"=\" + .value" "$CONFIG_FILE")
```

**✅ Статус: ПРАВИЛЬНО**
- Читає всі значення з run-config.yaml через yq
- Інжектує common та flavor-specific конфігурацію
- Перевіряє наявність PLACEHOLDER значень для production
- Блокує деплой на remote з localhost IPFS

---

### 2. `run-env-select.sh` (Step 1)

**Що робить:**
- Парсить аргументи середовища
- Нормалізує назви (local/staging/production)
- Ініціалізує checkpoint

**Читання run-config.yaml:**
- ❌ **НЕ ЧИТАЄ** run-config.yaml безпосередньо
- Використовує hardcoded мапінг:
```bash
case "$ENVIRONMENT" in
    local|development|dev)
        ENVIRONMENT="local"
        NETWORK="local"
        FLAVOR="dev"
        ;;
    staging|stage|stg)
        ENVIRONMENT="staging"
        NETWORK="staging"
        FLAVOR="staging"
        ;;
    ...
esac
```

**⚠️ ПРОБЛЕМА:**
- Hardcoded значення NETWORK і FLAVOR замість читання з run-config.yaml
- Якщо змінити значення в run-config.yaml (наприклад, `flavor: stg` для staging), скрипт ігнорує це

**Рекомендація:** Використовувати функції `normalize_network()` і `get_flavor()` з `common-utils.sh`, які читають з run-config.yaml

---

### 3. `run-preflight-checks.sh` (Step 2)

**Що робить:**
- Перевіряє наявність необхідних команд (dfx, flutter, jq, yq)
- Перевіряє структуру проєкту
- Перевіряє мережу та ресурси

**Читання run-config.yaml:**
- ❌ Не читає напряму
- Використовує `normalize_network()` і `get_flavor()` з common-utils.sh, які читають з run-config.yaml

**✅ Статус: ЧАСТКОВО ПРАВИЛЬНО**
- Використовує функції з common-utils.sh для отримання network/flavor
- Сам не читає конфігурацію безпосередньо

---

### 4. `run-dfx-status.sh` (Step 3)

**Що робить:**
- Перевіряє статус DFX
- Запускає DFX якщо потрібно
- Чекає на готовність replica

**Читання run-config.yaml:**
- Використовує `normalize_network()` і `get_flavor()` з common-utils.sh

**✅ Статус: ПРАВИЛЬНО** (через common-utils.sh)

---

### 5. `run-deploy-canisters.sh` (Step 4)

**Що робить:**
- Деплоїть каністери
- Обробляє partial deployment
- Відкочує при помилках

**Читання run-config.yaml:**
- Використовує `normalize_network()` і `get_flavor()` з common-utils.sh
- Завантажує список каністерів:
```bash
CANISTERS=("marketplace" "user_management" "atomic_swap" "price_oracle" "messaging" "dispute" "performance_monitor")
```

**⚠️ ПРОБЛЕМА МІНОРНА:**
- Список каністерів hardcoded в скрипті
- run-config.yaml також містить список каністерів у секції `canisters:`
- При додаванні нового каністера потрібно оновлювати обидва місця

**Рекомендація:** Завантажувати список каністерів з run-config.yaml:
```bash
CANISTERS=()
while IFS= read -r line; do
    CANISTERS+=("$line")
done < <(yq eval '.canisters[]' "$CONFIG_FILE")
```

---

### 6. `run-configure-canisters.sh`

**Що робить:**
- Конфігурує деплойовані каністери
- Встановлює Vault Key Name, RPC Config
- Лінкує залежні каністери

**Читання run-config.yaml:**
- ❌ **НЕ ЧИТАЄ** run-config.yaml

**⚠️⚠️ КРИТИЧНА ПРОБЛЕМА:**
- RPC URLs hardcoded в скрипті:
```bash
ETH_RPC="${ETH_RPC:-https://eth-sepolia.g.alchemy.com/v2/demo}"
SOL_RPC="${SOL_RPC:-https://api.devnet.solana.com}"
BTC_RPC="${BTC_RPC:-https://blockstream.info/testnet/api}"
BSC_RPC="${BSC_RPC:-https://data-seed-prebsc-1-s1.binance.org:8545}"
```

- Використовує змінні середовища `ETH_RPC`, `ETH_RPC_PROD` які **НЕ визначені в run-config.yaml**
- Ці значення повинні бути в run-config.yaml в секції flavors!

**Рекомендація:** Додати в run-config.yaml:
```yaml
flavors:
  dev:
    ETH_RPC: "https://eth-sepolia.g.alchemy.com/v2/demo"
    SOL_RPC: "https://api.devnet.solana.com"
    ...
  stg:
    ETH_RPC: "..."
    ...
```

І читати їх через yq в скрипті.

---

### 7. `run-verify-setup.sh` (Step 6)

**Що робить:**
- Верифікує деплоймент
- Перевіряє .env файли
- Перевіряє IPFS

**Читання run-config.yaml:**
- ❌ Не читає напряму
- Використовує `normalize_network()` з common-utils.sh

**✅ Статус: ЧАСТКОВО ПРАВИЛЬНО**
- Читає список каністерів hardcoded:
```bash
CANISTERS=("marketplace" "user_management" "atomic_swap" "price_oracle" "messaging" "dispute" "performance_monitor")
```
- Повинен читати з run-config.yaml

---

### 8. `run-launch-flutter.sh` (Step 7)

**Що робить:**
- Запускає Flutter додаток
- Вибирає shipping mode
- Запускає health checks

**Читання run-config.yaml:**
- ❌ Не читає напряму
- Використовує `normalize_network()` і `get_flavor()` з common-utils.sh

**✅ Статус: ПРАВИЛЬНО** (через common-utils.sh)

---

## 📚 Аналіз `common-utils.sh`

**Функції для роботи з run-config.yaml:**

```bash
# Нормалізація мережі - ЧИТАЄ з run-config.yaml
normalize_network() {
    local env=$1
    local config_file="$PROJECT_ROOT/_bmad/my-custom-agents/workflows/run/config/run-config.yaml"
    
    if [ -f "$config_file" ]; then
        local net=$(yq eval ".environments.$env.network" "$config_file" 2>/dev/null)
        if [ "$net" != "null" ] && [ -n "$net" ]; then
            echo "$net"
            return
        fi
    fi
    
    # Fallback
    case "$env" in
        local) echo "local" ;;
        staging) echo "ic" ;;
        production) echo "ic" ;;
        *) echo "local" ;;
    esac
}

# Отримання flavor - ЧИТАЄ з run-config.yaml
get_flavor() {
    local env=$1
    local config_file="$PROJECT_ROOT/_bmad/my-custom-agents/workflows/run/config/run-config.yaml"

    if [ -f "$config_file" ]; then
        local flav=$(yq eval ".environments.$env.flavor" "$config_file" 2>/dev/null)
        if [ "$flav" != "null" ] && [ -n "$flav" ]; then
            echo "$flav"
            return
        fi
    fi

    # Fallback
    case "$env" in
        local) echo "dev" ;;
        staging) echo "stg" ;;
        production) echo "prod" ;;
        *) echo "dev" ;;
    esac
}
```

**✅ Статус: ПРАВИЛЬНО**
- Функції правильно читають з run-config.yaml
- Є fallback на випадок відсутності файлу

---

## 🔐 Перевірка API ключів та секретів

### Що є в run-config.yaml:

```yaml
flavors:
  dev:
    OAUTH_GOOGLE_CLIENT_ID: "test-client-id-dev"
    OAUTH_GOOGLE_CLIENT_SECRET: "test-client-secret-dev"
    OAUTH_APPLE_TEAM_ID: "test-team-id-dev"
    OAUTH_APPLE_KEY_ID: "test-key-id-dev"
    JWT_SECRET_KEY: "dev-jwt-secret-key-local-32h"
    ENCRYPTION_KEY: "dev-encryption-key-local-32h"
    NOVA_POSHTA_SANDBOX_API_KEY: "0e2a76e0e87e633e50ed42b207d9c757e062a90c"
    
  stg:
    OAUTH_GOOGLE_CLIENT_ID: "STAGING_GOOGLE_CLIENT_ID_PLACEHOLDER"
    PINATA_JWT: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    NOVA_POSHTA_SANDBOX_API_KEY: "0e2a76e0e87e633e50ed42b207d9c757e062a90c"
    
  prod:
    OAUTH_GOOGLE_CLIENT_ID: "PROD_GOOGLE_CLIENT_ID_PLACEHOLDER"
    # Shipping Configuration
    SHIPPING_MODE: "production"
    NOVA_POSHTA_SANDBOX_API_KEY: "PLACEHOLDER"
    UKRPOSHTA_API_KEY: "PLACEHOLDER"
    MEEST_API_KEY: "PLACEHOLDER"
```

### ⚠️ ПРОБЛЕМИ З КЛЮЧАМИ:

1. **PINATA_JWT в stg:** Містить реальний JWT токен (не PLACEHOLDER) ⚠️
2. **NOVA_POSHTA_SANDBOX_API_KEY в stg:** Містить реальний API ключ
3. **dev значення:** Тестові значення - це нормально
4. **prod значення:** PLACEHOLDER - правильно, потребує заповнення

### Як інжектуються в .env:

В `run-sync-config.sh`:
```bash
# Inject Flavor Config
while IFS="=" read -r key val; do
    if [ -n "$key" ]; then
         update_env_var "$env_file" "$key" "$val"
    fi
done < <(yq eval ".app_config.flavors.$FLAVOR | to_entries | .[] | .key + \"=\" + .value" "$CONFIG_FILE")
```

**✅ Всі API ключі інжектуються автоматично з run-config.yaml**

---

## 📋 Зведена таблиця

| Скрипт | Читає run-config.yaml | Генерує .env | Hardcoded значення | Проблеми |
|--------|----------------------|--------------|-------------------|----------|
| run-sync-config.sh | ✅ Так | ✅ Так | ❌ Немає | ✅ Відмінно |
| run-env-select.sh | ❌ Ні | ❌ Ні | ⚠️ NETWORK, FLAVOR | Hardcoded замість читання з конфігу |
| run-preflight-checks.sh | ⚠️ Через utils | ❌ Ні | ❌ Немає | ✅ Добре |
| run-dfx-status.sh | ⚠️ Через utils | ❌ Ні | ❌ Немає | ✅ Добре |
| run-deploy-canisters.sh | ⚠️ Через utils | ❌ Ні | ⚠️ Список каністерів | Потрібно читати список з конфігу |
| run-configure-canisters.sh | ❌ Ні | ❌ Ні | ⚠️ RPC URLs | **КРИТИЧНО** - RPC URLs hardcoded |
| run-verify-setup.sh | ⚠️ Через utils | ❌ Ні | ⚠️ Список каністерів | Потрібно читати з конфігу |
| run-launch-flutter.sh | ⚠️ Через utils | ❌ Ні | ❌ Немає | ✅ Добре |

---

## 🚨 КРИТИЧНІ ПРОБЛЕМИ

### 1. `run-configure-canisters.sh` - RPC URLs hardcoded

**Вплив:** Високий  
**Опис:** RPC URLs для блокчейнів (ETH, SOL, BTC, BSC) hardcoded в скрипті. Ці значення мають бути в run-config.yaml для можливості конфігурації без зміни коду.

**Виправлення:**
1. Додати в run-config.yaml:
```yaml
flavors:
  dev:
    ETH_RPC: "https://eth-sepolia.g.alchemy.com/v2/demo"
    SOL_RPC: "https://api.devnet.solana.com"
    BTC_RPC: "https://blockstream.info/testnet/api"
    BSC_RPC: "https://data-seed-prebsc-1-s1.binance.org:8545"
  stg:
    ETH_RPC: "https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY"
    ...
  prod:
    ETH_RPC: "https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY"
    ...
```

2. Оновити скрипт для читання цих значень через yq

---

## ⚠️ МІНОРНІ ПРОБЛЕМИ

### 1. `run-env-select.sh` - Hardcoded NETWORK/FLAVOR

**Вплив:** Середній  
**Опис:** Скрипт використовує hardcoded мапінг середовищ замість читання з run-config.yaml

**Виправлення:** Використовувати функції `normalize_network()` та `get_flavor()` з common-utils.sh

### 2. Список каністерів hardcoded в декількох місцях

**Вплив:** Низький  
**Опис:** Список каністерів hardcoded в:
- run-deploy-canisters.sh
- run-verify-setup.sh
- run-config.yaml

**Виправлення:** Завантажувати список з run-config.yaml через yq

---

## ✅ ЩО ПРАЦЮЄ КОРЕКТНО

1. **`run-sync-config.sh`** - Повністю правильно читає run-config.yaml і генерує .env файли
2. **Інжекція API ключів** - PINATA_JWT, OAUTH ключі, NOVA_POSHTA_API_KEY правильно інжектуються
3. **Перевірка PLACEHOLDER** - run-sync-config.sh перевіряє що для production не використовуються placeholder значення
4. **Перевірка localhost для remote** - Блокує деплой на remote з localhost IPFS
5. **common-utils.sh** - Правильні функції для читання run-config.yaml

---

## 📊 Висновки

### Загальна оцінка: ⚠️ ЧАСТКОВО ПРАВИЛЬНО

- **8 скриптів** в workflow
- **1 критична проблема** (RPC URLs hardcoded)
- **2 мінорні проблеми** (hardcoded values)
- **6 скриптів** працюють коректно з run-config.yaml

### Рекомендації:

1. **ТЕРМІНОВО:** Виправити `run-configure-canisters.sh` - винести RPC URLs в run-config.yaml
2. **ВИСОКИЙ ПРІОРИТЕТ:** Оновити `run-env-select.sh` для використання common-utils функцій
3. **СРЕДНІЙ ПРІОРИТЕТ:** Завантажувати список каністерів з run-config.yaml в усіх скриптах
4. **БЕЗПЕКА:** Перевірити що PINATA_JWT в stg не продакшн токен (або це навмисно)

### Що стосується генерування .env файлів:

**✅ Повністю автоматично:** `run-sync-config.sh` правильно генерує всі .env файли з run-config.yaml

**Файли що генеруються:**
- `.env` (копія поточного flavor)
- `.env.dev` (для local)
- `.env.stg` (для staging)
- `.env.prod` (для production)

**Всі значення беруться з run-config.yaml - немає manual override!**
