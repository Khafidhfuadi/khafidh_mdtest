// AuthProvider - mengelola state autentikasi user di seluruh aplikasi
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khafidh_mdtest/data/models/user_model.dart';
import 'package:khafidh_mdtest/data/repositories/auth_repository.dart';
import 'package:khafidh_mdtest/data/repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthProvider({AuthRepository? authRepository, UserRepository? userRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        _userRepository = userRepository ?? UserRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;

  // Listener perubahan status verifikasi email secara realtime
  Timer? _verificationTimer;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Inisialisasi listener untuk perubahan state autentikasi Firebase.
  void initialize() {
    _authSubscription?.cancel();
    _authSubscription =
        _authRepository.authStateChanges.listen(_onAuthStateChanged);
  }

  /// Callback internal saat state autentikasi berubah.
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      _currentUser = UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        isEmailVerified: firebaseUser.emailVerified,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      );

      if (!firebaseUser.emailVerified) {
        startVerificationPolling();
      } else {
        stopVerificationPolling();
      }
    } else {
      _currentUser = null;
      stopVerificationPolling();
    }
    notifyListeners();
  }

  /// Mulai polling status verifikasi email setiap 5 detik.
  /// Otomatis berhenti ketika email sudah terverifikasi.
  void startVerificationPolling() {
    stopVerificationPolling();
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkVerificationStatus(),
    );
  }

  /// Hentikan polling status verifikasi email.
  void stopVerificationPolling() {
    _verificationTimer?.cancel();
    _verificationTimer = null;
  }

  /// Cek status verifikasi email dari Firebase.
  /// Jika status berubah menjadi verified: cancel timer, update state, sync Firestore.
  Future<void> _checkVerificationStatus() async {
    try {
      await _authRepository.reloadUser();
      final firebaseUser = _authRepository.currentUser;

      if (firebaseUser != null && firebaseUser.emailVerified) {
        stopVerificationPolling();

        if (_currentUser != null && !_currentUser!.isEmailVerified) {
          _currentUser = _currentUser!.copyWith(isEmailVerified: true);
          notifyListeners();

          await _userRepository.updateEmailVerification(
            firebaseUser.uid,
            true,
          );
        }
      }
    } catch (_) {
      // Polling gagal diabaikan, akan dicoba lagi di iterasi berikutnya
    }
  }

  /// Mengirim ulang email verifikasi.
  Future<bool> resendEmailVerification() async {
    try {
      _setLoading(true);
      _setError(null);
      await _authRepository.sendEmailVerification();
      return true;
    } on Exception catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      await _authRepository.signIn(email, password);
      return true;
    } on Exception catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      // Lakukan login ke Firebase via Google
      final credential = await _authRepository.signInWithGoogle();
      final user = credential.user;

      if (user != null) {
        // Cek apakah user sudah ada di database
        final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;
        
        if (isNewUser) {
          // Buat data UserModel baru untuk disimpan di Firestore
          final newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? 'Pengguna',
            email: user.email ?? '',
            isEmailVerified: true, // Google account otomatis verified
            createdAt: DateTime.now(),
          );
          
          await _userRepository.createUser(newUser);
          _currentUser = newUser;
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } on Exception catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      _setLoading(true);
      _setError(null);

      final credential = await _authRepository.signUp(email, password, name);
      await _authRepository.sendEmailVerification();

      final newUser = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        isEmailVerified: false,
        createdAt: DateTime.now(),
      );
      await _userRepository.createUser(newUser);

      // Set manual karena authStateChanges bisa fire sebelum displayName terupdate
      _currentUser = newUser;
      startVerificationPolling();
      notifyListeners();

      return true;
    } on Exception catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> logout() async {
    try {
      _setLoading(true);
      _setError(null);
      stopVerificationPolling();
      await _authRepository.signOut();
      _currentUser = null;
      return true;
    } on Exception catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      await _authRepository.sendPasswordReset(email);
      return true;
    } on Exception catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUser() async {
    try {
      _setLoading(true);
      _setError(null);
      await _authRepository.reloadUser();

      final firebaseUser = _authRepository.currentUser;
      if (firebaseUser != null && _currentUser != null) {
        final wasVerified = _currentUser!.isEmailVerified;
        _currentUser = _currentUser!.copyWith(
          isEmailVerified: firebaseUser.emailVerified,
          name: firebaseUser.displayName ?? _currentUser!.name,
        );

        if (!wasVerified && firebaseUser.emailVerified) {
          stopVerificationPolling();
          await _userRepository.updateEmailVerification(
            firebaseUser.uid,
            true,
          );
        }
      }
    } on Exception catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    stopVerificationPolling();
    super.dispose();
  }
}
