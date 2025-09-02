# AGENTS.md — Repo Agent Guide

Purpose
- Deterministic, repo‑specific rules and steps for Codex‑style coding agents and orchestrators to work safely and effectively in this repository.

High‑level goal
- Maintain and evolve the Flutter app with secure, test‑covered, CI‑compliant PRs that respect guardrails and branching policies.

Project snapshot
- Platform: Flutter / Dart (CI pins Flutter 3.35.1 stable; Dart ~3.8.x)
- App directory: `crypto_market`
- Shell: macOS / zsh (developer machines)
- CI gates: format, analyze, tests (`.github/workflows/flutter-ci.yml`)

User story (agent‑focused)
- Title: Produce a safe, CI‑passing feature PR
- As a repo agent, modify/add code, run local validations, and open a PR that follows conventions for safe review/merge.
- Acceptance criteria:
  - Local gates pass: `dart format`, `flutter analyze`, `flutter test` in the app dir.
  - No secrets/tokens/credentials are committed.
  - Conventional Commits; story work references story id and uses `story/<id>-<slug>`.

BMad method: how we work here
- Personas live in `.github/chatmodes/` and drive focus and outputs. Prefer orchestrating via `bmad-orchestrator` then embody `dev`, `qa`, `architect`, `pm`, etc., as needed.
- Core config: `.bmad-core/core-config.yaml`
  - Branch template: `story/${id}-${slug}`
  - Commit template: `feat(story-${id}): ${title}`
  - Always-loaded references: coding standards, tech stack, dev‑QA flow, story checklists
- Dev ↔ QA status model (see `docs/dev-qa-status-flow.md`):
  - SM: Draft → Approved
  - Dev: InProgress → Ready for Review (or Blocked / Decision Needed)
  - QA: Ready for Review → Done (or back to InProgress with reasons)

Persona mapping (chatmodes)
- Agents bundle (paths are workspace‑relative):
  - analyst → `.github/chatmodes/analyst.chatmode.md`
  - architect → `.github/chatmodes/architect.chatmode.md`
  - bmad-master → `.github/chatmodes/bmad-master.chatmode.md`
  - bmad-orchestrator → `.github/chatmodes/bmad-orchestrator.chatmode.md`
  - dev → `.github/chatmodes/dev.chatmode.md`
  - estimator → `.github/chatmodes/estimator.chatmode.md`
  - estimator-critic → `.github/chatmodes/estimator-critic.chatmode.md`
  - main-agent → `.github/chatmodes/main-agent.chatmode.md`
  - pm → `.github/chatmodes/pm.chatmode.md`
  - po → `.github/chatmodes/po.chatmode.md`
  - prompt-engineer → `.github/chatmodes/prompt-engineer.chatmode.md`
  - qa → `.github/chatmodes/qa.chatmode.md`
  - sm → `.github/chatmodes/sm.chatmode.md`
  - ux-expert → `.github/chatmodes/ux-expert.chatmode.md`

Operating flow (BMad‑aligned)
1) Choose story and branch
   - Create/switch: `scripts/story-flow.sh start <id> <slug>` → `story/<id>-<slug>` and set upstream.
   - Optional: keep in sync with `scripts/story-flow.sh watch-rebase 300 &` while coding.
2) Develop (dev persona)
   - Implement changes in `crypto_market` app; keep story file `docs/stories/<id>.*.md` updated (Tasks/Subtasks, Dev Agent Record, File List, Change Log).
   - When ready, set Status: Ready for Review in the story file and halt changes.
3) Verify locally (no‑network agent mode)
   - Run gates in app dir:
     - `cd crypto_market`
     - `dart format --output=none --set-exit-if-changed .`
     - `flutter analyze --fatal-infos --fatal-warnings`
     - `flutter test --no-pub`
4) QA pass/fail (qa persona)
   - Update `## QA Results` in the story file.
   - If pass: set Status: Done and push; automation/PR flow handles merge on green with `qa:approved`.
   - If fail/partial: set Status: InProgress and note reasons in Change Log.
5) PR & merge
   - PR target is `develop`. Automation may auto‑create/open PRs for `story/*` and manage merge‑on‑green; otherwise run `scripts/story-flow.sh open-pr`.
   - After Done, QA can run `scripts/qa-watch-and-sync.sh story/<id>-<slug>` to watch PR merge and auto‑sync `develop`.

Local validation (agent‑safe)
- Preferred (human local, may fetch tools): `scripts/dev-validate.sh`
  - Runs actionlint/yamllint/shellcheck plus Flutter gates.
  - Note: It may use `curl`, `brew`, `docker`, or `pip`; agents in restricted environments must NOT fetch tools.
- Agent‑safe manual gates (no network): run in `crypto_market`:
  - `dart format --output=none --set-exit-if-changed .`
  - `flutter analyze --fatal-infos --fatal-warnings`
  - `flutter test --no-pub`
- CI parity: `.github/workflows/flutter-ci.yml` pins Flutter `3.35.1` and runs the same format/analyze/test gates on PRs to `develop` and pushes to `story/*`.

Branching, commits, PRs
- Branches:
  - Story work: `story/<id>-<slug>` (enforced by `.bmad-core/core-config.yaml`)
  - Non‑story: `feature|fix|chore|patch/<slug>`
- Commits:
  - Conventional Commits. Story example: `feat(story-<id>): <title>`
  - Commit message must reference the story id on `story/*` branches.
- PRs:
  - Base: `develop`. Include validation summary and story reference (e.g., `story <id>`).
  - Required checks: Workflow Lint, PR Lint, Flutter CI, QA Gate (see `docs/architecture/development-workflow.md`).
  - Auto‑merge requires `qa:approved`. Actions using `actions/github-script` are banned.

Environment activation & commands
- From repo root, recommended (human):
  - `scripts/dev-validate.sh` (runs same CI gates; may fetch tools)
- Manual (agent‑safe, run in app dir):
  - `cd crypto_market`
  - `dart format --output=none --set-exit-if-changed .`
  - `flutter analyze --fatal-infos --fatal-warnings`
  - `flutter test --no-pub`

Codex Cloud Environment Setup
- **CRITICAL**: Agents executing in OpenAI Codex Cloud Environments must auto‑setup Flutter/Dart dependencies before any development work.
- Detection: Agent is running in Codex Cloud when `$CODEX_TASK_ID` or similar Codex environment variables are present.
- The Codex `universal` container has common languages but Flutter/Dart may need setup.
- Auto‑setup obligations (when in Codex Cloud):
  - Detect Flutter availability: `flutter --version` (may not be pre‑installed)
  - If Flutter missing: Download and install Flutter SDK for Linux (Codex containers run Linux)
  - Export Flutter to PATH: `export PATH="$HOME/flutter/bin:$PATH"`
  - Add to bashrc for persistence: `echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc`
  - Verify setup: `flutter doctor` and fix any missing dependencies
  - Navigate to app: `cd crypto_market && flutter pub get`
  - Test gates work: `dart format`, `flutter analyze`, `flutter test --no-pub`
- Setup script integration: `scripts/codex_setup.sh` for Codex Environment Setup Script field
- **FAIL‑FAST**: If Flutter setup fails in Codex Cloud, halt with clear setup instructions

Guardrails (must follow)
- No external network fetches during automated agent runs.
- Never commit secrets, API keys, or `.env` files. Use `--dart-define` and CI secret stores.
- Single source for agent rules: this `AGENTS.md` (no nested copies).
- Ban on `actions/github-script` in workflows; use repo scripts with `gh`/curl instead.
- Use Conventional Commits; story branches must reference the story id.

Troubleshooting
- App dir not found by scripts? `pubspec.yaml` should exist under:
  - `crypto_market` (current location)
  - `.` (root)
  - `crypto_market/crypto_market` (legacy)
- Analyzer complaining about missing keys? Provide `--dart-define` values or a local (uncommitted) `.env` for development. See `README.md` for required keys.
- CI mismatches? Re‑run `scripts/dev-validate.sh` locally (humans) or manual gates (agents) and check logs; CI mirrors these gates.

Safety & secrets
- Do not echo or print secrets in PRs or logs. Use the README config guidance and CI secret stores.

Related references
- CI gates: `.github/workflows/flutter-ci.yml`
- Dev ↔ QA flow: `docs/dev-qa-status-flow.md`
- Development workflow overview: `docs/architecture/development-workflow.md`
- Release process: `docs/architecture/development-workflow.md#release-process-develop-→-main`
- Story checklists: `.bmad-core/checklists/story-git-init-checklist.md`, `.bmad-core/checklists/story-dod-checklist.md`
- Multi‑agent worktrees (optional, advanced): `docs/READY-TO-USE-MULTI-AGENT-SYSTEM.md`

Chat shortcuts (for fast persona actions)
- Format: `<persona> *<command> [<label>](<path>) [options]`
  - Persona: `dev`, `qa`, `architect`, `pm` (common: `dev`, `qa`).
  - Command: persona‑specific action. Supported:
    - Dev: `*develop`, `*validate`, `*status`, `*open-pr`
    - QA: `*review`, `*validate`, `*status`
  - Story: pass a Markdown link to the story file (`docs/stories/<id>.*.md`) or just the path/ID.
  - Options (optional): `--branch story/<id>-<slug>` to override; otherwise derive from file.
- Parsing rules:
  - Derive `<id>` and `<slug>` from the file name `docs/stories/<id>.<slug>.md`.
  - Slug rules: lowercase, spaces→`-`, allowed `[a-z0-9-]` (see `.bmad-core/core-config.yaml`).
  - If only `<id>` is provided, auto‑locate `docs/stories/<id>.*.md` (prefer longest match).
  - Helper: `scripts/story-from-file.sh` enforces path and naming: file under `docs/stories/`, `.md` extension, `<id>` as dotted numbers (e.g., `0.9.10`), `<slug>` as lowercase `[a-z0-9-]`. It splits on the last dot and outputs `story/<id>-<slug>`; exits non‑zero on invalid input.
- Expected behavior:
  - `dev *develop [...]` → switch/create `story/<id>-<slug>`, set Status: InProgress, plan scope, implement, then run local gates in `crypto_market`.
  - `qa *review [...]` → read ACs, run local gates, update `## QA Results`, set Status: Done or InProgress with reasons.
  - `*validate` (dev/qa) → run: `dart format --output=none --set-exit-if-changed .`, `flutter analyze --fatal-infos --fatal-warnings`, `flutter test --no-pub` inside `crypto_market`.
- Examples (copy/paste ready):
  - `dev *develop [1.2.profile-and-reputation.md](docs/stories/1.2.profile-and-reputation.md)`
  - `qa *review [1.2.profile-and-reputation.md](docs/stories/1.2.profile-and-reputation.md)`
  - `dev *open-pr [3.1.initiate-swap-htlc.md](docs/stories/3.1.initiate-swap-htlc.md)`
  - `dev *open-pr --base main --head develop` (open release PR)
  - `dev *label release:approved` (apply release label)
  - `dev *status [0.5.icp-service-layer-bootstrap.md](docs/stories/0.5.icp-service-layer-bootstrap.md)`

Notes
- This file is intentionally concise and prescriptive to improve reliability.
- If you add automation needing special permissions or network access, update this file and explain the exception.
