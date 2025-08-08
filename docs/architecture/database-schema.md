# **Database Schema**

## **On-Chain Data Storage**

Since we're using ICP canisters, all data is stored on-chain in canister state. Here's the conceptual data model:

### **Marketplace Canister Storage**

```motoko
// User storage
private stable var users = Map.HashMap<Principal, User>();
private stable var userListings = Map.HashMap<Principal, List<Nat>>();
private stable var userReputation = Map.HashMap<Principal, Nat>();

// Listing storage
private stable var listings = Map.HashMap<Nat, Listing>();
private stable var categoryListings = Map.HashMap<Text, List<Nat>>();
private stable var activeListings = List<Nat>();
private stable var nextListingId = Nat = 1;

// Search indexes
private stable var titleIndex = Map.HashMap<Text, List<Nat>>();
private stable var priceIndex = Map.HashMap<Nat64, List<Nat>>();
private stable var locationIndex = Map.HashMap<Text, List<Nat>>();
```

### **Atomic Swap Canister Storage**

```motoko
// Swap storage
private stable var swaps = Map.HashMap<Nat, AtomicSwap>();
private stable var userSwaps = Map.HashMap<Principal, List<Nat>>();
private stable var listingSwaps = Map.HashMap<Nat, List<Nat>>();
private stable var pendingSwaps = List<Nat>();
private stable var nextSwapId = Nat = 1;

// Security tracking
private stable var secretHashes = Set.Set<[Nat8]>();
private stable var swapLocks = Map.HashMap<[Nat8], Bool>();
```

### **User Management Canister Storage**

```motoko
// User storage
private stable var users = Map.HashMap<Principal, User>();
private stable var emailUsers = Map.HashMap<Text, Principal>();
private stable var usernameUsers = Map.HashMap<Text, Principal>();
private stable var oauthUsers = Map.HashMap<Text, Principal>();

// Authentication
private stable var passwordHashes = Map.HashMap<Principal, [Nat8]>();
private stable var oauthTokens = Map.HashMap<Text, Principal>();
private stable var sessions = Map.HashMap<Text, Principal>();

// Security
private stable var failedAttempts = Map.HashMap<Principal, Nat>();
private stable var lockedAccounts = Set.Set<Principal>();
```

### **Price Oracle Canister Storage**

```motoko
// Price storage
private stable var prices = Map.HashMap<Text, PriceData>();
private stable var priceHistory = Map.HashMap<Text, List<PriceData>>();
private stable var lastUpdate = Int = 0;

// Authorized updaters
private stable var authorizedUpdaters = Set.Set<Principal>();
private stable var updateHistory = List<PriceUpdate>();
```
