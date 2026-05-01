import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khafidh_mdtest/core/constants/enums.dart';
import 'package:khafidh_mdtest/data/models/user_model.dart';
import 'package:khafidh_mdtest/data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  FilterStatus _filterStatus = FilterStatus.all;
  String _searchQuery = '';

  DocumentSnapshot? _lastDocument;
  StreamSubscription<QuerySnapshot>? _realtimeSubscription;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  FilterStatus get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;

  /// Computed property: menggabungkan filter status verifikasi dan search query
  /// terhadap _allUsers, menghasilkan daftar user yang siap ditampilkan di UI.
  List<UserModel> get filteredUsers {
    List<UserModel> result = _allUsers;

    switch (_filterStatus) {
      case FilterStatus.verified:
        result = result.where((u) => u.isEmailVerified).toList();
        break;
      case FilterStatus.unverified:
        result = result.where((u) => !u.isEmailVerified).toList();
        break;
      case FilterStatus.all:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((u) {
        return u.name.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  /// Memuat halaman pertama data user dari Firestore.
  /// Dipanggil saat pertama kali masuk ke HomeScreen.
  Future<void> loadUsers() async {
    if (_isLoading) return;

    _isLoading = true;
    _hasMore = true;
    _lastDocument = null;
    _allUsers = [];
    notifyListeners();

    try {
      final snapshot = await _userRepository.getFirstPage();
      _processSnapshot(snapshot);

      // Mulai listen ke perubahan realtime agar data tetap sinkron
      _startRealtimeSync();
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memuat halaman berikutnya (infinite scroll).
  /// Tidak melakukan apa-apa jika sedang loading atau sudah tidak ada data lagi.
  Future<void> loadMoreUsers() async {
    if (_isLoadingMore || !_hasMore || _lastDocument == null) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final snapshot = await _userRepository.getNextPage(_lastDocument!);
      _processSnapshot(snapshot);
    } catch (e) {
      debugPrint('Error loading more users: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Memproses QuerySnapshot: menambahkan user baru ke daftar,
  /// memperbarui cursor, dan menentukan apakah masih ada data selanjutnya.
  void _processSnapshot(QuerySnapshot snapshot) {
    if (snapshot.docs.isEmpty) {
      _hasMore = false;
      return;
    }

    final newUsers = snapshot.docs.map((doc) {
      return UserModel.fromFirestore(doc);
    }).toList();

    // Hindari duplikat berdasarkan uid
    for (final user in newUsers) {
      if (!_allUsers.any((u) => u.uid == user.uid)) {
        _allUsers.add(user);
      }
    }

    _lastDocument = snapshot.docs.last;
    _hasMore = snapshot.docs.length >= UserRepository.pageSize;
  }

  /// Mendengarkan perubahan realtime dari Firestore.
  /// Ketika ada dokumen yang berubah (misalnya isEmailVerified terupdate),
  /// data lokal akan diperbarui tanpa mereset seluruh daftar.
  void _startRealtimeSync() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _userRepository.getUsersStream().listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          final doc = change.doc;
          final user = UserModel.fromFirestore(doc);

          switch (change.type) {
            case DocumentChangeType.added:
              // Hanya tambahkan jika belum ada di daftar (user baru)
              if (!_allUsers.any((u) => u.uid == user.uid)) {
                _allUsers.insert(0, user);
              }
              break;
            case DocumentChangeType.modified:
              final index = _allUsers.indexWhere((u) => u.uid == user.uid);
              if (index != -1) {
                _allUsers[index] = user;
              }
              break;
            case DocumentChangeType.removed:
              _allUsers.removeWhere((u) => u.uid == user.uid);
              break;
          }
        }
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Realtime sync error: $error');
      },
    );
  }

  /// Mengubah filter status verifikasi dan memperbarui UI.
  void setFilter(FilterStatus status) {
    _filterStatus = status;
    notifyListeners();
  }

  /// Mengubah search query dan memperbarui UI.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
