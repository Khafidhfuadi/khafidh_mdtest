// UserModel - representasi data user dari Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool isEmailVerified;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isEmailVerified,
    required this.createdAt,
  });

  /// Membuat instance UserModel dari DocumentSnapshot Firestore.
  /// Field `createdAt` di-handle baik sebagai Timestamp maupun fallback ke DateTime.now().
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Mengonversi UserModel ke Map untuk disimpan ke Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Membuat salinan UserModel dengan nilai field yang bisa di-override.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    bool? isEmailVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, '
        'isEmailVerified: $isEmailVerified, createdAt: $createdAt)';
  }
}
