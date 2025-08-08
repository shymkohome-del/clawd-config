# **External APIs**

## **Chainlink Price Feeds API**

**Purpose:** Real-time cryptocurrency price data

**Documentation:** https://docs.chain.link/data-feeds/price-feeds/addresses

**Base URL(s):** https://feeds.chain.link/

**Authentication:** API key

**Rate Limits:** 100 requests per minute

**Key Endpoints Used:**
- `GET /price/{crypto_symbol}` - Current price data
- `GET /prices/{crypto_symbols}` - Batch price data

**Integration Notes:** ICP canisters will call this via HTTPS outcalls to update price oracle canister

## **CoinGecko API**

**Purpose:** Alternative cryptocurrency price data source

**Documentation:** https://www.coingecko.com/api/documentations/v3

**Base URL(s):** https://api.coingecko.com/api/v3

**Authentication:** Free tier (demo key)

**Rate Limits:** 10-50 requests per minute (free tier)

**Key Endpoints Used:**
- `GET /simple/price` - Simple price endpoint
- `GET /coins/markets` - Market data

**Integration Notes:** Secondary price source for redundancy

## **KYC Provider APIs**

**Purpose:** Identity verification services

**Documentation:** Provider-specific

**Base URL(s):** Provider-specific

**Authentication:** API keys and OAuth

**Rate Limits:** Provider-specific

**Key Endpoints Used:**
- `POST /verify` - Submit KYC verification
- `GET /status/{user_id}` - Check verification status

**Integration Notes:** Multiple providers for redundancy and geographic coverage

## **IPFS API**

**Purpose:** Decentralized file storage for images and documents

**Documentation:** https://docs.ipfs.io/reference/http/api/

**Base URL(s):** User's IPFS node or public gateway

**Authentication:** None (public IPFS)

**Rate Limits:** None (self-hosted) or provider limits

**Key Endpoints Used:**
- `POST /api/v0/add` - Upload file to IPFS
- `GET /api/v0/cat/{hash}` - Retrieve file from IPFS

**Integration Notes:** Used for storing large images and documents, with hashes stored on-chain
