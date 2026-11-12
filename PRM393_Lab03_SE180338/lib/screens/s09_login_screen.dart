import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo Icon
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // App Title & Tagline
                const Text(
                  'Expense Tracker',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Quản lý chi tiêu cá nhân thông minh & trực quan',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s32),

                // Card with Features & Instructions
                Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.cardRadius,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.flash_on_outlined,
                        title: 'Ghi chép nhanh chóng',
                        subtitle: 'Lưu khoản chi 45.000 VNĐ chỉ trong 15 giây',
                      ),
                      const Divider(height: 20, color: AppColors.divider),
                      _buildFeatureItem(
                        icon: Icons.pie_chart_outline,
                        title: 'Phân tích danh mục',
                        subtitle:
                            'Biểu đồ trực quan, theo dõi khoản chi lớn nhất',
                      ),
                      const Divider(height: 20, color: AppColors.divider),
                      _buildFeatureItem(
                        icon: Icons.notifications_active_outlined,
                        title: 'Cảnh báo ngân sách',
                        subtitle:
                            'Hạn mức chi tiết, cảnh báo khi vượt 80% / 100%',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Error Message if any
                if (authVm.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.errorBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      authVm.errorMessage!,
                      style: AppTextStyles.errorCaption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                // Google Sign-In Button
                SizedBox(
                  height: AppSpacing.inputHeight,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.buttonRadius,
                        side: const BorderSide(
                          color: AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onPressed: authVm.isLoading
                        ? null
                        : () async {
                            await authVm.signInWithGoogle();
                          },
                    child: authVm.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                width: 22,
                                height: 22,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.login,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s12),
                              const Text(
                                'Đăng nhập với Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                // Academic Information Note
                Text(
                  'PRM393 — Lab 3 · Nhóm GR5\nHọc viên: Hoàng Thanh Nguyên (SE180338)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}
