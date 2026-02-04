# Аудит Dart/Flutter коду: Hardcoded секрети та URL

**Дата аудиту:** 2025-02-02  
**Проект:** /Volumes/workspace-drive/projects/other/crypto_market/crypto_market  
**Scope:** lib/ директорія

---

## 📋 Виконано

1. ✅ Проаналізовано 100+ Dart файлів у lib/ директорії
2. ✅ Перевірено config/, services/, core/ директорії
3. ✅ Виявлено hardcoded URLs, API endpoints, canister IDs
4. ✅ Перевірено використання .env файлу через flutter_dotenv

---

## 🔴 КРИТИЧНІ ЗНАХІДКИ (Hardcoded URLs)

### 1. `lib/core/config/app_constants.dart`
```dart
// Рядок 10 - HARDCODED URL
static const String baseUrl = 'https://api.cryptomarket.com';
```
**Проблема:** API endpoint захардкожено без можливості конфігурації через .env  
**Рекомендація:** Винести в .env файл як `APP_API_URL` та використовувати з `String.fromEnvironment()`

---

### 2. `lib/core/config/shipping_config.dart`
```dart
// Рядки 40-52 - HARDCODED URLs
static String get novaPoshtaBaseUrl {
  switch (mode) {
    case ShippingMode.sandbox:
      return 'https://api-stage.novapost.com/v.1.0/';
    case ShippingMode.production:
      return 'https://api.novaposhta.ua/v2.0/json/';
  }
}

static String get ukrposhtaBaseUrl {
  return 'https://www.ukrposhta.ua/';
}

static String get meestBaseUrl {
  return 'https://api.meest.com/';
}
```
**Проблема:** URL провайдерів доставки захардкожено  
**Рекомендація:** 
- ✅ Nova Poshta URLs - **МОЖНА ЗАЛИШИТИ** (це офіційні API endpoints, не змінюються)
- ⚠️ Ukrposhta/Meest - винести в .env для гнучкості

---

### 3. `lib/core/services/nova_poshta_service.dart`
```dart
// Рядок 7 - HARDCODED URL
static const String _baseUrl = 'https://api.novaposhta.ua/v2.0/json/';
```
**Проблема:** Дублювання URL з shipping_config.dart  
**Рекомендація:** Використовувати ShippingConfig.novaPoshtaBaseUrl замість хардкоду

---

### 4. `lib/core/services/osm_location_service.dart`
```dart
// Рядок 15 - HARDCODED URL
_baseUrl = 'https://photon.komoot.io',
```
**Проблема:** Photon API endpoint захардкожено  
**Рекомендація:** 
- ✅ **МОЖНА ЗАЛИШИТИ** - це публічний geocoding сервіс без автентифікації
- Альтернативно винести в .env для можливості зміни mirror

---

### 5. `lib/core/blockchain/agent_dart_service.dart`
```dart
// Рядок 114 - HARDCODED IC0 APP URL
return 'https://ic0.app';
```
**Проблема:** IC0 APP endpoint для production режиму  
**Рекомендація:** 
- ✅ **МОЖНА ЗАЛИШИТИ** - це офіційний ICP gateway, змінюється рідко
- Можна винести в .env для гнучкості (наприклад, `ICP_GATEWAY_URL`)

---

### 6. `lib/features/payments/services/ipfs_service.dart`
```dart
// Рядок 16 - HARDCODED DEFAULT IPFS GATEWAY
: _ipfsGateway = ipfsGateway ?? config?.ipfsGatewayUrl ?? 'https://ipfs.io/ipfs/';

// Рядок 31 - HARDCODED LOCAL IPFS API
return 'http://localhost:5001/api/v0/add';
```
**Проблема:** Default IPFS gateway та localhost URL  
**Рекомендація:** 
- `https://ipfs.io/ipfs/` - ✅ **МОЖНА ЗАЛИШИТИ** (публічний gateway)
- `localhost:5001` - ✅ **МОЖНА ЗАЛИШИТИ** (тільки для локальної розробки)

---

### 7. `lib/core/blockchain/wallet_service.dart`
```dart
// Рядок 51-55 - HARDCODED METADATA
metadata: const PairingMetadata(
  name: 'Crypto Market',
  description: 'Decentralized P2P Marketplace',
  url: 'https://cryptomarket.io',
  icons: ['https://cryptomarket.io/logo.png'],
  redirect: Redirect(
    native: 'cryptomarket://',
    universal: 'https://cryptomarket.io',
  ),
),
```
**Проблема:** WalletConnect metadata захардкожено  
**Рекомендація:** Винести в .env: `WC_APP_NAME`, `WC_APP_URL`, `WC_REDIRECT_SCHEME`

---

## 🟡 СЕРЕДНІЙ ПРІОРИТЕТ

### 8. `lib/core/auth/jwt_service.dart`
```dart
// Рядок 44 - JWT EXPIRY HARDCODED
_tokenExpiry = tokenExpiry ?? const Duration(hours: 8),
```
**Проблема:** JWT token expiry час захардкожено  
**Рекомендація:** Винести в .env як `JWT_EXPIRY_HOURS`

---

### 9. `lib/core/services/push_notification_service.dart`
```dart
// Рядки 23-29 - HARDCODED NOTIFICATION CHANNEL IDs
static const String _tradeChannelId = 'trade_notifications';
static const String _timeoutChannelId = 'timeout_notifications';
static const String _disputeChannelId = 'dispute_notifications';
```
**Проблема:** Channel IDs захардкожено  
**Рекомендація:** 
- ✅ **МОЖНА ЗАЛИШИТИ** - це internal IDs, не чутливі

---

## 🟢 НИЗЬКИЙ ПРІОРИТЕТ / БЕЗПЕЧНО

### 10. Localhost URLs для розробки
```dart
// agent_dart_service.dart - рядок 106
return 'http://${_config.icpLocalHost}:${_config.icpLocalPort}';

// app_config.dart - рядки 113-116
String get ipfsNodeUrlOrLocal => ipfsNodeUrl ?? 'http://localhost:5001';
String get ipfsGatewayUrlOrLocal => ipfsGatewayUrl ?? 'http://localhost:8080';
```
**Статус:** ✅ **БЕЗПЕЧНО** - тільки для локальної розробки, не використовуються в production

---

## 🔒 Перевірка використання .env

### ✅ ДОБРЕ: Читається з .env через flutter_dotenv

| Файл | Змінні з .env |
|------|---------------|
| `app_config.dart` | CANISTER_ID_MARKETPLACE, CANISTER_ID_USER_MANAGEMENT, CANISTER_ID_ATOMIC_SWAP, CANISTER_ID_PRICE_ORACLE, CANISTER_ID_MESSAGING, CANISTER_ID_DISPUTE, OAUTH_GOOGLE_CLIENT_ID, OAUTH_GOOGLE_CLIENT_SECRET, OAUTH_APPLE_TEAM_ID, OAUTH_APPLE_KEY_ID, IPFS_NODE_URL, IPFS_GATEWAY_URL, PINATA_JWT, JWT_SECRET_KEY, ENCRYPTION_KEY, WALLET_CONNECT_PROJECT_ID, CHAINLINK_API_KEY, COINGECKO_API_KEY, KYC_PROVIDER_API_KEY |
| `shipping_config.dart` | SHIPPING_MODE (через dart-define) |
| `nova_poshta_service.dart` | apiKey (передається як параметр) |
| `agent_dart_service.dart` | ICP_LOCAL_HOST, ICP_LOCAL_PORT |

---

### ❌ ВІДСУТНІ В .env (Hardcoded)

| Файл | Hardcoded значення | Рекомендація |
|------|-------------------|--------------|
| `app_constants.dart` | `https://api.cryptomarket.com` | ⚠️ Винести в .env |
| `shipping_config.dart` | Nova Poshta, Ukrposhta, Meest URLs | ✅ Залишити (API endpoints) |
| `nova_poshta_service.dart` | `https://api.novaposhta.ua/v2.0/json/` | ⚠️ Використовувати ShippingConfig |
| `osm_location_service.dart` | `https://photon.komoot.io` | ✅ Залишити (публічний сервіс) |
| `wallet_service.dart` | WalletConnect metadata | ⚠️ Винести в .env |
| `push_notification_service.dart` | Channel IDs, descriptions | ✅ Залишити (internal IDs) |

---

## 🔑 API Keys & Secrets

### ✅ Правильно використовуються з .env:
- `JWT_SECRET_KEY` - для підпису JWT токенів
- `ENCRYPTION_KEY` - для шифрування даних
- `PINATA_JWT` - для IPFS через Pinata
- `WALLET_CONNECT_PROJECT_ID` - для WalletConnect
- OAuth credentials (Google, Apple)
- Canister IDs (всі 6 canisterів)

### ❌ Не знайдено hardcoded API keys або tokens
**Статус:** ✅ Жодних hardcoded API keys, passwords, tokens не виявлено!

---

## 📝 Canister IDs

### ✅ Правильно: Завантажуються з .env
```dart
// app_config.dart
final String canisterIdMarketplace;      // CANISTER_ID_MARKETPLACE
final String canisterIdUserManagement;   // CANISTER_ID_USER_MANAGEMENT
final String canisterIdAtomicSwap;       // CANISTER_ID_ATOMIC_SWAP
final String canisterIdPriceOracle;      // CANISTER_ID_PRICE_ORACLE
final String canisterIdMessaging;        // CANISTER_ID_MESSAGING
final String canisterIdDispute;          // CANISTER_ID_DISPUTE
```

**Статус:** ✅ Жодних hardcoded canister IDs - все читається з .env!

---

## 📊 Підсумок

### ✅ Безпечно (залишити як є):
1. Canister IDs - всі з .env
2. API Keys - всі з .env
3. Secrets/Tokens - всі з .env
4. Localhost URLs - тільки для dev
5. Public API endpoints (Nova Poshta, Photon, IPFS public gateway)
6. Internal notification channel IDs

### ⚠️ Рекомендується виправити:
1. **`app_constants.dart:10`** - `baseUrl` → винести в .env
2. **`wallet_service.dart:51`** - WalletConnect metadata → винести в .env
3. **`nova_poshta_service.dart:7`** - Дублювання URL → використовувати ShippingConfig

### 📋 Рекомендовані зміни в .env:
```bash
# Додати нові змінні:
APP_API_URL=https://api.cryptomarket.com
WC_APP_NAME="Crypto Market"
WC_APP_URL=https://cryptomarket.io
WC_REDIRECT_SCHEME=cryptomarket
WC_ICON_URL=https://cryptomarket.io/logo.png
```

---

## 🎯 Висновок

**Загальна оцінка:** ✅ **ДОБРЕ**

Код добре структурований з точки зору безпеки:
- ✅ Всі критичні секрети (API keys, JWT secret, encryption keys) читаються з .env
- ✅ Canister IDs конфігуруються через .env
- ✅ Використовується `flutter_dotenv` для завантаження конфігурації
- ✅ Підтримка dart-define для compile-time конфігурації

**Мінімальні ризики:** Невеликі hardcoded URLs для публічних API endpoints, що є прийнятною практикою.
