# BMAD Project Workflow

## Project
**crypto_market** — Flutter/ICP додаток

## Команда Агентів (my-custom-agents)

### Core Agents
| Агент | Роль | Коли викликати |
|-------|------|----------------|
| **Amos** 🔍 | Adversarial Code Reviewer | Code review, security audit, QA |
| **Flutter Dev** 🕵️ | Flutter Detective (non-UI) | Business logic, BLoC, data layer |
| **Flutter Dev UI** | Flutter UI specialist | UI components, screens |
| **Dr. Proof** 🛡️ | ICP Backend Specialist | Motoko/Rust canisters, backend logic |
| **Flutter Orchestrator** | Team lead / coordinator | Розподіл задач між агентами |
| **Flutter User Emulator** | QA/Testing | Тестування фіч |
| **Backend Dev** | General backend | Загальні backend задачі |
| **Prompt Optimizer** | Prompt engineer | Оптимізація промптів |

### Communication Flow
```
Вітальон → Бро → Flutter Orchestrator → Specific Agents
```

## Standard Workflow

1. **Вітальон** дає БУДЬ-ЯКУ задачу по проекту **Бро** (фіча, баг, рефакторинг, документація, дослідження, деплой...)
2. **Бро** активує **flutter-orchestrator** через BMAD
3. **Orchestrator** аналізує і розподіляє по агентах:
   - UI → flutter-dev-ui
   - Business Logic → flutter-dev
   - Backend → icp-backend-specialist (Dr. Proof)
   - Code Review → amos
   - QA/Testing → flutter-user-emulator
   - Оптимізація → prompt-optimizer
4. Агенти працюють, пишуть в **journals**, використовують **sidecar** для тимчасових знань
5. **Amos** робить фінальний code review (якщо потрібно)

## Key Files to Remember

### Config
- `_bmad/my-custom-agents/config.yaml` — основний конфіг
- `_bmad/my-custom-agents/module.yaml` — опис модуля

### Agents
- `_bmad/my-custom-agents/agents/amos/amos.md`
- `_bmad/my-custom-agents/agents/flutter-dev/flutter-dev.md`
- `_bmad/my-custom-agents/agents/icp-backend-specialist/icp-backend-specialist.md`
- `_bmad/my-custom-agents/agents/flutter-orchestrator/`

### Workflows
- `_bmad/my-custom-agents/workflows/run/workflow.md` — деплой workflow
- `_bmad/my-custom-agents/workflows/autonomous-review.yaml`

### Knowledge Base & Memory System

**Evidence Locker** (довгострокова пам'ять):
- `_bmad/my-custom-agents/data/flutter-rules.md`
- `_bmad/my-custom-agents/data/flutter-driver-mcp-guide.md`
- `docs/development/flutter/` — Flutter patterns
- `docs/development/` — ICP backend patterns

**Shared Sidecars** (координація між агентами):
- `_bmad/_memory/flutter-shared/` — Flutter team coordination
- `_bmad/_memory/icp-flutter-backend/` — Backend team coordination
- `_bmad/_memory/icp-flutter-backend/coordination-log.md` — Лог координації
- `_bmad/_memory/icp-flutter-backend/detective-journal.md` — Журнал розслідувань
- `_bmad/_memory/icp-flutter-backend/memories.md` — Загальні спогади

**Agent Journals** (персональні журнали):
- `pixel-journal.md` (UI агент)
- `dr-proof-journal.md` (Backend агент)
- `detective-journal.md` (Flutter Dev)
- Кожен агент оновлює свій journal після роботи

**Temporary Sidecar Folders** (тимчасові знання):
- Використовуються для поточної задачі
- Зберігають контекст між сесіями
- Очищаються або архівуються після завершення

## Activation Pattern

```bash
# Виклик агента
clawdbot agent run bmad/my-custom-agents/<agent-name>

# Або через .gemini/commands/
.gemini/commands/bmad-agent-<name>.toml
```

## Notes
- Кожен агент завантажує свій конфіг при старті
- Всі агенти використовують `communication_language` з конфігу
- Обов'язково перевіряють Evidence Locker перед роботою
- **Агенти самі пишуть в journals** після роботи — це їхня відповідальність
- **Sidecar папки** — для тимчасових знань поточної задачі
- **Coordination logs** — для синхронізації між агентами
- Бро не лізе вручну в journals — це робота агентів
- Бро може читати journals для контексту, але пишуть туди тільки агенти

## 🧪 Manual QA Testing Rules (Flutter Driver MCP)

**Location:** `_bmad/my-custom-agents/data/flutter-driver-mcp-guide.md`

**CRITICAL RULES (5 Validation Rules):**
1. **Profile Mode** — Always run with `--profile` on macOS (debug mode causes VM Service issues)
2. **Separate Entrypoint** — Create `lib/main_driver.dart` (never use `main.dart` for driver tests)
3. **Initialization Order** — Call `enableFlutterDriverExtension()` **FIRST** in `main()` (before `WidgetsFlutterBinding.ensureInitialized()`)
4. **Wait for DTD** — Pass `--print-dtd` and wait for "The Dart Tooling Daemon is available at: ws://..."
5. **ScreenUtil Safety** — MUST wrap app in `ScreenUtilInit` within driver entry point (white/gray screen crash otherwise)

**Execution Command:**
```bash
flutter run -d macos --profile -t lib/main_driver.dart --print-dtd
```

**All agents doing manual QA MUST follow these rules!**
