// user_provider.dart - Provider untuk mengelola state pengguna
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final List<dynamic> _users = [];
  List<dynamic> get users => _users;
}
