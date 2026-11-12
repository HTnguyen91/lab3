import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  // Số tiền nổi bật: 32 / 40, weight 700
  static const TextStyle prominentAmount = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 32.0,
    height: 40.0 / 32.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // Tiêu đề màn hình: 24 / 32, weight 700
  static const TextStyle screenTitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 24.0,
    height: 32.0 / 24.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Tiêu đề nhóm / Thẻ: 18 / 24, weight 600
  static const TextStyle groupTitle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18.0,
    height: 24.0 / 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Nội dung chính: 16 / 24, weight 400
  static const TextStyle body = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16.0,
    height: 24.0 / 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Nội dung nhấn mạnh: 16 / 24, weight 600
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16.0,
    height: 24.0 / 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Nút bấm & Nhãn ô nhập: 14 / 20, weight 600
  static const TextStyle buttonAndLabel = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Chú thích / Phụ trợ: 12 / 16, weight 500
  static const TextStyle caption = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12.0,
    height: 16.0 / 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Chú thích lỗi: 12 / 16, weight 500, color error
  static const TextStyle errorCaption = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12.0,
    height: 16.0 / 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );
}
