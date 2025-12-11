class AssetPaths {
  // SVG Images
  static const String svgBase = 'assets/svg';
  static const String blocksBase = '$svgBase/blocks';
  static const String backgroundsBase = '$svgBase/backgrounds';
  static const String uiBase = '$svgBase/ui';
  static const String charactersBase = '$svgBase/characters';
  static const String powerupsBase = '$svgBase/powerups';
  static const String achievementsBase = '$svgBase/achievements';

  // Blocks (by theme)
  static String block(String theme) => '$blocksBase/${theme}_block.svg';
  static String blockGold(String theme) => '$blocksBase/${theme}_block_gold.svg';

  // Backgrounds (parallax layers)
  static String bgSky(String theme) => '$backgroundsBase/${theme}_sky.svg';
  static String bgFar(String theme) => '$backgroundsBase/${theme}_far.svg';
  static String bgMid(String theme) => '$backgroundsBase/${theme}_mid.svg';
  static String bgNear(String theme) => '$backgroundsBase/${theme}_near.svg';

  // UI Elements
  static const String appIcon = '$uiBase/app_icon.svg';
  static const String btnPlay = '$uiBase/btn_play.svg';
  static const String btnPause = '$uiBase/btn_pause.svg';
  static const String btnSettings = '$uiBase/btn_settings.svg';
  static const String iconCoin = '$uiBase/icon_coin.svg';
  static const String iconHeart = '$uiBase/icon_heart.svg';
  static const String iconStar = '$uiBase/icon_star.svg';

  // Power-ups
  static const String powerupSlowMotion = '$powerupsBase/slow_motion.svg';
  static const String powerupWideBlock = '$powerupsBase/wide_block.svg';
  static const String powerupStabilizer = '$powerupsBase/stabilizer.svg';
  static const String powerupMagnet = '$powerupsBase/magnet.svg';
  static const String powerupShield = '$powerupsBase/shield.svg';
  static const String powerupDoublePoints = '$powerupsBase/double_points.svg';

  // Hazards
  static const String hazardsBase = '$svgBase/hazards';
  static const String hazardBird = '$hazardsBase/bird.svg';

  // Sounds
  static const String soundsBase = 'assets/sounds';
  static const String sfxBase = '$soundsBase/sfx';
  static const String musicBase = '$soundsBase/music';

  // SFX paths
  static const String sfxDrop = '$sfxBase/block_drop.wav';
  static const String sfxPerfect = '$sfxBase/block_land_perfect.wav';
  static const String sfxGood = '$sfxBase/block_land_good.wav';
  static const String sfxBad = '$sfxBase/block_land_bad.wav';
  static const String sfxWobble = '$sfxBase/block_wobble.wav';
  static const String sfxFall = '$sfxBase/block_fall.wav';
  static const String sfxCollapse = '$sfxBase/tower_collapse.wav';
  static const String sfxCombo1 = '$sfxBase/combo_1.wav';
  static const String sfxCombo2 = '$sfxBase/combo_2.wav';
  static const String sfxCombo3 = '$sfxBase/combo_3.wav';
  static const String sfxPowerupPickup = '$sfxBase/powerup_pickup.wav';
  static const String sfxPowerupUse = '$sfxBase/powerup_use.wav';
  static const String sfxTap = '$sfxBase/ui_tap.wav';
  static const String sfxBack = '$sfxBase/ui_back.wav';
  static const String sfxAchievement = '$sfxBase/achievement.wav';
  static const String sfxLevelUp = '$sfxBase/level_up.wav';

  // Music paths
  static const String musicMenu = '$musicBase/menu_theme.mp3';
  static const String musicGame1 = '$musicBase/game_theme_1.mp3';
  static const String musicGame2 = '$musicBase/game_theme_2.mp3';
  static const String musicVictory = '$musicBase/victory.mp3';
}
