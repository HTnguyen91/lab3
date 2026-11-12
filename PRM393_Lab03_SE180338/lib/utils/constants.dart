import 'package:flutter/material.dart';

import '../models/category_model.dart';

class AppConstants {
  static const String appName = 'Expense Tracker';
  static const String studentId = 'SE180338';
  static const String studentName = 'Hoàng Thanh Nguyên';

  // Remote Config keys
  static const String rcKeySpendingThreshold =
      'daily_spending_warning_threshold';
  static const String rcKeyPromoBanner = 'promo_banner_text';
  static const String rcKeyEnableTips = 'enable_budget_tips';

  // Cloudinary Config (Unsigned upload preset for PDF export)
  static const String cloudinaryCloudName = 'demo';
  static const String cloudinaryUploadPreset = 'prm393_preset';

  // Default Categories
  static final List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'cat_food',
      name: 'Ăn uống',
      iconCodePoint: Icons.restaurant.codePoint,
      isIncome: false,
      colorValue: 0xFFEA580C,
    ),
    CategoryModel(
      id: 'cat_transport',
      name: 'Đi lại',
      iconCodePoint: Icons.directions_bus.codePoint,
      isIncome: false,
      colorValue: 0xFF0284C7,
    ),
    CategoryModel(
      id: 'cat_shopping',
      name: 'Mua sắm',
      iconCodePoint: Icons.shopping_bag.codePoint,
      isIncome: false,
      colorValue: 0xFF9333EA,
    ),
    CategoryModel(
      id: 'cat_bills',
      name: 'Hóa đơn & Tiện ích',
      iconCodePoint: Icons.receipt_long.codePoint,
      isIncome: false,
      colorValue: 0xFF0D9488,
    ),
    CategoryModel(
      id: 'cat_entertainment',
      name: 'Giải trí',
      iconCodePoint: Icons.movie.codePoint,
      isIncome: false,
      colorValue: 0xFFE11D48,
    ),
    CategoryModel(
      id: 'cat_education',
      name: 'Học tập & Sách',
      iconCodePoint: Icons.school.codePoint,
      isIncome: false,
      colorValue: 0xFF4F46E5,
    ),
    CategoryModel(
      id: 'cat_salary',
      name: 'Tiền lương & Thưởng',
      iconCodePoint: Icons.account_balance_wallet.codePoint,
      isIncome: true,
      colorValue: 0xFF16A34A,
    ),
    CategoryModel(
      id: 'cat_other',
      name: 'Khác',
      iconCodePoint: Icons.category.codePoint,
      isIncome: false,
      colorValue: 0xFF64748B,
    ),
  ];
}
