// AuthProvider - mengelola state autentikasi user di seluruh aplikasi
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khafidh_mdtest/data/models/user_model.dart';
import 'package:khafidh_mdtest/data/repositories/auth_repository.dart';
import 'package:khafidh_mdtest/data/repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  // -- State --
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;

  // -- Getter --
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // -- Helper untuk mengubah loading state --
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // -- Helper untuk mengubah error state --
  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Inisialisasi listener untuk perubahan state autentikasi Firebase.
  /// Dipanggil sekali saat aplikasi dimulai.
  /// Ketika user login/logout, _currentUser akan diupdate secara otomatis.
  void initialize() {
    _authSubscription?.cancel();
    _authSubscription =
        _authRepository.authStateChanges.listen(_onAuthStateChanged);
  }

  /// Callback internal saat state autentikasi berubah.
  /// Jika ada user yang login, ambil data dari Firestore.
  /// Jika tidak ada user (logout), reset _currentUser.
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      _currentUser = UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        isEmailVerified: firebaseUser.emailVerified,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      );
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Login dengan email dan password.
  /// Memanggil AuthRepository.signIn dan menangani error.
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

  /// Registrasi akun baru.
  /// Alur: signUp -> kirim email verifikasi -> simpan user ke Firestore.
  Future<bool> register(String email, String password, String name) async {
    try {
      _setLoading(true);
      _setError(null);

      // 1. Buat akun di Firebase Auth
      final credential = await _authRepository.signUp(email, password, name);

      // 2. Kirim email verifikasi
      await _authRepository.sendEmailVerification();

      // 3. Simpan data user ke Firestore
      final newUser = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        isEmailVerified: false,
        createdAt: DateTime.now(),
      );
      await _userRepository.createUser(newUser);

      return true;
    } on Exception catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout dari akun saat ini.
  Future<bool> logout() async {
    try {
      _setLoading(true);
      _setError(null);
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

  /// Mengirim email reset password.
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

  /// Refresh data user dari Firebase.
  /// Berguna untuk mengecek status verifikasi email terbaru.
  /// Jika email sudah terverifikasi, update juga status di Firestore.
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

        // Sinkronkan status verifikasi ke Firestore jika baru saja terverifikasi
        if (!wasVerified && firebaseUser.emailVerified) {
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

  /// Menghapus pesan error.
  void clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
