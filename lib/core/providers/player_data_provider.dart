import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/player_data.dart';
import '../services/hive_service.dart';

/// Notifier for managing player data
class PlayerDataNotifier extends StateNotifier<PlayerData?> {
  final HiveService _hiveService = HiveService();

  PlayerDataNotifier() : super(null) {
    _loadPlayerData();
  }

  /// Load player data from Hive
  Future<void> _loadPlayerData() async {
    try {
      final playerData = await _hiveService.getOrCreatePlayerData();
      state = playerData;
    } catch (e) {
      // Error loading player data - state remains null
    }
  }

  /// Save current player data
  Future<void> _save() async {
    if (state == null) return;
    await _hiveService.savePlayerData(state!);
  }

  /// Get high score
  int get highScore => state?.stats.highScore ?? 0;

  /// Update high score if new score is higher
  /// Returns true if it's a new high score
  Future<bool> updateHighScore(int newScore) async {
    if (state == null) return false;

    final isNewHigh = state!.stats.updateHighScore(newScore);
    if (isNewHigh) {
      await _save();
    }
    return isNewHigh;
  }

  /// Record a completed game session
  Future<void> recordGameSession({
    required int score,
    required int blocksPlaced,
    required int population,
    required int perfectDrops,
    required int maxCombo,
    required int towerHeight,
    required int playTimeSeconds,
    int coinsEarned = 0,
  }) async {
    if (state == null) return;

    state!.stats.recordGameSession(
      score: score,
      blocksPlaced: blocksPlaced,
      population: population,
      perfectDrops: perfectDrops,
      maxCombo: maxCombo,
      towerHeight: towerHeight,
      playTimeSeconds: playTimeSeconds,
    );

    if (coinsEarned > 0) {
      state!.stats.addCoins(coinsEarned);
    }

    await _save();
    // Trigger state update with new reference
    state = state!.copy();
  }

  /// Add coins
  Future<void> addCoins(int amount, {double multiplier = 1.0}) async {
    if (state == null) return;

    state!.stats.addCoins(amount, multiplier: multiplier);
    await _save();
    state = state!.copy();
  }

  /// Spend coins
  /// Returns true if successful
  Future<bool> spendCoins(int amount) async {
    if (state == null) return false;

    final success = state!.stats.spendCoins(amount);
    if (success) {
      await _save();
      state = state!.copy();
    }
    return success;
  }

  /// Get current coins
  int get coins => state?.stats.currentCoins ?? 0;

  /// Update settings
  Future<void> updateSettings({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    bool? notificationsEnabled,
    String? selectedTheme,
    double? masterVolume,
    double? sfxVolume,
    double? musicVolume,
  }) async {
    if (state == null) return;

    final settings = state!.settings;
    if (soundEnabled != null) settings.soundEnabled = soundEnabled;
    if (musicEnabled != null) settings.musicEnabled = musicEnabled;
    if (vibrationEnabled != null) settings.vibrationEnabled = vibrationEnabled;
    if (notificationsEnabled != null) settings.notificationsEnabled = notificationsEnabled;
    if (selectedTheme != null) settings.selectedTheme = selectedTheme;
    if (masterVolume != null) settings.masterVolume = masterVolume;
    if (sfxVolume != null) settings.sfxVolume = sfxVolume;
    if (musicVolume != null) settings.musicVolume = musicVolume;

    await _save();
    state = state!.copy();
  }

  /// Get selected theme
  String get selectedTheme => state?.settings.selectedTheme ?? 'city';

  /// Set selected theme
  Future<void> setTheme(String themeId) async {
    await updateSettings(selectedTheme: themeId);
  }

  /// Check if a theme is unlocked
  bool isThemeUnlocked(String themeId) {
    return state?.unlocks.isThemeUnlocked(themeId) ?? false;
  }

  /// Unlock a theme
  Future<bool> unlockTheme(String themeId) async {
    if (state == null) return false;

    final unlocked = state!.unlocks.unlockTheme(themeId);
    if (unlocked) {
      await _save();
      state = state!.copy();
    }
    return unlocked;
  }

  /// Update achievement progress
  Future<void> updateAchievementProgress(String id, int progress, int target) async {
    if (state == null) return;

    var achievement = state!.getAchievement(id);
    if (achievement == null) {
      achievement = AchievementRecord(
        id: id,
        targetProgress: target,
      );
      state!.achievements.add(achievement);
    }

    achievement.updateProgress(progress);
    await _save();
    state = state!.copy();
  }

  /// Claim achievement reward
  Future<int> claimAchievementReward(String id, int rewardCoins) async {
    if (state == null) return 0;

    final achievement = state!.getAchievement(id);
    if (achievement != null && achievement.isUnlocked && !achievement.isClaimed) {
      achievement.claim();
      state!.stats.addCoins(rewardCoins);
      await _save();
      state = state!.copy();
      return rewardCoins;
    }
    return 0;
  }

  /// Get player stats
  PlayerStats? get stats => state?.stats;

  /// Get player settings
  PlayerSettings? get settings => state?.settings;

  /// Get player unlocks
  PlayerUnlocks? get unlocks => state?.unlocks;

  /// Update display name
  Future<void> updateDisplayName(String name) async {
    if (state == null) return;

    state!.displayName = name;
    await _save();
    state = state!.copy();
  }

  /// Refresh from storage
  Future<void> refresh() async {
    await _loadPlayerData();
  }

  /// Reset all player data (for debugging)
  Future<void> resetAll() async {
    await _hiveService.clearAllData();
    await _loadPlayerData();
  }
}

/// Provider for player data
final playerDataProvider =
    StateNotifierProvider<PlayerDataNotifier, PlayerData?>((ref) {
  return PlayerDataNotifier();
});

/// Provider for high score
final highScoreProvider = Provider<int>((ref) {
  final playerData = ref.watch(playerDataProvider);
  return playerData?.stats.highScore ?? 0;
});

/// Provider for current coins
final coinsProvider = Provider<int>((ref) {
  final playerData = ref.watch(playerDataProvider);
  return playerData?.stats.currentCoins ?? 0;
});

/// Provider for selected theme
final selectedThemeProvider = Provider<String>((ref) {
  final playerData = ref.watch(playerDataProvider);
  return playerData?.settings.selectedTheme ?? 'city';
});

/// Provider for sound enabled
final soundEnabledProvider = Provider<bool>((ref) {
  final playerData = ref.watch(playerDataProvider);
  return playerData?.settings.soundEnabled ?? true;
});

/// Provider for music enabled
final musicEnabledProvider = Provider<bool>((ref) {
  final playerData = ref.watch(playerDataProvider);
  return playerData?.settings.musicEnabled ?? true;
});

/// Provider for vibration enabled
final vibrationEnabledProvider = Provider<bool>((ref) {
  final playerData = ref.watch(playerDataProvider);
  return playerData?.settings.vibrationEnabled ?? true;
});

/// Provider for total games played
final gamesPlayedProvider = Provider<int>((ref) {
  final playerData = ref.watch(playerDataProvider);
  return playerData?.stats.totalGamesPlayed ?? 0;
});
