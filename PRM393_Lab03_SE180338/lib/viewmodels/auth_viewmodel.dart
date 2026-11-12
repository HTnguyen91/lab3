import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../services/crashlytics_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AnalyticsService _analyticsService;
  final CrashlyticsService _crashlyticsService;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthViewModel({
    required AuthService authService,
    required AnalyticsService analyticsService,
    required CrashlyticsService crashlyticsService,
  }) : _authService = authService,
       _analyticsService = analyticsService,
       _crashlyticsService = crashlyticsService {
    _currentUser = _authService.currentUser;
    _authSubscription = _authService.authStateChanges.listen((user) {
      _currentUser = user;
      if (user != null) {
        _crashlyticsService.setUserIdentifier(user.uid);
      }
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get displayName => _currentUser?.displayName ?? 'Người dùng';
  String get email => _currentUser?.email ?? 'Chưa xác định';
  String? get photoUrl => _currentUser?.photoURL;
  String get uid => _currentUser?.uid ?? '';

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithGoogle();
      if (credential != null && credential.user != null) {
        await _analyticsService.logLogin(method: 'google_sign_in');
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đăng nhập không thành công: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _analyticsService.logLogout();
      await _authService.signOut();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
