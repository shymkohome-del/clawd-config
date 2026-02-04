# 🎯 Quick Reference Card: Crypto Market Safety
## For Agents - Keep This Handy!

**Version:** 1.0  
**Last Updated:** 2026-02-01

---

## ⚡ 30-Second Safety Check

### Before ANY crypto_market operation, ask:

1. **Which environment?** (local / staging / production)
2. **Which identity?** (default / ic_user)
3. **Which network?** (local / ic)
4. **Will this cost ICP?** (local=no, ic=yes)

**If answer to #4 is "yes" → Get approval from Вітальон first!**

---

## 📋 Environment Cheat Sheet

| What You Want | Command | Identity | Cost | Safe? |
|--------------|---------|----------|------|-------|
| Test locally | `/run local` | `default` | FREE | ✅ Yes |
| Deploy local | `/run local` | `default` | FREE | ✅ Yes |
| Staging test | `/run staging` | `ic_user` | ICP ⚠️ | Ask first |
| Production | `/run production` | `ic_user` | ICP 💰 | MUST ASK |
| Check status | `dfx canister status <name> --network ic` | any | minimal | Query only |

---

## 🔐 Critical Information

### Production Canister IDs (Memorize These!)
```
atomic_swap:      6p4bg-hiaaa-aaaad-ad6ea-cai
marketplace:      6b6mo-4yaaa-aaaad-ad6fa-cai
user_management:  6i5hs-kqaaa-aaaad-ad6eq-cai
price_oracle:     6g7k2-raaaa-aaaad-ad6fq-cai
messaging:        6ty3x-qiaaa-aaaad-ad6ga-cai
dispute:          6uz5d-5qaaa-aaaad-ad6gq-cai
performance:      652w7-lyaaa-aaaad-ad6ha-cai
```

### Critical Identity
```
Name:     ic_user
Principal: 4gcgh-7p3b4-gznop-3q5kh-sx3zl-fz2qd-6cmhh-gxdd6-g6agu-zptr7-kqe
Location: ~/.config/dfx/identity/ic_user/
Status:   🔴 SOLE CONTROLLER OF ALL PRODUCTION CANISTERS
```

**NEVER DELETE THIS IDENTITY!**

---

## 🛠️ Essential Commands

### Check Current State
```bash
# Who am I?
dfx identity whoami

# What's my principal?
dfx identity get-principal

# Check canister status
dfx canister status atomic_swap --network ic

# Check wallet balance
dfx wallet balance --network ic
```

### Switch Identity (SAFE WAY)
```bash
# Use the identity switcher script
./memory/switch-identity.sh local      # For local dev
./memory/switch-identity.sh staging    # For staging
./memory/switch-identity.sh production # ⚠️ For production
```

### Safety Check (BEFORE mainnet)
```bash
# Run pre-flight safety check
./memory/safety-check.sh production
```

---

## 🚨 Red Flags - STOP and Ask!

**STOP immediately if you see:**

- ❌ About to run `dfx deploy --network ic` directly
- ❌ Identity shows `default` but network is `ic`
- ❌ Canister ID starts with `u` (local) but network is `ic` (mainnet)
- ❌ Not sure which environment you're in
- ❌ Wallet balance shows less than 1 TC
- ❌ Someone asks you to delete any identity

**When in doubt:** `/new` → Ask Вітальон

---

## ✅ Quick Checklist

### Before Starting Work:
```
[ ] Read Safety Vault (memory/CRYPTO_MARKET_SAFETY_VAULT.md)
[ ] Know which environment I'm targeting
[ ] Know which identity to use
[ ] Have /run workflow ready
```

### Before Mainnet Operation:
```
[ ] Got explicit approval from Вітальон
[ ] Running safety-check.sh
[ ] Switched to ic_user identity
[ ] Verified canister IDs
[ ] Understand what will happen
```

---

## 📂 Important File Locations

| File | Location | Purpose |
|------|----------|---------|
| Safety Vault | `memory/CRYPTO_MARKET_SAFETY_VAULT.md` | Complete asset registry |
| Canister IDs | `crypto_market/canister_ids.json` | All canister IDs |
| ic_user identity | `~/.config/dfx/identity/ic_user/` | Production controller |
| Safety check | `memory/safety-check.sh` | Pre-flight validation |
| Identity switcher | `memory/switch-identity.sh` | Safe identity switching |
| /run workflow | `_bmad/my-custom-agents/workflows/run/` | Deployment workflow |

---

## 🎯 Remember

### The Golden Rule:
> **Local = Free to experiment, Mainnet = Ask first always**

### The Three Never:
1. Never delete `ic_user` identity
2. Never use `default` for mainnet
3. Never deploy to mainnet without approval

### The One Always:
> **When in doubt, STOP and ask Вітальон**

---

## 📞 Emergency Contacts

**Primary:** Вітальон (@Vatalion on Telegram)  
**Use for:** Any doubt, any concern, any question

---

*Print this card and keep it visible when working on crypto_market.*
