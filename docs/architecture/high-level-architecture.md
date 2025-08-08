# **High Level Architecture**

## **Technical Summary**

This architecture implements an **ICP-first approach** where Flutter mobile apps communicate directly with Internet Computer canisters, eliminating the traditional backend. All business logic, data persistence, authentication, and API endpoints run as smart contracts on ICP. We use a hybrid authentication model implemented inside canisters (email/password + social OAuth + ICP principal mapping), with optional wallet connect later. Progressive decentralization follows the PRD’s stage gates.

## **Platform and Infrastructure Choice**

**Platform:** Internet Computer (Primary) + Optional CDN for static assets
**Key Services:** ICP Canisters (Smart Contracts), Cycles Management, Boundary Nodes, CDN (optional)
**Deployment Host and Regions:** ICP Mainnet + Geo-distributed canisters

**Rationale:**
- **ICP-first decentralization** with canister-native services
- **No traditional backend** to maintain or secure
- **Hybrid Auth in-canister** (email/password + OAuth + ICP mapping) with optional wallet connect later
- **Scalability** through ICP's horizontal scaling
- **Performance** with sub-second finality and high throughput
- **Progressive complexity**: add features/cross-chain per PRD stage gates; fallback to auxiliary services only if needed

## **Repository Structure**

**Structure:** Monorepo with Flutter app + ICP canisters
**Monorepo Tool:** Nx workspace + DFX (ICP SDK)
**Package Organization:** Flutter mobile app + ICP canisters + shared types

## **Architecture Diagram - ICP Native**

```mermaid
graph TB
    subgraph "Client Layer"
        M1[Flutter Mobile App<br/>iOS/Android]
        W1[Web Dashboard<br/>React/Next.js - Optional]
    end
    
    subgraph "ICP Canisters (Smart Contracts)"
        C1[Marketplace Canister<br/>Listings & Trading]
        C2[Atomic Swap Canister<br/>HTLC Escrow]
        C3[User Management Canister<br/>Profiles & Auth]
        C4[Messaging Canister<br/>P2P Communication]
        C5[Price Oracle Canister<br/>Real-time Pricing]
        C6[Asset Storage Canister<br/>IPFS Integration]
        C7[Analytics Canister<br/>Usage Metrics]
    end
    
    subgraph "External Services"
        E1[Payment Processors<br/>Bank/Wallet APIs]
        E2[External Price Feeds<br/>Chainlink/Coingecko]
        E3[KYC Providers<br/>Identity Services]
        E4[IPFS Network<br/>File Storage]
        E5[Notification Services<br/>Push/SMS/Email]
    end
    
    M1 --> C1
    M1 --> C2
    M1 --> C3
    M1 --> C4
    M1 --> C5
    W1 --> C1
    W1 --> C2
    W1 --> C3
    
    C1 -.-> C2
    C2 -.-> C5
    C3 -.-> C6
    C4 -.-> E5
    C5 -.-> E2
    C3 -.-> E3
    C6 -.-> E4
    C1 -.-> E1
```

## **Architectural Patterns**

- **Canister-Based Architecture:** Each logical component as separate canister - _Rationale:_ Enables independent scaling and deployment of different concerns
- **Direct Client-to-Canister Communication:** Flutter apps call canisters directly - _Rationale:_ Eliminates backend layer, reduces latency
- **Hybrid Authentication in Canister:** Traditional + OAuth + ICP principal mapping - _Rationale:_ Lower onboarding friction while keeping on-chain authorization
- **On-Chain Data Storage:** Canister state for business data; IPFS for large assets - _Rationale:_ Decentralization and cost efficiency
- **Inter-Canister Communication:** Canisters communicate directly - _Rationale:_ Efficient intra-system communication
- **Cycles-Based Economics:** Pay-per-use model - _Rationale:_ Cost-efficient, scales with usage
- **Asset Offloading to IPFS:** Large files stored on IPFS - _Rationale:_ Cost-effective for large media/files

## **MVP Scope Alignment**

Refer to the PRD’s ICP-first MVP constraints, KPIs, and stage gates:
- [0. MVP Scope (ICP-First)](../prd/0-mvp-scope.md)
- Stage gates and KPIs are mirrored in the timeline and success metrics sections of the PRD.
