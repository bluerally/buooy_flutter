import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/home/views/home_view.dart';

class BuooyApp extends StatelessWidget {
  const BuooyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buooy',
      theme: AppTheme.lightTheme,
      home: const HomeView(),
    );
  }
}
