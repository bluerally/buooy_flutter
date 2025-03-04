import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TokenService _tokenService = TokenService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  AuthViewModel() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _tokenService.getAccessToken();
      if (token != null) {
        final user = await _authService.getUserProfile();
        if (user != null) {
          _user = user;
          _isAuthenticated = true;
        } else {
          // 토큰은 있지만 사용자 정보를 가져오지 못한 경우 토큰 갱신 시도
          final refreshed = await _authService.refreshToken();
          if (refreshed) {
            final refreshedUser = await _authService.getUserProfile();
            _user = refreshedUser;
            _isAuthenticated = refreshedUser != null;
          } else {
            // 토큰 갱신 실패
            await _tokenService.clearTokens();
            _isAuthenticated = false;
          }
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tokens = await _authService.googleLogin();
      if (tokens != null) {
        final user = await _authService.getUserProfile();
        _user = user;
        _isAuthenticated = user != null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithKakao() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // SDK 방식 로그인 사용
      final tokens = await _authService.kakaoLogin();
      if (tokens != null) {
        final user = await _authService.getUserProfile();
        _user = user;
        _isAuthenticated = user != null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithNaver() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // SDK 방식 로그인 사용
      final tokens = await _authService.naverLogin();
      if (tokens != null) {
        final user = await _authService.getUserProfile();
        _user = user;
        _isAuthenticated = user != null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 웹 방식 로그인 (백업용)
  Future<bool> loginWithWeb(String platform) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tokens = await _authService.socialLoginWeb(platform);
      if (tokens != null) {
        final user = await _authService.getUserProfile();
        _user = user;
        _isAuthenticated = user != null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.logout();
      if (result) {
        _user = null;
        _isAuthenticated = false;
      }
      return result;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
