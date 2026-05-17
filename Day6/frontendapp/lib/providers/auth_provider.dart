import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  String? get errorMessage => _errorMessage;

  Future<void> bootstrap() async {
    _setLoading(true);

    try {
      _user = await _authService.getCurrentUser();
      _errorMessage = null;
    } catch (_) {
      try {
        await _authService.logout();
      } catch (_) {
        // Storage plugins can be unavailable in widget tests.
      }

      _user = null;
      _errorMessage = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final result = await _authService.login(email: email, password: password);
      _user = result.user;
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _authService.getErrorMessage(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    _setLoading(true);

    try {
      final result = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      _user = result.user;
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _authService.getErrorMessage(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(String fullName, String email) async {
    _setLoading(true);

    try {
      _user = await _authService.updateProfile(
        fullName: fullName,
        email: email,
      );
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _authService.getErrorMessage(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);

    try {
      await _authService.deleteAccount();
      _user = null;
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = _authService.getErrorMessage(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
