import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/statistics_viewmodel.dart';
import '../widgets/transaction_row.dart';
import '../widgets/empty_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import 's04_detail_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final String month;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final txVm = context.watch<TransactionViewModel>();
    final statsVm = context.watch<StatisticsViewModel>();

    final transactions = statsVm.getSelectedCategoryTransactions(
      txVm.allTransactions,
    );
    final totalSpent = transactions.fold(0.0, (s, tx) => s + tx.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
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
            // Month & Total Expense Banner
            Container(
              width: double.infinity,
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng chi tháng $month',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.formatCurrency(totalSpent),
                    style: AppTextStyles.prominentAmount.copyWith(
                      color: AppColors.expense,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Số giao dịch: ${transactions.length}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // Transactions Header
            const Text('Danh sách khoản chi', style: AppTextStyles.groupTitle),
            const SizedBox(height: AppSpacing.s12),

            if (transactions.isEmpty)
              const EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'Không có giao dịch',
                message:
                    'Chưa có khoản chi nào thuộc danh mục này trong tháng.',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
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
