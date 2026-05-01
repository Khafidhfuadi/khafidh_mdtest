// Test suite untuk UserModel - memverifikasi serialisasi & deserialisasi data
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khafidh_mdtest/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    // ---------------------------------------------------------------
    // fromFirestore
    // ---------------------------------------------------------------
    group('fromFirestore', () {
      test('parsing data Firestore menjadi UserModel dengan benar', () async {
        // Arrange - gunakan fake Firestore untuk membuat DocumentSnapshot asli
        final fakeFirestore = FakeFirebaseFirestore();
        final createdAt = DateTime(2026, 1, 15, 10, 30);

        await fakeFirestore.collection('users').doc('uid-123').set({
          'name': 'Test User',
          'email': 'test@example.com',
          'isEmailVerified': true,
          'createdAt': Timestamp.fromDate(createdAt),
        });

        final doc =
            await fakeFirestore.collection('users').doc('uid-123').get();

        // Act
        final user = UserModel.fromFirestore(doc);

        // Assert
        expect(user.uid, 'uid-123');
        expect(user.name, 'Test User');
        expect(user.email, 'test@example.com');
        expect(user.isEmailVerified, true);
        expect(user.createdAt, createdAt);
      });

      test('memberikan default value jika field kosong atau null', () async {
        // Arrange - dokumen tanpa field name, email, isEmailVerified, createdAt
        final fakeFirestore = FakeFirebaseFirestore();
        await fakeFirestore.collection('users').doc('uid-empty').set({});

        final doc =
            await fakeFirestore.collection('users').doc('uid-empty').get();

        // Act
        final user = UserModel.fromFirestore(doc);

        // Assert
        expect(user.uid, 'uid-empty');
        expect(user.name, '');
        expect(user.email, '');
        expect(user.isEmailVerified, false);
        // createdAt di-fallback ke DateTime.now(), cukup pastikan tidak null
        expect(user.createdAt, isA<DateTime>());
      });
    });

    // ---------------------------------------------------------------
    // toMap
    // ---------------------------------------------------------------
    group('toMap', () {
      test('mengonversi UserModel ke Map dengan format yang benar', () {
        // Arrange
        final createdAt = DateTime(2026, 5, 1, 8, 0);
        final user = UserModel(
          uid: 'uid-map',
          name: 'Map User',
          email: 'map@example.com',
          isEmailVerified: false,
          createdAt: createdAt,
        );

        // Act
        final map = user.toMap();

        // Assert
        expect(map['uid'], 'uid-map');
        expect(map['name'], 'Map User');
        expect(map['email'], 'map@example.com');
        expect(map['isEmailVerified'], false);
        expect(map['createdAt'], isA<Timestamp>());
        expect((map['createdAt'] as Timestamp).toDate(), createdAt);
      });

      test('Map berisi semua key yang diperlukan', () {
        // Arrange
        final user = UserModel(
          uid: 'uid-keys',
          name: 'Key User',
          email: 'key@example.com',
          isEmailVerified: true,
          createdAt: DateTime.now(),
        );

        // Act
        final map = user.toMap();

        // Assert
        expect(map.keys, containsAll(['uid', 'name', 'email', 'isEmailVerified', 'createdAt']));
        expect(map.length, 5);
      });
    });

    // ---------------------------------------------------------------
    // copyWith
    // ---------------------------------------------------------------
    group('copyWith', () {
      test('membuat salinan dengan field yang di-override', () {
        // Arrange
        final original = UserModel(
          uid: 'uid-orig',
          name: 'Original',
          email: 'orig@example.com',
          isEmailVerified: false,
          createdAt: DateTime(2026, 1, 1),
        );

        // Act
        final copied = original.copyWith(
          name: 'Updated Name',
          isEmailVerified: true,
        );

        // Assert - field yang di-override berubah
        expect(copied.name, 'Updated Name');
        expect(copied.isEmailVerified, true);

        // Assert - field yang tidak di-override tetap sama
        expect(copied.uid, 'uid-orig');
        expect(copied.email, 'orig@example.com');
        expect(copied.createdAt, DateTime(2026, 1, 1));
      });

      test('copyWith tanpa parameter mengembalikan salinan identik', () {
        // Arrange
        final original = UserModel(
          uid: 'uid-same',
          name: 'Same User',
          email: 'same@example.com',
          isEmailVerified: true,
          createdAt: DateTime(2026, 6, 1),
        );

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied.uid, original.uid);
        expect(copied.name, original.name);
        expect(copied.email, original.email);
        expect(copied.isEmailVerified, original.isEmailVerified);
        expect(copied.createdAt, original.createdAt);
      });
    });
  });
}
