# Feature PRD: Search & Filter Listings

## 1. Why This Matters

- **Problem**: Buyers struggle to discover relevant listings in the growing catalog; manual scrolling leads to drop-off and support tickets requesting better discovery.
- **Opportunity**: Structured search and filtering boosts conversion, improves perceived inventory breadth, and lays groundwork for personalized experiences.
- **Goal**: Deliver a fast, intuitive discovery workflow for ICP-first buyers that satisfies MVP marketplace needs and aligns with the decentralized roadmap.

### Success Signals
- ≥55% of daily active buyers use search or any filter within two weeks of launch.
- Search-driven sessions convert (listing viewed → contact or save) at least 20% higher than pre-feature baseline.
- Support tickets referencing “can’t find listing” drop by 40% within a month.

## 2. Scope

### In Scope (MVP)
- Keyword search across title, description, seller handle, and category tags.
- Filters for category, location (city/state), listing condition, and price band range.
- Sort controls: newest first, price low→high, price high→low.
- Paginated result grid/list that preserves query state during navigation.
- Localized labels/placeholders for search UI in supported locales (EN, LV).
- Client-side logging (dev/staging) capturing query, filters, latency, result count.
- API query parameters powering filters with canister-side validation and rate limits.

### Out of Scope (Future)
- Personalized recommendations, trending searches, saved searches.
- Server-side analytics pipelines beyond event logging already in scope.
- Advanced filters (seller rating, payment options, delivery ETA).
- Mobile push notifications or emails triggered by saved filters.

## 3. Users & Journeys

| Persona | Motivation | Key Journey |
| --- | --- | --- |
| **Casual Buyer (EN)** | Wants quick browse by keyword (e.g., “Ledger wallet”). | Open search → enter keyword → scan results → apply price filter → drill into listing. |
| **Regional Trader (LV)** | Needs to find local deals to avoid shipping. | Toggle location filter to region → narrow by category → contact seller. |
| **Power Seller** | Checks how inventory appears to buyers. | Search own product keywords → confirm sorting + filter discoverability. |

Pain points today: stale list view, no way to exclude irrelevant categories, manual price scanning, and inconsistent translation of category labels.

## 4. Requirements

### Functional
1. **Keyword Search**: Input updates result set on submit; handles empty states with guidance message.
2. **Category Filter**: Displays localized category names but stores canonical IDs (e.g., `fashion`).
3. **Price Filter**: Numeric min/max with validation and friendly errors (localized copy).
4. **Location Filter**: Free-text suggestions (MVP: manual input) with case-insensitive matching.
5. **Condition Filter**: Toggle for new, used, refurbished; multi-choice not required.
6. **Pagination**: Page size 20; includes next/previous controls with disabled states when not applicable.
7. **Clear All**: Resets query params, pagination, and UI affordances in one action.
8. **State Preservation**: When a user opens a listing and returns, prior filters/search remain applied.
9. **Telemetry (Dev/Staging)**: Log query string, filters, latency, counts; disable in production build.
10. **Accessibility**: Controls keyboard navigable, focus states visible, semantics for screen readers.

### Non-Functional
- **Performance**: Search response < 500ms median (p95 < 900ms) for datasets ≤10k listings.
- **Reliability**: Gracefully handles canister timeouts with retry CTA.
- **Security**: Input sanitized to prevent injection; enforced rate limit (10 queries / 10s per identity).
- **Localization**: Strings anchored in ARB files; new keys documented for translators.
- **Analytics**: Events emitted via existing logging pipeline; doc instrumentation spec in Appendix.

## 5. UX Notes

- Search field pinned to top with clear placeholder (“Search listings”).
- Filters exposed in collapsible chip row; expanded drawer for min/max price input.
- Empty state illustration with actionable copy (“No matches yet – adjust filters or add new keywords.”).
- Loading skeleton for initial fetch and between pagination requests.
- Responsive behavior: For narrow viewports, filters collapse into bottom sheet toggle.

### Content Checklist
- Ensure category labels match localized strings: Electronics, Fashion, Home & Garden, Sports, Books, Automotive, Collectibles, Other.
- Validation messages localizable; price error copy must include “greater than” in EN to satisfy regression tests.

## 6. Technical Alignment

- **Frontend**: Flutter `SearchListingsCubit` manages state, leverages debounced text input, integrates with `MarketServiceProvider`.
- **Backend / Canister**: `getListings` query accepts optional filters (`query`, `category`, `minPrice`, `maxPrice`, `location`, `condition`) and returns cursor-based pagination struct.
- **Data Model**: Listing IDs treated as strings, ensuring consistency with ICP canister responses.
- **Routing**: `AppRouter` includes `/search` route, supports deep linking with serialized query params.
- **Testing**: Widget tests for search screen interactions; ic-repl coverage validates canister filter combinations; integration test ensures pagination and clear-all behavior.

## 7. Dependencies & Risks

| Item | Owner | Risk | Mitigation |
| --- | --- | --- | --- |
| Canister filter performance | Backend | Query complexity could exceed limits | Benchmark with sample data, optimize indexing. |
| Localization backlog | PM | New strings miss translation window | Batch translation request ahead of release, provide context. |
| Analytics noise | Dev | Logging in prod could expose PII | Keep telemetry gated to non-prod builds, hash user IDs. |
| UX clarity | Design | Chip overload on small screens | Validate responsive design with mockups; adjust to dropdown menu if needed. |

## 8. Launch Plan

1. **Dev Complete** → QA validation (format/analyze/test + exploratory flows).
2. **Feature Flag (optional)**: Roll out behind runtime flag for staged release.
3. **Beta Pilot**: Enable for internal accounts + select power sellers for feedback.
4. **Full Launch**: Promote via in-app banner for two weeks; monitor conversion metrics daily.
5. **Post-Launch Review**: Compare metrics to success signals at +2 weeks and +4 weeks; document learnings and backlog follow-ups.

## 9. Appendices

- **A. Telemetry Spec**: `search_query`, `filter_applied`, `pagination_next`, `filters_cleared` events with fields {query, category, min_price, max_price, location, result_count, duration_ms}.
- **B. QA Checklist**: Validate each filter combination, verify localization toggles, confirm analytics disabled in production flavor.
- **C. Future Enhancements**: Saved searches, alert notifications, ML-powered recommendations, multi-seller comparisons.

