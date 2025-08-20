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

### Execution Flow

1. Workflow lint runs (actionlint, yamllint).
2. Preflight parser validates branch naming and story gating locally (no network).
3. Wrapper delegates to reusable workflow which:
   - Parses branch and story status, enforces `Status: Done` for `story/*`.
   - Ensures PR exists or creates it.
   - Applies labels `automerge-candidate` and `automerge-ok`.
   - Attempts GraphQL auto‑merge enable (squash) when allowed.
   - Optionally auto‑approves.
4. Fallback merge-on-green workflow monitors required checks and performs squash merge + branch delete.

### Inputs/Flags (repo variables)

- `AUTO_PR_ENABLED` — enable/disable PR auto‑creation
- `AUTO_MERGE_ENABLED` — enable/disable auto‑merge steps
- `AUTO_APPROVE_ENABLED` — enable/disable auto‑approval
  
Feature flags can be toggled via repository variables without modifying workflows.

### Auto‑merge Gating

- For `story/*`: requires label `automerge-ok`
- For non‑story: allowed by default

Additionally, if repository setting “Allow auto‑merge” is disabled, GraphQL enable will be skipped with a non‑fatal note; the fallback workflow continues to merge on green.

## **Error Taxonomy**

- `status-not-done`: story file exists but status is not Done
- `story-file-missing`: cannot find `docs/stories/<id>.*.md`
- `unsupported-branch`: branch does not match expected patterns
- `insufficient-permissions`: API blocked by token permissions
- `automerge.setting_disabled`: repository auto‑merge not enabled; GraphQL enable refused
- `label-gate`: missing `automerge-ok` on story branch
- `no-pr`: PR not found for branch when enabling auto‑merge
- `no-node-id`: missing PR node id for GraphQL

## **Troubleshooting**

- See job summary at the end of runs for decisions and reasons
- Check annotations in logs for misconfigurations
- Expand grouped logs (`::group::`) in steps for detailed traces

## **Local Preflight**

- Run `scripts/dev-validate.sh` before pushing
- Preflight parser validates branch and story file presence without network calls
  
For deeper local parity, you can run `RUN_ACT=true scripts/dev-validate.sh` to execute selected workflows via `act` if installed.