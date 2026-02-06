# Emergency Backup & Recovery Plan
## Crypto Market - Environment Safety

**Version:** 1.0  
**Created:** 2026-02-01  
**Purpose:** Prevent loss of critical production data

---

## 🚨 CRITICAL ASSETS

### Tier 1: IRREPLACEABLE (Loss = Catastrophic)

| Asset | Location | Backup Location | Recovery Priority |
|-------|----------|-----------------|-------------------|
| **Production Canister IDs** | `crypto_market/canister_ids.json` | `.dfx/backups/`, `memory/` | CRITICAL |
| **DFX Identity** | `~/.config/dfx/identity/` | Secure offline storage | CRITICAL |
| **Wallet Private Keys** | `~/.config/dfx/identity/*/identity.pem` | Hardware wallet / offline | CRITICAL |

### Tier 2: IMPORTANT (Loss = Major Inconvenience)

| Asset | Location | Backup Location | Recovery Priority |
|-------|----------|-----------------|-------------------|
| Local Canister State | `crypto_market/.dfx/local/` | `.dfx/backups/` | HIGH |
| Environment Configs | `.env`, `.env.stg`, `.env.prod` | Regenerable from canister_ids.json | MEDIUM |
| Session Logs | `SESSION_LOG*.md` | Git repository | LOW |

---

## 💾 BACKUP PROCEDURES

### Automatic Backups (Handled by /run Workflow)

**When:** Before every deployment  
**What:** `canister_ids.json`  
**Where:** `crypto_market/.dfx/backups/canister_ids.json.backup.<timestamp>`

### Manual Backup (Weekly Recommended)

```bash
# 1. Navigate to project
cd /Users/vitaliisimko/workspace/projects/other/crypto_market/crypto_market

# 2. Create timestamped backup
BACKUP_DIR="backups/$(date +%Y-%m-%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 3. Backup critical files
cp canister_ids.json "$BACKUP_DIR/"
cp -r .dfx/local/canister_ids.json "$BACKUP_DIR/dfx-local-ids.json" 2>/dev/null || true
cp ../.env "$BACKUP_DIR/" 2>/dev/null || true

# 4. Create manifest
cat > "$BACKUP_DIR/MANIFEST.txt" << EOF
Backup Date: $(date)
Backup Type: Manual Weekly
Contents:
- canister_ids.json (ALL canister IDs)
- dfx-local-ids.json (Local canister state)
- .env (Environment configuration)

Production Canister IDs (Verification):
- atomic_swap: $(jq -r '.atomic_swap.ic' canister_ids.json)
- marketplace: $(jq -r '.marketplace.ic' canister_ids.json)
- user_management: $(jq -r '.user_management.ic' canister_ids.json)
EOF

echo "✅ Backup created: $BACKUP_DIR"
```

### Emergency Backup (RIGHT NOW)

```bash
# Run this immediately to create safety backup
cp crypto_market/canister_ids.json memory/canister_ids.json.backup.$(date +%s)
echo "✅ Emergency backup created in memory/"
```

---

## 🔄 RECOVERY PROCEDURES

### Scenario 1: Lost canister_ids.json

**Symptoms:**
- File deleted or corrupted
- Production canister IDs unknown

**Recovery Steps:**

```bash
# 1. Check automatic backups
ls -la crypto_market/.dfx/backups/canister_ids.json.backup.*

# 2. Check manual backups
ls -la crypto_market/backups/*/canister_ids.json

# 3. Check memory folder
ls -la memory/canister_ids.json.backup*

# 4. Restore from latest backup
LATEST_BACKUP=$(ls -t crypto_market/.dfx/backups/canister_ids.json.backup.* | head -1)
cp "$LATEST_BACKUP" crypto_market/canister_ids.json

# 5. Verify restoration
jq '.atomic_swap.ic, .marketplace.ic' crypto_market/canister_ids.json
# Should show:
# "6p4bg-hiaaa-aaaad-ad6ea-cai"
# "6b6mo-4yaaa-aaaad-ad6fa-cai"

# 6. If no backups available → CRITICAL EMERGENCY
# Contact Вітальон IMMEDIATELY
# Check: ~/.dfx/local/canister_ids.json may have some IDs
# Check: Git history may have the file
```

### Scenario 2: Corrupted .env File

**Symptoms:**
- Flutter can't connect to canisters
- Wrong canister IDs in .env

**Recovery Steps:**

```bash
# 1. Identify target environment
# local, staging, or production?

# 2. Regenerate using /run workflow
/run local    # For local development
/run staging  # For staging
/run production  # For production (⚠️ requires approval)

# 3. Verify generated .env
cat crypto_market/.env | grep CANISTER_ID

# 4. Manual regeneration (if workflow fails)
cd crypto_market
# For local:
jq -r 'to_entries | .[] | "CANISTER_ID_\(.key | ascii_upcase)=\(.value.local)"' canister_ids.json > .env

# For production (⚠️ DANGER - verify first):
jq -r 'to_entries | .[] | "CANISTER_ID_\(.key | ascii_upcase)=\(.value.ic)"' canister_ids.json > .env.prod
```

### Scenario 3: Lost DFX Identity

**Symptoms:**
- `dfx identity list` shows wrong identities
- Can't access canisters
- "Unauthorized" errors

**Recovery Steps:**

```bash
# 1. Check if identity files exist
ls -la ~/.config/dfx/identity/

# 2. Check for backups
cp -r ~/.config/dfx/identity ~/dfx-identity-backup-$(date +%Y%m%d)

# 3. If identity lost but canisters accessible:
# - Create new identity: dfx identity new recovery
# - Add new identity as controller: dfx canister update-settings --add-controller <new_id>
# - Requires existing controller access

# 4. If completely locked out:
# - Contact DFINITY support with proof of ownership
# - This is why we have multiple controllers
```

### Scenario 4: Accidental Mainnet Deployment

**Symptoms:**
- Test code deployed to production
- Wrong WASM module on mainnet

**Recovery Steps:**

```bash
# 1. DON'T PANIC - canisters can be upgraded

# 2. Assess what was deployed
dfx canister status <canister> --network ic

# 3. If test code (safe to upgrade):
# - Prepare correct WASM
# - Deploy correct version: dfx deploy <canister> --network ic

# 4. If sensitive data exposed:
# - Some canisters can be deleted (if not holding user funds)
# - Contact Вітальон for decision

# 5. Document incident
cat >> INCIDENT_LOG.md << EOF
## Incident: $(date)
- What happened: Accidental deployment to mainnet
- Canister: <name>
- Action taken: <description>
- Resolution: <outcome>
EOF
```

---

## 🛡️ PREVENTION CHECKLIST

### Daily (Automatic)
- [ ] /run workflow creates backup before deploy
- [ ] Git commits include canister_ids.json

### Weekly (Manual)
- [ ] Run manual backup procedure
- [ ] Verify backups are readable
- [ ] Test restoration process

### Monthly (Review)
- [ ] Review backup retention policy
- [ ] Clean old backups (keep last 10)
- [ ] Update emergency contacts

### Before Major Operations
- [ ] Create manual backup
- [ ] Document current state
- [ ] Have rollback plan ready

---

## 📋 BACKUP VERIFICATION

### Test Your Backups

```bash
# 1. Verify backup file is valid JSON
jq empty canister_ids.json.backup.XXXX || echo "CORRUPTED!"

# 2. Check all production IDs present
for canister in atomic_swap marketplace user_management price_oracle messaging dispute; do
    ID=$(jq -r ".${canister}.ic" canister_ids.json.backup.XXXX)
    if [[ -z "$ID" || "$ID" == "null" ]]; then
        echo "❌ Missing: $canister"
    else
        echo "✅ $canister: $ID"
    fi
done

# 3. Compare with known good values
KNOWN_ATOMIC_SWAP="6p4bg-hiaaa-aaaad-ad6ea-cai"
BACKUP_ID=$(jq -r '.atomic_swap.ic' canister_ids.json.backup.XXXX)
if [[ "$BACKUP_ID" == "$KNOWN_ATOMIC_SWAP" ]]; then
    echo "✅ Backup verified against known good value"
else
    echo "❌ Backup mismatch!"
fi
```

---

## 📞 EMERGENCY CONTACTS

**Primary:** Вітальон (@Vatalion on Telegram)  
**Context:** This document, latest backup location  
**Escalation:** If critical production data at risk

---

## 📝 INCIDENT RESPONSE LOG

| Date | Incident | Action Taken | Resolution | Status |
|------|----------|--------------|------------|--------|
| 2026-02-01 | Safety plan created | N/A | N/A | Preventive |

---

*Remember: Backups are insurance. Test them regularly.*
