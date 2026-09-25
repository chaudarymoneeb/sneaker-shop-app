import 'dart:async';

import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../model/services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  final Completer<void> _readyCompleter = Completer<void>();
  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _init();
  }

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  Future<void> get ready => _readyCompleter.future;

  void _init() {
    _authService.authStateChanges.listen((authState) async {
      final supabaseUser = authState.session?.user;
      if (supabaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
      } else {
        final profile = await _authService.fetchUserProfile(supabaseUser.id);
        _user =
            profile ??
            AppUser(
              uid: supabaseUser.id,
              email: supabaseUser.email ?? '',
              name: supabaseUser.userMetadata?['name'] as String? ?? '',
            );
        _status = AuthStatus.authenticated;
      }
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _user = await _authService.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );
      _status = AuthStatus.unauthenticated;
      _user = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _status = AuthStatus.unauthenticated;
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
