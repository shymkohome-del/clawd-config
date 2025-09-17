import Principal "mo:base/Principal";

module {
  public type ListingId = Text;

  public type ListingCondition = { #new; #used; #refurbished };
  public type ListingStatus = { #active; #pending; #sold; #cancelled };

  public type Listing = {
    id : ListingId;
    seller : Principal;
    title : Text;
    description : Text;
    priceUSD : Nat64;
    cryptoType : Text;
    images : [Text];
    category : Text;
    condition : ListingCondition;
    location : Text;
    shippingOptions : [Text];
    status : ListingStatus;
    createdAt : Nat64;
    updatedAt : Nat64;
  };

  public type CreateListingRequest = {
    title : Text;
    description : Text;
    priceUSD : Nat64;
    cryptoType : Text;
    images : [Text];
    category : Text;
    condition : ListingCondition;
    location : Text;
    shippingOptions : [Text];
  };

  public type UpdateListingRequest = {
    title : ?Text;
    description : ?Text;
    priceUSD : ?Nat64;
    cryptoType : ?Text;
    images : ?[Text];
    category : ?Text;
    condition : ?ListingCondition;
    location : ?Text;
    shippingOptions : ?[Text];
    status : ?ListingStatus;
  };

  public type SearchFilters = {
    query : ?Text;
    category : ?Text;
    minPrice : ?Nat64;
    maxPrice : ?Nat64;
    location : ?Text;
    condition : ?ListingCondition;
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
