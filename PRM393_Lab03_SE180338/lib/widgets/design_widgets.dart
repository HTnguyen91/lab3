import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/constants.dart';

class DesignCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  const DesignCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(16),
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}

class CategoryIcon extends StatelessWidget {
  final String name;
  final bool selected;
  final double size;
  const CategoryIcon({
    super.key,
    required this.name,
    this.selected = false,
    this.size = 42,
  });
  @override
  Widget build(BuildContext context) {
    final category = AppConstants.defaultCategories
        .where((c) => c.name == name)
        .firstOrNull;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.primaryTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        category?.icon ?? Icons.category_outlined,
        size: size * .48,
        color: selected ? Colors.white : AppColors.primary,
      ),
    );
  }
}

Future<bool> confirmDiscard(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bỏ thay đổi?'),
        content: const Text(
          'Dữ liệu đang nhập chưa được lưu. Bạn có muốn hủy không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tiếp tục nhập'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy thay đổi'),
          ),
        ],
      ),
    ) ??
    false;
