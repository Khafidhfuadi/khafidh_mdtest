# Khafidh MDTest

Aplikasi Flutter untuk manajemen user yang terintegrasi dengan Firebase. Mendukung autentikasi lengkap (Email/Password dan Google Sign-In), email verification secara realtime, serta CRUD data user melalui Cloud Firestore. Dibangun dengan arsitektur berlapis (Repository Pattern) dan state management menggunakan Provider.

---

## Tech Stack

| Layer              | Teknologi                        |
|--------------------|----------------------------------|
| Framework          | Flutter (Dart)                   |
| Authentication     | Firebase Authentication          |
| Database           | Cloud Firestore                  |
| State Management   | Provider (`ChangeNotifier`)      |
| Architecture       | Repository Pattern + Provider    |

---

## Prerequisites

Pastikan tools berikut sudah terinstal sebelum menjalankan project:

- **Flutter SDK** >= 3.9.2 (channel stable)
- **Dart SDK** >= 3.9.2 (sudah termasuk dalam Flutter SDK)
- **Firebase CLI** -- untuk setup project Firebase (`npm install -g firebase-tools`)
- **Android Studio** (untuk Android) atau **Xcode** (untuk iOS)
- **Akun Firebase** dengan project yang sudah dibuat

Verifikasi instalasi Flutter:

```bash
flutter doctor
```

---

## Firebase Setup

1. **Buat project Firebase** di [Firebase Console](https://console.firebase.google.com/).

2. **Tambahkan aplikasi** (Android dan/atau iOS) ke project Firebase.

3. **Enable Authentication**:
   - Buka menu **Authentication > Sign-in method**.
   - Aktifkan provider **Email/Password**.
   - (Opsional) Aktifkan provider **Google** -- pastikan SHA-1 fingerprint sudah ditambahkan untuk Android.

4. **Buat koleksi Firestore**:
   - Buka menu **Firestore Database > Create database**.
   - Buat koleksi `users` dengan struktur dokumen:

     | Field             | Tipe      | Keterangan                        |
     |-------------------|-----------|-----------------------------------|
     | `uid`             | string    | UID dari Firebase Auth            |
     | `name`            | string    | Nama lengkap user                 |
     | `email`           | string    | Alamat email                      |
     | `isEmailVerified` | boolean   | Status verifikasi email           |
     | `createdAt`       | timestamp | Waktu registrasi                  |

5. **Atur Firestore Security Rules** sesuai kebutuhan (contoh minimal):

   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

---

## Installation

```bash
# 1. Clone repository
git clone https://github.com/khafidh/khafidh_mdtest.git
cd khafidh_mdtest

# 2. Install dependencies
flutter pub get

# 3. Tambahkan file konfigurasi Firebase
# - Android: Salin google-services.json ke android/app/
# - iOS:     Salin GoogleService-Info.plist ke ios/Runner/

# 4. Jalankan aplikasi
flutter run
```

> File `google-services.json` dan `GoogleService-Info.plist` didapat dari Firebase Console saat mendaftarkan aplikasi Android/iOS ke project Firebase.

---

## Running Tests

Jalankan seluruh test suite:

```bash
flutter test
```

Jalankan test spesifik:

```bash
# Test providers
flutter test test/providers/auth_provider_test.dart
flutter test test/providers/user_provider_test.dart

# Test repositories
flutter test test/repositories/auth_repository_test.dart
flutter test test/repositories/user_repository_test.dart

# Test models
flutter test test/models/user_model_test.dart

# Test utilities
flutter test test/utils/validators_test.dart
```

Jalankan test dengan coverage report:

```bash
flutter test --coverage
```

---

## Third-party Libraries

### Dependencies

| Library            | Versi      | Alasan Penggunaan                                                                                         |
|--------------------|------------|-----------------------------------------------------------------------------------------------------------|
| `firebase_core`    | ^4.7.0     | Inisialisasi Firebase SDK -- wajib sebagai fondasi seluruh layanan Firebase.                               |
| `firebase_auth`    | ^6.4.0     | Autentikasi user (Email/Password, Google Sign-In) termasuk email verification dan password reset.          |
| `cloud_firestore`  | ^6.3.0     | Database NoSQL realtime untuk menyimpan dan mengelola data profil user.                                    |
| `provider`         | ^6.1.5+1   | State management yang simpel dan ringan. Dipilih karena sesuai untuk skala project ini tanpa boilerplate berlebihan dibanding BLoC atau Riverpod. |
| `google_sign_in`   | ^6.2.1     | Integrasi Sign-In with Google untuk menyediakan opsi login yang lebih cepat bagi user.                     |
| `intl`             | ^0.19.0    | Formatting tanggal dan waktu sesuai locale (digunakan untuk menampilkan `createdAt` user).                 |

### Dev Dependencies

| Library                | Versi       | Alasan Penggunaan                                                                                     |
|------------------------|-------------|-------------------------------------------------------------------------------------------------------|
| `flutter_lints`        | ^5.0.0      | Kumpulan lint rules untuk menjaga kualitas dan konsistensi kode Dart/Flutter.                          |
| `mockito`              | ^5.6.4      | Framework mocking standar untuk Dart. Digunakan membuat mock object pada unit test.                    |
| `build_runner`         | ^2.15.0     | Code generator untuk Mockito -- menghasilkan file `.mocks.dart` secara otomatis.                       |
| `firebase_auth_mocks`  | ^0.15.1     | Mock implementasi Firebase Auth. Memungkinkan testing alur autentikasi **tanpa koneksi ke Firebase asli**, termasuk simulasi user state dan email verification. |
| `fake_cloud_firestore`  | ^4.1.0+1   | In-memory fake Firestore. Memungkinkan testing operasi CRUD Firestore **tanpa emulator atau project Firebase**, sehingga test berjalan cepat dan deterministik. |
| `mock_exceptions`      | ^0.8.2      | Helper untuk mensimulasikan exception pada mock objects -- mempermudah testing error handling.          |
| `google_sign_in_mocks` | ^0.3.0      | Mock untuk Google Sign-In flow agar bisa ditest tanpa interaksi OAuth nyata.                           |

---

## Project Structure

```
lib/
|-- main.dart                          # Entry point, setup Provider & Firebase
|-- firebase_options.dart              # Konfigurasi Firebase (auto-generated)
|
|-- core/                             # Shared utilities & constants
|   |-- constants/
|   |   |-- app_colors.dart            # Definisi warna aplikasi
|   |   |-- app_strings.dart           # String constants
|   |   +-- enums.dart                 # Enum definitions
|   |-- theme/
|   |   +-- app_theme.dart             # Konfigurasi ThemeData
|   |-- utils/
|   |   |-- error_handler.dart         # Mapping error Firebase ke pesan user-friendly
|   |   |-- helpers.dart               # Fungsi helper umum
|   |   +-- validators.dart            # Validasi input (email, password, nama)
|   +-- widgets/
|       |-- empty_state_widget.dart    # Widget untuk state kosong/empty
|       +-- verification_badge.dart    # Badge status verifikasi email
|
|-- data/                             # Data layer (Repository Pattern)
|   |-- models/
|   |   +-- user_model.dart            # Model data user (toMap, fromMap, copyWith)
|   +-- repositories/
|       |-- auth_repository.dart       # Abstraksi operasi Firebase Auth
|       +-- user_repository.dart       # Abstraksi operasi Firestore (koleksi users)
|
|-- features/                         # Feature-based UI screens
|   |-- auth/
|   |   |-- login/                     # Halaman login
|   |   |-- register/                  # Halaman registrasi
|   |   +-- forgot_password/           # Halaman forgot password
|   +-- home/
|       |-- home_screen.dart           # Halaman utama (daftar user)
|       |-- user_detail_screen.dart    # Detail profil user
|       +-- user_list_item.dart        # Widget item user dalam list
|
+-- providers/                        # State management (ChangeNotifier)
    |-- auth_provider.dart             # State autentikasi + verification polling
    +-- user_provider.dart             # State manajemen data user Firestore

test/
|-- widget_test.dart                   # Default widget test
|-- models/
|   +-- user_model_test.dart           # Unit test UserModel
|-- providers/
|   |-- auth_provider_test.dart        # Unit test AuthProvider
|   +-- user_provider_test.dart        # Unit test UserProvider
|-- repositories/
|   |-- auth_repository_test.dart      # Unit test AuthRepository
|   +-- user_repository_test.dart      # Unit test UserRepository
+-- utils/
    +-- validators_test.dart           # Unit test Validators
```

---

## Additional Features

### Realtime Email Verification Polling

Setelah user melakukan registrasi, aplikasi secara otomatis memulai polling status verifikasi email setiap **5 detik** menggunakan `Timer.periodic`. Mekanisme ini memungkinkan UI langsung terupdate begitu user mengklik link verifikasi di emailnya, **tanpa perlu manual refresh atau restart aplikasi**.

Alur kerja:

1. User registrasi -> email verifikasi dikirim otomatis.
2. `AuthProvider.startVerificationPolling()` dipanggil.
3. Setiap 5 detik, `_checkVerificationStatus()` memanggil `FirebaseAuth.currentUser.reload()` untuk mendapatkan status terbaru.
4. Jika `emailVerified` berubah menjadi `true`:
   - Timer dihentikan (`stopVerificationPolling()`).
   - State `_currentUser.isEmailVerified` diupdate.
   - Status verifikasi disinkronkan ke koleksi `users` di Firestore.
   - UI terupdate secara otomatis melalui `notifyListeners()`.

Polling otomatis dihentikan saat user logout atau email sudah terverifikasi, sehingga tidak membuang resource secara percuma.
