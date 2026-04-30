import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khafidh_mdtest/core/constants/enums.dart';
import 'package:khafidh_mdtest/data/models/user_model.dart';
import 'package:khafidh_mdtest/data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  FilterStatus _filterStatus = FilterStatus.all;
  String _searchQuery = '';

  StreamSubscription<List<UserModel>>? _usersSubscription;

  bool get isLoading => _isLoading;
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

  /// Subscribe ke stream Firestore koleksi users.
  /// Setiap ada perubahan data di Firestore, _allUsers otomatis terupdate.
  void listenToUsers() {
    _isLoading = true;
    notifyListeners();

    _usersSubscription?.cancel();
    _usersSubscription = _userRepository.getUsers().listen(
      (users) {
        _allUsers = users;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
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
    _usersSubscription?.cancel();
    super.dispose();
  }
}
