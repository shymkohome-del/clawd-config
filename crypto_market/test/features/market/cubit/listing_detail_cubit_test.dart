import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_market/core/blockchain/errors.dart';
import 'package:crypto_market/features/auth/models/user_profile.dart';
import 'package:crypto_market/features/auth/providers/user_service_provider.dart';
import 'package:crypto_market/features/market/cubit/listing_detail_cubit.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMarketService extends Mock implements MarketService {}

class MockUserService extends Mock implements UserService {}

void main() {
  late MockMarketService marketService;
  late MockUserService userService;
  late ListingDetailCubit cubit;

  setUp(() {
    marketService = MockMarketService();
    userService = MockUserService();
    cubit = ListingDetailCubit(
      marketService: marketService,
      userService: userService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ListingDetailCubit', () {
    const testListingId = 'test-listing-id';
    final testListing = Listing(
      id: 'test-listing-id',
      seller: 'test-seller',
      title: 'Test Item',
      description: 'This is a test item description',
      priceUSD: 100,
      cryptoType: 'BTC',
      images: ['https://example.com/image.jpg'],
      category: 'Electronics',
      condition: ListingCondition.newCondition,
      location: 'New York, NY',
      shippingOptions: ['Standard'],
      status: ListingStatus.active,
      createdAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
      updatedAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
    );

    final testUserProfile = UserProfile(
      id: 'test-seller',
      email: 'test@example.com',
      username: 'testuser',
      authProvider: 'email',
      createdAtMillis: DateTime(2024, 1, 1).millisecondsSinceEpoch,
      reputation: 500,
      kycVerified: true,
    );

    test('initial state is correct', () {
      expect(cubit.state.status, ListingDetailStatus.initial);
      expect(cubit.state.listing, isNull);
      expect(cubit.state.sellerProfile, isNull);
      expect(cubit.state.errorMessage, isNull);
    });

    blocTest<ListingDetailCubit, ListingDetailState>(
      'emits loading and success states when listing is loaded successfully',
      build: () {
        when(
          () => marketService.getListingById(testListingId),
        ).thenAnswer((_) async => testListing);
        when(
          () => userService.getUserProfile(testListing.seller),
        ).thenAnswer((_) async => Result.ok(testUserProfile));
        return cubit;
      },
      act: (cubit) => cubit.loadListing(testListingId),
      expect: () => [
        const ListingDetailState(status: ListingDetailStatus.loading),
        ListingDetailState(
          status: ListingDetailStatus.success,
          listing: testListing,
          sellerProfile: testUserProfile,
        ),
      ],
      verify: (_) {
        verify(() => marketService.getListingById(testListingId)).called(1);
        verify(() => userService.getUserProfile(testListing.seller)).called(1);
      },
    );

    blocTest<ListingDetailCubit, ListingDetailState>(
      'emits loading and failure states when listing is not found',
      build: () {
        when(
          () => marketService.getListingById(testListingId),
        ).thenAnswer((_) async => null);
        return cubit;
      },
      act: (cubit) => cubit.loadListing(testListingId),
      expect: () => [
        const ListingDetailState(status: ListingDetailStatus.loading),
        const ListingDetailState(
          status: ListingDetailStatus.failure,
          errorMessage: 'Listing not found',
        ),
      ],
      verify: (_) {
        verify(() => marketService.getListingById(testListingId)).called(1);
        verifyNever(() => userService.getUserProfile(any()));
      },
    );

    blocTest<ListingDetailCubit, ListingDetailState>(
      'emits loading and failure states when service throws exception',
      build: () {
        when(
          () => marketService.getListingById(testListingId),
        ).thenThrow(Exception('Network error'));
        return cubit;
      },
      act: (cubit) => cubit.loadListing(testListingId),
      expect: () => [
        const ListingDetailState(status: ListingDetailStatus.loading),
        const ListingDetailState(
          status: ListingDetailStatus.failure,
          errorMessage: 'Exception: Network error',
        ),
      ],
      verify: (_) {
        verify(() => marketService.getListingById(testListingId)).called(1);
        verifyNever(() => userService.getUserProfile(any()));
      },
    );

    blocTest<ListingDetailCubit, ListingDetailState>(
      'does not call service if already loading',
      build: () {
        when(
          () => marketService.getListingById(testListingId),
        ).thenAnswer((_) async => testListing);
        return cubit;
      },
      seed: () => const ListingDetailState(status: ListingDetailStatus.loading),
      act: (cubit) => cubit.loadListing(testListingId),
      expect: () => <ListingDetailState>[],
      verify: (_) {
        verifyNever(() => marketService.getListingById(testListingId));
        verifyNever(() => userService.getUserProfile(any()));
      },
    );

    blocTest<ListingDetailCubit, ListingDetailState>(
      'resets to initial state when reset is called',
      build: () {
        when(
          () => marketService.getListingById(testListingId),
        ).thenAnswer((_) async => testListing);
        when(
          () => userService.getUserProfile(testListing.seller),
        ).thenAnswer((_) async => Result.ok(testUserProfile));
        return cubit;
      },
      act: (cubit) async {
        await cubit.loadListing(testListingId);
        cubit.reset();
      },
      expect: () => [
        const ListingDetailState(status: ListingDetailStatus.loading),
        ListingDetailState(
          status: ListingDetailStatus.success,
          listing: testListing,
          sellerProfile: testUserProfile,
        ),
        const ListingDetailState(),
      ],
    );

    blocTest<ListingDetailCubit, ListingDetailState>(
      'emits success state with listing but no seller profile when user profile fails to load',
      build: () {
        when(
          () => marketService.getListingById(testListingId),
        ).thenAnswer((_) async => testListing);
        when(
          () => userService.getUserProfile(testListing.seller),
        ).thenAnswer((_) async => Result.err(AuthError.network));
        return cubit;
      },
      act: (cubit) => cubit.loadListing(testListingId),
      expect: () => [
        const ListingDetailState(status: ListingDetailStatus.loading),
        ListingDetailState(
          status: ListingDetailStatus.success,
          listing: testListing,
          sellerProfile: null,
        ),
      ],
      verify: (_) {
        verify(() => marketService.getListingById(testListingId)).called(1);
        verify(() => userService.getUserProfile(testListing.seller)).called(1);
      },
    );
  });
}
