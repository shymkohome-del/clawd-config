# 4b. User Stories & Acceptance Criteria (MVP)

Notation: [Epic].[Story]

## E1. User & Identity
- E1.S1 Register with email/social
  - As a new user, I want to register with email or social so I can access the marketplace.
  - Acceptance:
    - Given valid email/social, when I submit, then an account is created and I am signed in.
    - Given registration completes, when mapping occurs, then an ICP principal is associated with my account.

## E2. Listings & Discovery
- E2.S1 Create listing
  - As a seller, I want to create a listing with price and payment method so buyers can discover my offer.
  - Acceptance:
    - Given required fields, when I submit, then listing status=Active and searchable.

## E3. Atomic Swap Escrow
- E3.S1 Initiate swap (HTLC)
  - As a buyer, I want to initiate an atomic swap so my payment is protected until release.
  - Acceptance:
    - Given listing is active, when I initiate with valid parameters, then escrow is created with timelock and hashlock.

## E7. Disputes (Manual MVP)
- E7.S1 Open dispute
  - As a buyer or seller, I want to open a dispute if payment and release are inconsistent.
  - Acceptance:
    - Given an active trade, when I open a dispute, then a case is created and assigned for moderation.

Notes:
- Extend with additional stories as needed; trace stories to requirements and KPIs in Traceability Matrix.

