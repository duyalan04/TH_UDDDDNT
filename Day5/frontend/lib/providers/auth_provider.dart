import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _auth = AuthService();
  bool _isAuthenticated = false;
  String? _email;

  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;

  Future<void> checkAuth() async {
    final token = await _auth.getToken();
    _isAuthenticated = token != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final success = await _auth.login(email, password);
    if (success) {
      _isAuthenticated = true;
      _email = email;
      notifyListeners();
    }
    return success;
  }

  Future<bool> register(String email, String password) async {
    return await _auth.register(email, password);
  }

  Future<void> logout() async {
    await _auth.logout();
    _isAuthenticated = false;
    _email = null;
    notifyListeners();
  }
}
