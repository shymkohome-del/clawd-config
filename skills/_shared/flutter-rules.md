# Flutter Rules (Shared)

## 🚨 CRITICAL: Blockchain Mindset

**ЦЕ НЕ ГРА. ЦЕ РЕАЛЬНІ ГРОШІ ЛЮДЕЙ.**

### Жорсткі правила для Flutter коду:

| Що | Чому це важливо | Наслідок помилки |
|-----|----------------|------------------|
| **0 warnings** | Кожен warning — потенційний вектор атаки | Втрата криптовалют користувачів |
| **0 assumptions** | Блокчейн не пробачає помилок | Незворотні транзакції |
| **0 "мабуть"** | Код працює як написано, не як задумано | Експлойти, drains, hacks |

### Золоті правила:

1. **WARNING = ERROR**
   - Немає "просто warnings" в блокчейні
   - Кожен unused identifier — потенційна діра
   - Кожен "operator may trap" — можливий freeze коштів
   - Завдання: **0 warnings, 0 errors, 0 compromises**

2. **Перевіряй ВСЕ**
   - Nat underflow? Перевір границі явно.
   - Division by zero? Перевір перед діленням.
   - Array index? Перевір bounds.
   - Principal validation? Перевір формат.

3. **Fail fast, but safely**
   - Краще зупинити операцію, ніж втратити кошти
   - assert() — твій друг для критичних інваріантів
   - Всі throw мають бути оброблені

4. **Не довіряй нічому**
   - Вхідні дані — це атака поки не доведено інше
   - Caller може бути будь-яким
   - Час може бути маніпульований
   - External calls можуть fail

5. **Коментарі = обіцянки**
   - Якщо написав "BUG FIX" — це має бути fix, не workaround
   - TODO = P0 якщо це security
   - Кожен коментар має бути актуальним

---

## 📋 Pre-Commit Checklist (ОБОВ'ЯЗКОВО перед кожним commit)

- [ ] `flutter analyze` на змінених файлах — 0 errors, 0 warnings
- [ ] `flutter test` — всі тести проходять
- [ ] Немає print() в коді (використовуй logger)
- [ ] Всі типи відповідають інтерфейсам
- [ ] Всі deprecated API замінені на сучасні
- [ ] Всі імпорти присутні
- [ ] Для тестів: моки точно відповідають оригінальним інтерфейсам
- [ ] Відсутні TODOs що стосуються security

---

## 🚫 Absolute Forbidden

| Дія | Наслідок |
|-----|----------|
| Використання `print()` замість logger | ❌ REJECT |
| Ігнорування warnings | ❌ REJECT |
| Використання deprecated API | ❌ REJECT |
| Неповні error handling | ❌ REJECT |
| Hardcoded secrets/keys | ❌ REJECT |

---

## ✅ Required Validation After Any Code Change

```bash
# ОБОВ'ЯЗКОВО виконати після кожної зміни:
flutter analyze lib/

# Очікуваний результат:
# ✅ Validation: 0 errors, 0 warnings
```

---

## 📝 Print Statement Policy

**❌ ЗАБОРОНЕНО:** `print("debug")`, `print(value)`

**✅ ДОЗВОЛЕНО:**
```dart
import 'package:logger/logger.dart';

final logger = Logger();

// Debug mode only
if (kDebugMode) {
  logger.d("Debug: $value");
}

// Production logging
logger.i("User action: login");
logger.e("Error: $error", stackTrace: stackTrace);
```

---

## 🏗️ Architecture Principles

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────┐
│ UI Layer (Widgets, Screens)                     │
├─────────────────────────────────────────────────┤
│ Presentation Layer (Cubits, BLoCs, Controllers) │
├─────────────────────────────────────────────────┤
│ Domain Layer (Use Cases, Entities)              │
├─────────────────────────────────────────────────┤
│ Data Layer (Repositories, Data Sources)         │
└─────────────────────────────────────────────────┘
```

### Key Rules

1. **Dependency Inversion:** Higher layers depend on abstractions
2. **Single Responsibility:** Each class has one reason to change
3. **Immutability:** Prefer `final` and immutable collections
4. **Null Safety:** Never allow unhandled nulls

---

## 🔒 Security-First Design

### Input Validation

```dart
// ❌ ПОГАНО
final amount = double.parse(userInput);

// ✅ ДОБРЕ
final amount = double.tryParse(userInput);
if (amount == null || amount <= 0) {
  return Left(ValidationError.invalidAmount);
}
```

### Error Handling

```dart
// ❌ ПОГАНО - expose internals
try {
  await performSwap();
} catch (e) {
  print("Error: $e");  // Forbidden!
  rethrow;
}

// ✅ ДОБРЕ - secure error handling
try {
  await performSwap();
} on SwapException catch (e) {
  logger.e("Swap failed: ${e.code}", error: e);
  return Left(SwapError.insufficientFunds);
}
```

---

## 🧪 Testing Requirements

### Unit Test Pattern

```dart
@GenerateMocks([WalletRepository])
void main() {
  late WalletCubit cubit;
  late MockWalletRepository mockRepo;

  setUp(() {
    mockRepo = MockWalletRepository();
    cubit = WalletCubit(repository: mockRepo);
  });

  test('should emit error when insufficient balance', () async {
    // Arrange
    when(mockRepo.getBalance(any)).thenReturn(0);

    // Act
    cubit.withdraw(100);

    // Assert
    expectLater(cubit.stream, emitsError(isA<InsufficientFundsError>()));
  });
}
```

### Widget Test Pattern

```dart
void main() {
  testWidgets('should show error on invalid input', (tester) async {
    await tester.pumpWidget(
      TestWrapper(child: LoginScreen()),
    );

    await tester.enterText(find.byType(TextField), 'invalid');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Invalid email'), findsOneWidget);
  });
}
```

---

## 📦 Dependency Management

### Version Policy

- ** завжди:** Use latest stable versions
- **Перевіряй:** Context7 або websearch перед додаванням нової залежності
- **Уникай:** Deprecated packages
- **Фіксуй:** `pubspec.yaml` з конкретними версіями

### Example pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  bloc: ^8.1.2
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  logger: ^2.0.2+1
  get_it: ^7.6.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.4
  mockito: ^5.4.2
  build_runner: ^2.4.6
```

---

## 📚 Documentation Standards

### Code Documentation

```dart
/// Performs an atomic swap between two tokens.
///
/// **Security:** Validates all input amounts and prevents front-running attacks.
///
/// Returns [SwapResult.success] on successful completion or
/// [SwapResult.failure] with specific error code.
///
/// Throws [SwapException] only for unrecoverable system errors.
Future<Result<SwapResult, SwapError>> performAtomicSwap({
  required Token from,
  required Token to,
  required BigInt amount,
}) async {
  // Implementation
}
```

---

## 🚀 Performance Guidelines

1. **Lazy Loading:** Use `ListView.builder`, not `ListView`
2. **Caching:** Cache network responses appropriately
3. **Async:** Use `FutureBuilder` or `StreamBuilder` for async data
4. **Images:** Use `cached_network_image` for remote images
5. **State:** Minimize rebuilds with proper BLoC patterns

---

## 📖 Remember

> **"Якщо в коді є warning, значить я не закінчив роботу."**
>
> - Пушити код з warnings = зрада довіри користувачів
> - "Працює" ≠ "безпечно"
> - Кожен рядок коду — потенційна відповідальність

**Вітальон довірив мені доступ до проєкту, де люди тримають реальні гроші.**

Моя легковажність = реальні збитки реальних людей.

**Завжди перепитуй, завжди перевіряй, ніколи не припускай.**
