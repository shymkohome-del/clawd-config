import 'package:crypto_market/features/auth/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Profile & Reputation Feature Tests', () {
    test('UserProfile should calculate trust level correctly', () {
      // Test novice level (< 50 reputation)
      final noviceProfile = UserProfile(
        id: 'user1',
        email: 'user1@test.com',
        username: 'novice_user',
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        reputation: 25,
      );
      expect(noviceProfile.trustLevel, TrustLevel.novice);

      // Test newcomer level (50-99 reputation)
      final newcomerProfile = UserProfile(
        id: 'user2',
        email: 'user2@test.com',
        username: 'newcomer_user',
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        reputation: 75,
      );
      expect(newcomerProfile.trustLevel, TrustLevel.newcomer);

      // Test established level (100-499 reputation)
      final establishedProfile = UserProfile(
        id: 'user3',
        email: 'user3@test.com',
        username: 'established_user',
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        reputation: 250,
      );
      expect(establishedProfile.trustLevel, TrustLevel.established);

      // Test trusted level (500-999 reputation)
      final trustedProfile = UserProfile(
        id: 'user4',
        email: 'user4@test.com',
        username: 'trusted_user',
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        reputation: 750,
      );
      expect(trustedProfile.trustLevel, TrustLevel.trusted);

      // Test expert level (1000+ reputation)
      final expertProfile = UserProfile(
        id: 'user5',
        email: 'user5@test.com',
        username: 'expert_user',
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        reputation: 1500,
      );
      expect(expertProfile.trustLevel, TrustLevel.expert);
    });

    test('UserProfile should provide correct display name', () {
      final profileWithUsername = UserProfile(
        id: 'user1',
        email: 'user1@test.com',
        username: 'test_username',
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        reputation: 100,
      );
      expect(profileWithUsername.displayName, 'test_username');

      final profileWithoutUsername = UserProfile(
        id: 'user2',
        email: 'user2@test.com',
        username: '',
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        reputation: 100,
      );
      expect(profileWithoutUsername.displayName, 'user2@test.com');
    });

    test('UserProfile should copy with updated fields', () {
      final originalProfile = UserProfile(
        id: 'user1',
        email: 'user1@test.com',
        username: 'original_username',
        authProvider: 'email',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        reputation: 100,
        profileImage: 'original_hash',
      );

      final updatedProfile = originalProfile.copyWith(
        username: 'updated_username',
        reputation: 200,
        profileImage: 'updated_hash',
      );

      expect(updatedProfile.username, 'updated_username');
      expect(updatedProfile.reputation, 200);
      expect(updatedProfile.profileImage, 'updated_hash');
      // Unchanged fields should remain the same
      expect(updatedProfile.id, originalProfile.id);
      expect(updatedProfile.email, originalProfile.email);
      expect(updatedProfile.authProvider, originalProfile.authProvider);
    });

    test('UserUpdate should track changes correctly', () {
      const noChanges = UserUpdate();
      expect(noChanges.hasChanges, isFalse);

      const usernameChange = UserUpdate(username: 'new_username');
      expect(usernameChange.hasChanges, isTrue);

      const imageChange = UserUpdate(profileImage: 'new_image_hash');
      expect(imageChange.hasChanges, isTrue);

      const bothChanges = UserUpdate(
        username: 'new_username',
        profileImage: 'new_image_hash',
      );
      expect(bothChanges.hasChanges, isTrue);
    });

    test('TrustLevel enum should have correct values', () {
      expect(TrustLevel.novice.minReputation, 0);
      expect(TrustLevel.novice.displayName, 'Novice');

      expect(TrustLevel.newcomer.minReputation, 50);
      expect(TrustLevel.newcomer.displayName, 'Newcomer');

      expect(TrustLevel.established.minReputation, 100);
      expect(TrustLevel.established.displayName, 'Established');

      expect(TrustLevel.trusted.minReputation, 500);
      expect(TrustLevel.trusted.displayName, 'Trusted');

      expect(TrustLevel.expert.minReputation, 1000);
      expect(TrustLevel.expert.displayName, 'Expert');
    });
  });
}
