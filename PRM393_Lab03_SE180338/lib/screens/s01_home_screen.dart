import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/budget_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../widgets/overview_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/transaction_row.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 's02_add_transaction_screen.dart';
import 's04_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenHistory;

  const HomeScreen({super.key, required this.onOpenHistory});

  @override
  Widget build(BuildContext context) {
    final txVm = context.watch<TransactionViewModel>();
    final budgetVm = context.watch<BudgetViewModel>();
    final settingsVm = context.watch<SettingsViewModel>();

    final totalRemaining = budgetVm.calculateTotalRemaining(
      txVm.allTransactions,
    );
    final todaySpent = txVm.todayExpense;
    final recentTxs = txVm.recentTransactions;

    return RefreshIndicator(
      onRefresh: () async {
        await settingsVm.refreshRemoteConfig();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Remote Config Promo Banner
            if (settingsVm.enableBudgetTips &&
                settingsVm.promoBannerText.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        settingsVm.promoBannerText,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Top Overview Card: Ngân sách tháng còn lại & Chi tiêu hôm nay
            OverviewCard(
              title: 'Ngân sách tháng còn lại',
              amount: totalRemaining,
              subtitle: 'Tổng chi hôm nay',
              subtitleAmount: todaySpent,
              isHighlight: true,
            ),
            const SizedBox(height: AppSpacing.s16),

            // Main Action Button: Thêm khoản chi
            PrimaryButton(
              label: 'Thêm khoản chi',
              icon: Icons.add_circle_outline,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.s24),

            // Recent Transactions Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giao dịch gần đây',
                  style: AppTextStyles.groupTitle,
                ),
                TextButton(
                  onPressed: onOpenHistory,
                  child: Text(
                    'Xem tất cả',
                    style: AppTextStyles.buttonAndLabel.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),

            // Recent Transactions List
            if (txVm.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.s24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (recentTxs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.s24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.cardRadius,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 40,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    const Text(
                      'Chưa có giao dịch nào',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    const Text(
                      'Bấm "Thêm khoản chi" hoặc tạo dữ liệu mẫu Lab 2.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.dataset_outlined, size: 18),
                      label: const Text('Tạo dữ liệu mẫu Lab 2'),
                      onPressed: () => txVm.seedInitialData(),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTxs.length,
                itemBuilder: (context, index) {
                  final tx = recentTxs[index];
                  return TransactionRow(
                    transaction: tx,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              TransactionDetailScreen(transaction: tx),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
