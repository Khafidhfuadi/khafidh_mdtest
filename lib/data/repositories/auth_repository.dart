// AuthRepository - abstraksi semua operasi Firebase Authentication
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Getter untuk mendapatkan user yang sedang login saat ini.
  User? get currentUser => _auth.currentUser;

  /// Stream perubahan state autentikasi (login/logout).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login dengan email dan password.
  /// Melempar exception jika kredensial salah atau terjadi error jaringan.
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Akun dengan email ini tidak ditemukan.');
        case 'wrong-password':
          throw Exception('Password yang dimasukkan salah.');
        case 'invalid-email':
          throw Exception('Format email tidak valid.');
        case 'user-disabled':
          throw Exception('Akun ini telah dinonaktifkan.');
        case 'invalid-credential':
          throw Exception('Email atau password salah.');
        default:
          throw Exception('Login gagal: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat login: $e');
    }
  }

  /// Registrasi akun baru dengan email, password, dan nama.
  /// Setelah berhasil, displayName akan diupdate di FirebaseAuth.
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
      // Update display name setelah registrasi berhasil
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
      return credential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email sudah terdaftar. Gunakan email lain.');
        case 'weak-password':
          throw Exception('Password terlalu lemah. Gunakan minimal 6 karakter.');
        case 'invalid-email':
          throw Exception('Format email tidak valid.');
        case 'operation-not-allowed':
          throw Exception('Registrasi dengan email/password tidak diizinkan.');
        default:
          throw Exception('Registrasi gagal: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat registrasi: $e');
    }
  }

  /// Logout dari akun saat ini.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Terjadi kesalahan saat logout: $e');
    }
  }

  /// Mengirim email reset password ke alamat email yang diberikan.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Akun dengan email ini tidak ditemukan.');
        case 'invalid-email':
          throw Exception('Format email tidak valid.');
        default:
          throw Exception('Gagal mengirim email reset password: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengirim reset password: $e');
    }
  }

  /// Mengirim email verifikasi ke user yang sedang login.
  /// Melempar exception jika tidak ada user yang login.
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
      throw Exception('Gagal mengirim email verifikasi: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengirim verifikasi email: $e');
    }
  }

  /// Me-reload data user dari Firebase untuk mendapatkan status terbaru
  /// (misalnya status emailVerified setelah user klik link verifikasi).
  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Tidak ada user yang sedang login.');
      }
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw Exception('Gagal memuat ulang data user: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat reload user: $e');
    }
  }
}
