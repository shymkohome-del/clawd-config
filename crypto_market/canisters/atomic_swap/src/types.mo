import Principal "mo:base/Principal";
import Blob "mo:base/Blob";

module {
  public type SwapId = Text;
  public type SecretHash = Blob;
  public type Secret = Blob;
  
  public type SwapState = {
    #initiated;
    #locked;
    #completed;
    #refunded;
    #expired;
  };
  
  public type HTLCContract = {
    id : SwapId;
    buyer : Principal;
    seller : Principal;
    listingId : Text;
    cryptoAsset : Text;
    amount : Nat64;
    priceInUsd : Nat64;
    secretHash : SecretHash;
    lockTime : Nat64; // Unix timestamp in seconds
    createdAt : Nat64;
    state : SwapState;
    buyerDeposit : ?Nat64; // escrow amount from buyer
    sellerDeposit : ?Nat64; // escrow amount from seller
  };

  public type InitiateSwapRequest = {
    seller : Principal;
    listingId : Text;
    cryptoAsset : Text;
    amount : Nat64;
    priceInUsd : Nat64;
    lockTimeHours : Nat; // timeout in hours (typically 24-48)
  };

  public type LockFundsRequest = {
    swapId : SwapId;
    buyerDepositAmount : Nat64;
    sellerDepositAmount : Nat64;
  };

  public type CompleteSwapRequest = {
    swapId : SwapId;
    secret : Secret;
  };

  public type InitiateSwapResult = { #ok : HTLCContract; #err : Text };
  public type LockFundsResult = { #ok : HTLCContract; #err : Text };
  public type CompleteSwapResult = { #ok : HTLCContract; #err : Text };
  public type RefundSwapResult = { #ok : HTLCContract; #err : Text };
  public type GetSwapResult = { #ok : HTLCContract; #err : Text };
  public type GetUserSwapsResult = { #ok : [HTLCContract]; #err : Text };
}
