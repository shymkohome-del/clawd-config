# Stories Index

Status: Draft

This index mirrors the execution order from `docs/prd/4b-user-stories-and-acceptance.md`. Each story links to its detailed specification.

## Status Legend

- Draft: Story is being written or refined; not yet ready for review
- **Ready for Review**: Content is complete and awaiting PO/tech review (story document stage) ⭐
- Approved: Story is finalized and unblocked for implementation
- Review: Code implementation is complete and awaiting QA review (development stage)
- Blocked: Requires external dependency or prerequisite before proceeding
- Decision Needed: Awaiting a specific product/technical decision before progressing

## Epic 0: Baseline
- [0.1 Repo and CI Baseline](./0.1.repo-and-ci-baseline.md)
- [0.2 Testing Baseline](./0.2.testing-baseline.md)
- [0.3 Config and Secrets](./0.3.config-and-secrets.md)
- [0.4 App Structure Alignment](./0.4.app-structure-alignment.md)
- [0.5 ICP Service Layer Bootstrap](./0.5.icp-service-layer-bootstrap.md)
- [0.6 Logging and Error Handling Baseline](./0.6.logging-and-error-handling-baseline.md)
- [0.7 Auth Skeleton (UI-only)](./0.7.auth-skeleton-ui-only.md)
- [0.8 Security Baseline](./0.8.security-baseline.md)
- [0.10 Dependency Updates](./0.10.dependency-updates.md)

## Epic 1: User & Identity
- [1.1 Register with email/social](./1.1.register-with-email-or-social.md)
- [1.2 Profile & reputation](./1.2.profile-and-reputation.md)
- [1.3 Login and session management](./1.3.login-and-session-management.md)

## Epic 2: Listings & Discovery
- [2.1 Create listing](./2.1.create-listing.md)
- [2.2 Search and filter listings](./2.2.search-and-filter.md)
- [2.3 Listing detail view](./2.3.listing-detail.md)
- [2.4 Edit listing](./2.4.edit-listing.md)
- [2.5 Deactivate listing](./2.5.deactivate-listing.md)
- **[2.6 Buy listing - Complete trade initiation flow](./2.6.buy-listing-complete-trade-flow.md)** ⭐ **CRITICAL**

## Epic 3: Atomic Swap Escrow
- [3.1 Initiate swap (HTLC)](./3.1.initiate-swap-htlc.md)
- [3.2 Complete swap (secret reveal)](./3.2.complete-swap.md)
- [3.3 Refund swap (timelock expiry)](./3.3.refund-swap.md)
- [3.4 Cancel swap before commit](./3.4.cancel-swap-pre-commit.md)

## Epic 4: Payments & Confirmation
- [4.1 Payment method capture & confirmation](./4.1.payments-and-confirmation.md)
- [4.2 Trade payment confirmation UX](./4.2.trade-payment-confirmation-ux.md)
- **[4.3 Payment method integration and validation](./4.3.payment-method-integration.md)** ⭐ **CRITICAL**

## Epic 5: Messaging & Notifications
- [5.1 In-app messaging and notifications](./5.1.messaging-and-notifications.md)
- **[5.2 Real-time trade status tracking and notifications](./5.2.trade-status-tracking.md)** ⭐ **CRITICAL**

## Epic 6: Compliance & Limits
- [6.1 Compliance limits and optional KYC](./6.1.compliance-and-limits.md)
- [6.2 Audit logging baseline](./6.2.audit-logging-baseline.md)
- [6.3 Rate limiting enforcement](./6.3.rate-limiting-enforcement.md)
- **[6.4 Basic fraud detection and prevention system](./6.4.basic-fraud-detection.md)** ⭐ **CRITICAL**

## Epic 7: Disputes (MVP Manual)
- [7.1 Open dispute (manual moderation)](./7.1.open-dispute.md)

## Epic 8: Observability & Ops
- [8.1 Observability baseline (telemetry and error tracking)](./8.1.observability-and-ops.md)
- [8.2 Alerts and lightweight runbooks](./8.2.alerts-and-runbooks.md)
- **[8.3 Performance monitoring and optimization system](./8.3.performance-monitoring.md)** ⭐ **CRITICAL**

## 🚨 CRITICAL STORIES FOR MVP SUCCESS

The following newly created stories are **ESSENTIAL** for a viable marketplace launch:

### **Immediate Priority (Blocks Core User Journey):**
1. **[2.6 Buy listing - Complete trade initiation flow](./2.6.buy-listing-complete-trade-flow.md)** - Enables end-to-end purchase process
2. **[4.3 Payment method integration and validation](./4.3.payment-method-integration.md)** - Required for real transactions
3. **[5.2 Real-time trade status tracking and notifications](./5.2.trade-status-tracking.md)** - Critical for user experience

### **Production Readiness (Blocks Launch):**
4. **[6.4 Basic fraud detection and prevention system](./6.4.basic-fraud-detection.md)** - Essential for platform security
5. **[8.3 Performance monitoring and optimization system](./8.3.performance-monitoring.md)** - Required to meet MVP KPIs

Source of truth: `docs/prd/4b-user-stories-and-acceptance.md` and `docs/prd.md`.
