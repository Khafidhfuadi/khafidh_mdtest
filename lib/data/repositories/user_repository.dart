// UserRepository - abstraksi semua operasi Firestore untuk koleksi users
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khafidh_mdtest/data/models/user_model.dart';

class UserRepository {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  /// Mendapatkan stream daftar semua user dari Firestore.
  /// Data akan otomatis terupdate secara realtime ketika ada perubahan.
  Stream<List<UserModel>> getUsers() {
    try {
      return _usersCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return UserModel.fromFirestore(doc);
        }).toList();
      });
    } catch (e) {
      throw Exception('Gagal mengambil data users: $e');
    }
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
