# **Coding Standards**

## **Critical Fullstack Rules**

- **Type Sharing:** Always define types in packages/shared and import from there
- **Canister Calls:** Never make direct HTTP calls to canisters - use the ICP service layer
- **Environment Variables:** Access only through config objects, never process.env directly
- **Error Handling:** All canister calls must handle Result types properly
- **State Updates:** Never mutate state directly - use proper state management patterns
- **Principal Security:** Always validate caller principal in canister functions
- **Input Validation:** Validate all inputs in canisters before processing
- **Rate Limiting:** Implement rate limiting for all user-facing canister functions

## **Naming Conventions**

| Element | Frontend (Flutter) | Backend (Motoko) | Example |
|----------|-------------------|------------------|---------|
| Components | PascalCase | - | `UserProfile` |
| Files | snake_case | snake_case | `user_service.dart` |
| Functions | camelCase | camelCase | `getUserProfile` |
| Variables | camelCase | camelCase | `userName` |
| Constants | UPPER_SNAKE_CASE | UPPER_SNAKE_CASE | `MAX_LISTING_PRICE` |
| Canisters | snake_case | snake_case | `user_management` |
| Types | PascalCase | PascalCase | `UserProfile` |
