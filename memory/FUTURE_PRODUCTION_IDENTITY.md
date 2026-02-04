## Future Production Identity Setup

**Status:** Planned for future implementation  
**Current:** Staging uses `ic_user` identity  
**Future:** Production will have SEPARATE identity (NOT ic_user)

### Current Identity Mapping:
| Environment | Network | Identity | Principal |
|-------------|---------|----------|-----------|
| local | local | default | bibc2-doxoe... |
| staging | ic | ic_user | 4gcgh-7p3b4... |
| **production** | **ic** | **TBD (separate)** | **TBD** |

### Implications:
- `ic_user` currently controls BOTH staging and production canisters
- Future: Separate identity for production = better security isolation
- Will need updates to:
  - `run-config.yaml` (add production identity)
  - `switch-identity.sh` (add production case)
  - SwiftBar plugin (recognize production as separate from staging)
  - Safety protocols (production identity protection)

### Action Items When Ready:
1. Create new production identity
2. Add principal to `canister_ids.json` (production section)
3. Update all scripts to recognize production vs staging distinction
4. Update SwiftBar to show separate indicators for staging vs production

**Note:** This is NOT urgent - staging with ic_user is acceptable for now.
