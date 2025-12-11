import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4A90D9);
  static const Color primaryDark = Color(0xFF1a237e);
  static const Color primaryLight = Color(0xFF7BB3F0);

  // Accent Colors
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF9A6C);

  // Game Colors
  static const Color perfect = Color(0xFFFFD700); // Gold for perfect drops
  static const Color good = Color(0xFF5CB85C); // Green for good drops
  static const Color bad = Color(0xFFD9534F); // Red for bad drops

  // UI Colors
  static const Color background = Color(0xFF1a237e);
  static const Color backgroundLight = Color(0xFF4a148c);
  static const Color surface = Color(0xFF2C3E50);
  static const Color surfaceLight = Color(0xFF34495E);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF78909C);

  // Block Colors (for placeholder blocks)
  static const List<Color> blockColors = [
    Color(0xFF4A90D9), // Blue
    Color(0xFF5CB85C), // Green
    Color(0xFFF0AD4E), // Orange
    Color(0xFFD9534F), // Red
    Color(0xFF9B59B6), // Purple
    Color(0xFF1ABC9C), // Teal
    Color(0xFFE74C3C), // Crimson
    Color(0xFF3498DB), // Sky Blue
  ];

  // Gradient for backgrounds
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, backgroundLight],
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
