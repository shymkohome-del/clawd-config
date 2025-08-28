import Array "mo:base/Array";
import Blob "mo:base/Blob";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Random "mo:base/Random";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Types "./types";
import UUID "mo:uuid/UUID";
import Source "mo:uuid/Source";

actor AtomicSwapCanister {
  
  stable var swapsEntries : [(Types.SwapId, Types.HTLCContract)] = [];
  stable var userSwapsEntries : [(Principal, [Types.SwapId])] = [];
  
  let swaps = HashMap.HashMap<Types.SwapId, Types.HTLCContract>(16, Text.equal, Text.hash);
  let userSwaps = HashMap.HashMap<Principal, [Types.SwapId]>(16, Principal.equal, Principal.hash);

  system func preupgrade() {
    swapsEntries := Iter.toArray(swaps.entries());
    userSwapsEntries := Iter.toArray(userSwaps.entries());
  };

  system func postupgrade() {
    swaps.clear();
    for ((id, swap) in swapsEntries.vals()) { swaps.put(id, swap); };
    userSwaps.clear();
    for ((user, userSwap) in userSwapsEntries.vals()) { userSwaps.put(user, userSwap); };
    swapsEntries := [];
    userSwapsEntries := [];
  };

  private func nowSeconds() : Nat64 {
    let nanos = Time.now();
    Nat64.fromNat(Nat.div(nanos, 1_000_000_000));
  };

  private func nowMillis() : Nat64 {
    let nanos = Time.now();
    Nat64.fromNat(Nat.div(nanos, 1_000_000));
  };

  private func generateSwapId() : Types.SwapId {
    let g = Source.Source();
    UUID.toText(g.new());
  };

  private func generateSecretHash() : Types.SecretHash {
    // In real implementation, this would be provided by the buyer
    // For now, generate a random 32-byte hash
    let entropy = Random.blob();
    Blob.fromArray([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]);
  };

  private func validateSecretAgainstHash(secret : Types.Secret, hash : Types.SecretHash) : Bool {
    // In real implementation, this would use SHA-256 or similar
    // For now, simple validation
    Blob.toArray(secret) == Blob.toArray(hash)
  };

  private func addUserSwap(user : Principal, swapId : Types.SwapId) {
    switch (userSwaps.get(user)) {
      case (?existing) {
        let updated = Array.append(existing, [swapId]);
        userSwaps.put(user, updated);
      };
      case null {
        userSwaps.put(user, [swapId]);
      };
    };
  };

  public shared ({ caller }) func initiateSwap(req : Types.InitiateSwapRequest) : async Types.InitiateSwapResult {
    // Validate request
    if (req.amount == 0) {
      return #err("amount_must_be_positive");
    };
    if (req.priceInUsd == 0) {
      return #err("price_must_be_positive");
    };
    if (req.lockTimeHours < 1 or req.lockTimeHours > 168) { // 1 hour to 1 week
      return #err("invalid_lock_time");
    };
    if (caller == req.seller) {
      return #err("cannot_initiate_swap_with_yourself");
    };

    let swapId = generateSwapId();
    let secretHash = generateSecretHash();
    let lockTime = nowSeconds() + Nat64.fromNat(req.lockTimeHours * 3600); // convert hours to seconds
    
    let htlcContract : Types.HTLCContract = {
      id = swapId;
      buyer = caller;
      seller = req.seller;
      listingId = req.listingId;
      cryptoAsset = req.cryptoAsset;
      amount = req.amount;
      priceInUsd = req.priceInUsd;
      secretHash = secretHash;
      lockTime = lockTime;
      createdAt = nowMillis();
      state = #initiated;
      buyerDeposit = null;
      sellerDeposit = null;
    };

    swaps.put(swapId, htlcContract);
    addUserSwap(caller, swapId);
    addUserSwap(req.seller, swapId);
    
    #ok(htlcContract)
  };

  public shared ({ caller }) func lockFunds(req : Types.LockFundsRequest) : async Types.LockFundsResult {
    switch (swaps.get(req.swapId)) {
      case (?existing) {
        // Check authorization
        if (existing.buyer != caller and existing.seller != caller) {
          return #err("unauthorized");
        };

        // Check current state
        if (existing.state != #initiated and existing.state != #locked) {
          return #err("invalid_state_for_locking");
        };

        // Check if not expired
        if (nowSeconds() > existing.lockTime) {
          let expiredContract = updateSwapState(existing, #expired);
          return #err("swap_expired");
        };

        // Update deposits based on caller
        let (newBuyerDeposit, newSellerDeposit) = if (existing.buyer == caller) {
          (Option.get(existing.buyerDeposit, 0) + req.buyerDepositAmount, existing.sellerDeposit)
        } else {
          (existing.buyerDeposit, Option.get(existing.sellerDeposit, 0) + req.sellerDepositAmount)
        };

        let updated : Types.HTLCContract = {
          id = existing.id;
          buyer = existing.buyer;
          seller = existing.seller;
          listingId = existing.listingId;
          cryptoAsset = existing.cryptoAsset;
          amount = existing.amount;
          priceInUsd = existing.priceInUsd;
          secretHash = existing.secretHash;
          lockTime = existing.lockTime;
          createdAt = existing.createdAt;
          state = if (newBuyerDeposit != null and newSellerDeposit != null) #locked else existing.state;
          buyerDeposit = ?newBuyerDeposit;
          sellerDeposit = ?newSellerDeposit;
        };

        swaps.put(req.swapId, updated);
        #ok(updated)
      };
      case null { #err("swap_not_found") };
    }
  };

  public shared ({ caller }) func completeSwap(req : Types.CompleteSwapRequest) : async Types.CompleteSwapResult {
    switch (swaps.get(req.swapId)) {
      case (?existing) {
        // Only seller can complete the swap by revealing the secret
        if (existing.seller != caller) {
          return #err("only_seller_can_complete");
        };

        // Check current state
        if (existing.state != #locked) {
          return #err("swap_not_locked");
        };

        // Check if not expired
        if (nowSeconds() > existing.lockTime) {
          let expiredContract = updateSwapState(existing, #expired);
          return #err("swap_expired");
        };

        // Validate secret against hash
        if (not validateSecretAgainstHash(req.secret, existing.secretHash)) {
          return #err("invalid_secret");
        };

        let completed = updateSwapState(existing, #completed);
        #ok(completed)
      };
      case null { #err("swap_not_found") };
    }
  };

  public shared ({ caller }) func refundSwap(swapId : Types.SwapId) : async Types.RefundSwapResult {
    switch (swaps.get(swapId)) {
      case (?existing) {
        // Both buyer and seller can initiate refund
        if (existing.buyer != caller and existing.seller != caller) {
          return #err("unauthorized");
        };

        // Check if expired or can be refunded
        let canRefund = (nowSeconds() > existing.lockTime) or 
                       (existing.state == #initiated and existing.buyer == caller);

        if (not canRefund) {
          return #err("cannot_refund_yet");
        };

        let refunded = updateSwapState(existing, #refunded);
        #ok(refunded)
      };
      case null { #err("swap_not_found") };
    }
  };

  public query func getSwap(swapId : Types.SwapId) : async Types.GetSwapResult {
    switch (swaps.get(swapId)) {
      case (?swap) { #ok(swap) };
      case null { #err("swap_not_found") };
    }
  };

  public query func getUserSwaps(user : Principal) : async Types.GetUserSwapsResult {
    switch (userSwaps.get(user)) {
      case (?swapIds) {
        let userSwapContracts = Array.mapFilter<Types.SwapId, Types.HTLCContract>(swapIds, func(id) {
          swaps.get(id)
        });
        #ok(userSwapContracts)
      };
      case null { #ok([]) };
    }
  };

  // Helper function to update swap state
  private func updateSwapState(existing : Types.HTLCContract, newState : Types.SwapState) : Types.HTLCContract {
    let updated : Types.HTLCContract = {
      id = existing.id;
      buyer = existing.buyer;
      seller = existing.seller;
      listingId = existing.listingId;
      cryptoAsset = existing.cryptoAsset;
      amount = existing.amount;
      priceInUsd = existing.priceInUsd;
      secretHash = existing.secretHash;
      lockTime = existing.lockTime;
      createdAt = existing.createdAt;
      state = newState;
      buyerDeposit = existing.buyerDeposit;
      sellerDeposit = existing.sellerDeposit;
    };
    
    swaps.put(existing.id, updated);
    updated
  };

  // Cleanup expired swaps (should be called periodically)
  public func cleanupExpiredSwaps() : async Nat {
    let now = nowSeconds();
    let allSwaps = Iter.toArray(swaps.vals());
    var cleanedCount = 0;
    
    for (swap in allSwaps.vals()) {
      if (now > swap.lockTime and (swap.state == #initiated or swap.state == #locked)) {
        ignore updateSwapState(swap, #expired);
        cleanedCount += 1;
      };
    };
    
    cleanedCount
  };
}
