# 3a. Personas & User Journeys

## Personas
- Buyer (New-to-crypto, wants simple, safe purchase)
- Seller (Experienced, values speed and reputation)
- Moderator/Admin (Resolves disputes, ensures compliance)

## Primary Journeys (Happy Paths)
1) Buyer purchases crypto via bank transfer
   - Discover listing → Verify price → Initiate swap (HTLC) → Pay off-chain → Seller confirms → Buyer redeems → Complete
2) Seller lists crypto and completes sale
   - Create listing → Price oracle fetch → Receive request → Lock availability → Confirm payment → Release funds → Complete

## Edge/Exception Journeys (MVP)
- Dispute: Payment claimed but not received → Manual review → Resolution outcome
- Timeout: HTLC timelock expires → Refund path

## Journey Acceptance (examples)
- Given listing is available, when buyer initiates swap with valid parameters, then escrow is created and status=Pending.
- Given seller confirms payment received, when buyer reveals secret, then funds release to seller and order marked Fulfilled.

