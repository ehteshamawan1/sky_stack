import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available game themes
class GameTheme {
  final String id;
  final String name;
  final String description;
  final Color previewColor;

  const GameTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.previewColor,
  });

  static const List<GameTheme> all = [
    GameTheme(
      id: 'city',
      name: 'City',
      description: 'Modern urban skyline',
      previewColor: Color(0xFF5E9FFF),
    ),
    GameTheme(
      id: 'desert',
      name: 'Desert',
      description: 'Ancient pyramids & dunes',
      previewColor: Color(0xFFFF9F43),
    ),
    GameTheme(
      id: 'underwater',
      name: 'Underwater',
      description: 'Deep ocean depths',
      previewColor: Color(0xFF4ECDC4),
    ),
    GameTheme(
      id: 'space',
      name: 'Space',
      description: 'Among the stars',
      previewColor: Color(0xFF9B59B6),
    ),
    GameTheme(
      id: 'fantasy',
      name: 'Fantasy',
      description: 'Magical kingdom',
      previewColor: Color(0xFFE879F9),
    ),
  ];
}

/// Provider for the current game theme
class GameThemeNotifier extends StateNotifier<String> {
  static const String _key = 'selected_theme';

  GameThemeNotifier() : super('city') {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_key);
    if (savedTheme != null) {
      state = savedTheme;
    }
  }

  Future<void> setTheme(String themeId) async {
    state = themeId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, themeId);
  }
}

final gameThemeProvider = StateNotifierProvider<GameThemeNotifier, String>((ref) {
  return GameThemeNotifier();
});
