import Array "mo:base/Array";
import Char "mo:base/Char";
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
    if (Text.size(req.title) < 3 or Text.size(req.title) > 100) {
      return ?"title_invalid_length";
    };
    if (Text.size(req.description) < 10 or Text.size(req.description) > 1000) {
      return ?"description_invalid_length";
    };
    if (req.priceUSD == 0) {
      return ?"price_must_be_positive";
    };
    if (Text.size(req.category) == 0) {
      return ?"category_required";
    };
    if (Text.size(req.location) == 0) {
      return ?"location_required";
    };
    if (Array.size(req.shippingOptions) == 0) {
      return ?"shipping_options_required";
    };
    null
  };

  private func validateUpdateListing(req : Types.UpdateListingRequest) : ?Text {
    switch (req.title) {
      case (?title) {
        if (Text.size(title) < 3 or Text.size(title) > 100) {
          return ?"title_invalid_length";
        };
      };
      case null {};
    };

    switch (req.description) {
      case (?description) {
        if (Text.size(description) < 10 or Text.size(description) > 1000) {
          return ?"description_invalid_length";
        };
      };
      case null {};
    };

    switch (req.priceUSD) {
      case (?price) {
        if (price == 0) {
          return ?"price_must_be_positive";
        };
      };
      case null {};
    };

    switch (req.category) {
      case (?category) {
        if (Text.size(category) == 0) {
          return ?"category_required";
        };
      };
      case null {};
    };

    switch (req.location) {
      case (?location) {
        if (Text.size(location) == 0) {
          return ?"location_required";
        };
      };
      case null {};
    };

    switch (req.shippingOptions) {
      case (?options) {
        if (Array.size(options) == 0) {
          return ?"shipping_options_required";
        };
      };
      case null {};
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
      priceUSD = req.priceUSD;
      cryptoType = req.cryptoType;
      images = req.images;
      category = req.category;
      condition = req.condition;
      location = req.location;
      shippingOptions = req.shippingOptions;
      status = #active;
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

        switch (validateUpdateListing(req)) {
          case (?error) { return #err(error); };
          case null {};
        };

        let updated : Types.Listing = {
          id = existing.id;
          seller = existing.seller;
          title = Option.get(req.title, existing.title);
          description = Option.get(req.description, existing.description);
          priceUSD = Option.get(req.priceUSD, existing.priceUSD);
          cryptoType = Option.get(req.cryptoType, existing.cryptoType);
          images = Option.get(req.images, existing.images);
          category = Option.get(req.category, existing.category);
          condition = Option.get(req.condition, existing.condition);
          location = Option.get(req.location, existing.location);
          shippingOptions = Option.get(req.shippingOptions, existing.shippingOptions);
          status = Option.get(req.status, existing.status);
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

  private func toLower(text : Text) : Text {
    Text.map(text, func(c : Char) : Char {
      Char.toLower(c)
    })
  };

  public query func getListings(filters : Types.SearchFilters, offset : Nat, limit : Nat) : async Types.SearchListingsResult {
    let maxLimit = 50;
    let actualLimit = if (limit > maxLimit) maxLimit else limit;

    let allListings = Iter.toArray(listings.vals());
    let filtered = Array.filter<Types.Listing>(allListings, func(listing) {
      if (listing.status != #active) return false;

      switch (filters.query) {
        case (?q) {
          let queryLower = toLower(q);
          let titleLower = toLower(listing.title);
          let descriptionLower = toLower(listing.description);
          let locationLower = toLower(listing.location);

          if (
            not Text.contains(titleLower, #text(queryLower)) and
            not Text.contains(descriptionLower, #text(queryLower)) and
            not Text.contains(locationLower, #text(queryLower))
          ) {
            return false;
          };
        };
        case null {};
      };

      switch (filters.category) {
        case (?category) { if (listing.category != category) return false; };
        case null {};
      };

      switch (filters.location) {
        case (?location) {
          let locationLower = toLower(location);
          if (not Text.contains(toLower(listing.location), #text(locationLower))) return false;
        };
        case null {};
      };

      switch (filters.condition) {
        case (?condition) { if (listing.condition != condition) return false; };
        case null {};
      };

      switch (filters.minPrice) {
        case (?min) { if (listing.priceUSD < min) return false; };
        case null {};
      };

      switch (filters.maxPrice) {
        case (?max) { if (listing.priceUSD > max) return false; };
        case null {};
      };

      true
    });

    let totalCount = Array.size(filtered);
    let hasMore = offset + actualLimit < totalCount;

    let startIndex = offset;
    let endIndex = Nat.min(startIndex + actualLimit, totalCount);
    let paginatedListings = if (startIndex >= totalCount) {
      []
    } else {
      Array.subArray<Types.Listing>(filtered, startIndex, endIndex - startIndex)
    };

    #ok({
      listings = paginatedListings;
      totalCount = totalCount;
      hasMore = hasMore;
    })
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
