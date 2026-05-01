// Test suite untuk AuthProvider - memverifikasi state management autentikasi
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:khafidh_mdtest/providers/auth_provider.dart';
import 'package:khafidh_mdtest/data/repositories/auth_repository.dart';
import 'package:khafidh_mdtest/data/repositories/user_repository.dart';

void main() {
  group('AuthProvider', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;
    late AuthProvider authProvider;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      fakeFirestore = FakeFirebaseFirestore();
      authProvider = AuthProvider(
        authRepository: AuthRepository(auth: mockAuth, googleSignIn: MockGoogleSignIn()),
        userRepository: UserRepository(firestore: fakeFirestore),
      );
    });

    // ---------------------------------------------------------------
    // Initial state
    // ---------------------------------------------------------------
    test('initial state: currentUser null, isLoading false, errorMessage null',
        () {
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, isNull);
      expect(authProvider.isLoggedIn, isFalse);
    });

    // ---------------------------------------------------------------
    // login
    // ---------------------------------------------------------------
    group('login', () {
      test('login sukses mengupdate currentUser melalui authStateChanges',
          () async {
        // Arrange
        final mockUser = MockUser(
          isAnonymous: false,
          uid: 'login-uid',
          email: 'user@example.com',
          displayName: 'Test User',
        );
        final signedOutAuth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: false,
        );
        final provider = AuthProvider(
          authRepository: AuthRepository(auth: signedOutAuth, googleSignIn: MockGoogleSignIn()),
          userRepository: UserRepository(firestore: fakeFirestore),
        );

        // Act
        final result = await provider.login('user@example.com', 'password123');

        // Assert
        expect(result, isTrue);
        expect(provider.errorMessage, isNull);
      });

      test('login gagal menyimpan error message', () async {
        // Arrange - configure mock to throw on signIn
        whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
            .on(mockAuth)
            .thenThrow(FirebaseAuthException(code: 'wrong-password'));

        // Act
        final result = await authProvider.login('user@example.com', 'wrong');

        // Assert
        expect(result, isFalse);
        expect(authProvider.errorMessage, isNotNull);
        expect(authProvider.errorMessage!.length, greaterThan(0));
      });
    });

    // ---------------------------------------------------------------
    // logout
    // ---------------------------------------------------------------
    group('logout', () {
      test('logout sukses mereset state', () async {
        // Arrange - login dulu
        final mockUser = MockUser(
          isAnonymous: false,
          uid: 'logout-uid',
          email: 'logout@example.com',
          displayName: 'Logout User',
        );
        final signedInAuth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: true,
        );
        final provider = AuthProvider(
          authRepository: AuthRepository(auth: signedInAuth, googleSignIn: MockGoogleSignIn()),
          userRepository: UserRepository(firestore: fakeFirestore),
        );

        // Act
        final result = await provider.logout();

        // Assert
        expect(result, isTrue);
        expect(provider.errorMessage, isNull);
      });
    });

    // ---------------------------------------------------------------
    // error message
    // ---------------------------------------------------------------
    group('error handling', () {
      test('error message tersimpan saat login gagal dan bisa di-clear', () async {
        // Arrange
        whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
            .on(mockAuth)
            .thenThrow(FirebaseAuthException(code: 'invalid-credential'));

        // Act
        await authProvider.login('bad@example.com', 'wrong');

        // Assert - error tersimpan
        expect(authProvider.errorMessage, isNotNull);

        // Act - clear error
        authProvider.clearError();

        // Assert - error sudah null
        expect(authProvider.errorMessage, isNull);
      });
    });

    // ---------------------------------------------------------------
    // isLoading
    // ---------------------------------------------------------------
    group('isLoading', () {
      test('isLoading berubah selama proses login', () async {
        // Arrange - track perubahan isLoading
        final loadingStates = <bool>[];
        authProvider.addListener(() {
          loadingStates.add(authProvider.isLoading);
        });

        // Act
        await authProvider.login('user@example.com', 'password123');

        // Assert - isLoading pernah true (saat loading) dan false (setelah selesai)
        expect(loadingStates, contains(true));
        expect(loadingStates.last, isFalse);
      });
    });
  });
}
