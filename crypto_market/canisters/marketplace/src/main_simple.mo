import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Int "mo:base/Int";

persistent actor Marketplace {
    type Listing = {
        id: Text;
        title: Text;
        description: Text;
        price: Nat;
        seller: Principal;
        createdAt: Int;
    };

    type ListingResult = Result.Result<Listing, Text>;
    
    private transient var listings: [Listing] = [];
    
    public shared({caller}) func createListing(title: Text, description: Text, price: Nat): async ListingResult {
        let listing: Listing = {
            id = "listing_" # Nat.toText(Int.abs(Time.now()));
            title = title;
            description = description;
            price = price;
            seller = caller;
            createdAt = Time.now();
        };
        #ok(listing)
    };
    
    public query func getListings(): async [Listing] {
        listings
    };
    
    public query func healthCheck(): async Bool {
        true
    };
}
