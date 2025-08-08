# **Data Models**

## **User Model**

**Purpose:** Represents user accounts with hybrid authentication and reputation system

**Key Attributes:**
- id: Principal - ICP principal identifier
- username: Text - User display name
- email: Text - Email address (traditional auth)
- authProvider: Text - Authentication method (email, google, etc.)
- reputation: Nat - User reputation score
- createdAt: Int - Account creation timestamp
- lastLogin: Int - Last activity timestamp
- isActive: Bool - Account status
- kycVerified: Bool - KYC verification status
- profileImage: Text - IPFS hash of profile image

**TypeScript Interface:**
```typescript
interface User {
  id: Principal;
  username: string;
  email: string;
  authProvider: 'email' | 'google' | 'github' | 'apple';
  reputation: number;
  createdAt: bigint;
  lastLogin: bigint;
  isActive: boolean;
  kycVerified: boolean;
  profileImage?: string; // IPFS hash
}
```

**Relationships:**
- One-to-many: User creates many Listings
- One-to-many: User participates in many Atomic Swaps
- One-to-many: User sends many Messages
- One-to-many: User receives many Reputation ratings

## **Listing Model**

**Purpose:** Represents marketplace items for sale

**Key Attributes:**
- id: Nat - Unique listing identifier
- seller: Principal - Seller's principal
- title: Text - Item title
- description: Text - Item description
- priceUSD: Nat64 - Price in USD
- cryptoType: Text - Accepted cryptocurrency
- images: [Text] - Array of IPFS image hashes
- category: Text - Item category
- condition: Text - Item condition
- location: Text - Seller location
- shippingOptions: [Text] - Available shipping methods
- status: Text - Listing status
- createdAt: Int - Creation timestamp
- updatedAt: Int - Last update timestamp

**TypeScript Interface:**
```typescript
interface Listing {
  id: number;
  seller: Principal;
  title: string;
  description: string;
  priceUSD: bigint;
  cryptoType: string;
  images: string[];
  category: string;
  condition: 'new' | 'used' | 'refurbished';
  location: string;
  shippingOptions: string[];
  status: 'active' | 'pending' | 'sold' | 'cancelled';
  createdAt: bigint;
  updatedAt: bigint;
}
```

**Relationships:**
- Many-to-one: Listing belongs to one User
- One-to-many: Listing can have many Atomic Swaps
- One-to-many: Listing can have many Messages

## **Atomic Swap Model**

**Purpose:** Handles trustless cryptocurrency escrow for transactions

**Key Attributes:**
- id: Nat - Unique swap identifier
- listingId: Nat - Associated listing
- buyer: Principal - Buyer's principal
- seller: Principal - Seller's principal
- secretHash: [Nat8] - Hashed secret for HTLC
- secret: [Nat8] - Revealed secret (when completed)
- amount: Nat64 - Cryptocurrency amount
- cryptoType: Text - Cryptocurrency type
- timeout: Int - Timeout timestamp
- status: Text - Swap status
- createdAt: Int - Creation timestamp
- completedAt: Int - Completion timestamp

**TypeScript Interface:**
```typescript
interface AtomicSwap {
  id: number;
  listingId: number;
  buyer: Principal;
  seller: Principal;
  secretHash: Uint8Array;
  secret?: Uint8Array;
  amount: bigint;
  cryptoType: string;
  timeout: bigint;
  status: 'pending' | 'completed' | 'cancelled' | 'disputed';
  createdAt: bigint;
  completedAt?: bigint;
}
```

**Relationships:**
- Many-to-one: Atomic Swap belongs to one Listing
- Many-to-one: Atomic Swap initiated by one User (buyer)
- Many-to-one: Atomic Swap associated with one User (seller)
