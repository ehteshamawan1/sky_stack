/// Game modes available in Sky Stack
enum GameMode {
  /// Classic endless mode - stack blocks until you fail
  classic,

  /// City Builder mode - build multiple towers in a city
  cityBuilder,

  /// Challenge mode - complete specific objectives
  challenge,

  /// Versus mode - compete against another player
  versus,

  /// Story mode - progress through levels with narrative
  story,
}

/// Configuration for Classic game mode
class ClassicModeConfig {
  /// Whether power-ups are enabled in classic mode
  static const bool enablePowerUps = true;

  /// Whether hazards are enabled in classic mode
  static const bool enableHazards = true;

  /// Number of blocks placed before hazards start appearing
  static const int hazardStartBlock = 15;

  /// Maximum number of continues allowed per game (via rewarded ad)
  static const int maxContinues = 1;
}

/// Configuration for City Builder mode
class CityBuilderModeConfig {
  /// Size of the city grid (3x3)
  static const int gridSize = 3;

  /// Total number of building slots
  static const int totalSlots = gridSize * gridSize;

  /// Minimum blocks to "complete" a building slot
  static const int minBlocksForBuilding = 5;

  /// Bonus points for completing a full city
  static const int cityCompletionBonus = 10000;

  /// Maximum number of continues allowed per game (via rewarded ad)
  static const int maxContinues = 1;
}
