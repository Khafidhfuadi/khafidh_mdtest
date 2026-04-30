// ErrorHandler - mengubah FirebaseAuthException code menjadi pesan error yang user-friendly
import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  ErrorHandler._();

  /// Mengonversi FirebaseAuthException menjadi pesan error yang mudah dipahami user.
  static String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      // Login errors
      case 'user-not-found':
        return 'Akun dengan email ini tidak ditemukan.';
      case 'wrong-password':
        return 'Password yang dimasukkan salah.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan oleh administrator.';

      // Register errors
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Gunakan email lain.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'operation-not-allowed':
        return 'Metode autentikasi ini tidak diizinkan.';

      // Network & rate limit errors
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Silakan coba lagi nanti.';

      // Token & session errors
      case 'expired-action-code':
        return 'Link sudah kedaluwarsa. Silakan minta link baru.';
      case 'invalid-action-code':
        return 'Link tidak valid atau sudah digunakan.';
      case 'requires-recent-login':
        return 'Sesi login sudah lama. Silakan login ulang.';

      // Credential errors
      case 'account-exists-with-different-credential':
        return 'Akun sudah terdaftar dengan metode login yang berbeda.';
      case 'credential-already-in-use':
        return 'Kredensial ini sudah digunakan oleh akun lain.';

      // Misc
      case 'user-token-expired':
        return 'Sesi Anda telah berakhir. Silakan login kembali.';
      case 'user-mismatch':
        return 'Kredensial tidak cocok dengan akun yang aktif.';

      default:
        return e.message ?? 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  /// Mengonversi exception generik menjadi pesan yang user-friendly.
  static String getGeneralErrorMessage(dynamic e) {
    final message = e.toString();

    if (message.contains('network') ||
        message.contains('SocketException') ||
        message.contains('ClientException')) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    }

    if (message.contains('timeout') || message.contains('TimeoutException')) {
      return 'Koneksi timeout. Silakan coba lagi.';
    }

    if (message.contains('permission-denied') ||
        message.contains('PERMISSION_DENIED')) {
      return 'Anda tidak memiliki izin untuk melakukan operasi ini.';
    }

    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
