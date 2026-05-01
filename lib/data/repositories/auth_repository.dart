// AuthRepository - abstraksi semua operasi Firebase Authentication
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:khafidh_mdtest/core/utils/error_handler.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

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

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In dibatalkan oleh pengguna.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(ErrorHandler.getAuthErrorMessage(e));
    } on PlatformException catch (e) {
      // PlatformException terjadi jika ada masalah dari sisi platform native (Android/iOS)
      if (e.code == 'sign_in_canceled') {
        throw Exception('Login Google dibatalkan.');
      } else if (e.code == 'network_error') {
        throw Exception('Gagal masuk. Periksa koneksi internet Anda.');
      }
      throw Exception('Google Sign-In Error: ${e.code} - ${e.message}');
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
      // Google Sign-In signout tidak boleh menghalangi Firebase signout.
      // Jika user login via email (bukan Google), signOut Google bisa gagal
      // dan itu bukan masalah.
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // Abaikan error Google Sign-Out
      }
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
