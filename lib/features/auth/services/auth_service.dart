import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../core/constants/api_constants.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';
import 'token_service.dart';

class AuthService {
  final TokenService _tokenService = TokenService();

  // 일반적인 소셜 로그인 처리 (웹 방식)
  Future<TokenModel?> socialLoginWeb(String platform) async {
    try {
      // 1. 리다이렉트 URL 요청
      final redirectUrl = await _getRedirectUrl(platform);
      if (redirectUrl == null) return null;

      // 2. 웹 인증 실행
      final callbackUri = await _authenticateWithWeb(redirectUrl, platform);
      if (callbackUri == null) return null;

      // 3. 콜백 URI에서 코드 추출
      final uri = Uri.parse(callbackUri);
      final code = uri.queryParameters['code'];
      if (code == null) return null;

      // 4. 토큰 발급
      final tokens = await _processLoginCallback(platform, code);
      if (tokens != null) {
        await _tokenService.saveTokens(tokens);
      }

      return tokens;
    } catch (e) {
      debugPrint('Social login error: $e');
      return null;
    }
  }

  // 카카오 SDK 로그인
  Future<TokenModel?> kakaoLogin() async {
    try {
      OAuthToken token;

      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        // 카카오톡으로 로그인
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오 계정으로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 사용자 정보 요청
      User kakaoUser = await UserApi.instance.me();

      // 백엔드 서버에 토큰 전송
      final Map<String, dynamic> body = {
        'token': token.accessToken,
        'platform': ApiConstants.platformKakao,
        'user_info': {
          'id': kakaoUser.id.toString(),
          'email': kakaoUser.kakaoAccount?.email,
          'name': kakaoUser.kakaoAccount?.profile?.nickname,
          'profile_image': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        }
      };

      final tokenResponse = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/user/auth/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (tokenResponse.statusCode == 201) {
        final tokens = TokenModel.fromJson(jsonDecode(tokenResponse.body));
        await _tokenService.saveTokens(tokens);
        return tokens;
      }

      return null;
    } catch (e) {
      debugPrint('Kakao login error: $e');
      return null;
    }
  }

  // 네이버 SDK 로그인
  Future<TokenModel?> naverLogin() async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        final NaverAccountResult account =
            await FlutterNaverLogin.currentAccount();

        // 백엔드 서버에 토큰 전송
        final Map<String, dynamic> body = {
          'token': result.accessToken,
          'platform': ApiConstants.platformNaver,
          'user_info': {
            'id': account.id,
            'email': account.email,
            'name': account.name,
            'profile_image': account.profileImage,
          }
        };

        final tokenResponse = await http.post(
          Uri.parse('${ApiConstants.baseUrl}/api/user/auth/token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (tokenResponse.statusCode == 201) {
          final tokens = TokenModel.fromJson(jsonDecode(tokenResponse.body));
          await _tokenService.saveTokens(tokens);
          return tokens;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Naver login error: $e');
      return null;
    }
  }

  // 구글 로그인 처리 (GoogleSignIn SDK 사용)
  Future<TokenModel?> googleLogin() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;

      // Firebase Auth 사용하는 경우
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      // Firebase Auth로 로그인
      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) return null;

      // 백엔드 서버에 토큰 전송
      final idToken = await user.getIdToken();
      final tokenResponse = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/user/auth/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': idToken,
          'platform': ApiConstants.platformGoogle,
          'user_info': {
            'id': user.uid,
            'email': user.email,
            'name': user.displayName,
            'profile_image': user.photoURL,
          }
        }),
      );

      if (tokenResponse.statusCode == 201) {
        final tokens = TokenModel.fromJson(jsonDecode(tokenResponse.body));
        await _tokenService.saveTokens(tokens);
        return tokens;
      }

      return null;
    } catch (e) {
      debugPrint('Google login error: $e');
      return null;
    }
  }

  // 리다이렉트 URL 가져오기
  Future<String?> _getRedirectUrl(String platform) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.redirectUrl}/$platform'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['redirect_url'];
      }

      return null;
    } catch (e) {
      debugPrint('Error getting redirect URL: $e');
      return null;
    }
  }

  // 웹 인증 실행
  Future<String?> _authenticateWithWeb(String url, String platform) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Flutter Web Auth를 사용한 웹 인증
        final callbackUrl = await FlutterWebAuth2.authenticate(
          url: url,
          callbackUrlScheme: 'buooy',
        );
        return callbackUrl;
      } else {
        // 웹에서는 URL을 열고 사용자가 직접 인증하도록 함
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          // 여기서는 웹에서 콜백 처리를 위한 추가 로직이 필요할 수 있음
        }
        return null;
      }
    } catch (e) {
      debugPrint('Web auth error: $e');
      return null;
    }
  }

  // 로그인 콜백 처리하여 토큰 발급
  Future<TokenModel?> _processLoginCallback(
      String platform, String code) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.loginCallback}/$platform?code=$code'),
      );

      if (response.statusCode == 307) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl == null) return null;

        final uri = Uri.parse(redirectUrl);
        final accessToken = uri.queryParameters['access_token'];
        final refreshToken = uri.queryParameters['refresh_token'];
        final isNewUser = uri.queryParameters['is_new_user'];

        if (accessToken != null && refreshToken != null) {
          return TokenModel(
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewUser: isNewUser == '1',
          );
        }
      }

      return null;
    } catch (e) {
      debugPrint('Process login callback error: $e');
      return null;
    }
  }

  // 토큰으로 사용자 정보 가져오기
  Future<UserModel?> getUserProfile() async {
    try {
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/user/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      }

      return null;
    } catch (e) {
      debugPrint('Get user profile error: $e');
      return null;
    }
  }

  // 토큰 갱신
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse(ApiConstants.tokenRefresh),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];

        if (newAccessToken != null) {
          await _tokenService.saveTokens(
            TokenModel(
              accessToken: newAccessToken,
              refreshToken: refreshToken,
            ),
          );
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Refresh token error: $e');
      return false;
    }
  }

  // 로그아웃
  Future<bool> logout() async {
    try {
      // 토큰 가져오기
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken == null) return false;

      // 각 SDK 로그아웃
      try {
        await UserApi.instance.logout(); // 카카오 로그아웃
      } catch (e) {
        debugPrint('Kakao logout error: $e');
      }

      try {
        await FlutterNaverLogin.logOut(); // 네이버 로그아웃
      } catch (e) {
        debugPrint('Naver logout error: $e');
      }

      try {
        await GoogleSignIn().signOut(); // 구글 로그아웃
      } catch (e) {
        debugPrint('Google logout error: $e');
      }

      // 백엔드 로그아웃 처리
      final response = await http.post(
        Uri.parse(ApiConstants.logout),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        await _tokenService.clearTokens();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Logout error: $e');
      return false;
    }
  }
}
