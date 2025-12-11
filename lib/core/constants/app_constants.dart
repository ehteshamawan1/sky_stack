class AppConstants {
  // Game Physics
  static const double gravity = 980.0;
  static const double swingSpeed = 3.0;
  static const double dropSpeed = 800.0;
  static const double wobbleDecay = 0.95;
  static const double maxWobbleAngle = 15.0; // degrees

  // Block Dimensions
  static const double blockWidth = 80.0;
  static const double blockHeight = 40.0;
  static const double perfectThreshold = 5.0; // pixels
  static const double goodThreshold = 15.0;

  // Scoring
  static const int perfectScore = 100;
  static const int goodScore = 50;
  static const int badScore = 25;
  static const double comboMultiplier = 0.5; // +50% per combo level
  static const int maxCombo = 10;

  // Game Settings
  static const int startingLives = 3;
  static const double craneHeight = 100.0;
  static const double baseY = 50.0; // from bottom

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
