module {
  public type CryptoCurrency = Text; // "BTC", "ETH", "ICP", etc.
  public type FiatCurrency = Text; // "USD", "EUR", etc.
  
  public type PriceData = {
    symbol : CryptoCurrency;
    fiatCurrency : FiatCurrency;
    price : Nat64; // Price in cents (for USD) to avoid floating point
    marketCap : ?Nat64; // Optional market cap in cents
    volume24h : ?Nat64; // Optional 24h volume in cents
    change24h : ?Int; // Percentage change in basis points (10000 = 100%)
    lastUpdated : Nat64; // Unix timestamp in milliseconds
    source : Text; // Data source identifier
  };

  public type PriceFeed = {
    symbol : CryptoCurrency;
    feeds : [PriceData];
    aggregatedPrice : Nat64;
    confidence : Nat; // Confidence level 0-100
    lastAggregated : Nat64;
  };

  public type PriceSource = {
    #coinGecko;
    #coinMarketCap;
    #chainlink;
    #manual; // For admin updates
  };

  public type UpdatePriceRequest = {
    symbol : CryptoCurrency;
    fiatCurrency : FiatCurrency;
    price : Nat64;
    marketCap : ?Nat64;
    volume24h : ?Nat64;
    change24h : ?Int;
    source : PriceSource;
  };

  public type ConversionRequest = {
    fromSymbol : CryptoCurrency;
    toSymbol : CryptoCurrency;
    amount : Nat64;
  };

  public type ConversionResult = {
    fromSymbol : CryptoCurrency;
    toSymbol : CryptoCurrency;
    fromAmount : Nat64;
    toAmount : Nat64;
    rate : Nat64; // Exchange rate in basis points
    calculatedAt : Nat64;
  };

  public type GetPriceResult = { #ok : PriceFeed; #err : Text };
  public type UpdatePriceResult = { #ok : PriceFeed; #err : Text };
  public type ConvertResult = { #ok : ConversionResult; #err : Text };
  public type GetSupportedCurrenciesResult = { #ok : [CryptoCurrency]; #err : Text };
}
