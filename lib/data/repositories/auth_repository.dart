// AuthRepository - abstraksi semua operasi Firebase Authentication
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khafidh_mdtest/core/utils/error_handler.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    } catch (e) {
      throw Exception(ErrorHandler.getGeneralErrorMessage(e));
    }
  }

  Future<UserCredential> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    } catch (e) {
      throw Exception(ErrorHandler.getGeneralErrorMessage(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    } catch (e) {
      throw Exception(ErrorHandler.getGeneralErrorMessage(e));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    } catch (e) {
      throw Exception(ErrorHandler.getGeneralErrorMessage(e));
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Tidak ada user yang sedang login.');
      }
      if (user.emailVerified) {
        throw Exception('Email sudah terverifikasi.');
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception(ErrorHandler.getGeneralErrorMessage(e));
    }
  }

  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Tidak ada user yang sedang login.');
      }
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception(ErrorHandler.getGeneralErrorMessage(e));
    }
  }
}
