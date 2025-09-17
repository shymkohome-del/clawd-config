import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:crypto_market/features/market/cubit/create_listing_cubit.dart';
import 'package:crypto_market/features/market/models/create_listing_request.dart';
import 'package:crypto_market/features/market/models/listing.dart';
import 'package:crypto_market/features/market/providers/market_service_provider.dart';

import 'create_listing_cubit_test.mocks.dart';

@GenerateMocks([MarketService])
void main() {
  group('CreateListingCubit', () {
    late MockMarketService mockMarketService;
    late CreateListingCubit cubit;

    setUp(() {
      mockMarketService = MockMarketService();
      cubit = CreateListingCubit(marketService: mockMarketService);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is CreateListingInitial', () {
      expect(cubit.state, isA<CreateListingInitial>());
    });

    group('createListing', () {
      final testRequest = CreateListingRequest(
        title: 'Test Item',
        description: 'Test description',
        priceUSD: 100,
        cryptoType: 'BTC',
        images: ['hash1', 'hash2'],
        category: 'Electronics',
        condition: ListingCondition.used,
        location: 'Test City',
        shippingOptions: ['Standard', 'Express'],
      );

      blocTest<CreateListingCubit, CreateListingState>(
        'emits [submitting, success] when createListing succeeds',
        build: () {
          when(
            mockMarketService.createListing(any),
<<<<<<< HEAD
          ).thenAnswer((_) async => {'id': 123});
=======
          ).thenAnswer((_) async => {'id': '123'});
>>>>>>> develop
          return cubit;
        },
        act: (cubit) => cubit.createListing(testRequest),
        expect: () => [
          isA<CreateListingSubmitting>(),
          isA<CreateListingSuccess>().having(
            (state) => state.listingId,
            'listingId',
<<<<<<< HEAD
            123,
=======
            '123',
>>>>>>> develop
          ),
        ],
        verify: (_) {
          verify(mockMarketService.createListing(testRequest)).called(1);
        },
      );

      blocTest<CreateListingCubit, CreateListingState>(
        'emits [submitting, failure] when createListing throws exception',
        build: () {
          when(
            mockMarketService.createListing(any),
          ).thenThrow(Exception('Network error'));
          return cubit;
        },
        act: (cubit) => cubit.createListing(testRequest),
        expect: () => [
          isA<CreateListingSubmitting>(),
          isA<CreateListingFailure>().having(
            (state) => state.error,
            'error',
            contains('Network error'),
          ),
        ],
      );

      blocTest<CreateListingCubit, CreateListingState>(
        'does not emit new states when already submitting',
        build: () {
<<<<<<< HEAD
          when(
            mockMarketService.createListing(any),
          ).thenAnswer((_) async => {'id': 123});
=======
          when(mockMarketService.createListing(any)).thenAnswer(
            (_) async => {
              'ok': {'id': '123'},
            },
          );
>>>>>>> develop
          return cubit;
        },
        seed: () => CreateListingState.submitting(),
        act: (cubit) => cubit.createListing(testRequest),
        expect: () => [],
        verify: (_) {
          verifyNever(mockMarketService.createListing(any));
        },
      );

      blocTest<CreateListingCubit, CreateListingState>(
        'handles missing id in response',
        build: () {
          when(
            mockMarketService.createListing(any),
          ).thenAnswer((_) async => {'success': true});
          return cubit;
        },
        act: (cubit) => cubit.createListing(testRequest),
        expect: () => [
          isA<CreateListingSubmitting>(),
          isA<CreateListingSuccess>().having(
            (state) => state.listingId,
            'listingId',
<<<<<<< HEAD
            0,
=======
            '',
>>>>>>> develop
          ),
        ],
      );
    });

    group('reset', () {
      blocTest<CreateListingCubit, CreateListingState>(
        'emits initial state when reset is called',
        build: () => cubit,
        seed: () => CreateListingState.failure('Some error'),
        act: (cubit) => cubit.reset(),
        expect: () => [isA<CreateListingInitial>()],
      );
    });
  });
}
