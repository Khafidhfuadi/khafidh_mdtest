// Test suite untuk UserRepository - memverifikasi operasi Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khafidh_mdtest/data/models/user_model.dart';
import 'package:khafidh_mdtest/data/repositories/user_repository.dart';

void main() {
  group('UserRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore: fakeFirestore);
    });

    // ---------------------------------------------------------------
    // getUsersStream
    // ---------------------------------------------------------------
    group('getUsersStream', () {
      test('mengembalikan stream dengan data user yang sudah disimpan',
          () async {
        // Arrange - seed data langsung ke fake Firestore
        final now = DateTime(2026, 1, 1);
        await fakeFirestore.collection('users').doc('uid-1').set({
          'uid': 'uid-1',
          'name': 'User Satu',
          'email': 'satu@example.com',
          'isEmailVerified': true,
          'createdAt': Timestamp.fromDate(now),
        });
        await fakeFirestore.collection('users').doc('uid-2').set({
          'uid': 'uid-2',
          'name': 'User Dua',
          'email': 'dua@example.com',
          'isEmailVerified': false,
          'createdAt':
              Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        });

        // Act
        final stream = repository.getUsersStream();
        final snapshot = await stream.first;

        // Assert
        expect(snapshot.docs.length, 2);

        // Data diurutkan descending berdasarkan createdAt,
        // jadi 'User Satu' (tanggal lebih baru) muncul pertama.
        final firstDoc = snapshot.docs.first.data() as Map<String, dynamic>;
        expect(firstDoc['name'], 'User Satu');
        expect(firstDoc['email'], 'satu@example.com');
      });

      test('mengembalikan stream kosong jika belum ada data', () async {
        // Act
        final stream = repository.getUsersStream();
        final snapshot = await stream.first;

        // Assert
        expect(snapshot.docs, isEmpty);
      });
    });

    // ---------------------------------------------------------------
    // createUser
    // ---------------------------------------------------------------
    group('createUser', () {
      test('menyimpan data user ke Firestore dengan benar', () async {
        // Arrange
        final user = UserModel(
          uid: 'new-uid',
          name: 'New User',
          email: 'new@example.com',
          isEmailVerified: false,
          createdAt: DateTime(2026, 5, 1),
        );

        // Act
        await repository.createUser(user);

        // Assert - baca langsung dari fake Firestore
        final doc =
            await fakeFirestore.collection('users').doc('new-uid').get();
        expect(doc.exists, isTrue);

        final data = doc.data()!;
        expect(data['name'], 'New User');
        expect(data['email'], 'new@example.com');
        expect(data['isEmailVerified'], false);
        expect(data['uid'], 'new-uid');
      });
    });

    // ---------------------------------------------------------------
    // updateEmailVerification
    // ---------------------------------------------------------------
    group('updateEmailVerification', () {
      test('mengupdate field isEmailVerified dengan benar', () async {
        // Arrange - buat dokumen terlebih dahulu
        await fakeFirestore.collection('users').doc('uid-verify').set({
          'uid': 'uid-verify',
          'name': 'Verify User',
          'email': 'verify@example.com',
          'isEmailVerified': false,
          'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        });

        // Act
        await repository.updateEmailVerification('uid-verify', true);

        // Assert
        final doc =
            await fakeFirestore.collection('users').doc('uid-verify').get();
        expect(doc.data()!['isEmailVerified'], true);
      });

      test(
          'mengupdate field isEmailVerified tanpa mengubah field lain',
          () async {
        // Arrange
        await fakeFirestore.collection('users').doc('uid-other').set({
          'uid': 'uid-other',
          'name': 'Other User',
          'email': 'other@example.com',
          'isEmailVerified': false,
          'createdAt': Timestamp.fromDate(DateTime(2026, 3, 15)),
        });

        // Act
        await repository.updateEmailVerification('uid-other', true);

        // Assert - pastikan field lain tidak berubah
        final doc =
            await fakeFirestore.collection('users').doc('uid-other').get();
        final data = doc.data()!;
        expect(data['isEmailVerified'], true);
        expect(data['name'], 'Other User');
        expect(data['email'], 'other@example.com');
      });
    });
  });
}
