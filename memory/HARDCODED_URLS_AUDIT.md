# Аудит Hardcoded Значень в Коді

## Дата: 2026-02-02

### 🔴 КРИТИЧНО: Hardcoded URLs в Dart коді

Ці файли мають hardcoded замість читання з конфігурації:

#### 1. lib/core/config/app_constants.dart
```dart
static const String baseUrl = 'https://api.cryptomarket.com';
```
**Проблема:** Має бути різний для staging/production

#### 2. lib/core/config/shipping_config.dart
```dart
return 'https://api-stage.novapost.com/v.1.0/';  // staging
return 'https://api.novaposhta.ua/v2.0/json/';   // production
return 'https://www.ukrposhta.ua/';
return 'https://api.meest.com/';
```
**Проблема:** URL захардкоджені, мають братися з .env

#### 3. lib/core/blockchain/blockchain_verification_service.dart
```dart
rpcUrl = 'https://eth.llamarpc.com';
rpcUrl = 'https://binance.llamarpc.com';
rpcUrl = 'https://polygon.llamarpc.com';
'https://mempool.space/api/address/$address';
'https://api.mainnet-beta.solana.com';
'https://api.trongrid.io/wallet/getaccount';
'https://ic-api.internetcomputer.org/api/v1/accounts/$target';
```
**Проблема:** Всі RPC URLs захардкоджені

---

### ✅ РІШЕННЯ

Всі ці URL вже є в `secrets/run-config.yaml`:
- `external_apis.app_api.staging/production`
- `external_apis.shipping.*`
- `external_apis.blockchain_fallback.*`
- `blockchain_rpc.staging/production.*`

**Треба зробити:**
1. Винести ці значення в `.env` файли (вже робить run-sync-config.sh)
2. Оновити Dart код читати з `Platform.environment` замість hardcoded

---

### 📝 ПРИОРИТЕТ

**Варіант А (Рекомендовано):** Залишити як є зараз
- Ці URL публічні (не секретні)
- Не критично для безпеки
- Можна виправити пізніше

**Варіант Б:** Виправити зараз
- Оновити Dart код
- Додати flutter_dotenv пакет
- Перевірити що все читається з .env

---

### 🎯 СТАТУС

- ✅ Скрипти читають з `secrets/run-config.yaml`
- ✅ .env файли генеруються автоматично
- ⚠️  Dart код ще має hardcoded URLs (не критично)

