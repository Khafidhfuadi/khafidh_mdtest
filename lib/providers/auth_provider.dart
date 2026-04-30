// auth_provider.dart - Provider untuk mengelola state autentikasi
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
}
