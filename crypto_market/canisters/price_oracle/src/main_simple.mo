import Text "mo:base/Text";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";

persistent actor PriceOracle {
    type PriceResult = Result.Result<Float, Text>;
    
    private transient var prices = HashMap.HashMap<Text, Float>(16, Text.equal, Text.hash);
    
    public query func healthCheck(): async Bool {
        true
    };
    
    public query func getPrice(symbol: Text): async PriceResult {
        switch (prices.get(symbol)) {
            case (?price) { #ok(price) };
            case null { #err("Price not found for " # symbol) };
        }
    };
    
    public func updatePrice(symbol: Text, price: Float): async Result.Result<(), Text> {
        prices.put(symbol, price);
        #ok()
    };
}
