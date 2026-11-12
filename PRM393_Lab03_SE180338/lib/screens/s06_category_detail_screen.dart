import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_viewmodel.dart';
import '../widgets/design_widgets.dart';
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
    final transactions = txVm.allTransactions
        .where(
          (tx) =>
              tx.isExpense &&
              tx.categoryId == categoryId &&
              Formatters.formatMonth(tx.date) == month,
        )
        .toList();
    final totalSpent = transactions.fold(0.0, (s, tx) => s + tx.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiêu Theo Danh Mục'),
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
                color: AppColors.surface,
                borderRadius: AppSpacing.cardRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CategoryIcon(name: categoryName),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          categoryName,
                          style: AppTextStyles.groupTitle,
                        ),
                      ),
                      Text(
                        '${transactions.length} khoản',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                      color: AppColors.primary,
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
            DesignCard(
              color: AppColors.warningBackground,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.warning),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryId == 'cat_food'
                              ? 'Mẹo ăn uống tiết kiệm'
                              : 'Mẹo quản lý chi tiêu',
                          style: AppTextStyles.buttonAndLabel,
                        ),
                        SizedBox(height: 4),
                        Text(
                          categoryId == 'cat_food'
                              ? 'Tự nấu ăn tại phòng trọ giúp giảm chi phí so với việc dùng bữa ngoài cổng trường.'
                              : 'Theo dõi từng khoản chi và đặt hạn mức phù hợp để kiểm soát ngân sách tháng.',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('LỊCH SỬ CHI TIẾT', style: AppTextStyles.buttonAndLabel),
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
