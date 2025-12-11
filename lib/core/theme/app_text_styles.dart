import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Title Styles - Using Fredoka instead of FredokaOne
  static TextStyle get gameTitle => GoogleFonts.fredoka(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 4,
      );

  static TextStyle get screenTitle => GoogleFonts.fredoka(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get sectionTitle => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  // Score Styles
  static TextStyle get scoreDisplay => GoogleFonts.bangers(
        fontSize: 48,
        color: AppColors.textPrimary,
        letterSpacing: 2,
      );

  static TextStyle get scoreLarge => GoogleFonts.bangers(
        fontSize: 32,
        color: AppColors.textPrimary,
      );

  static TextStyle get scorePopup => GoogleFonts.bangers(
        fontSize: 24,
        color: AppColors.perfect,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      );

  // Body Styles
  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 18,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 16,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 14,
        color: AppColors.textSecondary,
      );

  // Button Styles
  static TextStyle get buttonLarge => GoogleFonts.fredoka(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get buttonMedium => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  // HUD Styles
  static TextStyle get hudLabel => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textMuted,
      );

  static TextStyle get hudValue => GoogleFonts.bangers(
        fontSize: 32,
        color: AppColors.textPrimary,
      );

  static TextStyle get comboText => GoogleFonts.bangers(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );
}
