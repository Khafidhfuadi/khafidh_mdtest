// Test suite untuk Validators - memverifikasi semua fungsi validasi input
import 'package:flutter_test/flutter_test.dart';
import 'package:khafidh_mdtest/core/utils/validators.dart';

void main() {
  group('Validators', () {
    // ---------------------------------------------------------------
    // validateEmail
    // ---------------------------------------------------------------
    group('validateEmail', () {
      test('email valid mengembalikan null', () {
        expect(Validators.validateEmail('user@example.com'), isNull);
        expect(Validators.validateEmail('test.name+tag@domain.co.id'), isNull);
      });

      test('email kosong mengembalikan pesan error', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
        expect(Validators.validateEmail('   '), isNotNull);
      });

      test('email tanpa @ mengembalikan pesan error', () {
        final result = Validators.validateEmail('userdomain.com');
        expect(result, isNotNull);
        expect(result, contains('Format email'));
      });

      test('email tanpa domain mengembalikan pesan error', () {
        expect(Validators.validateEmail('user@'), isNotNull);
      });

      test('email tanpa TLD mengembalikan pesan error', () {
        expect(Validators.validateEmail('user@domain'), isNotNull);
      });
    });

    // ---------------------------------------------------------------
    // validatePassword
    // ---------------------------------------------------------------
    group('validatePassword', () {
      test('password valid mengembalikan null', () {
        expect(Validators.validatePassword('abc123'), isNull);
        expect(Validators.validatePassword('Password1'), isNull);
      });

      test('password kosong mengembalikan pesan error', () {
        expect(Validators.validatePassword(''), isNotNull);
        expect(Validators.validatePassword(null), isNotNull);
      });

      test('password terlalu pendek (kurang dari 6 karakter) mengembalikan pesan error',
          () {
        final result = Validators.validatePassword('ab1');
        expect(result, isNotNull);
        expect(result, contains('minimal 6'));
      });

      test('password tanpa huruf mengembalikan pesan error', () {
        final result = Validators.validatePassword('123456');
        expect(result, isNotNull);
        expect(result, contains('huruf'));
      });

      test('password tanpa angka mengembalikan pesan error', () {
        final result = Validators.validatePassword('abcdef');
        expect(result, isNotNull);
        expect(result, contains('angka'));
      });
    });

    // ---------------------------------------------------------------
    // validateName
    // ---------------------------------------------------------------
    group('validateName', () {
      test('nama valid mengembalikan null', () {
        expect(Validators.validateName('John'), isNull);
        expect(Validators.validateName('Ab'), isNull);
      });

      test('nama kosong mengembalikan pesan error', () {
        final result = Validators.validateName('');
        expect(result, isNotNull);
        expect(result, contains('tidak boleh kosong'));
      });

      test('nama null mengembalikan pesan error', () {
        expect(Validators.validateName(null), isNotNull);
      });

      test('nama terlalu pendek (1 karakter) mengembalikan pesan error', () {
        final result = Validators.validateName('A');
        expect(result, isNotNull);
        expect(result, contains('minimal 2'));
      });

      test('nama hanya spasi mengembalikan pesan error', () {
        expect(Validators.validateName('   '), isNotNull);
      });
    });
  });
}
