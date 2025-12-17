import 'package:hive/hive.dart';

part 'player_data.g.dart';

/// Player settings stored in Hive
@HiveType(typeId: 10)
class PlayerSettings extends HiveObject {
  @HiveField(0)
  bool soundEnabled;

  @HiveField(1)
  bool musicEnabled;

  @HiveField(2)
  bool vibrationEnabled;

  @HiveField(3)
  bool notificationsEnabled;

  @HiveField(4)
  bool adsRemoved;

  @HiveField(5)
  String selectedTheme;

  @HiveField(6)
  double masterVolume;

  @HiveField(7)
  double sfxVolume;

  @HiveField(8)
  double musicVolume;

  PlayerSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.notificationsEnabled = true,
    this.adsRemoved = false,
    this.selectedTheme = 'city',
    this.masterVolume = 1.0,
    this.sfxVolume = 1.0,
    this.musicVolume = 0.7,
  });

  /// Create default settings
  factory PlayerSettings.defaults() => PlayerSettings();

  /// Copy with updated values
  PlayerSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    bool? notificationsEnabled,
    bool? adsRemoved,
    String? selectedTheme,
    double? masterVolume,
    double? sfxVolume,
    double? musicVolume,
  }) {
    return PlayerSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      adsRemoved: adsRemoved ?? this.adsRemoved,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      masterVolume: masterVolume ?? this.masterVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      musicVolume: musicVolume ?? this.musicVolume,
    );
  }
}

/// Player statistics stored in Hive
@HiveType(typeId: 11)
class PlayerStats extends HiveObject {
  @HiveField(0)
  int highScore;

  @HiveField(1)
  int totalGamesPlayed;

  @HiveField(2)
  int totalBlocksPlaced;

  @HiveField(3)
  int totalPopulationHoused;

  @HiveField(4)
  int totalPerfectDrops;

  @HiveField(5)
  int longestCombo;

  @HiveField(6)
  int highestTower;

  @HiveField(7)
  int totalCoinsEarned;

  @HiveField(8)
  int currentCoins;

  @HiveField(9)
  int citiesCompleted;

  @HiveField(10)
  int totalPlayTimeSeconds;

  @HiveField(11)
  DateTime? lastPlayedAt;

  @HiveField(12)
  DateTime firstPlayedAt;

  PlayerStats({
    this.highScore = 0,
    this.totalGamesPlayed = 0,
    this.totalBlocksPlaced = 0,
    this.totalPopulationHoused = 0,
    this.totalPerfectDrops = 0,
    this.longestCombo = 0,
    this.highestTower = 0,
    this.totalCoinsEarned = 0,
    this.currentCoins = 0,
    this.citiesCompleted = 0,
    this.totalPlayTimeSeconds = 0,
    this.lastPlayedAt,
    DateTime? firstPlayedAt,
  }) : firstPlayedAt = firstPlayedAt ?? DateTime.now();

  /// Create default stats for new player
  factory PlayerStats.defaults() => PlayerStats();

  /// Update high score if new score is higher
  bool updateHighScore(int newScore) {
    if (newScore > highScore) {
      highScore = newScore;
      return true;
    }
    return false;
  }

  /// Add coins (with optional multiplier)
  void addCoins(int amount, {double multiplier = 1.0}) {
    final coins = (amount * multiplier).round();
    currentCoins += coins;
    totalCoinsEarned += coins;
  }

  /// Spend coins, returns true if successful
  bool spendCoins(int amount) {
    if (currentCoins >= amount) {
      currentCoins -= amount;
      return true;
    }
    return false;
  }

  /// Record a game session
  void recordGameSession({
    required int score,
    required int blocksPlaced,
    required int population,
    required int perfectDrops,
    required int maxCombo,
    required int towerHeight,
    required int playTimeSeconds,
  }) {
    totalGamesPlayed++;
    totalBlocksPlaced += blocksPlaced;
    totalPopulationHoused += population;
    totalPerfectDrops += perfectDrops;
    totalPlayTimeSeconds += playTimeSeconds;
    lastPlayedAt = DateTime.now();

    if (maxCombo > longestCombo) {
      longestCombo = maxCombo;
    }
    if (towerHeight > highestTower) {
      highestTower = towerHeight;
    }

    updateHighScore(score);
  }

  /// Create a copy of this stats object
  PlayerStats copy() {
    return PlayerStats(
      highScore: highScore,
      totalGamesPlayed: totalGamesPlayed,
      totalBlocksPlaced: totalBlocksPlaced,
      totalPopulationHoused: totalPopulationHoused,
      totalPerfectDrops: totalPerfectDrops,
      longestCombo: longestCombo,
      highestTower: highestTower,
      totalCoinsEarned: totalCoinsEarned,
      currentCoins: currentCoins,
      citiesCompleted: citiesCompleted,
      totalPlayTimeSeconds: totalPlayTimeSeconds,
      lastPlayedAt: lastPlayedAt,
      firstPlayedAt: firstPlayedAt,
    );
  }
}

/// Achievement status
@HiveType(typeId: 12)
enum AchievementStatus {
  @HiveField(0)
  locked,

  @HiveField(1)
  unlocked,

  @HiveField(2)
  claimed,
}

/// Single achievement record
@HiveType(typeId: 13)
class AchievementRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  AchievementStatus status;

  @HiveField(2)
  DateTime? unlockedAt;

  @HiveField(3)
  int progress;

  @HiveField(4)
  int targetProgress;

  AchievementRecord({
    required this.id,
    this.status = AchievementStatus.locked,
    this.unlockedAt,
    this.progress = 0,
    this.targetProgress = 1,
  });

  /// Whether achievement is unlocked (but maybe not claimed)
  bool get isUnlocked => status != AchievementStatus.locked;

  /// Whether achievement reward has been claimed
  bool get isClaimed => status == AchievementStatus.claimed;

  /// Progress percentage (0.0 - 1.0)
  double get progressPercent =>
      targetProgress > 0 ? (progress / targetProgress).clamp(0.0, 1.0) : 0.0;

  /// Unlock this achievement
  void unlock() {
    if (status == AchievementStatus.locked) {
      status = AchievementStatus.unlocked;
      unlockedAt = DateTime.now();
    }
  }

  /// Claim reward for this achievement
  void claim() {
    if (status == AchievementStatus.unlocked) {
      status = AchievementStatus.claimed;
    }
  }

  /// Update progress
  void updateProgress(int newProgress) {
    progress = newProgress;
    if (progress >= targetProgress && status == AchievementStatus.locked) {
      unlock();
    }
  }
}

/// Player unlockables (themes, blocks, etc.)
@HiveType(typeId: 14)
class PlayerUnlocks extends HiveObject {
  @HiveField(0)
  List<String> unlockedThemes;

  @HiveField(1)
  List<String> unlockedBlocks;

  @HiveField(2)
  List<String> unlockedPowerUps;

  @HiveField(3)
  List<String> unlockedCharacters;

  @HiveField(4)
  List<String> unlockedBackgrounds;

  PlayerUnlocks({
    List<String>? unlockedThemes,
    List<String>? unlockedBlocks,
    List<String>? unlockedPowerUps,
    List<String>? unlockedCharacters,
    List<String>? unlockedBackgrounds,
  })  : unlockedThemes = unlockedThemes ?? ['city'], // City theme unlocked by default
        unlockedBlocks = unlockedBlocks ?? [],
        unlockedPowerUps = unlockedPowerUps ?? [],
        unlockedCharacters = unlockedCharacters ?? [],
        unlockedBackgrounds = unlockedBackgrounds ?? [];

  /// Create default unlocks for new player
  factory PlayerUnlocks.defaults() => PlayerUnlocks();

  /// Check if a theme is unlocked
  bool isThemeUnlocked(String themeId) => unlockedThemes.contains(themeId);

  /// Unlock a theme
  bool unlockTheme(String themeId) {
    if (!unlockedThemes.contains(themeId)) {
      unlockedThemes.add(themeId);
      return true;
    }
    return false;
  }

  /// Check if a power-up is unlocked
  bool isPowerUpUnlocked(String powerUpId) => unlockedPowerUps.contains(powerUpId);

  /// Unlock a power-up
  bool unlockPowerUp(String powerUpId) {
    if (!unlockedPowerUps.contains(powerUpId)) {
      unlockedPowerUps.add(powerUpId);
      return true;
    }
    return false;
  }

  /// Create a copy of this unlocks object
  PlayerUnlocks copy() {
    return PlayerUnlocks(
      unlockedThemes: List<String>.from(unlockedThemes),
      unlockedBlocks: List<String>.from(unlockedBlocks),
      unlockedPowerUps: List<String>.from(unlockedPowerUps),
      unlockedCharacters: List<String>.from(unlockedCharacters),
      unlockedBackgrounds: List<String>.from(unlockedBackgrounds),
    );
  }
}

/// Complete player data model
@HiveType(typeId: 15)
class PlayerData extends HiveObject {
  @HiveField(0)
  final String odbc;

  @HiveField(1)
  String displayName;

  @HiveField(2)
  PlayerSettings settings;

  @HiveField(3)
  PlayerStats stats;

  @HiveField(4)
  PlayerUnlocks unlocks;

  @HiveField(5)
  List<AchievementRecord> achievements;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime lastModifiedAt;

  @HiveField(8)
  int dataVersion;

  /// Current data version for migrations
  static const int currentDataVersion = 1;

  PlayerData({
    required this.odbc,
    this.displayName = 'Player',
    PlayerSettings? settings,
    PlayerStats? stats,
    PlayerUnlocks? unlocks,
    List<AchievementRecord>? achievements,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    this.dataVersion = currentDataVersion,
  })  : settings = settings ?? PlayerSettings.defaults(),
        stats = stats ?? PlayerStats.defaults(),
        unlocks = unlocks ?? PlayerUnlocks.defaults(),
        achievements = achievements ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastModifiedAt = lastModifiedAt ?? DateTime.now();

  /// Create new player data with unique ID
  factory PlayerData.create({String? displayName}) {
    return PlayerData(
      odbc: DateTime.now().millisecondsSinceEpoch.toString(),
      displayName: displayName ?? 'Player',
    );
  }

  /// Mark data as modified (for sync purposes)
  void markModified() {
    lastModifiedAt = DateTime.now();
  }

  /// Get achievement by ID
  AchievementRecord? getAchievement(String id) {
    try {
      return achievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Add or update an achievement
  void setAchievement(AchievementRecord achievement) {
    final index = achievements.indexWhere((a) => a.id == achievement.id);
    if (index >= 0) {
      achievements[index] = achievement;
    } else {
      achievements.add(achievement);
    }
    markModified();
  }

  /// Create a deep copy of this player data (for state management)
  PlayerData copy() {
    return PlayerData(
      odbc: odbc,
      displayName: displayName,
      settings: settings.copyWith(),
      stats: stats.copy(),
      unlocks: unlocks.copy(),
      achievements: achievements.map((a) => AchievementRecord(
        id: a.id,
        status: a.status,
        unlockedAt: a.unlockedAt,
        progress: a.progress,
        targetProgress: a.targetProgress,
      )).toList(),
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt,
      dataVersion: dataVersion,
    );
  }
}
