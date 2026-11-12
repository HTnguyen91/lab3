import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class OverviewCard extends StatelessWidget {
  final String title;
  final double amount;
  final String subtitle;
  final double subtitleAmount;
  final bool isHighlight;

  const OverviewCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.subtitleAmount,
    this.isHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.primaryTint : AppColors.surface,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: isHighlight
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.divider,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            Formatters.formatCurrency(amount),
            style: AppTextStyles.prominentAmount.copyWith(
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.s12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                Formatters.formatCurrency(subtitleAmount),
                style: AppTextStyles.buttonAndLabel.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
