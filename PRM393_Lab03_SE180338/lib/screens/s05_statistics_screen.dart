import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/statistics_viewmodel.dart';
import '../widgets/category_bar.dart';
import '../widgets/design_widgets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 's06_category_detail_screen.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final txVm = context.watch<TransactionViewModel>();
    final vm = context.watch<StatisticsViewModel>();
    final all = txVm.allTransactions;
    final income = vm.getTotalIncome(all),
        expense = vm.getTotalExpense(all),
        balance = vm.getBalance(all);
    final breakdown = vm.getCategoryBreakdown(all);
    final now = DateTime.now();
    final months = {
      ...List.generate(
        12,
        (i) => Formatters.formatMonth(DateTime(now.year, now.month - i)),
      ),
      vm.selectedMonth,
    }.toList();
    void step(int delta) {
      final parts = vm.selectedMonth.split('/');
      vm.setSelectedMonth(
        Formatters.formatMonth(
          DateTime(int.parse(parts[1]), int.parse(parts[0]) + delta),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DesignCard(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: () => step(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: vm.selectedMonth,
                    items: months
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              'Tháng $m',
                              style: AppTextStyles.buttonAndLabel,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (m) {
                      if (m != null) vm.setSelectedMonth(m);
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () => step(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DesignCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TỔNG QUAN TÀI CHÍNH', style: AppTextStyles.caption),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _summary(
                      '↓ Tổng chi',
                      '−${Formatters.formatCurrency(expense)}',
                      AppColors.expense,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summary(
                      '↑ Tổng thu',
                      '+${Formatters.formatCurrency(income)}',
                      AppColors.income,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DesignCard(
                color: AppColors.primaryTint,
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    const Text(
                      'Thặng dư tích lũy:',
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      Formatters.formatCurrency(balance),
                      style: AppTextStyles.buttonAndLabel.copyWith(
                        color: balance < 0
                            ? AppColors.expense
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chi tiêu theo danh mục',
                    style: AppTextStyles.groupTitle,
                  ),
                  Text(
                    'Sắp xếp theo giá trị giảm dần',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Text(
              '${breakdown.length} danh mục',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (txVm.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (breakdown.isEmpty)
          const DesignCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.bar_chart, size: 40, color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Chưa có khoản chi trong tháng này'),
                  SizedBox(height: 8),
                  Text(
                    'Chọn tháng khác để xem thống kê.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          )
        else
          ...breakdown.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DesignCard(
                padding: const EdgeInsets.all(12),
                child: CategoryBar(
                  categoryName: item.categoryName,
                  amount: item.totalAmount,
                  percentage: item.percentage,
                  onTap: () {
                    vm.selectCategoryForDetail(
                      item.categoryId,
                      item.categoryName,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryDetailScreen(
                          categoryId: item.categoryId,
                          categoryName: item.categoryName,
                          month: vm.selectedMonth,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _summary(String title, String amount, Color color) => DesignCard(
    color: AppColors.background,
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.caption),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            style: AppTextStyles.groupTitle.copyWith(color: color),
          ),
        ),
      ],
    ),
  );
}
