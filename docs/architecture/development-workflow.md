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
- Required sections must include `Status:`. Automation treats story PR creation as eligible only when `Status: Done`.

## **Automation Overview**

- Wrapper workflow: `.github/workflows/auto-pr-from-qa.yml` (thin wrapper)
- Core logic: `.github/workflows/reusable-auto-pr.yml` (called via `workflow_call`)
- Fallback merge: `.github/workflows/merge-on-green-fallback.yml`

### Inputs/Flags (repo variables)

- `AUTO_PR_ENABLED` — enable/disable PR auto‑creation
- `AUTO_MERGE_ENABLED` — enable/disable auto‑merge steps
- `AUTO_APPROVE_ENABLED` — enable/disable auto‑approval

### Auto‑merge Gating

- For `story/*`: requires label `automerge-ok`
- For non‑story: allowed by default

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

## **Agent quick-start**

### Dev agent (`@dev`)

- Work on `story/<id>-<slug>` or `feature/<slug>`.
- Before push: `dart format .`, `flutter analyze --fatal-infos --fatal-warnings`, `flutter test --no-pub` or `scripts/dev-validate.sh`.
- Pre-push guard: pushes are blocked if your branch is behind `origin/develop`; rebase with:
  - `git fetch origin && git rebase --autostash origin/develop`
- Push to remote; automation will open a PR to `develop`. For `story/*`, QA must set `Status: Done` in the story file to be eligible.
- Auto-merge gates: required checks must be green; for `story/*`, label `automerge-ok` is required (non‑story branches are allowed by default).

### QA agent (`@qa`)

- Review story ACs; update `QA Results` and set `Status: Done` only when all ACs pass.
- A push with `Status: Done` on `story/*` triggers auto‑PR. Labels `automerge-candidate` and `automerge-ok` allow enablement; required checks must pass.
- If any AC fails/partial: set `Status: InProgress` and add a brief reason in the story `Change Log` (returns ownership to Dev).

### Feature flags (repo variables)

- `AUTO_PR_ENABLED`, `AUTO_MERGE_ENABLED`, `AUTO_APPROVE_ENABLED` — set to `'false'` to disable respective behavior without code changes.