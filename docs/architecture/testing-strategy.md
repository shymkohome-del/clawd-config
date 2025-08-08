# **Testing Strategy**

## **Testing Pyramid**

```
                  E2E Tests
                 /        \
            Integration Tests
               /            \
      Frontend Unit     Canister Unit
```

## **Test Organization**

**Frontend Tests:**
```
apps/mobile/test/
├── unit/                     # Unit tests
│   ├── models/
│   ├── services/
│   └── widgets/
├── integration/              # Integration tests
│   ├── screens/
│   └── flows/
└── e2e/                      # End-to-end tests
    ├── authentication/
    ├── marketplace/
    └── trading/
```

**Canister Tests:**
```
canisters/marketplace/test/
├── unit/                     # Unit tests
│   ├── listing_tests.mo
│   ├── user_tests.mo
│   └── search_tests.mo
├── integration/              # Integration tests
│   ├── auth_tests.mo
│   └── marketplace_tests.mo
└── e2e/                      # End-to-end tests
    ├── full_flow_tests.mo
    └── performance_tests.mo
```

## **Test Examples**

**Frontend Component Test:**
```dart
void main() {
  testWidgets('ListingCard displays listing information', (WidgetTester tester) async {
    // Arrange
    final listing = Listing(
      id: 1,
      title: 'Test Listing',
      priceUSD: BigInt.from(100),
      // ... other fields
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: ListingCard(listing: listing),
      ),
    );
    
    // Act
    await tester.pumpAndSettle();
    
    // Assert
    expect(find.text('Test Listing'), findsOneWidget);
    expect(find.text('\$100'), findsOneWidget);
  });
}
```

**Canister Unit Test:**
```motoko
import List "mo:base/List";
import Result "mo:base/Result";
import Time "mo:base/Time";

actor {
  // Test function
  public func testCreateListing() : async Bool {
    let testUser = Principal.fromText("2vxsx-fae");
    
    let result = await createListing(
      "Test Listing",
      "Test Description",
      1000000, // $10 in cents
      "BTC",
      ["QmTest"],
      "electronics",
      #new,
      "US",
      ["standard"]
    );
    
    switch (result) {
      case (#ok(id)) { return true; };
      case (#err(_)) { return false; };
    };
  };
}
```

**E2E Test:**
```dart
void main() {
  testWidgets('Complete marketplace flow', (WidgetTester tester) async {
    // Setup
    await tester.pumpWidget(MyApp());
    
    // Login
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();
    
    // Navigate to marketplace
    await tester.tap(find.byKey(Key('marketplace_tab')));
    await tester.pumpAndSettle();
    
    // Create listing
    await tester.tap(find.byKey(Key('create_listing_button')));
    await tester.pumpAndSettle();
    
    // Fill form and submit
    await tester.enterText(find.byKey(Key('title_field')), 'Test Item');
    await tester.enterText(find.byKey(Key('price_field')), '100');
    await tester.tap(find.byKey(Key('submit_button')));
    await tester.pumpAndSettle();
    
    // Verify listing was created
    expect(find.text('Test Item'), findsOneWidget);
  });
}
```
