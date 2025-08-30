import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Types "./types";
import UUID "mo:uuid/UUID";
import Source "mo:uuid/Source";

actor MarketplaceCanister {
  
  stable var listingsEntries : [(Types.ListingId, Types.Listing)] = [];
  stable var userListingsEntries : [(Principal, [Types.ListingId])] = [];
  
  let listings = HashMap.HashMap<Types.ListingId, Types.Listing>(16, Text.equal, Text.hash);
  let userListings = HashMap.HashMap<Principal, [Types.ListingId]>(16, Principal.equal, Principal.hash);

  system func preupgrade() {
    listingsEntries := Iter.toArray(listings.entries());
    userListingsEntries := Iter.toArray(userListings.entries());
  };

  system func postupgrade() {
    listings.clear();
    for ((id, listing) in listingsEntries.vals()) { listings.put(id, listing); };
    userListings.clear();
    for ((user, userListing) in userListingsEntries.vals()) { userListings.put(user, userListing); };
    listingsEntries := [];
    userListingsEntries := [];
  };

  private func nowMillis() : Nat64 {
    let nanos = Time.now();
    Nat64.fromNat(Nat.div(nanos, 1_000_000));
  };

  private func generateListingId() : Types.ListingId {
    let g = Source.Source();
    UUID.toText(g.new());
  };

  private func validateCreateListing(req : Types.CreateListingRequest) : ?Text {
    if (Text.size(req.title) < 5 or Text.size(req.title) > 100) {
      return ?"title_invalid_length";
    };
    if (Text.size(req.description) < 10 or Text.size(req.description) > 1000) {
      return ?"description_invalid_length";
    };
    if (req.amount == 0) {
      return ?"amount_must_be_positive";
    };
    if (req.priceInUsd == 0) {
      return ?"price_must_be_positive";
    };
    if (Array.size(req.paymentMethods) == 0) {
      return ?"payment_methods_required";
    };
    null
  };

  private func addUserListing(user : Principal, listingId : Types.ListingId) {
    switch (userListings.get(user)) {
      case (?existing) {
        let updated = Array.append(existing, [listingId]);
        userListings.put(user, updated);
      };
      case null {
        userListings.put(user, [listingId]);
      };
    };
  };

  private func removeUserListing(user : Principal, listingId : Types.ListingId) {
    switch (userListings.get(user)) {
      case (?existing) {
        let filtered = Array.filter<Types.ListingId>(existing, func(id) { id != listingId });
        userListings.put(user, filtered);
      };
      case null {};
    };
  };

  public shared ({ caller }) func createListing(req : Types.CreateListingRequest) : async Types.CreateListingResult {
    switch (validateCreateListing(req)) {
      case (?error) { return #err(error); };
      case null {};
    };

    let listingId = generateListingId();
    let now = nowMillis();
    
    let listing : Types.Listing = {
      id = listingId;
      seller = caller;
      title = req.title;
      description = req.description;
      cryptoAsset = req.cryptoAsset;
      amount = req.amount;
      priceInUsd = req.priceInUsd;
      paymentMethods = req.paymentMethods;
      isActive = true;
      createdAt = now;
      updatedAt = now;
    };

    listings.put(listingId, listing);
    addUserListing(caller, listingId);
    #ok(listing)
  };

  public query func getListing(listingId : Types.ListingId) : async Types.GetListingResult {
    switch (listings.get(listingId)) {
      case (?listing) { #ok(listing) };
      case null { #err("listing_not_found") };
    }
  };

  public shared ({ caller }) func updateListing(listingId : Types.ListingId, req : Types.UpdateListingRequest) : async Types.UpdateListingResult {
    switch (listings.get(listingId)) {
      case (?existing) {
        if (existing.seller != caller) {
          return #err("unauthorized");
        };
        
        let updated : Types.Listing = {
          id = existing.id;
          seller = existing.seller;
          title = Option.get(req.title, existing.title);
          description = Option.get(req.description, existing.description);
          cryptoAsset = existing.cryptoAsset; // immutable
          amount = Option.get(req.amount, existing.amount);
          priceInUsd = Option.get(req.priceInUsd, existing.priceInUsd);
          paymentMethods = Option.get(req.paymentMethods, existing.paymentMethods);
          isActive = Option.get(req.isActive, existing.isActive);
          createdAt = existing.createdAt;
          updatedAt = nowMillis();
        };
        
        listings.put(listingId, updated);
        #ok(updated)
      };
      case null { #err("listing_not_found") };
    }
  };

  public shared ({ caller }) func deleteListing(listingId : Types.ListingId) : async Types.DeleteListingResult {
    switch (listings.get(listingId)) {
      case (?existing) {
        if (existing.seller != caller) {
          return #err("unauthorized");
        };
        
        listings.delete(listingId);
        removeUserListing(caller, listingId);
        #ok(())
      };
      case null { #err("listing_not_found") };
    }
  };

  public query func searchListings(filters : Types.SearchFilters, offset : Nat, limit : Nat) : async Types.SearchListingsResult {
    let maxLimit = 50;
    let actualLimit = if (limit > maxLimit) maxLimit else limit;
    
    // Get all listings and filter
    let allListings = Iter.toArray(listings.vals());
    let filtered = Array.filter<Types.Listing>(allListings, func(listing) {
      if (not listing.isActive) return false;
      
      // Apply filters
      switch (filters.cryptoAsset) {
        case (?asset) { if (listing.cryptoAsset != asset) return false; };
        case null {};
      };
      
      switch (filters.minAmount) {
        case (?min) { if (listing.amount < min) return false; };
        case null {};
      };
      
      switch (filters.maxAmount) {
        case (?max) { if (listing.amount > max) return false; };
        case null {};
      };
      
      switch (filters.minPrice) {
        case (?min) { if (listing.priceInUsd < min) return false; };
        case null {};
      };
      
      switch (filters.maxPrice) {
        case (?max) { if (listing.priceInUsd > max) return false; };
        case null {};
      };
      
      switch (filters.paymentMethod) {
        case (?method) { 
          if (not Array.find<Text>(listing.paymentMethods, func(pm) { pm == method }) != null) return false;
        };
        case null {};
      };
      
      true
    });
    
    let totalCount = Array.size(filtered);
    let hasMore = offset + actualLimit < totalCount;
    
    // Apply pagination
    let startIndex = offset;
    let endIndex = Nat.min(startIndex + actualLimit, totalCount);
    let paginatedListings = if (startIndex >= totalCount) {
      []
    } else {
      Array.subArray<Types.Listing>(filtered, startIndex, endIndex - startIndex)
    };
    
    let result : Types.SearchResult = {
      listings = paginatedListings;
      totalCount = totalCount;
      hasMore = hasMore;
    };
    
    #ok(result)
  };

  public query func getUserListings(user : Principal) : async [Types.Listing] {
    switch (userListings.get(user)) {
      case (?listingIds) {
        Array.mapFilter<Types.ListingId, Types.Listing>(listingIds, func(id) {
          listings.get(id)
        })
      };
      case null { [] };
    }
  };
}
