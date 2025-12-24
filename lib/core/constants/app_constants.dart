class AppConstants {
  // Game Physics
  static const double gravity = 980.0;
  static const double swingSpeed = 2.0; // Swing speed
  static const double dropSpeed = 800.0;
  static const double wobbleDecay = 0.95;
  static const double maxWobbleAngle = 15.0; // degrees

  // Block Dimensions - square blocks like building floors
  static const double blockWidth = 100.0;
  static const double blockHeight = 100.0;  // Square blocks
  static const double perfectThreshold = 2.0; // pixels - very precise!
  static const double comboThreshold = 5.0; // pixels - good enough for combo
  static const double goodThreshold = 20.0; // pixels
  static const double minOverlapPercent = 0.2; // 20% minimum overlap to land

  // Scoring
  static const int perfectScore = 200; // Double points for perfect
  static const int goodScore = 50;
  static const int badScore = 25;
  static const double comboMultiplier = 0.5; // +50% per combo level
  static const int maxCombo = 10;

  // Game Settings
  static const double craneHeight = 100.0; // Pivot point Y position from top
  static const double baseY = 60.0; // Platform height from bottom (road/floor)

  // Animation Durations
  static const Duration dropDuration = Duration(milliseconds: 300);
  static const Duration wobbleDuration = Duration(milliseconds: 500);
  static const Duration perfectEffectDuration = Duration(milliseconds: 400);

  // AdMob IDs
  static const String admobAppId = 'ca-app-pub-2291016820514184~7976124484';
  static const String bannerAdUnitId = 'ca-app-pub-2291016820514184/2507981860';
  static const String interstitialAdUnitId = 'ca-app-pub-2291016820514184/7153997405';
  static const String rewardedAdUnitId = 'ca-app-pub-2291016820514184/1059168825';
}
