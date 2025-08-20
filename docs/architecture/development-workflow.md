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

## **Repo Settings**

- Allow auto‑merge: Enabled (confirmed)
- Merge method: Squash (preferred and used by workflows)
- Branch protection for `develop`: ensure required checks are defined to gate merges