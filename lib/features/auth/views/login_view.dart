import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: size.height - 60, // SafeArea 영역을 고려한 높이
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: authViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 로고와 앱 설명
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 로고 이미지 (SVG 또는 Image 위젯으로 교체 가능)
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.waves,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // 앱 이름
                            Text(
                              'Buooy',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 앱 설명 텍스트
                            Text(
                              '해양 스포츠를 즐기는 사람들을 위한 커뮤니티',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // 소셜 로그인 버튼들
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              '소셜 계정으로 로그인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // 구글 로그인 버튼
                            _buildSocialLoginButton(
                              context: context,
                              text: 'Google로 로그인',
                              iconWidget: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    'G',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              backgroundColor: Colors.white,
                              textColor: Colors.black87,
                              borderColor: Colors.grey.shade300,
                              onPressed: () => _handleLogin(
                                  context: context,
                                  loginMethod: authViewModel.loginWithGoogle),
                            ),
                            const SizedBox(height: 16),

                            // 카카오 로그인 버튼
                            _buildSocialLoginButton(
                              context: context,
                              text: '카카오로 로그인',
                              iconWidget: Image.network(
                                'https://developers.kakao.com/static/images/dev/design/icon/kakaotalk/kakaotalk.png',
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.chat_bubble, size: 24),
                              ),
                              backgroundColor: const Color(0xFFFEE500),
                              textColor: Colors.black87,
                              onPressed: () => _handleLogin(
                                  context: context,
                                  loginMethod: authViewModel.loginWithKakao),
                            ),
                            const SizedBox(height: 16),

                            // 네이버 로그인 버튼
                            _buildSocialLoginButton(
                              context: context,
                              text: '네이버로 로그인',
                              iconWidget: Container(
                                width: 24,
                                height: 24,
                                color: const Color(0xFF03C75A),
                                child: const Center(
                                  child: Text(
                                    'N',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              backgroundColor: const Color(0xFF03C75A),
                              textColor: Colors.white,
                              onPressed: () => _handleLogin(
                                  context: context,
                                  loginMethod: authViewModel.loginWithNaver),
                            ),
                          ],
                        ),
                      ),

                      // 에러 메시지
                      if (authViewModel.error != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            '로그인 중 오류가 발생했습니다: ${authViewModel.error}',
                            style: TextStyle(color: theme.colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      // 개인정보 처리방침 등의 텍스트
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 30.0),
                        child: Text(
                          '로그인시 이용약관 및 개인정보 처리방침에 동의하게 됩니다.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required BuildContext context,
    required String text,
    required Widget iconWidget,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
    Color? borderColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: borderColor != null
              ? BorderSide(color: borderColor)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin(
      {required BuildContext context,
      required Future<bool> Function() loginMethod}) async {
    final result = await loginMethod();
    if (result && context.mounted) {
      // 로그인 성공 시 홈 화면으로 이동
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
