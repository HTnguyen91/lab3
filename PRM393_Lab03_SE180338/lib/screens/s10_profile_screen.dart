import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/statistics_viewmodel.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final settingsVm = context.watch<SettingsViewModel>();
    final txVm = context.watch<TransactionViewModel>();
    final statsVm = context.watch<StatisticsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ & Cài đặt Lab 3'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryTint,
                    backgroundImage: authVm.photoUrl != null
                        ? NetworkImage(authVm.photoUrl!)
                        : null,
                    child: authVm.photoUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 36,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authVm.displayName,
                          style: AppTextStyles.groupTitle,
                        ),
                        const SizedBox(height: 2),
                        Text(authVm.email, style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'MSSV: SE180338',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // Status message feedback
            if (settingsVm.statusMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  settingsVm.statusMessage!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            // SECTION 1: PDF REPORT EXPORT & STORAGE (Lab 3 Sec 6.4)
            _buildSectionHeader(
              Icons.picture_as_pdf_outlined,
              'Xuất Báo Cáo PDF & Lưu Trữ (Mục 6.4)',
            ),
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sinh tài liệu PDF định dạng bảng cho tháng hiện tại, tải lên Cloudinary / Storage và lưu liên kết vào Cloud Firestore.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  PrimaryButton(
                    label: 'Xuất & Tải lên Báo cáo PDF',
                    isLoading: settingsVm.isExporting,
                    icon: Icons.upload_file,
                    onPressed: () async {
                      final all = txVm.allTransactions;
                      final month = statsVm.selectedMonth;
                      final inc = statsVm.getTotalIncome(all);
                      final exp = statsVm.getTotalExpense(all);
                      final monthTxs = statsVm.getMonthTransactions(all);

                      await settingsVm.exportMonthlyReport(
                        userName: authVm.displayName,
                        month: month,
                        totalIncome: inc,
                        totalExpense: exp,
                        transactions: monthTxs,
                      );
                    },
                  ),
                  if (settingsVm.lastExportedUrl != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đường dẫn tệp đã lưu trên Firestore:',
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 2),
                          SelectableText(
                            settingsVm.lastExportedUrl!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // SECTION 2: REMOTE CONFIG DEMO (Lab 3 Sec 6.6)
            _buildSectionHeader(
              Icons.settings_remote_outlined,
              'Firebase Remote Config (Mục 6.6)',
            ),
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfigRow(
                    'Hạn mức cảnh báo giao dịch lớn:',
                    Formatters.formatCurrency(
                      settingsVm.spendingWarningThreshold,
                    ),
                  ),
                  const Divider(height: 16, color: AppColors.divider),
                  _buildConfigRow(
                    'Banner khuyến mãi / Mẹo:',
                    settingsVm.promoBannerText,
                  ),
                  const Divider(height: 16, color: AppColors.divider),
                  _buildConfigRow(
                    'Bật mẹo tài chính:',
                    settingsVm.enableBudgetTips ? 'Bật (true)' : 'Tắt (false)',
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    label: 'Làm mới Remote Config từ máy chủ',
                    icon: Icons.sync,
                    onPressed: () => settingsVm.refreshRemoteConfig(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // SECTION 3: CRASHLYTICS DEMO (Lab 3 Sec 6.7)
            _buildSectionHeader(
              Icons.bug_report_outlined,
              'Firebase Crashlytics (Mục 6.7)',
            ),
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  SecondaryButton(
                    label: 'Ghi Exception có xử lý (Handled)',
                    icon: Icons.warning_amber_rounded,
                    onPressed: () => settingsVm.recordHandledException(),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: AppSpacing.inputHeight,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.buttonRadius,
                        ),
                      ),
                      icon: const Icon(Icons.flash_off, color: AppColors.error),
                      label: const Text(
                        'Thử nghiệm Crash ứng dụng (Force Crash)',
                      ),
                      onPressed: () => settingsVm.triggerForceCrash(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // SECTION 4: NOTIFICATION CENTER (Lab 3 Sec 6.5)
            _buildSectionHeader(
              Icons.notifications_outlined,
              'Notification Center (Mục 6.5)',
            ),
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.divider),
              ),
              child: settingsVm.notifications.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'Chưa nhận thông báo nào từ Firebase FCM.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: settingsVm.notifications.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 16, color: AppColors.divider),
                      itemBuilder: (context, index) {
                        final notif = settingsVm.notifications[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryTint,
                            child: Icon(
                              Icons.notifications_active,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            notif.title,
                            style: AppTextStyles.bodyMedium,
                          ),
                          subtitle: Text(
                            notif.body,
                            style: AppTextStyles.caption,
                          ),
                          trailing: Text(
                            Formatters.formatDate(notif.receivedAt),
                            style: AppTextStyles.caption,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppSpacing.s32),

            // Sign Out Button
            SizedBox(
              height: AppSpacing.inputHeight,
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorBackground,
                  foregroundColor: AppColors.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.buttonRadius,
                    side: const BorderSide(color: AppColors.error, width: 1),
                  ),
                ),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Đăng xuất tài khoản',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await authVm.signOut();
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.groupTitle.copyWith(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
