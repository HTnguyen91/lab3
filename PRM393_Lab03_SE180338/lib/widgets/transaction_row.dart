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
    final initialChar = transaction.categoryName.isNotEmpty
        ? transaction.categoryName.characters.first.toUpperCase()
        : 'G';
    final primaryTitle = transaction.note.isNotEmpty
        ? transaction.note
        : transaction.categoryName;
    final secondarySub =
        '${transaction.categoryName} · ${Formatters.formatDate(transaction.date)}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 0.8),
        ),
        child: Row(
          children: [
            // Category Avatar (Figma 40x40 rounded-20 with initial letter)
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                initialChar,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),

            // Title & Category · Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    primaryTitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    secondarySub,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
