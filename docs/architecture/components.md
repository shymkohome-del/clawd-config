# **Components**

## **Marketplace Canister**

**Responsibility:** Core marketplace functionality including listing creation, management, and search

**Key Interfaces:**
- `createListing()` - Create new marketplace listing
- `getListing()` - Retrieve specific listing
- `getListings()` - Search and filter listings
- `updateListing()` - Update listing details
- `deleteListing()` - Remove listing

**Dependencies:** User Management Canister (for seller validation)

**Technology Stack:** Motoko smart contract on ICP

## **Atomic Swap Canister**

**Responsibility:** Handle trustless cryptocurrency escrow using HTLC (Hashed Timelock Contracts)

**Key Interfaces:**
- `initiateSwap()` - Create new atomic swap
- `completeSwap()` - Complete swap with secret
- `refundSwap()` - Refund after timeout
- `getSwap()` - Retrieve swap details
- `initiateDispute()` - Start dispute resolution

**Dependencies:** Marketplace Canister (listing validation), Price Oracle Canister (price validation)

**Technology Stack:** Motoko smart contract on ICP

## **User Management Canister**

**Responsibility:** User authentication, profile management, and reputation system

**Key Interfaces:**
- `authenticate()` - Traditional email/password authentication
- `register()` - User registration
- `loginWithOAuth()` - Social OAuth authentication
- `updateUserProfile()` - Profile updates
- `updateReputation()` - Reputation management

**Dependencies:** None (core service)

**Technology Stack:** Motoko smart contract on ICP

## **Price Oracle Canister**

**Responsibility:** Provide real-time cryptocurrency pricing data

**Key Interfaces:**
- `updatePrice()` - Update price from external sources
- `getPrice()` - Retrieve current price
- `getConversionAmount()` - Convert USD to crypto amount
- `getSupportedSymbols()` - Get supported cryptocurrencies

**Dependencies:** External price APIs (Chainlink, CoinGecko)

**Technology Stack:** Motoko smart contract on ICP

## **Messaging Canister**

**Responsibility:** Peer-to-peer communication between buyers and sellers

**Key Interfaces:**
- `sendMessage()` - Send message to another user
- `getMessages()` - Retrieve conversation history
- `markAsRead()` - Mark messages as read
- `deleteMessage()` - Remove messages

**Dependencies:** User Management Canister (user validation)

**Technology Stack:** Motoko smart contract on ICP
