import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/viewmodels/auth_viewmodel.dart';
import '../features/auth/views/login_view.dart';
import '../features/home/views/home_view.dart';

class BuooyApp extends StatelessWidget {
  const BuooyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buooy',
      theme: AppTheme.lightTheme,
      home: const _AuthWrapper(),
      routes: {
        '/login': (context) => const LoginView(),
        '/home': (context) => const HomeView(),
      },
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // 로딩 중이면 로딩 인디케이터 표시
    if (authViewModel.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 인증되지 않았다면 로그인 화면 보여주기
    if (!authViewModel.isAuthenticated) {
      return const LoginView();
    }

    // 인증되었다면 홈 화면 보여주기
    return const HomeView();
  }
}
