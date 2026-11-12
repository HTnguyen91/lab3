import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryTint,
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.primary,
        onSecondary: AppColors.onPrimary,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.screenTitle,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardRadius,
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
          textStyle: AppTextStyles.buttonAndLabel.copyWith(color: Colors.white),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
          side: const BorderSide(color: AppColors.divider, width: 1.5),
          textStyle: AppTextStyles.buttonAndLabel.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.inputRadius,
          borderSide: const BorderSide(color: AppColors.controlBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputRadius,
          borderSide: const BorderSide(color: AppColors.controlBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
        errorStyle: AppTextStyles.errorCaption,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
