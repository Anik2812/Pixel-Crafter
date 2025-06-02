import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:replica/constants/colors.dart';

class AppTextStyles {
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
  );
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
  );
  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
  );
  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 18,
    color: AppColors.textPrimaryLight,
  );
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16,
    color: AppColors.textPrimaryLight,
  );
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textPrimaryLight,
  );

  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 16,
    color: AppColors.textSecondaryLight,
  );
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textSecondaryLight,
  );
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 12,
    color: AppColors.textSecondaryLight,
  );

  static TextStyle displayLargeDark =
      displayLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle headlineLargeDark =
      headlineLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle headlineMediumDark =
      headlineMedium.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle headlineSmallDark =
      headlineSmall.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle bodyLargeDark =
      bodyLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle bodyMediumDark =
      bodyMedium.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle bodySmallDark =
      bodySmall.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle labelLargeDark =
      labelLarge.copyWith(color: AppColors.textSecondaryDark);
  static TextStyle labelMediumDark =
      labelMedium.copyWith(color: AppColors.textSecondaryDark);
  static TextStyle labelSmallDark =
      labelSmall.copyWith(color: AppColors.textSecondaryDark);

  static TextStyle canvasToolLabel = GoogleFonts.inter(
    fontSize: 12,
    color: AppColors.textPrimaryDark,
  );
}
