import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class TransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionRow({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final iconColor = isIncome ? AppColors.income : AppColors.primary;
    final iconBgColor = isIncome
        ? const Color(0xFFDCFCE7)
        : AppColors.primaryTint;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 0.8),
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.restaurant,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),

            // Category & Note
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.categoryName,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.note.isNotEmpty
                        ? transaction.note
                        : Formatters.formatDate(transaction.date),
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              Formatters.formatTransactionAmount(
                transaction.amount,
                isIncome: isIncome,
              ),
              style: AppTextStyles.buttonAndLabel.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
