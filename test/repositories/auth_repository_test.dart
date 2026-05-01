// Test suite untuk AuthRepository - memverifikasi semua operasi autentikasi
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:khafidh_mdtest/data/repositories/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    // ---------------------------------------------------------------
    // signIn
    // ---------------------------------------------------------------
    group('signIn', () {
      test('login sukses mengembalikan UserCredential', () async {
        // Arrange
        final mockUser = MockUser(
          isAnonymous: false,
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
        );
        final mockAuth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: false,
        );
        final repo = AuthRepository(auth: mockAuth);

        // Act
        final result = await repo.signIn('test@example.com', 'password123');

        // Assert
        expect(result, isA<UserCredential>());
        expect(result.user, isNotNull);
        expect(result.user!.email, 'test@example.com');
        expect(mockAuth.currentUser, isNotNull);
      });

      test('login gagal dengan wrong-password melempar exception', () async {
        // Arrange
        final mockAuth = MockFirebaseAuth();
        whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
            .on(mockAuth)
            .thenThrow(FirebaseAuthException(code: 'wrong-password'));
        final repo = AuthRepository(auth: mockAuth);

        // Act & Assert
        expect(
          () => repo.signIn('test@example.com', 'wrong'),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ---------------------------------------------------------------
    // signUp
    // ---------------------------------------------------------------
    group('signUp', () {
      test('register sukses mengembalikan UserCredential', () async {
        // Arrange
        final mockAuth = MockFirebaseAuth(signedIn: false);
        final repo = AuthRepository(auth: mockAuth);

        // Act
        final result = await repo.signUp(
          'new@example.com',
          'password123',
          'New User',
        );

        // Assert
        expect(result, isA<UserCredential>());
        expect(result.user, isNotNull);
        expect(result.user!.email, 'new@example.com');
      });

      test('register email duplikat melempar exception', () async {
        // Arrange
        final mockAuth = MockFirebaseAuth();
        whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
            .on(mockAuth)
            .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
        final repo = AuthRepository(auth: mockAuth);

        // Act & Assert
        expect(
          () => repo.signUp('existing@example.com', 'password123', 'User'),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ---------------------------------------------------------------
    // sendPasswordReset
    // ---------------------------------------------------------------
    group('sendPasswordReset', () {
      test('mengirim email reset password tanpa error', () async {
        // Arrange
        final mockAuth = MockFirebaseAuth();
        final repo = AuthRepository(auth: mockAuth);

        // Act & Assert - tidak melempar exception
        await expectLater(
          repo.sendPasswordReset('test@example.com'),
          completes,
        );
      });
    });

    // ---------------------------------------------------------------
    // sendEmailVerification
    // ---------------------------------------------------------------
    group('sendEmailVerification', () {
      test('mengirim email verifikasi untuk user yang belum terverifikasi',
          () async {
        // Arrange
        final mockUser = MockUser(
          isAnonymous: false,
          uid: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: false,
        );
        final mockAuth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: true,
        );
        final repo = AuthRepository(auth: mockAuth);

        // Act & Assert - tidak melempar exception
        await expectLater(
          repo.sendEmailVerification(),
          completes,
        );
      });

      test('melempar exception jika tidak ada user yang login', () async {
        // Arrange
        final mockAuth = MockFirebaseAuth(signedIn: false);
        final repo = AuthRepository(auth: mockAuth);

        // Act & Assert
        expect(
          () => repo.sendEmailVerification(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Tidak ada user yang sedang login'),
            ),
          ),
        );
      });
    });
  });
}
