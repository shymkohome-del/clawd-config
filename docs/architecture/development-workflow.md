# **Development Workflow**

## **Local Development Setup**

**Prerequisites:**
```bash
```

## **Branch Naming Policy**

- `story/<id>-<slug>` (e.g., `story/0.9.6-policy-and-docs`)
- `feature|fix|chore|patch/<slug>` for non‑story work

## **Story Files**

- Location: `docs/stories/<id>.*.md`
- Required sections must include `Status:` and a `## QA Results` section.

## **Automation Overview**

- Deterministic PR creation: `.github/workflows/auto-pr-from-qa.yml` (wrapper)
- Core engine (reusable): `.github/workflows/reusable-auto-pr.yml` (workflow_call)
- QA gate: `.github/workflows/qa-gate.yml` (required status)
- Label authority: `.github/workflows/label-guard.yml` (restrict `qa:approved` to QA)
- Fallback merge: `.github/workflows/merge-on-green-fallback.yml`
- CI→Story bridge: `.github/workflows/ci-to-story-bridge.yml` (posts failure summary to story and labels `qa:blocker`)
- GitHub Copilot Review provides PR summaries and suggestions; validation report injection and comment-only enforcement are retired by default.

### Required Checks (branch protection)

- Workflow Lint / lint
- PR Lint / pr-lint
- Flutter CI / build-and-test
- QA Gate / qa-approved
 - Merge on Green (fallback) is not a required check; it only executes when QA gate is satisfied and all required checks are green. Auto-merge via GraphQL is attempted only if the repository setting `allow_auto_merge` is enabled.

Use `.github/workflows/enforce-required-checks.yml` to apply these contexts to `main` and `develop` using a repo admin token (`REPO_ADMIN_TOKEN`).

### Inputs/Flags (repo variables)

- `AUTO_PR_ENABLED` — enable/disable PR auto‑creation
- `AUTO_MERGE_ENABLED` — enable/disable auto‑merge steps
- `AUTO_APPROVE_ENABLED` — enable/disable auto‑approval
- `COPILOT_REVIEW_ENABLED` — enable/disable Copilot Review integration (when `'false'`, legacy validation/comment steps run)
  
Branch protection should require the above checks on `develop` and `main`. Use `.github/workflows/enforce-required-checks.yml` to configure via admin token (`REPO_ADMIN_TOKEN`).

### Auto‑merge Gating

- All branches require QA gate: label `qa:approved` must be present (QA-only via `label-guard.yml`)
- Required checks must be green (see CI Gates)
- Developers cannot self-approve; auto-approval is disabled by default in the wrapper and must be explicitly enabled via repo variable `AUTO_APPROVE_ENABLED == 'true'` (not recommended)
- If GraphQL auto-merge is disabled at the repo level, the fallback workflow merges on green with squash and deletes the source branch
- QA approval allowlist is managed via repo variable `QA_APPROVERS` (comma/space separated GitHub usernames) and enforced by `label-guard.yml`

## Release Process (develop → main)

1. Ensure `develop` is up to date and all CI checks are green.
2. Open a pull request with base `main` and head `develop` (see chat shortcut below).
3. Apply the `release:approved` label to the PR.
4. The `main-release-gate` check verifies branch and label; it reports `wrong-head`, `missing-label`, or `ok`.
5. When all required checks including `Main Release Gate / main-release-gate` pass, squash merge to `main` is permitted.

**Chat shortcuts**

- `dev *open-pr --base main --head develop`
- `dev *label release:approved`

## **Error Taxonomy**

- `status-not-done`: story file exists but status is not Done
- `story-file-missing`: cannot find `docs/stories/<id>.*.md`
- `unsupported-branch`: branch does not match expected patterns
- `insufficient-permissions`: API blocked by token permissions

## **Troubleshooting**

- See job summary at the end of runs for decisions and reasons
- Check annotations in logs for misconfigurations

## **Local Preflight**

- Run `scripts/dev-validate.sh` before pushing
- Preflight parser validates branch and story file presence without network calls
- Optional: set `RUN_ACT=true` to execute a subset of workflows locally with `act` for parity

## **Agent quick-start**

### Dev agent (`@dev`)

- Work on `story/<id>-<slug>` or `feature/<slug>`.
- Before push: `dart format .`, `flutter analyze --fatal-infos --fatal-warnings`, `flutter test --no-pub` or `scripts/dev-validate.sh`.
- Pre-push guard: pushes are blocked if your branch is behind `origin/develop`; rebase with:
  - `git fetch origin && git rebase --autostash origin/develop`
- Push to remote; automation will open a PR to `develop`. For `story/*`, ensure PR includes `story <id>` reference and story file exists.
- Auto-merge gates: required checks green + `qa:approved` label (applied by QA only).
 - PR template enforces story reference and checklist (see `.github/pull_request_template.md`).

### QA agent (`@qa`)

- Review story ACs; update `## QA Results` and apply `qa:approved` when acceptable.
- After setting `Status: Done` and pushing, run `scripts/qa-watch-and-sync.sh <branch>` to watch PR merge and automatically sync develop branch.
- Automation adds `qa:ready` on PR creation; only QA approvers may add `qa:approved`.
- If any AC fails/partial: do not apply `qa:approved`; automation will apply `qa:blocker` on CI failures and append a concise failure summary to `## QA Results`.

### Feature flags (repo variables)

- `AUTO_PR_ENABLED`, `AUTO_MERGE_ENABLED`, `AUTO_APPROVE_ENABLED` — set to `'false'` to disable respective behavior without code changes.