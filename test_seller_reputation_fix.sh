#!/bin/bash

# Test script to demonstrate the seller reputation fix
echo "=== Testing Seller Reputation Fix ==="
echo ""

# Change to the correct directory
cd crypto_market

echo "1. Running listing detail cubit tests..."
flutter test test/features/market/cubit/listing_detail_cubit_test.dart --no-pub
if [ $? -eq 0 ]; then
    echo "✅ Cubit tests passed"
else
    echo "❌ Cubit tests failed"
    exit 1
fi
echo ""

echo "2. Checking compilation of modified files..."
flutter analyze --no-fatal-infos lib/features/market/cubit/listing_detail_cubit.dart
if [ $? -eq 0 ]; then
    echo "✅ Cubit compiles correctly"
else
    echo "❌ Cubit compilation failed"
    exit 1
fi

flutter analyze --no-fatal-infos lib/features/market/screens/listing_detail_screen.dart
if [ $? -eq 0 ]; then
    echo "✅ Screen compiles correctly"
else
    echo "❌ Screen compilation failed"
    exit 1
fi

flutter analyze --no-fatal-infos lib/core/routing/app_router.dart
if [ $? -eq 0 ]; then
    echo "✅ Router compiles correctly"
else
    echo "❌ Router compilation failed"
    exit 1
fi
echo ""

echo "3. Summary of changes made:"
echo ""
echo "📁 Modified files:"
echo "   - lib/features/market/cubit/listing_detail_cubit.dart"
echo "   - lib/features/market/cubit/listing_detail_state.dart"
echo "   - lib/features/market/screens/listing_detail_screen.dart"
echo "   - lib/core/routing/app_router.dart"
echo "   - test/features/market/cubit/listing_detail_cubit_test.dart"
echo ""

echo "🔧 Key changes:"
echo "   - Added UserService dependency to ListingDetailCubit"
echo "   - Modified cubit to fetch real user profile data using getUserProfile API"
echo "   - Added sellerProfile field to ListingDetailState"
echo "   - Updated UI to use real reputation data from user profile"
echo "   - Enhanced error handling for failed user profile fetches"
echo "   - Updated tests to cover new functionality"
echo ""

echo "🎯 Implementation details:"
echo "   - Fetches seller profile after loading listing details"
echo "   - Uses UserProfile.reputation field instead of mock data"
echo "   - Displays reputation level (Novice, Newcomer, Established, Trusted, Expert)"
echo "   - Shows username instead of raw principal when available"
echo "   - Handles cases where user profile fails to load gracefully"
echo ""

echo "✅ All tests passed! The seller reputation now uses real API data."
echo ""
echo "📋 Test Coverage:"
echo "   - Initial state with sellerProfile field"
echo "   - Success state with both listing and user profile"
echo "   - Error handling for failed user profile fetches"
echo "   - Loading state management"
echo "   - Reset functionality"
echo ""