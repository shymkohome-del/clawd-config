# IPFS Хостинг Провайдери для Staging Середовища

**Дата дослідження:** Січень 2025  
**Вимоги:** Віддалений (remote), децентралізований IPFS, безкоштовний tier

---

## 1. Pinata

### Основна інформація
- **Назва:** Pinata
- **URL реєстрації:** https://app.pinata.cloud/auth/sign-up
- **Документація:** https://docs.pinata.cloud/

### Безкоштовний Tier (Free Plan)
- **Обсяг сховища:** 1 GB
- **Кількість файлів:** 500 файлів
- **Пропускна здатність (Bandwidth):** 10 GB
- **Кількість запитів:** 10,000 запитів
- **Gateway:** 1 dedicated gateway
- **Тип:** Постійно безкоштовний (не trial)

### Аутентифікація
- **Тип:** JWT (JSON Web Token)
- **API Key:** Підтримуються обмежені API keys з різними правами доступу
- **Авторизація:** Bearer token у заголовку HTTP запитів

### SDK та Клієнти
- **JavaScript/TypeScript SDK:** ✅ Офіційний SDK (`pinata` npm package)
- **React Hooks:** ✅ Pinata React SDK
- **Go SDK:** ❌ (тільки HTTP API)
- **Flutter/Dart:** ❌ Немає офіційного SDK

### Flutter/Dart Сумісність
- **Пряма сумісність:** ❌ Офіційного Dart SDK немає
- **HTTP API:** ✅ Можна використовувати REST API напряму
- **Реалізація:** Потрібно реалізувати власний Dart клієнт для HTTP API
- **Приклад API endpoint:** `https://uploads.pinata.cloud/v3/files`

### Переваги
- Найпопулярніший IPFS провайдер
- Відмінна документація
- Потужний SDK для JavaScript
- Gateway з CDN
- Приватні файли (private IPFS)

### Недоліки
- Обмежений безкоштовний tier (1GB)
- Немає офіційного Dart/Flutter SDK

---

## 2. Storacha (колишній web3.storage)

### Основна інформація
- **Назва:** Storacha (rebrand від web3.storage)
- **URL реєстрації:** https://console.storacha.network/
- **Документація:** https://docs.storacha.network/
- **Сайт:** https://storacha.network/

### Безкоштовний Tier (Mild Plan)
- **Обсяг сховища:** 5 GB
- **Пропускна здатність (Egress):** 5 GB
- **Додатково:** $0.15/GB за перевищення
- **Тип:** Постійно безкоштовний (не trial)

### Платні Tiers
- **Medium:** $10/місяць - 100 GB storage + 100 GB egress
- **Extra Spicy:** $100/місяць - 2 TB storage + 2 TB egress

### Аутентифікація
- **Тип:** UCANs (User Controlled Authorization Networks)
- **Метод:** Децентралізована ідентифікація
- **Альтернатива:** Email/password через консоль

### SDK та Клієнти
- **JavaScript/TypeScript:** ✅ Офіційний JS Client
- **Go:** ✅ Офіційний Go Client
- **CLI:** ✅ Офіційний CLI
- **Flutter/Dart:** ❌ Немає офіційного SDK

### Flutter/Dart Сумісність
- **Пряма сумісність:** ❌ Офіційного Dart SDK немає
- **HTTP API:** ✅ Можна використовувати HTTP API
- **Альтернатива:** Можна використовувати Go Client через FFI (не рекомендовано)

### Особливості
- Побудований на Filecoin та IPFS
- Децентралізована архітектура (справжній IPFS)
- UCANs для авторизації
- 99.9% доступність
- Автоматичне шардинг великих файлів

### Переваги
- Великий безкоштовний tier (5GB)
- Справжня децентралізація
- UCANs - сучасний підхід до авторизації
- Open source

### Недоліки
- Новий ребрендинг (можуть бути зміни)
- UCANs вимагають вивчення нової концепції
- Немає Dart SDK

---

## 3. NFT.Storage

### Основна інформація
- **Назва:** NFT.Storage
- **URL реєстрації:** https://app.nft.storage/signup
- **Документація:** https://app.nft.storage/v1/docs/intro
- **Сайт:** https://nft.storage/

### Ціноутворення
- **Вартість:** $4.99 за GB (одноразова плата)
- **Тип:** Оплата за розмір, без часових обмежень
- **Безкоштовний tier:** ❌ Немає безкоштовного tierу

### Аутентифікація
- **Тип:** GitHub OAuth
- **API Token:** JWT токен після автентифікації

### Особливості
- Спеціалізований на NFT метаданих та медіа
- Довгострокове зберігання на Filecoin
- Верифіковане сховище через смарт-контракти

### Вердикт для Staging
**Не рекомендується** для загального staging використання через відсутність безкоштовного tierу та специфічну спеціалізацію на NFT.

---

## Порівняльна таблиця

| Провайдер | Безкоштовний Tier | Аутентифікація | Dart SDK | Сумісність Flutter |
|-----------|-------------------|----------------|----------|-------------------|
| **Pinata** | 1 GB + 10GB bandwidth | JWT | ❌ | Через HTTP API |
| **Storacha** | 5 GB + 5GB egress | UCANs | ❌ | Через HTTP API |
| **NFT.Storage** | ❌ ($4.99/GB) | GitHub OAuth | ❌ | Через HTTP API |

---

## Рекомендації для Flutter/Dart

### Найкращий вибір для Staging: **Storacha**
- **Причина:** Найбільший безкоштовний tier (5GB)
- **Реалізація:** Використовувати HTTP API через Dart `http` package
- **Альтернатива:** Pinata для менших проєктів (простіший API)

### Приклад Dart HTTP запиту для Pinata/Storacha:
```dart
import 'package:http/http.dart' as http;

// Pinata API приклад
Future<void> uploadFile() async {
  final response = await http.post(
    Uri.parse('https://uploads.pinata.cloud/v3/files'),
    headers: {
      'Authorization': 'Bearer YOUR_JWT_TOKEN',
      'Content-Type': 'multipart/form-data',
    },
    // ... body з файлом
  );
}
```

### Важливі зауваження
1. **Жоден провайдер не має офіційного Dart SDK** - потрібна власна реалізація HTTP клієнта
2. **Pinata** має простіший REST API
3. **Storacha** використовує UCANs що ускладнює інтеграцію
4. Для production розгляньте створення backend proxy для IPFS операцій

---

## Не рекомендовані (закриті або змінили модель):
- ❌ **Infura IPFS** - закрита IPFS послуга (2024)
- ❌ **Fleek** - перейшли на платну модель
- ❌ **Estuary** - припинив роботу

---

**Висновок:** Для staging середовища з Flutter рекомендується **Storacha** через найбільший безкоштовний обсяг (5GB), або **Pinata** для простішої інтеграції з меншим обсягом (1GB).
