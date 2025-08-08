# 0. MVP Scope (ICP-First)

## 0.1 Goals & Principles
- Deliver a usable, secure ICP-native P2P marketplace with atomic swap escrow and hybrid authentication.
- Optimize for reliability and UX; minimize cross-chain complexity in Phase 1.
- Ship quickly with a narrow slice; expand features post validation.

## 0.2 In Scope (Phase 1)
- Platforms: Flutter mobile (iOS/Android)
- Chain: Internet Computer (ICP) only
- Canisters: Marketplace, Atomic Swap (HTLC), Identity Mapping, Messaging (simple)
- Auth: Hybrid (email/password + social OAuth) with ICP principal mapping
- Listings: Create, browse, filter, basic reputation
- Escrow: HTLC-based swaps, time locks, refunds, dispute workflow (manual/admin)
- Pricing: ICP-native oracle with staleness checks; conservative limits
- Compliance: Tiered limits with optional KYC; logging and audit trail
- Security: Rate limiting, RBAC, circuit breakers; internal review prior to beta

## 0.3 Out of Scope (Phase 1)
- Broad cross-chain support beyond core ICP integrations
- Advanced DeFi, NFTs, governance, complex derivatives
- Full on-chain dispute arbitration; automated adjudication
- Direct Web3 wallet connect for the mainstream flow (optional later)
- Sophisticated ML fraud detection (use heuristics and rules first)

## 0.4 Technical Constraints
- ICP as the execution environment; threshold ECDSA leveraged where applicable
- Minimal off-chain services (only where required for auth and compliance)
- Privacy-first logging; avoid unnecessary identity linkage

## 0.5 MVP KPIs
- Swap success rate: >= 90% within SLA
- Median swap completion time: <= 30 minutes (ICP-only path)
- Day-1 retention (D1): >= 25%; 4-week retention: >= 15%
- Dispute rate: <= 3% of completed swaps; average resolution time <= 24h
- Crash-free sessions: >= 99.5%; P95 API latency: <= 2s

## 0.6 Stage Gates & Exit Criteria
- Gate A (Beta):
  - Security review passed; critical issues resolved
  - Swap success rate >= 85% on testnet; P95 completion <= 45 minutes
  - Core flows user-tested with SUS >= 70
- Gate B (Mainnet Limited Release):
  - Swap success rate >= 90%; incident runbook ready; on-call
  - Compliance sign-off for target jurisdictions; DSAR process defined
  - Telemetry live; dashboard for KPIs and alerts
- Gate C (Scale & Expansion):
  - Retention and dispute KPIs on target for 4 consecutive weeks
  - External security audit with no critical findings outstanding
  - Readiness review for additional currencies and features

## 0.7 Risks & Mitigations (MVP)
- Atomic swap UX: hide complexity; guided steps; resilient retries; clear timeouts
- Identity mapping: strict rate limits; audit trails; privacy by design
- App distribution: align flows with store policies; region-gate if needed
- Compliance: launch in friendlier jurisdictions; modular KYC tiers
