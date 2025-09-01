import Principal "mo:base/Principal";

module {
  public type ListingId = Text;
  
  public type Listing = {
    id : ListingId;
    seller : Principal;
    title : Text;
    description : Text;
    cryptoAsset : Text; // e.g., "BTC", "ETH", "ICP"
    amount : Nat64; // in smallest units (satoshis, wei, etc.)
    priceInUsd : Nat64; // price in USD cents
    paymentMethods : [Text]; // supported payment methods
    isActive : Bool;
    createdAt : Nat64;
    updatedAt : Nat64;
  };

  public type CreateListingRequest = {
    title : Text;
    description : Text;
    cryptoAsset : Text;
    amount : Nat64;
    priceInUsd : Nat64;
    paymentMethods : [Text];
  };

  public type UpdateListingRequest = {
    title : ?Text;
    description : ?Text;
    amount : ?Nat64;
    priceInUsd : ?Nat64;
    paymentMethods : ?[Text];
    isActive : ?Bool;
  };

  public type SearchFilters = {
    cryptoAsset : ?Text;
    minAmount : ?Nat64;
    maxAmount : ?Nat64;
    minPrice : ?Nat64;
    maxPrice : ?Nat64;
    paymentMethod : ?Text;
  };

  public type SearchResult = {
    listings : [Listing];
    totalCount : Nat;
    hasMore : Bool;
  };

  public type CreateListingResult = { #ok : Listing; #err : Text };
  public type UpdateListingResult = { #ok : Listing; #err : Text };
  public type GetListingResult = { #ok : Listing; #err : Text };
  public type SearchListingsResult = { #ok : SearchResult; #err : Text };
  public type DeleteListingResult = { #ok : (); #err : Text };
}
