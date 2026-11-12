import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import '../viewmodels/budget_viewmodel.dart';

class BudgetCard extends StatelessWidget {
  final BudgetCategoryStatus status;
  final VoidCallback? onEdit;

  const BudgetCard({super.key, required this.status, this.onEdit});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;

    switch (status.status) {
      case BudgetStatus.exceeded:
        statusColor = AppColors.error;
        statusBgColor = AppColors.errorBackground;
        break;
      case BudgetStatus.reached:
        statusColor = AppColors.error;
        statusBgColor = AppColors.errorBackground;
        break;
      case BudgetStatus.warning:
        statusColor = AppColors.warning;
        statusBgColor = AppColors.warningBackground;
        break;
      case BudgetStatus.normal:
        statusColor = AppColors.success;
        statusBgColor = const Color(0xFFDCFCE7);
        break;
    }

    final clampedProgress = status.percentage.clamp(0.0, 1.0);

    return Container(
      padding: AppSpacing.cardPadding,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Name & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  status.budget.categoryName,
                  style: AppTextStyles.buttonAndLabel,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusTag),
                ),
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  status.statusLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),

          // Details: Đã chi, Hạn mức, Còn lại
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Đã chi', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatCurrency(status.spentAmount),
                      style: AppTextStyles.buttonAndLabel.copyWith(
                        color: status.status == BudgetStatus.normal
                            ? AppColors.textPrimary
                            : statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hạn mức', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatCurrency(status.budget.limitAmount),
                      style: AppTextStyles.buttonAndLabel,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Còn lại', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatCurrency(status.remainingAmount),
                      style: AppTextStyles.buttonAndLabel.copyWith(
                        color: status.status == BudgetStatus.normal
                            ? AppColors.textPrimary
                            : statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),

          if (onEdit != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Chỉnh sửa'),
              ),
            ),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: clampedProgress,
              minHeight: 10,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                status.status == BudgetStatus.normal
                    ? AppColors.primary
                    : statusColor,
              ),
            ),
          ),
          if (status.status == BudgetStatus.warning ||
              status.status == BudgetStatus.exceeded ||
              status.status == BudgetStatus.reached) ...[
            const SizedBox(height: 8),
            Text(
              'Xem lại chi tiêu của danh mục.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
