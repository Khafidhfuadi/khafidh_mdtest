// UserRepository - abstraksi semua operasi Firestore untuk koleksi users
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khafidh_mdtest/data/models/user_model.dart';

class UserRepository {
  final CollectionReference _usersCollection;

  UserRepository({FirebaseFirestore? firestore})
      : _usersCollection =
            (firestore ?? FirebaseFirestore.instance).collection('users');

  /// Jumlah dokumen yang diambil per halaman.
  static const int pageSize = 15;

  /// Mengambil halaman pertama dari daftar user, diurutkan berdasarkan createdAt descending.
  Future<QuerySnapshot> getFirstPage() {
    return _usersCollection
        .orderBy('createdAt', descending: true)
        .limit(pageSize)
        .get();
  }

  /// Mengambil halaman berikutnya setelah dokumen terakhir yang diberikan.
  Future<QuerySnapshot> getNextPage(DocumentSnapshot lastDocument) {
    return _usersCollection
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDocument)
        .limit(pageSize)
        .get();
  }

  /// Mendapatkan stream realtime untuk mendeteksi perubahan data user.
  /// Digunakan untuk memperbarui data yang sudah dimuat jika ada perubahan di Firestore.
  Stream<QuerySnapshot> getUsersStream() {
    return _usersCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Membuat dokumen user baru di Firestore.
  /// Menggunakan uid sebagai document ID agar konsisten dengan Firebase Auth.
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Gagal membuat data user: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat membuat user: $e');
    }
  }

  /// Mengupdate status verifikasi email user di Firestore.
  /// [uid] adalah ID dokumen user, [status] adalah nilai boolean baru.
  Future<void> updateEmailVerification(String uid, bool status) async {
    try {
      await _usersCollection.doc(uid).update({
        'isEmailVerified': status,
      });
    } on FirebaseException catch (e) {
      throw Exception(
          'Gagal mengupdate status verifikasi email: ${e.message}');
    } catch (e) {
      throw Exception(
          'Terjadi kesalahan saat update verifikasi email: $e');
    }
  }
}
