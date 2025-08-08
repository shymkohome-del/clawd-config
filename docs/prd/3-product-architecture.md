# 3. Product Architecture

## 3.1 System Architecture Overview
```
┌─────────────────┐    ┌─────────────────────────────────┐
│   Frontend      │    │   Internet Computer (ICP)       │
│   (Flutter)     │◄──►│   Canisters (Smart Contracts)   │
└─────────────────┘    └─────────────────────────────────┘
         │                             │
         ▼                             ▼
┌─────────────────┐    ┌─────────────────────────────────┐
│   Mobile App    │    │   Marketplace Canister          │
│   (iOS/Android) │    │   Atomic Swap Canister          │
└─────────────────┘    │   User Management Canister      │
                       │   Price Oracle Canister         │
                       │   Messaging Canister            │
                       └─────────────────────────────────┘
```

## 3.2 Technology Stack
- **Frontend**: Flutter/Dart for cross-platform mobile applications
- **Backend**: Internet Computer (ICP) canisters (no traditional backend)
- **Smart Contracts**: Motoko for business logic and data persistence
- **Database**: On-chain storage in ICP canisters
- **Authentication**: Hybrid authentication with ICP identity mapping
- **Storage**: IPFS for large file storage + on-chain metadata

## 3.3 Smart Contract Architecture
The marketplace will implement three core smart contracts:

### 3.3.1 Marketplace Contract
```motoko
actor Marketplace {
    // User management
    private stable var users : HashMap.Principal = HashMap.HashMap<Principal, User>();
    private stable var listings : HashMap.Nat = HashMap.HashMap<Nat, Listing>();
    private stable var nextListingId : Nat = 1;
    
    // User type definition
    private type User = {
        id : Principal;
        username : Text;
        reputation : Nat;
        createdAt : Int;
        isActive : Bool;
    };
    
    // Listing type definition
    private type Listing = {
        id : Nat;
        seller : Principal;
        amount : Nat;
        price : Nat;
        cryptocurrency : Text;
        paymentMethod : Text;
        status : Text;
        createdAt : Int;
    };
    
    // Create new listing
    public shared ({ caller }) func createListing(
        amount : Nat,
        price : Nat,
        cryptocurrency : Text,
        paymentMethod : Text
    ) : async Result<Nat, Text> {
        // Implementation details
    };
    
    // Get all active listings
    public query func getActiveListings() : async [Listing] {
        // Implementation details
    };
}
```

## 3.4 Identity & Authentication Architecture

The platform uses a hybrid authentication model to balance mainstream UX with decentralized security, while standardizing on ICP principals for all on-chain operations.

- Traditional authentication: Email/password and social OAuth (Google, GitHub, Apple)
- Optional Web3: Wallet connection for advanced users (progressive onboarding)
- Identity mapping: An ICP "Identity Mapping" canister maps user accounts to ICP principals for consistent authorization across contracts

High-level flow:
1. User signs in via traditional auth (or social OAuth)
2. App/backend requests or creates an ICP principal via the Identity Mapping canister
3. Principal is associated with the user for all marketplace, swap, and messaging actions
4. Sensitive operations (e.g., high-value swaps) can require step-up auth (2FA)

Security considerations (summarized; see Risks):
- Principal issuance: prevent duplicate mappings and enforce rate limits
- Token/session handling: short-lived JWTs, secure storage, rotation
- Privacy: avoid unnecessary linkage between Web2 identity and ICP principal in logs/analytics

## 3.5 Technology Alternatives & Selection Rationale

Decision: Standardize on Internet Computer (ICP) for smart contracts and execution environment.

Rationale for ICP:
- Reverse gas model and predictable operating costs (cycles)
- Native HTTPS outcalls and threshold ECDSA enable direct BTC/ETH integrations
- Strong performance characteristics suitable for consumer apps
- Unified on-chain state and canister model simplifies multi-component orchestration

Alternative considered — Tezos:
- Strengths: formal verification, low fees, PoS governance
- Trade-offs: weaker direct cross-chain primitives vs ICP threshold ECDSA; fewer native web integrations for our use case

Conclusion: ICP provides better end-to-end alignment with our goals (atomic swaps, cross-chain support, consumer-grade UX). Tezos remains a viable future expansion target if requirements shift.

### 3.3.2 Atomic Swap Escrow Contract
```motoko
actor AtomicSwapEscrow {
    private stable var swaps : HashMap.Nat = HashMap.HashMap<Nat, AtomicSwap>();
    private stable var nextSwapId : Nat = 1;
    
    private type AtomicSwap = {
        id : Nat;
        initiator : Principal;
        participant : Principal;
        amount : Nat;
        hashLock : [Nat8];
        timeLock : Int;
        status : Text;
        secret : ?[Nat8];
        createdAt : Int;
    };
    
    // Initiate atomic swap
    public shared ({ caller }) func initiateSwap(
        participant : Principal,
        amount : Nat,
        hashLock : [Nat8],
        timeLock : Int
    ) : async Result<Nat, Text> {
        // Implementation details
    };
    
    // Complete atomic swap
    public shared ({ caller }) func completeSwap(
        swapId : Nat,
        secret : [Nat8]
    ) : async Result<(), Text> {
        // Implementation details
    };
    
    // Refund atomic swap
    public shared ({ caller }) func refundSwap(
        swapId : Nat
    ) : async Result<(), Text> {
        // Implementation details
    };
}
```

### 3.3.3 Cross-Chain Price Oracle
```motoko
actor PriceOracle {
    private stable var prices : HashMap.Text = HashMap.HashMap<Text, Nat>();
    private stable var lastUpdate : Int = 0;
    
    // Update price data
    public shared ({ caller }) func updatePrice(
        cryptocurrency : Text,
        price : Nat
    ) : async Result<(), Text> {
        // Implementation details
    };
    
    // Get current price
    public query func getPrice(
        cryptocurrency : Text
    ) : async Result<Nat, Text> {
        // Implementation details
    };
}
```
