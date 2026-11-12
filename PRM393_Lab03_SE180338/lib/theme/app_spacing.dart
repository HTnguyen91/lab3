import 'package:flutter/material.dart';

class AppSpacing {
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);

  // Border Radii
  static const double radiusButton = 12.0;
  static const double radiusInput = 12.0;
  static const double radiusCard = 16.0;
  static const double radiusTag = 8.0;

  static final BorderRadius buttonRadius = BorderRadius.circular(radiusButton);
  static final BorderRadius inputRadius = BorderRadius.circular(radiusInput);
  static final BorderRadius cardRadius = BorderRadius.circular(radiusCard);

  // Minimum Touch Target
  static const double minTouchTarget = 48.0;
  static const double inputHeight = 52.0;
}
