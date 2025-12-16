import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Sky theme
  static const Color primary = Color(0xFF5E9FFF);
  static const Color primaryDark = Color(0xFF3D7DD8);
  static const Color primaryLight = Color(0xFF8BBFFF);

  // Accent Colors - Vibrant orange/coral
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF8E8E);
  static const Color accentDark = Color(0xFFE55555);

  // Secondary accent - Teal/Cyan
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryLight = Color(0xFF7EDCD6);

  // Game Colors
  static const Color perfect = Color(0xFFFFD93D); // Bright gold for perfect drops
  static const Color good = Color(0xFF6BCB77); // Fresh green for good drops
  static const Color bad = Color(0xFFFF6B6B); // Coral red for bad drops

  // UI Colors - Clean and modern
  static const Color background = Color(0xFF1A1A2E);
  static const Color backgroundLight = Color(0xFF16213E);
  static const Color surface = Color(0xFF0F0F23);
  static const Color surfaceLight = Color(0xFF1A1A35);

  // Card/Dialog backgrounds
  static const Color cardBackground = Color(0xFFF8F9FA);
  static const Color cardBackgroundDark = Color(0xFF2D2D44);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB8C5D6);
  static const Color textMuted = Color(0xFF6C7A89);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textDarkSecondary = Color(0xFF636E72);

  // Block Colors (for placeholder blocks)
  static const List<Color> blockColors = [
    Color(0xFF5E9FFF), // Sky Blue
    Color(0xFF6BCB77), // Green
    Color(0xFFFFD93D), // Gold
    Color(0xFFFF6B6B), // Coral
    Color(0xFFA66CFF), // Purple
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFF9F43), // Orange
    Color(0xFFFF6B9D), // Pink
  ];

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF667EEA),
      Color(0xFF764BA2),
    ],
  );

  static const LinearGradient homeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B73FF),
      Color(0xFF9F7AEA),
      Color(0xFFE879F9),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFF8E53),
    ],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4ECDC4),
      Color(0xFF6BCB77),
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD93D),
      Color(0xFFFF9F43),
    ],
  );

  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF87CEEB),
      Color(0xFF98D8C8),
    ],
  );
}
