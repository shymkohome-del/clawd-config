import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Types "./types";

actor PriceOracleCanister {
  
  stable var priceFeedsEntries : [(Types.CryptoCurrency, Types.PriceFeed)] = [];
  stable var authorizedPriceUpdaters : [Principal] = [];
  
  let priceFeeds = HashMap.HashMap<Types.CryptoCurrency, Types.PriceFeed>(16, Text.equal, Text.hash);
  var priceUpdaters : [Principal] = [];

  // Admin principal for managing price updaters (set during deployment)
  private stable var admin : ?Principal = null;

  system func preupgrade() {
    priceFeedsEntries := Iter.toArray(priceFeeds.entries());
    authorizedPriceUpdaters := priceUpdaters;
  };

  system func postupgrade() {
    priceFeeds.clear();
    for ((symbol, feed) in priceFeedsEntries.vals()) { priceFeeds.put(symbol, feed); };
    priceUpdaters := authorizedPriceUpdaters;
    priceFeedsEntries := [];
  };

  private func nowMillis() : Nat64 {
    let nanos = Time.now();
    Nat64.fromNat(Nat.div(nanos, 1_000_000));
  };

  private func isAdmin(caller : Principal) : Bool {
    switch (admin) {
      case (?adminPrincipal) { adminPrincipal == caller };
      case null { true }; // First caller becomes admin
    }
  };

  private func isAuthorizedUpdater(caller : Principal) : Bool {
    isAdmin(caller) or Array.find<Principal>(priceUpdaters, func(p) { p == caller }) != null
  };

  private func setAdminIfFirst(caller : Principal) {
    switch (admin) {
      case null { admin := ?caller };
      case _ {};
    }
  };

  private func aggregatePrices(feeds : [Types.PriceData]) : (Nat64, Nat) {
    if (Array.size(feeds) == 0) return (0, 0);
    
    // Simple average with recency weighting
    let now = nowMillis();
    var totalWeight : Nat64 = 0;
    var weightedSum : Nat64 = 0;
    
    for (feed in feeds.vals()) {
      // Weight based on recency (newer data gets higher weight)
      let age = if (now > feed.lastUpdated) now - feed.lastUpdated else 0;
      let maxAge : Nat64 = 3600000; // 1 hour in milliseconds
      let weight = if (age >= maxAge) 1 else maxAge - age;
      
      weightedSum += feed.price * weight;
      totalWeight += weight;
    };
    
    let aggregatedPrice = if (totalWeight > 0) weightedSum / totalWeight else 0;
    let confidence = Nat.min(Array.size(feeds) * 25, 100); // Max 100% confidence with 4+ sources
    
    (aggregatedPrice, confidence)
  };

  public shared ({ caller }) func updatePrice(req : Types.UpdatePriceRequest) : async Types.UpdatePriceResult {
    setAdminIfFirst(caller);
    
    if (not isAuthorizedUpdater(caller)) {
      return #err("unauthorized");
    };

    if (req.price == 0) {
      return #err("price_must_be_positive");
    };

    let sourceText = switch (req.source) {
      case (#coinGecko) "coingecko";
      case (#coinMarketCap) "coinmarketcap";
      case (#chainlink) "chainlink";
      case (#manual) "manual";
    };

    let newPriceData : Types.PriceData = {
      symbol = req.symbol;
      fiatCurrency = req.fiatCurrency;
      price = req.price;
      marketCap = req.marketCap;
      volume24h = req.volume24h;
      change24h = req.change24h;
      lastUpdated = nowMillis();
      source = sourceText;
    };

    let updatedFeed = switch (priceFeeds.get(req.symbol)) {
      case (?existing) {
        // Update existing feed by replacing data from the same source or adding new source
        let updatedFeeds = Array.map<Types.PriceData, Types.PriceData>(existing.feeds, func(feed) {
          if (feed.source == sourceText) newPriceData else feed
        });
        
        // If no existing feed from this source, add it
        let finalFeeds = if (Array.find<Types.PriceData>(updatedFeeds, func(feed) { feed.source == sourceText }) == null) {
          Array.append(updatedFeeds, [newPriceData])
        } else {
          updatedFeeds
        };
        
        let (aggregatedPrice, confidence) = aggregatePrices(finalFeeds);
        
        {
          symbol = existing.symbol;
          feeds = finalFeeds;
          aggregatedPrice = aggregatedPrice;
          confidence = confidence;
          lastAggregated = nowMillis();
        }
      };
      case null {
        // Create new price feed
        let (aggregatedPrice, confidence) = aggregatePrices([newPriceData]);
        {
          symbol = req.symbol;
          feeds = [newPriceData];
          aggregatedPrice = aggregatedPrice;
          confidence = confidence;
          lastAggregated = nowMillis();
        }
      };
    };

    priceFeeds.put(req.symbol, updatedFeed);
    #ok(updatedFeed)
  };

  public query func getPrice(symbol : Types.CryptoCurrency) : async Types.GetPriceResult {
    switch (priceFeeds.get(symbol)) {
      case (?feed) { #ok(feed) };
      case null { #err("price_not_found") };
    }
  };

  public query func getPriceInFiat(symbol : Types.CryptoCurrency, fiatCurrency : Types.FiatCurrency) : async Types.GetPriceResult {
    switch (priceFeeds.get(symbol)) {
      case (?feed) {
        // Find price data for the requested fiat currency
        switch (Array.find<Types.PriceData>(feed.feeds, func(data) { data.fiatCurrency == fiatCurrency })) {
          case (?priceData) { #ok(feed) };
          case null { #err("fiat_currency_not_supported") };
        }
      };
      case null { #err("price_not_found") };
    }
  };

  public query func convertCurrency(req : Types.ConversionRequest) : async Types.ConvertResult {
    // Get prices for both symbols
    let fromPriceFeed = priceFeeds.get(req.fromSymbol);
    let toPriceFeed = priceFeeds.get(req.toSymbol);
    
    switch (fromPriceFeed, toPriceFeed) {
      case (?from, ?to) {
        if (from.aggregatedPrice == 0 or to.aggregatedPrice == 0) {
          return #err("invalid_price_data");
        };
        
        // Calculate conversion: (amount * fromPrice) / toPrice
        let fromValueInFiat = req.amount * from.aggregatedPrice;
        let toAmount = fromValueInFiat / to.aggregatedPrice;
        let rate = (from.aggregatedPrice * 10000) / to.aggregatedPrice; // Rate in basis points
        
        let result : Types.ConversionResult = {
          fromSymbol = req.fromSymbol;
          toSymbol = req.toSymbol;
          fromAmount = req.amount;
          toAmount = toAmount;
          rate = rate;
          calculatedAt = nowMillis();
        };
        
        #ok(result)
      };
      case (null, _) { #err("from_currency_not_found") };
      case (_, null) { #err("to_currency_not_found") };
    }
  };

  public query func getSupportedCurrencies() : async Types.GetSupportedCurrenciesResult {
    let symbols = Iter.toArray(priceFeeds.keys());
    #ok(symbols)
  };

  public query func getAllPrices() : async [(Types.CryptoCurrency, Types.PriceFeed)] {
    Iter.toArray(priceFeeds.entries())
  };

  // Admin functions
  public shared ({ caller }) func addPriceUpdater(updater : Principal) : async Bool {
    setAdminIfFirst(caller);
    
    if (not isAdmin(caller)) {
      return false;
    };
    
    if (Array.find<Principal>(priceUpdaters, func(p) { p == updater }) == null) {
      priceUpdaters := Array.append(priceUpdaters, [updater]);
    };
    true
  };

  public shared ({ caller }) func removePriceUpdater(updater : Principal) : async Bool {
    setAdminIfFirst(caller);
    
    if (not isAdmin(caller)) {
      return false;
    };
    
    priceUpdaters := Array.filter<Principal>(priceUpdaters, func(p) { p != updater });
    true
  };

  public query ({ caller }) func getPriceUpdaters() : async [Principal] {
    if (isAdmin(caller)) {
      priceUpdaters
    } else {
      []
    }
  };

  // Initialize with some common cryptocurrencies and mock prices
  public shared ({ caller }) func initializeWithMockPrices() : async Bool {
    setAdminIfFirst(caller);
    
    if (not isAdmin(caller)) {
      return false;
    };

    let mockPrices = [
      ("BTC", 4300000), // $43,000.00
      ("ETH", 255000),  // $2,550.00
      ("ICP", 1200),    // $12.00
    ];

    for ((symbol, priceInCents) in mockPrices.vals()) {
      let mockPriceData : Types.PriceData = {
        symbol = symbol;
        fiatCurrency = "USD";
        price = Nat64.fromNat(priceInCents);
        marketCap = null;
        volume24h = null;
        change24h = null;
        lastUpdated = nowMillis();
        source = "manual";
      };

      let feed : Types.PriceFeed = {
        symbol = symbol;
        feeds = [mockPriceData];
        aggregatedPrice = Nat64.fromNat(priceInCents);
        confidence = 75;
        lastAggregated = nowMillis();
      };

      priceFeeds.put(symbol, feed);
    };

    true
  };
}
