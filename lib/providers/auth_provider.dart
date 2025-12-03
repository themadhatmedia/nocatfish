import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _isAuthenticated = false;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      _user = {
        'id': 1,
        'name': 'Test User',
        'email': email,
      };
      _isAuthenticated = true;

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      _user = {
        'id': 1,
        'name': name,
        'email': email,
      };
      _isAuthenticated = true;

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> loadAuthData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }
}
