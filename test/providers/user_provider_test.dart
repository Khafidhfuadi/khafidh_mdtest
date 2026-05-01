// Test suite untuk UserProvider - memverifikasi filter & search logic
import 'package:flutter_test/flutter_test.dart';
import 'package:khafidh_mdtest/core/constants/enums.dart';
import 'package:khafidh_mdtest/data/models/user_model.dart';
import 'package:khafidh_mdtest/providers/user_provider.dart';

void main() {
  group('UserProvider - filteredUsers', () {
    late UserProvider provider;
    late List<UserModel> testUsers;

    setUp(() {
      provider = UserProvider();
      testUsers = [
        UserModel(
          uid: '1',
          name: 'Alice Verified',
          email: 'alice@example.com',
          isEmailVerified: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        UserModel(
          uid: '2',
          name: 'Bob Unverified',
          email: 'bob@example.com',
          isEmailVerified: false,
          createdAt: DateTime(2026, 1, 2),
        ),
        UserModel(
          uid: '3',
          name: 'Charlie Verified',
          email: 'charlie@example.com',
          isEmailVerified: true,
          createdAt: DateTime(2026, 1, 3),
        ),
        UserModel(
          uid: '4',
          name: 'Diana Unverified',
          email: 'diana@test.org',
          isEmailVerified: false,
          createdAt: DateTime(2026, 1, 4),
        ),
      ];
      provider.allUsersForTesting = testUsers;
    });

    // ---------------------------------------------------------------
    // Filter by status
    // ---------------------------------------------------------------
    group('filter by status', () {
      test('filter "verified" mengembalikan hanya user terverifikasi', () {
        // Act
        provider.setFilter(FilterStatus.verified);

        // Assert
        final result = provider.filteredUsers;
        expect(result.length, 2);
        expect(result.every((u) => u.isEmailVerified), isTrue);
        expect(result.map((u) => u.name), containsAll(['Alice Verified', 'Charlie Verified']));
      });

      test('filter "unverified" mengembalikan hanya user belum terverifikasi',
          () {
        // Act
        provider.setFilter(FilterStatus.unverified);

        // Assert
        final result = provider.filteredUsers;
        expect(result.length, 2);
        expect(result.every((u) => !u.isEmailVerified), isTrue);
        expect(result.map((u) => u.name), containsAll(['Bob Unverified', 'Diana Unverified']));
      });

      test('filter "all" mengembalikan semua user', () {
        // Act
        provider.setFilter(FilterStatus.all);

        // Assert
        expect(provider.filteredUsers.length, 4);
      });
    });

    // ---------------------------------------------------------------
    // Search
    // ---------------------------------------------------------------
    group('search', () {
      test('search by name mengembalikan user yang cocok', () {
        // Act
        provider.setSearchQuery('alice');

        // Assert
        final result = provider.filteredUsers;
        expect(result.length, 1);
        expect(result.first.name, 'Alice Verified');
      });

      test('search by email mengembalikan user yang cocok', () {
        // Act
        provider.setSearchQuery('test.org');

        // Assert
        final result = provider.filteredUsers;
        expect(result.length, 1);
        expect(result.first.email, 'diana@test.org');
      });

      test('search case-insensitive', () {
        // Act
        provider.setSearchQuery('BOB');

        // Assert
        final result = provider.filteredUsers;
        expect(result.length, 1);
        expect(result.first.name, 'Bob Unverified');
      });
    });

    // ---------------------------------------------------------------
    // Kombinasi filter + search
    // ---------------------------------------------------------------
    group('kombinasi filter + search', () {
      test('filter verified + search name mengembalikan hasil yang tepat', () {
        // Act
        provider.setFilter(FilterStatus.verified);
        provider.setSearchQuery('charlie');

        // Assert
        final result = provider.filteredUsers;
        expect(result.length, 1);
        expect(result.first.name, 'Charlie Verified');
        expect(result.first.isEmailVerified, isTrue);
      });

      test('filter unverified + search mengembalikan hasil kosong jika tidak cocok',
          () {
        // Act - cari Alice (verified) tapi filter hanya unverified
        provider.setFilter(FilterStatus.unverified);
        provider.setSearchQuery('alice');

        // Assert
        final result = provider.filteredUsers;
        expect(result, isEmpty);
      });

      test('filter unverified + search email mengembalikan hasil yang tepat',
          () {
        // Act
        provider.setFilter(FilterStatus.unverified);
        provider.setSearchQuery('bob@');

        // Assert
        final result = provider.filteredUsers;
        expect(result.length, 1);
        expect(result.first.name, 'Bob Unverified');
      });
    });
  });
}
