# AGENTS.md - Coding Agents Configuration

Цей файл містить конфігурацію coding агентів та workflow для генерації коду.

---

## 🧠 Архітектура: Мозок vs Руки

```
┌─────────────────────────────────────────────────────────────────┐
│                    MAIN AGENT (Kimi/Claude)                      │
│                  Я - архітектор/оркестратор                      │
│                                                                  │
│  Робота:                                                         │
│  - Аналіз задачі від Вітальона                                   │
│  - Декомпозиція на підзадачі                                     │
│  - Вибір спеціалізованого sub-agent'а                            │
│  - Spawn через sessions_spawn()                                  │
│  - Рев'ю та інтеграція результатів                               │
└──────────────────────────┬───────────────────────────────────────┘
                           │ sessions_spawn()
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              SUB-AGENT (MiniMax M2.1 - дешевий/швидкий)          │
│                                                                  │
│  Робота:                                                         │
│  - Виконання конкретного завдання                                │
│  - Ізольована сесія (agent:main:subagent:<uuid>)                │
│  - Отримує AGENTS.md + TOOLS.md + project context               │
│  - Анонсує результат назад в чат                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Основна модель

### Main Agent (Default)
- **Model:** `kimi-code/kimi-for-coding` (або `anthropic/claude-opus-4-5` для складних задач)
- **Роль:** Архітектор, планувальник, інтегратор
- **Завжди перший:** Аналізую задачу перед spawn'ом sub-agent'ів

### Sub-Agent (для виконання) — "РУКИ"
- **Model:** `minimax/minimax-m2.1` (1M tokens, дешевий)
- **Конфіг:** `agents.defaults.subagents.model`
- **Max concurrent:** 4-8 (налаштовується)

**⚠️ КРИТИЧНО: Ця модель СЛАБША і не вміє мислити архітектурно!**

| MiniMax M2.1 (руки) | Kimi/Claude (мозок) |
|---------------------|---------------------|
| ❌ Не вміє архітектурувати | ✅ Архітектура, планування |
| ❌ Не розуміє абстракції | ✅ Розуміє контекст |
| ✅ Виконує конкретні задачі | ✅ Аналізує та інтегрує |
| ✅ Швидка і дешева | ✅ Якісна, дорожча |

**🎯 Імперативний стиль для MiniMax:**
```
❌ НЕ ПРАЦЮЄ: "Зроби краще архітектуру auth"
✅ ПРАЦЮЄ: "Винеси функцію validateEmail з AuthCubit в окремий файл validators.dart"

❌ НЕ ПРАЦЮЄ: "Порефактори код"
✅ ПРАЦЮЄ: "Заміни всі print на logger.d в файлі lib/services/api_service.dart"
```

---

## 🤖 Project Sub-Agents (Crypto Market)

Коли я працюю над crypto_market проєктом, spawn'ю sub-agent'ів з **рольовою ін'єкцією**:

| Агент | Роль | Зона відповідальності |
|-------|------|----------------------|
| **amos** 🔍 | Adversarial Code Reviewer | Security audit, logic flaws, best practices |
| **flutter-dev** 🕵️ | Flutter Detective | Business logic, BLoC, Repository pattern, state mgmt |
| **flutter-dev-ui** 🎨 | Flutter UI Specialist | Screens, widgets, animations, responsive design |
| **icp-backend-specialist** ⚡ | ICP Backend Dev | Canister development, Motoko/Rust, blockchain logic |
| **flutter-user-emulator** 👤 | UX Tester | User journey testing, edge cases, flows |

---

## 🛡️ Safety Protocol Injection (MANDATORY)

**Every sub-agent for crypto_market MUST receive:**

```markdown
## 🚨 CRITICAL RULES (Read before work!)

### Required Files:
1. `memory/CRYPTO_MARKET_SAFETY_VAULT.md` - Canister IDs, ic_user identity
2. `memory/ENVIRONMENT_SAFETY_MANIFEST.md` - Environment zones
3. `memory/AGENT_SAFETY_GUIDELINES.md` - Blockchain operations

### Environment Zones:
- 🔴 **Production/Mainnet (`ic`)** - REAL ICP, REAL MONEY
- 🟡 **Staging (`ic`)** - Controlled access, costs ICP  
- 🟢 **Local (`local`)** - Free to experiment

### ABSOLUTE FORBIDDEN:
1. ❌ NEVER delete `ic_user` identity
2. ❌ NEVER use `default` for mainnet
3. ❌ NEVER run raw `dfx deploy --network ic`
4. ❌ NEVER modify `canister_ids.json` manually
5. ❌ NEVER deploy to mainnet without Вітальон approval

### For ICP Operations:
- Local dev: ✅ Safe
- Staging: ⚠️ Requires verification
- Production: 🚨 MUST ask Вітальон first

### Swap Operations (if applicable):
- [ ] Secret/hash consistency verified
- [ ] Secret logged in Safety Vault
- [ ] Candid blob format verified (Motoko style: \xx not \x)
```

---

## 📋 Workflow: Як я spawn'ю sub-agent'ів

### Крок 1: Аналіз
```
Вітальон: "Зроби code review для atomic_swap canister"
    ↓
Я: Аналізую - це security audit → потрібен amos
```

### Крок 2: Spawn з контекстом
```javascript
sessions_spawn({
  task: `
## Your Role: amos (Adversarial Code Reviewer)
You specialize in security audits and vulnerability detection.

## 🛡️ Safety Protocol (MANDATORY - read before work!)
1. Read: memory/CRYPTO_MARKET_SAFETY_VAULT.md
2. Read: memory/ENVIRONMENT_SAFETY_MANIFEST.md
3. Canister IDs ONLY from VAULT
4. For mainnet MUST get approval from Вітальон

## Task:
Perform security audit for atomic_swap canister.
Look for:
- Reentrancy vulnerabilities
- Integer overflow/underflow
- Access control issues
- Logic flaws in swap flow

## Context:
- Project: /Volumes/workspace-drive/projects/other/crypto_market/
- Canister ID (local): uxrrr-q7777-77774-qaaaq-cai
- Canister ID (prod): 6p4bg-hiaaa-aaaad-ad6ea-cai

## Output:
- List of found issues
- Severity (Critical/High/Medium/Low)
- Recommendations for fixes
`,
  model: "minimax/minimax-m2.1",
  runTimeoutSeconds: 600,
  cleanup: "keep"
})
```

### Крок 3: Очікування та інтеграція
```
Sub-agent працює → Анонсує результат → Я аналізую → Інтегрую/ітерую
```

---

## 🛠️ Специфічні шаблони spawn

### Для flutter-dev (Business Logic)
```javascript
sessions_spawn({
  task: `
## Role: flutter-dev (Flutter Detective)
- BLoC/Cubit patterns
- Repository pattern  
- API integration
- State management

## Safety:
- Local development: use .env.dev
- Canister IDs: from VAULT (do not hardcode!)

## Task: [business logic task]
`,
  model: "minimax/minimax-m2.1",
  runTimeoutSeconds: 300
})
```

### Для flutter-dev-ui (UI)
```javascript
sessions_spawn({
  task: `
## Role: flutter-dev-ui (Flutter UI Specialist)  
- Screens & widgets
- Animations
- Responsive design
- Theme compliance

## Safety:
- DO NOT touch business logic (that's flutter-dev)
- DO NOT touch canister calls directly

## Task: [UI task]
`,
  model: "minimax/minimax-m2.1",
  runTimeoutSeconds: 300
})
```

### Для icp-backend-specialist (ICP)
```javascript
sessions_spawn({
  task: `
## Role: icp-backend-specialist (ICP Backend Dev)
- Canister architecture
- Motoko/Rust development
- Blockchain logic
- ICP specific patterns

## 🚨 CRITICAL: Environment Safety
Before any operation:
1. Read memory/ENVIRONMENT_SAFETY_MANIFEST.md
2. Verify environment (local/staging/production)
3. For mainnet: MUST get approval from Вітальон

## Canister IDs (from VAULT):
- atomic_swap: local=uxrrr..., prod=6p4bg...
- marketplace: local=u6s2n..., prod=6b6mo...
- [others from VAULT]

## Task: [ICP task]
`,
  model: "minimax/minimax-m2.1",
  runTimeoutSeconds: 600
})
```

---

---

## 🌐 Мовна політика (CRITICAL)

**⚠️ ОБОВ'ЯЗКОВО ДОТРИМУВАТИСЯ:**

| З ким | Мова | Приклад |
|-------|------|---------|
| **Вітальон** | ТАКА Ж як у нього 🇺🇦🇬🇧 | Відповідаю на тій мові, на якій він звертається |
| **Sub-агенти** | Англійська 🇬🇧 | ВСЕ: документація, коментарі, промпти |
| **Код** | Англійська 🇬🇧 | Змінні, функції, коментарі в коді |

### Правила:
1. **Документація** (AGENTS.md, SOUL.md, etc.) → Англійська
2. **Промпти для sub-agent** → Англійська
3. **Код та коментарі** → Англійська
4. **Відповіді sub-agent** → Англійська (я перекладу для Вітальона якщо треба)
5. **Спілкування з Вітальоном** → **ТА МОВА, ЯКОЮ ВІН ЗВЕРТАЄТЬСЯ**

### Чому:
- MiniMax краще розуміє англійську
- Код має бути англійською для consistency
- Уникаємо мішанини мов в проєкті
- З Вітальоном — на його мові (він визначає)

---

## 📝 Як формулювати завдання для Sub-Agent

**⚠️ MiniMax M2.1 — менш самостійна за Kimi/Claude.**

Вона **МОЖЕ** мислити, але:
- ❌ Не так глибоко — пропускає нюанси
- ❌ Менше контексту — швидко губить зв'язок
- ❌ Слабша абстракція — краще працює з конкретикою
- ❌ Може "заблукати" в складних завданнях

**Тому я як "мозок" маю дати їй:**
- ✅ Чітку структуру завдання
- ✅ Контекст і обмеження
- ✅ Очікуваний формат результату
- ✅ План дій (якщо складно)

---

### Task Template (ENGLISH ONLY for sub-agents):

```markdown
## Goal
[What needs to be done — 1-2 sentences]

## Context
- Project: [name/type]
- Files: [main files]
- Important to know: [context]

## Task
[Detailed description with specifics]

## Constraints
- [what NOT to do]
- [technical constraints]

## Expected Output
- [output format]
- [what should be done]
```

---

### Examples: ❌ BAD vs ✅ GOOD

| ❌ Too Abstract | ✅ Enough Details |
|----------------|-------------------|
| "Do code review" | "Analyze lib/auth.dart for SQL injection and XSS. Look for: 1) raw queries, 2) unescaped output. Output: list of found issues with line numbers." |
| "Improve UI" | "In login screen add: 1) red border for TextField on invalid email, 2) error message below field. Use existing AppTheme.errorColor." |
| "Refactor code" | "Extract validation from AuthCubit into separate class. Create lib/validators/auth_validators.dart with methods: validateEmail(), validatePassword(). Keep calls in AuthCubit unchanged." |
| "Find bugs" | "Test case: when clicking 'Login' button with empty fields app crashes. Reproduce bug, find cause in lib/screens/login_screen.dart, propose fix." |

---

### Pre-Spawn Checklist:

- [ ] Task has **clear goal** (not "improve", but "add validation")
- [ ] Has **context** (which project, which files)
- [ ] Has **constraints** (what not to touch, which rules)
- [ ] **Output format** specified
- [ ] If complex — has **step-by-step plan**
- [ ] I'm ready to **review result** and explain what's wrong

---

## ⚙️ Конфігурація Clawdbot

### Додати в `~/.clawdbot/clawdbot.json`:

```json5
{
  agents: {
    defaults: {
      // Main agent (я)
      model: "kimi-code/kimi-for-coding",
      
      // Sub-agents (руки)
      subagents: {
        model: "minimax/minimax-m2.1",
        maxConcurrent: 4,
        archiveAfterMinutes: 60,
        // Sub-agents не отримують session tools за замовчуванням
        tools: {
          // Можна додати allow/deny за потреби
        }
      }
    }
  }
}
```

---

## 📊 Порівняння підходів

| Аспект | Старий підхід (OpenCode CLI) | Новий підхід (Sub-Agents) |
|--------|------------------------------|---------------------------|
| Модель | MiniMax напряму через CLI | MiniMax в ізольованій сесії |
| Контекст | Маю передавати вручну | Автоматично inject через task |
| Безпека | Я контролюю сам | Safety protocol auto-injected |
| Паралелізм | Послідовно | До 4 concurrent sub-agents |
| Моніторинг | Блокує мою сесію | Background, анонс назад |
| Cost | Той самий | Контроль через subagents.model |

---

## 🎯 Правила використання

### Як Main Agent (я):
1. **Аналізую першим** — ніколи не spawn'ю без розуміння задачі
2. **Вибираю правильного агента** — amos/flutter-dev/icp-backend...
3. **Inject safety** — кожен spawn містить safety protocol
4. **Review результату** — не сліпо приймаю, аналізую
5. **Iterate якщо треба** — respawn з уточненнями

### Коли НЕ spawn'ити:
- ❌ Просте завдання (швидше зроблю сам)
- ❌ Критичний баг (потребує мого аналізу)
- ❌ Архітектурні рішення (це моя робота)
- ❌ OpenCode не працює / ліміти досягнуті

---

## 🔄 Приклад повного workflow

```
Вітальон: "Зроби рефакторинг auth flow в Flutter"
    ↓
Я: Аналізую
   - Це business logic (BLoC/Repository)
   - Потрібен flutter-dev
   - Можна розбити на підзадачі
    ↓
Я: Spawn sub-agent #1
   - flutter-dev аналізує поточну архітектуру
   - Час: 5 хв
    ↓
[Чекаю анонс]
    ↓
Sub-agent #1: "Знайшов проблеми: 1).. 2).. 3).."
    ↓
Я: Аналізую рекомендації
    ↓
Я: Spawn sub-agent #2  
   - flutter-dev рефакторить згідно плану
   - Час: 15 хв
    ↓
[Чекаю анонс]
    ↓
Sub-agent #2: "Рефакторинг завершено. Файли: ..."
    ↓
Я: Рев'ю змін
   - Перевіряю код
   - Тестую локально (якщо можу)
   - Готую summary для Вітальона
    ↓
Я: Відповідаю Вітальону
   "Готово! Зроблено:
    1. Винесено auth logic в окремий BLoC
    2. Додано Repository pattern для API calls
    3. Покрито тестами
    Файли: lib/auth/..."
```

---

---

## 🚨 CRITICAL: Config Modification Safety Protocol (ABSOLUTE)

### ⛔ FORBIDDEN WITHOUT EXPLICIT USER APPROVAL:
1. **NEVER** modify `kimi-code:default` profile or provider
2. **NEVER** modify existing working models/providers
3. **NEVER** delete or overwrite auth profiles
4. **NEVER** restart gateway without verifying config is valid

### ✅ ONLY Allowed Actions:
- **ADD** new providers (minimax, openrouter, etc.) as **SEPARATE** entries
- **ADD** new auth profiles without touching existing ones
- **MODIFY ONLY** `subagents` section for sub-agent configuration

### 🔒 Before ANY Config Edit - MANDATORY Checklist:

```markdown
- [ ] BACKUP current config: `cp ~/.clawdbot/clawdbot.json ~/.clawdbot/clawdbot.json.backup`
- [ ] Verify JSON syntax is valid before saving
- [ ] Confirm NOT modifying kimi-code/moonshot provider
- [ ] Confirm ONLY ADDING new entries, not replacing
- [ ] Test config with `clawdbot doctor` after changes
- [ ] If error → IMMEDIATELY restore from backup
```

### 🛡️ Safe Pattern for Adding New Provider:

```json5
// ONLY ADD, NEVER REPLACE
{
  "auth": {
    "profiles": {
      // KEEP EXISTING:
      "kimi-code:default": { ... },  // ← DO NOT TOUCH
      // ADD NEW:
      "minimax:default": { ... }     // ← ONLY THIS IS NEW
    }
  },
  "models": {
    "providers": {
      // KEEP EXISTING:
      "kimi-code": { ... },  // ← DO NOT TOUCH
      // ADD NEW:
      "minimax": { ... }     // ← ONLY THIS IS NEW
    }
  }
}
```

### ⚠️ If Config Breaks:
1. **STOP** — don't make more changes
2. Restore from backup: `cp ~/.clawdbot/clawdbot.json.backup ~/.clawdbot/clawdbot.json`
3. Restart gateway
4. Ask user before attempting again

---

## 📁 Файли

- `AGENTS.md` — цей файл (конфігурація workflow)
- `SOUL.md` — особистість та принципи
- `memory/CRYPTO_MARKET_SAFETY_VAULT.md` — критичні assets
- `memory/ENVIRONMENT_SAFETY_MANIFEST.md` — environment правила
- `memory/AGENT_SAFETY_GUIDELINES.md` — safety для агентів

---

*Оновлено: 2026-02-04 з інтеграцією Clawdbot sub-agents*
