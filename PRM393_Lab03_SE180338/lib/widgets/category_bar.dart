import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'design_widgets.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class CategoryBar extends StatelessWidget {
  final String categoryName;
  final double amount;
  final double percentage;
  final VoidCallback onTap;

  const CategoryBar({
    super.key,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clampedRatio = (percentage / 100.0).clamp(0.0, 1.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryIcon(name: categoryName),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    categoryName,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${Formatters.formatCurrency(amount)}\n${percentage.toStringAsFixed(1)}%',
                  style: AppTextStyles.buttonAndLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: clampedRatio > 0 ? clampedRatio : 0.02,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
