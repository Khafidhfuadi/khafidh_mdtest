// Validators - kumpulan fungsi validasi input form
class Validators {
  /// Validasi format dan keberadaan input email.
  /// Mengembalikan null jika valid, atau pesan error jika tidak valid.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong.';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid.';
    }

    return null;
  }

  /// Validasi password.
  /// Minimal 6 karakter, mengandung huruf dan angka.
  /// Mengembalikan null jika valid, atau pesan error jika tidak valid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong.';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter.';
    }

    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password harus mengandung minimal satu huruf.';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password harus mengandung minimal satu angka.';
    }

    return null;
  }

  /// Validasi nama user.
  /// Tidak boleh kosong dan minimal 2 karakter.
  /// Mengembalikan null jika valid, atau pesan error jika tidak valid.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong.';
    }

    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter.';
    }

    if (value.trim().length > 50) {
      return 'Nama maksimal 50 karakter.';
    }

    return null;
  }
}
