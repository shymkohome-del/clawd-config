# 🔍 АУДИТ #2 - Git та проєктна структура

**Проєкт:** `/Volumes/workspace-drive/projects/other/crypto_market/`  
**Дата:** 2026-02-02  
**Аудитор:** Clawdbot  
**Статус:** ⚠️ Знайдено критичні проблеми

---

## 📊 Executive Summary

| Метрика | Значення | Оцінка |
|---------|----------|--------|
| Розмір .git/ | 59 MB | 🔴 Занадто великий |
| Файлів у git | 5,050 | 🔴 Занадто багато |
| Великих файлів (>1MB) в історії | 30+ | 🔴 Критично |
| Secrets в історії | Не виявлено | 🟢 OK |

---

## 1. 🚨 Git Історія - Критичні Проблеми

### 1.1 Великі бінарні файли в історії (bloat)

**🔴 КРИТИЧНО:** В git історії залишилися великі бінарні файли:

| Файл | Розмір | Статус |
|------|--------|--------|
| `.bin/actionlint` | 5.0 MB | ❌ В історії |
| `.claude/audio/tts-padded-*.wav` | ~5 MB | ❌ Були в історії (видалені) |
| `crypto_market/.dartServer/*` | ~15 MB | ❌ В історії (2916 файлів!) |
| `crypto_market/.dfx/network/local/state/*` | ~3 MB | ❌ В історії |
| `_bmad/*/audio/tracks/*.mp3` | ~7 MB | ❌ В історії (34 файли) |

**Коміти де з'явилися проблеми:**
```
dd52fd32 - feat(story-2.2): Complete search and filter... (dart-кеш)
50267ac8 - chore: remove audio files from repository (видалення)
9ab08b8d - chore: clean up repository and fix test errors (.dfx)
```

### 1.2 Secrets в історії

**🟢 ДОБРЕ:** Secrets не виявлені в поточній історії.

**🟡 УВАГА:** `.env` файл був у git історії (commit fd4641c2), але видалений. Містив mock-значення, не реальні secrets.

---

## 2. 🔴 Зайві файли в Git (Поточні)

### 2.1 Бінарні файли (мають бути в .gitignore)

```
crypto_market/TransactionBroadcaster.wasm       (293 KB)
crypto_market/TransactionBroadcaster_test.wasm  (388 KB)
crypto_market/TronBroadcaster.wasm              (новий)
```

### 2.2 Лог-файли

```
.auto_pr_watch.log
.auto_pr_watch_pr25.log
.github/qa-trigger.tmp
```

### 2.3 AppleDouble файли (macOS metadata)

```
crypto_market/._.dart_tool
crypto_market/._.flutter-plugins-dependencies
crypto_market/._build
crypto_market/._pubspec.lock
```

### 2.4 Бекапи (не мають бути в git)

```
crypto_market/canister_ids.json.backup.*        (9 файлів)
```

---

## 3. 🔴 Дублікати

### 3.1 MP3 аудіо треки (ідентичні файли)

**Локація 1:** `_bmad/_config/custom/my-custom-agents/audio/tracks/` (17 файлів)  
**Локація 2:** `_bmad/my-custom-agents/audio/tracks/` (17 файлів)

**Приклад дублікату:**
```
_bmad/_config/custom/.../agent_vibes_bachata_v1_loop.mp3    (447 KB)
_bmad/my-custom-agents/.../agent_vibes_bachata_v1_loop.mp3  (447 KB)
```

**Вплив:** ~7.5 MB зайвого місця в git

---

## 4. ⚠️ Проблеми .gitignore

### 4.1 Чинний .gitignore

```gitignore
# Editor/IDE history
.history/

# macOS metadata
.DS_Store
docs/.DS_Store

# Audio files (TTS)
.claude/audio/

# AI assistant debug logs
.ai/
crypto_market/.ai/

# Bmad output logs
_bmad-output/

# DFX local canister IDs (machine-specific)
.dfx/

# Environment files
.env
.env.local
.env.staging
.env.prod
.env.bak
crypto_market/.env
crypto_market/.env.*

# BMAD Runtime Memory & State
_bmad/_memory/
_bmad/_bmad/_memory/

# Temporary logs
*.log
node_modules/

# Secrets directory
secrets/

# Claude Code configuration
.claude/config/*
!.claude/config/.gitkeep
.claude/personalities/*
!.claude/personalities/.gitkeep
.claude/hooks/*
!.claude/hooks/.gitkeep
.claude/screenshots/*
!.claude/screenshots/.gitkeep
.claude/github-star-reminder.txt
.claude/tts-*.txt
```

### 4.2 🔴 Відсутні правила

```gitignore
# ⚠️ ДОДАТИ:

# AppleDouble files (macOS)
._*

# Backup files
*.backup
*.backup.*
canister_ids.json.backup*

# Temporary files
*.tmp

# WASM binaries
*.wasm

# Dart/Flutter cache (критично!)
crypto_market/.dart-tool/
crypto_market/.dartServer/
crypto_market/.dart_tool/

# DFX state (критично!)
crypto_market/.dfx/

# Build artifacts
crypto_market/build/
```

---

## 5. ⚠️ Структурні Проблеми

### 5.1 Порожні/непотрібні директорії

| Директорія | Вміст | Рекомендація |
|------------|-------|--------------|
| `.bmad-core/` | Лише `.DS_Store` | 🗑️ Видалити |
| `_bmad-output/` | Не відстежується | 🟢 OK |
| `_bmad/_memory/` | Кеш | 🟢 В .gitignore |

### 5.2 Зайві AI-конфігурації

**Питання:** Навіщо потрібні одночасно:
- `.agent/workflows/bmad/` (61 файл)
- `.gemini/commands/` (15 файлів)
- `.opencode/agents/` (12 файлів)
- `_bmad/` з кастомними агентами

**Рекомендація:** Обрати ОДИН AI-асистент для проєкту.

---

## 6. 📈 Розмір Git Репозиторію

```
$ du -sh .git
59M    .git

$ git count-objects -vH
count: 3077
size: 15.53 MiB
in-pack: 19228
packs: 1
size-pack: 42.75 MiB
```

**Порівняння:**
- Звичайний Flutter проєкт: ~5-10 MB
- Поточний стан: 59 MB
- **Висновок:** Репозиторій у 5-10 разів більший за норму

---

## 7. 🛠️ Рекомендації

### 7.1 Негайні дії (Високий пріоритет)

1. **Додати в .gitignore:**
   ```bash
   echo "._*" >> .gitignore
   echo "*.wasm" >> .gitignore
   echo "*.backup*" >> .gitignore
   echo "*.tmp" >> .gitignore
   echo "crypto_market/.dart-tool/" >> .gitignore
   echo "crypto_market/.dartServer/" >> .gitignore
   echo "crypto_market/.dart_tool/" >> .gitignore
   echo "crypto_market/.dfx/" >> .gitignore
   ```

2. **Видалити з git індексу (зберегти локально):**
   ```bash
   git rm --cached crypto_market/*.wasm
   git rm --cached .auto_pr_watch*.log
   git rm --cached .github/qa-trigger.tmp
   git rm --cached crypto_market/._*
   git rm --cached crypto_market/canister_ids.json.backup*
   ```

3. **Видалити дублікати MP3:**
   ```bash
   # Залишити лише _bmad/_config/custom/my-custom-agents/audio/
   rm -rf _bmad/my-custom-agents/audio/
   git rm -r _bmad/my-custom-agents/audio/
   ```

### 7.2 Очистка історії (ОБЕРЕЖНО!)

⚠️ **Це змінить історію - потрібно узгодити з командою!**

```bash
# Видалити великі файли з історії
# Вимагає git-filter-repo або BFG Repo-Cleaner

# Приклад з BFG:
bfg --delete-files '*.wav' --delete-files '*.mp3'
bfg --delete-folders '.dartServer' --delete-folders '.dart-tool'
bfg --delete-folders '.dfx'
```

### 7.3 Структурні покращення

1. **Видалити порожню директорію:**
   ```bash
   rm -rf .bmad-core/
   ```

2. **Обрати один AI-фреймворк:**
   - Варіант A: Залишити тільки `_bmad/`
   - Варіант B: Перенести потрібні конфіги в одне місце

---

## 8. 📋 Чекліст Виправлень

- [ ] Оновити `.gitignore` з усіма правилами
- [ ] Видалити WASM файли з git індексу
- [ ] Видалити .log файли з git індексу
- [ ] Видалити AppleDouble файли з git індексу
- [ ] Видалити бекапи canister_ids з git індексу
- [ ] Видалити дублікати MP3
- [ ] Видалити порожню `.bmad-core/` директорію
- [ ] Запустити `git gc` для оптимізації
- [ ] (Опціонально) Очистити історію від великих файлів

---

## 9. 📊 Підсумок

| Категорія | Критичних | Середніх | Низьких |
|-----------|-----------|----------|---------|
| Git історія | 3 | 1 | 0 |
| .gitignore | 2 | 2 | 1 |
| Зайві файли | 4 | 2 | 1 |
| Структура | 0 | 2 | 2 |
| **ВСЬОГО** | **9** | **7** | **4** |

**Загальна оцінка:** 🔴 **ПОГАНО** - Потребує термінової уваги

**Основні ризики:**
1. Репозиторій занадто великий (59 MB)
2. Історія забруднена бінарними файлами
3. .gitignore не повний - ризик повторного додавання
4. Дублікати займають місце

---

*Звіт згенеровано автоматично. НЕ ЧІПАТИ secrets/ директорію.*
