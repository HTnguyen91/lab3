import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/budget_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../widgets/budget_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/primary_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 's08_create_budget_screen.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetVm = context.watch<BudgetViewModel>();
    final txVm = context.watch<TransactionViewModel>();

    final statuses = budgetVm.calculateStatuses(txVm.allTransactions);
    final totalLimit = budgetVm.totalBudgetLimit;
    final totalRemaining = budgetVm.calculateTotalRemaining(
      txVm.allTransactions,
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tháng áp dụng', style: AppTextStyles.groupTitle),
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: budgetVm.selectedMonth,
                      items: _getAvailableMonths().map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(m, style: AppTextStyles.buttonAndLabel),
                        );
                      }).toList(),
                      onChanged: (newMonth) {
                        if (newMonth != null) {
                          budgetVm.setSelectedMonth(newMonth);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),

            // Total Budget Overview Card
            Container(
              width: double.infinity,
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng hạn mức tháng',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatCurrency(totalLimit),
                          style: AppTextStyles.groupTitle.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.divider),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ngân sách còn lại', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatCurrency(totalRemaining),
                          style: AppTextStyles.groupTitle.copyWith(
                            color: totalRemaining >= 0
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // Budgets List Header & Create Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hạn mức theo danh mục',
                  style: AppTextStyles.groupTitle,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm mới'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateBudgetScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),

            if (budgetVm.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (statuses.isEmpty)
              EmptyStateWidget(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Chưa thiết lập ngân sách',
                message: 'Hãy đặt hạn mức chi tiêu cho các danh mục trong tháng này để kiểm soát tài chính.',
                action: PrimaryButton(
                  label: 'Tạo ngân sách',
                  icon: Icons.add,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateBudgetScreen(),
                      ),
                    );
                  },
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: statuses.length,
                itemBuilder: (context, index) {
                  final status = statuses[index];
                  return BudgetCard(
                    status: status,
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateBudgetScreen(
                            initialCategoryName: status.budget.categoryName,
                            initialAmount: status.budget.limitAmount,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreateBudgetScreen()));
        },
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
