import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../theme/app_colors.dart';

const _ink = Color(0xFF152547);
const _muted = Color(0xFF65718A);
const _mint = Color(0xFFBEF6DC);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            final hero = _WelcomePanel(wide: wide);
            final form = _SignInPanel(auth: auth);
            return Center(
              child: SingleChildScrollView(
                padding: wide ? const EdgeInsets.all(40) : EdgeInsets.zero,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: wide ? 1080 : 480),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(wide ? 32 : 0),
                    child: ColoredBox(
                      color: Colors.white,
                      child: wide
                          ? IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: hero),
                                  Expanded(child: Center(child: form)),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [hero, form],
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  final bool wide;
  const _WelcomePanel({required this.wide});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF14254E), Color(0xFF254BB0)],
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(wide ? 0 : 32),
        bottomRight: Radius.circular(wide ? 0 : 32),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.all(wide ? 40 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: _mint,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Expense Tracker',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -.3,
                  ),
                ),
              ),
              const Icon(Icons.auto_awesome_rounded, size: 18, color: _mint),
            ],
          ),
          SizedBox(height: wide ? 48 : 24),
          Text(
            'Chi tiêu gọn gàng.\nCuộc sống nhẹ nhàng.',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: wide ? 35 : 28,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: -.9,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Một thói quen nhỏ,\nmột tương lai chủ động hơn.',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              height: 1.5,
              color: Color(0xFFCAD6F5),
            ),
          ),
          SizedBox(height: wide ? 36 : 22),
          const ExcludeSemantics(child: _WalletIllustration()),
        ],
      ),
    ),
  );
}

class _WalletIllustration extends StatelessWidget {
  const _WalletIllustration();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 102,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 18,
          right: 12,
          top: 12,
          bottom: -5,
          child: Transform.rotate(
            angle: -.035,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 28,
          top: 0,
          bottom: 4,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.savings_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Mỗi ngày một chút',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          value: .68,
                          minHeight: 6,
                          color: AppColors.primary,
                          backgroundColor: Color(0xFFEDF2FF),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          for (var i = 0; i < 4; i++)
                            Expanded(
                              child: Container(
                                height: 4,
                                margin: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  color: i < 3
                                      ? const Color(0xFFCAF1DD)
                                      : const Color(0xFFEDF2FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 28,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _mint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF294FA9), width: 4),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Color(0xFF15664D),
              size: 23,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SignInPanel extends StatelessWidget {
  final AuthViewModel auth;
  const _SignInPanel({required this.auth});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BẮT ĐẦU TỪ HÔM NAY',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Chào bạn, người giữ ví!',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            height: 1.25,
            letterSpacing: -.6,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Theo dõi thu chi, hiểu thói quen và dành dụm cho những điều bạn yêu thích.',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 13,
            height: 1.6,
            color: _muted,
          ),
        ),
        const SizedBox(height: 22),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Benefit(
                icon: Icons.bolt_rounded,
                label: 'Ghi chép nhanh',
                color: Color(0xFFA66B15),
                background: Color(0xFFFFF4DB),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _Benefit(
                icon: Icons.donut_small_rounded,
                label: 'Hiểu chi tiêu',
                color: AppColors.primary,
                background: Color(0xFFEDF2FF),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _Benefit(
                icon: Icons.flag_outlined,
                label: 'Giữ ngân sách',
                color: Color(0xFF20745A),
                background: Color(0xFFE7F6EF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (auth.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: auth.isLoading ? null : () => auth.signInWithGoogle(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE5EBF8),
              disabledForegroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (auth.isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  const Icon(Icons.login_rounded, size: 20),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    auth.isLoading ? 'Đang đăng nhập…' : 'Tiếp tục với Google',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'Dùng tài khoản Google để bắt đầu.',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11,
              height: 1.5,
              color: _muted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 22),
        const Center(
          child: Text(
            'EXPENSE TRACKER  /  PRM393',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 9,
              letterSpacing: 1.6,
              color: Color(0xFF8A94A8),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, background;
  const _Benefit({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 10,
          height: 1.4,
          color: _muted,
        ),
      ),
    ],
  );
}
