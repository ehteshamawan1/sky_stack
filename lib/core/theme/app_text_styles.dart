import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Title Styles - Using Bungee for impactful game titles
  static TextStyle get gameTitle => GoogleFonts.bungee(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 2,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      );

  static TextStyle get screenTitle => GoogleFonts.bungee(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get sectionTitle => GoogleFonts.righteous(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  // Score Styles - Using Orbitron for futuristic game feel
  static TextStyle get scoreDisplay => GoogleFonts.orbitron(
        fontSize: 44,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 2,
      );

  static TextStyle get scoreLarge => GoogleFonts.orbitron(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get scorePopup => GoogleFonts.bungee(
        fontSize: 22,
        color: AppColors.perfect,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      );

  // Body Styles - Using Quicksand for clean readability
  static TextStyle get bodyLarge => GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // Button Styles
  static TextStyle get buttonLarge => GoogleFonts.bungee(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get buttonMedium => GoogleFonts.righteous(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  // HUD Styles
  static TextStyle get hudLabel => GoogleFonts.quicksand(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textMuted,
        letterSpacing: 1,
      );

  static TextStyle get hudValue => GoogleFonts.orbitron(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get comboText => GoogleFonts.bungee(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );
}
