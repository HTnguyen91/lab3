import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/statistics_viewmodel.dart';
import '../widgets/category_bar.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 's06_category_detail_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final txVm = context.watch<TransactionViewModel>();
    final statsVm = context.watch<StatisticsViewModel>();

    final allTxs = txVm.allTransactions;
    final totalIncome = statsVm.getTotalIncome(allTxs);
    final totalExpense = statsVm.getTotalExpense(allTxs);
    final balance = statsVm.getBalance(allTxs);
    final breakdown = statsVm.getCategoryBreakdown(allTxs);

    return Scaffold(
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Filter Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kỳ thống kê', style: AppTextStyles.groupTitle),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: statsVm.selectedMonth,
                          items: _getAvailableMonths().map((m) {
                            return DropdownMenuItem(
                              value: m,
                              child: Text(
                                m,
                                style: AppTextStyles.buttonAndLabel,
                              ),
                            );
                          }).toList(),
                          onChanged: (newMonth) {
                            if (newMonth != null) {
                              statsVm.setSelectedMonth(newMonth);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),

            // Summary 3-Box Header (Tổng thu, Tổng chi, Số dư)
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng thu', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatCurrency(totalIncome),
                          style: AppTextStyles.buttonAndLabel.copyWith(
                            color: AppColors.income,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 36, color: AppColors.divider),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng chi', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatCurrency(totalExpense),
                          style: AppTextStyles.buttonAndLabel.copyWith(
                            color: AppColors.expense,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 36, color: AppColors.divider),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Số dư', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatCurrency(balance),
                          style: AppTextStyles.buttonAndLabel.copyWith(
                            color: balance >= 0
                                ? AppColors.primary
                                : AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // Category Breakdown Section
            const Text(
              'Chi tiêu theo danh mục',
              style: AppTextStyles.groupTitle,
            ),
            const SizedBox(height: 4),
            Text(
              'Chạm một danh mục để xem chi tiết các khoản chi',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.s12),

            if (breakdown.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.cardRadius,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.bar_chart_outlined,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    const Text(
                      'Chưa có khoản chi trong tháng này.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Chọn tháng khác để xem thống kê.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.cardRadius,
                  border: Border.all(color: AppColors.divider),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: breakdown.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 16, color: AppColors.divider),
                  itemBuilder: (context, index) {
                    final item = breakdown[index];
                    return CategoryBar(
                      categoryName: item.categoryName,
                      amount: item.totalAmount,
                      percentage: item.percentage,
                      onTap: () {
                        statsVm.selectCategoryForDetail(
                          item.categoryId,
                          item.categoryName,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CategoryDetailScreen(
                              categoryId: item.categoryId,
                              categoryName: item.categoryName,
                              month: statsVm.selectedMonth,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _getAvailableMonths() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final date = DateTime(now.year, now.month - i, 1);
      return Formatters.formatMonth(date);
    });
  }
}
