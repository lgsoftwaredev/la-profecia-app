import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Inter';

  static const TextTheme textTheme = TextTheme(
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 21,
      fontWeight: FontWeight.w600,
      height: 1.18,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 17 / 1.05,
      fontWeight: FontWeight.w400,
      height: 1.33,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 21,
      fontWeight: FontWeight.w700,
      height: 1.05,
      color: AppColors.textMuted,
    ),
  );
}
