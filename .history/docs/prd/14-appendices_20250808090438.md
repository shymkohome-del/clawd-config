# 14. Appendices

## 14.1 Technical Specifications
- **API Documentation**: Complete API reference
- **Database Schema**: Detailed database structure
- **Smart Contract Interfaces**: Contract ABI documentation
- **Integration Guides**: Third-party integration instructions

## 14.2 User Documentation
- **User Guide**: Step-by-step user instructions
- **Security Best Practices**: Security recommendations for users
- **FAQ**: Frequently asked questions
- **Video Tutorials**: Educational video content

## 14.3 Legal Documents
- **Terms of Service**: Complete terms and conditions
- **Privacy Policy**: Data protection and privacy policies
- **KYC/AML Policy**: Compliance procedures documentation
- **Risk Disclosure**: Investment risk disclosures

## 14.4 Sequence Diagrams

### 14.4.1 Multi-Crypto Payment Flow (ICP)

```mermaid
sequenceDiagram
    participant Buyer
    participant App as Mobile App
    participant Oracle as Price Oracle Canister
    participant Market as Marketplace Canister
    participant Escrow as Atomic Swap Canister
    participant Seller

    Buyer->>App: Select listing, choose crypto
    App->>Oracle: Fetch latest price for selected crypto
    Oracle-->>App: Price data
    App->>Escrow: Initiate HTLC (hashLock, timeLock, amount)
    Escrow-->>App: Swap created (#pending)
    App-->>Seller: Notify pending swap
    Seller->>Market: Lock listing / confirm availability
    Buyer->>Escrow: Reveal secret to redeem
    Escrow-->>Seller: Release funds (on redemption)
    Market-->>Buyer: Mark order fulfilled
    App-->>Buyer: Confirm completion

    Note over Escrow,Seller: BTC/ETH handled via ICP threshold ECDSA; other chains via ICP integrations
```

## 14.5 Frontend Module Structure

```text
lib/
  core/
    config/
    network/
    storage/
    blockchain/
    auth/
  shared/
    widgets/
    utils/
    models/
    theme/
  features/
    market/
    payments/
    atomic_swap/
    messaging/
    disputes/
    profile/
  main.dart
```

---

*This document represents the merged requirements from the project brief and product requirements document, providing a comprehensive guide for the development of the decentralized P2P cryptocurrency marketplace.*