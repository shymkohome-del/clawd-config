# **API Specification**

## **ICP Candid Interface**

Since we're using ICP canisters, the API is defined using Candid interface definition language. This provides type-safe communication between Flutter apps and canisters.

```candid
type Principal = Principal;
type Nat = Nat;
type Nat64 = Nat64;
type Int = Int;
type Text = Text;
type Bool = Bool;
type Timestamp = Int;

// User types
type User = {
  id: Principal;
  username: Text;
  email: Text;
  authProvider: Text;
  reputation: Nat;
  createdAt: Timestamp;
  lastLogin: Timestamp;
  isActive: Bool;
  kycVerified: Bool;
  profileImage: ?Text;
};

type AuthProvider = { #email; #google; #github; #apple };

// Listing types
type Listing = {
  id: Nat;
  seller: Principal;
  title: Text;
  description: Text;
  priceUSD: Nat64;
  cryptoType: Text;
  images: [Text];
  category: Text;
  condition: { #new; #used; #refurbished };
  location: Text;
  shippingOptions: [Text];
  status: { #active; #pending; #sold; #cancelled };
  createdAt: Timestamp;
  updatedAt: Timestamp;
};

// Atomic Swap types
type AtomicSwap = {
  id: Nat;
  listingId: Nat;
  buyer: Principal;
  seller: Principal;
  secretHash: [Nat8];
  secret: ?[Nat8];
  amount: Nat64;
  cryptoType: Text;
  timeout: Timestamp;
  status: { #pending; #completed; #cancelled; #disputed };
  createdAt: Timestamp;
  completedAt: ?Timestamp;
};

// Marketplace Canister
service : {
  // Listing management
  createListing : (title: Text, description: Text, priceUSD: Nat64, 
                   cryptoType: Text, images: [Text], category: Text,
                   condition: { #new; #used; #refurbished }, location: Text,
                   shippingOptions: [Text]) -> async (Result<Nat, Text>);
  getListing : (id: Nat) -> async (?Listing);
  getListings : (query: ?Text, category: ?Text, minPrice: ?Nat64, 
                 maxPrice: ?Nat64, limit: ?Nat) -> async ([Listing]);
  updateListing : (id: Nat, updates: ListingUpdate) -> async (Result<(), Text>);
  deleteListing : (id: Nat) -> async (Result<(), Text>);
  
  // User listings
  getUserListings : (user: Principal) -> async ([Listing]);
  
  // Categories
  getCategories : () -> async ([Text]);
};

// User Management Canister
service : {
  // Authentication
  authenticate : (email: Text, password: Text) -> async (Result<User, Text>);
  register : (email: Text, password: Text, username: Text) -> async (Result<User, Text>);
  loginWithOAuth : (provider: AuthProvider, token: Text) -> async (Result<User, Text>);
  
  // User management
  updateUserProfile : (updates: UserUpdate) -> async (Result<(), Text>);
  getUserProfile : (user: Principal) -> async (?User);
  verifyKYC : (kycData: KYCData) -> async (Result<(), Text>);
  
  // Reputation
  updateReputation : (user: Principal, change: Int) -> async (Result<(), Text>);
  getUserReputation : (user: Principal) -> async (Nat);
};

// Atomic Swap Canister
service : {
  // Swap operations
  initiateSwap : (listingId: Nat, secretHash: [Nat8], timeout: Timestamp) -> async (Result<Nat, Text>);
  completeSwap : (swapId: Nat, secret: [Nat8]) -> async (Result<(), Text>);
  refundSwap : (swapId: Nat) -> async (Result<(), Text>);
  cancelSwap : (swapId: Nat) -> async (Result<(), Text>);
  
  // Swap queries
  getSwap : (swapId: Nat) -> async (?AtomicSwap);
  getUserSwaps : (user: Principal) -> async ([AtomicSwap]);
  getListingSwaps : (listingId: Nat) -> async ([AtomicSwap]);
  
  // Dispute resolution
  initiateDispute : (swapId: Nat, reason: Text) -> async (Result<(), Text>);
  resolveDispute : (swapId: Nat, resolution: DisputeResolution) -> async (Result<(), Text>);
};

// Price Oracle Canister
service : {
  // Price updates
  updatePrice : (symbol: Text, priceUSD: Nat64, confidence: Nat8, source: Text) -> async (Result<(), Text>);
  
  // Price queries
  getPrice : (symbol: Text) -> async (?PriceData);
  getPrices : () -> async ([(Text, PriceData)]);
  getConversionAmount : (fromUSD: Nat64, toCrypto: Text) -> async (?Nat64);
  
  // Supported symbols
  getSupportedSymbols : () -> async ([Text]);
};
```
