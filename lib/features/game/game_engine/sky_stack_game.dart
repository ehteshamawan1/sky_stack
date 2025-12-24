import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'components/crane_component.dart';
import 'components/block_component.dart';
import 'components/tower_component.dart';
import 'components/background_component.dart';
import 'components/umbrella_person_component.dart';
import 'components/particle_effects.dart';
import 'components/score_popup_component.dart';
import 'components/powerup_pickup_component.dart';
import 'systems/scoring_system.dart';
import 'systems/combo_system.dart';
import 'systems/powerup_system.dart';
import 'systems/hazard_system.dart';
import '../data/models/powerup_model.dart';
import '../data/models/hazard_model.dart';
import '../data/models/game_mode.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

enum GameState { ready, playing, paused, gameOver }

class SkyStackGame extends FlameGame with TapCallbacks {
  // Game state
  GameState gameState = GameState.ready;
  int score = 0;
  int combo = 0;
  int blocksPlaced = 0;
  int population = 0;

  // Components
  late CraneComponent crane;
  late TowerComponent tower;
  late BackgroundComponent background;
  BlockComponent? currentBlock;

  // Systems
  late ScoringSystem scoringSystem;
  late ComboSystem comboSystem;
  late PowerUpSystem powerUpSystem;
  late HazardSystem hazardSystem;
  PowerUpPickupComponent? _activePowerUpPickup;

  // Random for umbrella people spawning
  final Random _random = Random();

  // Callbacks for Flutter UI
  Function(int)? onScoreUpdate;
  Function(int)? onComboUpdate;
  Function(int)? onBlocksUpdate;
  Function(int)? onPopulationUpdate;
  Function()? onGameOver;
  Function()? onPerfectPlacement;
  Function()? onGameStart;
  Function()? onBlockDrop;
  Function(int quality)? onBlockLand; // 0=bad, 1=good, 2=perfect
  Function()? onBlockFall;
  Function(PowerUpType)? onPowerUpCollected;
  Function(PowerUpType)? onPowerUpActivated;
  Function(PowerUpType?, double)? onPowerUpStatus;
  Function(HazardType?, double)? onHazardStatus;
  Function(HazardType?, double)? onHazardWarning;

  // Block color index for variety
  int _colorIndex = 0;

  // Screen shake variables
  double _shakeIntensity = 0;
  double _shakeDuration = 0;
  Vector2 _shakeOffset = Vector2.zero();

  // Topple check timing to avoid false positives right after landing
  double _toppleCheckDelay = 0;
  static const double _toppleDelaySeconds = 0.5;
  double _statusTick = 0;

  // Current theme
  String currentTheme = 'city';

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize systems
    scoringSystem = ScoringSystem();
    comboSystem = ComboSystem();
    powerUpSystem = PowerUpSystem();
    hazardSystem = HazardSystem();

    // Add background with current theme
    background = BackgroundComponent(theme: currentTheme);
    add(background);

    // Add tower (manages placed blocks)
    tower = TowerComponent();
    add(tower);

    // Add crane
    crane = CraneComponent(
      position: Vector2(size.x / 2, AppConstants.craneHeight),
      gameWidth: size.x,
    );
    add(crane);

    // Spawn first block
    spawnBlock();
  }

  void spawnBlock() {
    // Get next color (used as fallback if SVG fails)
    final color = AppColors.blockColors[_colorIndex % AppColors.blockColors.length];
    _colorIndex++;

    // Blocks are always full width (Anchor.center)
    currentBlock = BlockComponent(
      position: crane.hookPosition + Vector2(0, AppConstants.blockHeight / 2 + 10),
      width: AppConstants.blockWidth,
      height: AppConstants.blockHeight,
      color: color,
      theme: currentTheme,
    );
    currentBlock!.attachToCrane(crane);
    add(currentBlock!);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameState == GameState.ready) {
      gameState = GameState.playing;
      onGameStart?.call();
    }

    if (gameState == GameState.playing && currentBlock != null) {
      dropBlock();
    }
  }

  void dropBlock() {
    if (currentBlock == null) return;

    // Notify UI that block was dropped
    onBlockDrop?.call();

    currentBlock!.drop(
      onLanded: handleBlockLanded,
      onFell: handleBlockFell,
    );
  }

  @override
  void update(double dt) {
    final cappedDt = dt.clamp(0.0, 1.0 / 30);
    super.update(cappedDt);

    // Update screen shake
    _updateScreenShake(cappedDt);

    if (gameState != GameState.playing) return;

    powerUpSystem.update(cappedDt);
    hazardSystem.update(cappedDt);
    tower.setStabilizerMultiplier(powerUpSystem.getWobbleMultiplier());
    crane.setSpeedMultiplier(
      powerUpSystem.getSwingSpeedMultiplier() * hazardSystem.getCraneSpeedMultiplier(),
    );

    // Check for block collision with tower while falling
    if (currentBlock != null && currentBlock!.state == BlockState.falling) {
      _applyWindForce(currentBlock!, cappedDt);
      _checkPowerUpPickup(currentBlock!);
      final (shouldLand, targetY) = tower.checkCollision(currentBlock!);
      if (shouldLand) {
        currentBlock!.land(targetY);
      }
    }

    _updateStatusCallbacks(cappedDt);

    if (_toppleCheckDelay > 0) {
      _toppleCheckDelay -= cappedDt;
    } else if (tower.hasToppled()) {
      _triggerGameOver('Tower toppled');
    }
  }

  /// Triggers screen shake effect for bad drops
  void triggerScreenShake({double intensity = 8, double duration = 0.3}) {
    _shakeIntensity = intensity;
    _shakeDuration = duration;
  }

  void _updateScreenShake(double dt) {
    if (_shakeDuration > 0) {
      _shakeDuration -= dt;
      _shakeOffset = Vector2(
        (_random.nextDouble() - 0.5) * 2 * _shakeIntensity,
        (_random.nextDouble() - 0.5) * 2 * _shakeIntensity,
      );

      // Apply shake to camera
      camera.viewfinder.position = _shakeOffset;

      if (_shakeDuration <= 0) {
        _shakeOffset = Vector2.zero();
        camera.viewfinder.position = Vector2.zero();
      }
    }
  }

  void handleBlockLanded(BlockComponent block, double blockX) {
    // Calculate offset from where the block should have landed (center of top block or base)
    final targetX = tower.topBlockCenterX;
    double offset = blockX - targetX;
    double absOffset = offset.abs();

    // First block always lands on the base - no combo possible
    final isFirstBlock = tower.blocks.isEmpty;

    if (!isFirstBlock) {
      final topBlock = tower.blocks.last;
      final overlapPercent = _calculateOverlapPercent(block, topBlock);
      if (overlapPercent < AppConstants.minOverlapPercent) {
        onBlockFall?.call();
        block.removeFromParent();
        currentBlock = null;
        _triggerGameOver('Insufficient overlap (${(overlapPercent * 100).toStringAsFixed(1)}%)');
        return;
      }
    }

    final magnetRange = powerUpSystem.getMagnetSnapRange();
    if (magnetRange > 0 && absOffset <= magnetRange) {
      block.position.x = targetX;
      offset = 0;
      absOffset = 0;
    }

    PlacementQuality quality;
    bool isPerfect = absOffset <= AppConstants.perfectThreshold;
    bool isComboWorthy = absOffset <= AppConstants.comboThreshold;

    if (isPerfect) {
      quality = PlacementQuality.perfect;
      // Trigger perfect placement indicator
      onPerfectPlacement?.call();
      onBlockLand?.call(2); // 2 = perfect
      // Add golden sparkle effect for perfect placement
      add(ParticleEffects.perfectDropEffect(block.position));
    } else if (absOffset <= AppConstants.goodThreshold) {
      quality = PlacementQuality.good;
      onBlockLand?.call(1); // 1 = good
    } else {
      quality = PlacementQuality.bad;
      onBlockLand?.call(0); // 0 = bad
      // Screen shake for bad placement
      triggerScreenShake(intensity: 6, duration: 0.25);
    }

    // Add dust effect for all landings
    add(ParticleEffects.dustEffect(block.position + Vector2(0, AppConstants.blockHeight / 2), AppConstants.blockWidth));

    // Update combo (only after first block)
    // Combo builds for placements within comboThreshold (5px), which includes perfect (2px)
    if (!isFirstBlock && isComboWorthy) {
      combo = comboSystem.incrementCombo(combo);
      // Combo celebration effect
      if (combo >= 3) {
        add(ParticleEffects.comboEffect(block.position, combo));
        add(ComboIndicatorComponent(comboLevel: combo, position: block.position - Vector2(0, 60)));
      }
    } else if (!isFirstBlock) {
      combo = comboSystem.resetCombo();
    }
    onComboUpdate?.call(combo);

    // Calculate and add score
    final points = scoringSystem.calculateScore(quality, combo);
    score += points;
    onScoreUpdate?.call(score);

    // Add score popup
    add(ScorePopupComponent(
      score: points,
      position: block.position - Vector2(0, 20),
      isPerfect: isPerfect,
      isCombo: combo > 1,
      comboLevel: combo,
    ));

    // Add block to tower with its placement offset
    tower.addBlock(block, offset);
    _toppleCheckDelay = _toppleDelaySeconds;
    blocksPlaced++;
    onBlocksUpdate?.call(blocksPlaced);

    // Update parallax background scroll
    updateParallax();

    // Spawn umbrella people based on placement quality
    _spawnUmbrellaPeople(block, quality, isComboWorthy);

    // Spawn next block
    currentBlock = null;
    spawnBlock();

    _maybeSpawnPowerUpPickup();
    _maybeScheduleHazard();
  }

  /// Spawn umbrella people floating down to the building
  /// Better placement = more people
  void _spawnUmbrellaPeople(BlockComponent block, PlacementQuality quality, bool isComboWorthy) {
    // Determine number of people based on quality
    int peopleCount;
    switch (quality) {
      case PlacementQuality.perfect:
        peopleCount = 5 + _random.nextInt(3); // 5-7 people for perfect!
        break;
      case PlacementQuality.good:
        // Combo-worthy good placements (≤8px) get more people
        if (isComboWorthy) {
          peopleCount = 3 + _random.nextInt(2); // 3-4 people for combo
        } else {
          peopleCount = 2 + _random.nextInt(2); // 2-3 people
        }
        break;
      case PlacementQuality.bad:
        peopleCount = 1; // 1 person
        break;
    }

    // Spawn people from above, floating down to the block
    for (int i = 0; i < peopleCount; i++) {
      // Stagger spawn positions and timing
      final delay = i * 150; // milliseconds between each person

      Future.delayed(Duration(milliseconds: delay), () {
        if (gameState != GameState.playing && gameState != GameState.ready) return;

        // Random horizontal position above the block
        final startX = block.position.x + (_random.nextDouble() - 0.5) * AppConstants.blockWidth;
        final startY = block.position.y - AppConstants.blockHeight - 50 - _random.nextDouble() * 100;

        // Target is on the block
        final targetY = block.position.y;

        final person = UmbrellaPersonComponent(
          startPosition: Vector2(startX, startY),
          targetPosition: Vector2(startX, targetY),
          theme: currentTheme,
          onArrived: () {
            // Only update if game is still active (not game over)
            if (gameState == GameState.gameOver) return;

            // Person entered the building - add to population
            population++;
            onPopulationUpdate?.call(population);

            // Bonus score for population
            score += 10;
            onScoreUpdate?.call(score);
          },
        );
        add(person);
      });
    }
  }

  void handleBlockFell(BlockComponent block) {
    // Block fell off - game over
    combo = comboSystem.resetCombo();
    onComboUpdate?.call(combo);

    // Notify UI that block fell
    onBlockFall?.call();

    currentBlock = null;
    _triggerGameOver('Block fell off screen');
  }

  void reset() {
    score = 0;
    combo = 0;
    blocksPlaced = 0;
    population = 0;
    _colorIndex = 0;
    gameState = GameState.ready;
    _toppleCheckDelay = 0;
    _statusTick = 0;

    tower.clear();
    currentBlock?.removeFromParent();
    currentBlock = null;
    _activePowerUpPickup?.removeFromParent();
    _activePowerUpPickup = null;
    powerUpSystem.clear();
    hazardSystem.clear();

    // Remove any floating umbrella people
    children.whereType<UmbrellaPersonComponent>().toList().forEach((p) => p.removeFromParent());

    // Reset background scroll position
    background.resetScroll();

    spawnBlock();

    onScoreUpdate?.call(score);
    onComboUpdate?.call(combo);
    onBlocksUpdate?.call(blocksPlaced);
    onPopulationUpdate?.call(population);

    // Ensure engine is running (in case we were paused)
    resumeEngine();
  }

  void pauseGame() {
    if (gameState == GameState.playing) {
      gameState = GameState.paused;
      pauseEngine();
    }
  }

  void resumeGame() {
    if (gameState == GameState.paused) {
      gameState = GameState.playing;
      resumeEngine();
    }
  }

  /// Change the current theme (affects blocks and backgrounds)
  void setTheme(String theme) {
    currentTheme = theme;
    background.theme = theme;
  }

  /// Change the time of day (day, sunset, night)
  void setTimeOfDay(TimeOfDay timeOfDay) {
    background.timeOfDay = timeOfDay;
  }

  /// Update parallax scroll based on tower height
  void updateParallax() {
    final towerHeight = tower.blocks.length * AppConstants.blockHeight;
    background.updateScroll(towerHeight);
  }

  double _calculateOverlapPercent(BlockComponent block, BlockComponent topBlock) {
    final blockLeft = block.position.x - block.initialWidth / 2;
    final blockRight = block.position.x + block.initialWidth / 2;
    final topLeft = topBlock.position.x - topBlock.initialWidth / 2;
    final topRight = topBlock.position.x + topBlock.initialWidth / 2;

    final overlapLeft = max(blockLeft, topLeft);
    final overlapRight = min(blockRight, topRight);
    final overlapWidth = max(0.0, overlapRight - overlapLeft);

    return overlapWidth / block.initialWidth;
  }

  void _triggerGameOver(String reason) {
    if (gameState == GameState.gameOver) return;
    gameState = GameState.gameOver;
    onGameOver?.call();
  }

  void _maybeSpawnPowerUpPickup() {
    if (!ClassicModeConfig.enablePowerUps) return;
    if (powerUpSystem.hasActivePowerUp || _activePowerUpPickup != null) return;
    if (_random.nextDouble() > 0.12) return;

    final types = PowerUpDefinition.launch.keys.toList();
    if (types.isEmpty) return;
    final type = types[_random.nextInt(types.length)];

    final baseY = tower.blocks.isEmpty
        ? size.y - AppConstants.baseY - 140
        : tower.topY - 140;
    final spawnX = (tower.topBlockCenterX + (_random.nextDouble() - 0.5) * 140)
        .clamp(40.0, size.x - 40.0)
        .toDouble();
    final spawnY = baseY
        .clamp(AppConstants.craneHeight + 60.0, size.y - 200.0)
        .toDouble();

    _activePowerUpPickup = PowerUpPickupComponent(
      type: type,
      position: Vector2(spawnX, spawnY),
      onCollected: _activatePowerUp,
    );
    add(_activePowerUpPickup!);
  }

  void _checkPowerUpPickup(BlockComponent block) {
    if (_activePowerUpPickup == null) return;
    if (_activePowerUpPickup!.isRemoved) {
      _activePowerUpPickup = null;
      return;
    }

    if (_activePowerUpPickup!.isCollidingWith(block.position)) {
      final pickup = _activePowerUpPickup!;
      _activePowerUpPickup = null;
      pickup.collect();
    }
  }

  void _activatePowerUp(PowerUpType type) {
    final definition = PowerUpDefinition.launch[type]!;
    powerUpSystem.activate(type, definition.durationSeconds);
    onPowerUpCollected?.call(type);
    onPowerUpActivated?.call(type);
  }

  void _maybeScheduleHazard() {
    if (!ClassicModeConfig.enableHazards) return;
    if (hazardSystem.hasActiveHazard || hazardSystem.hasWarning) return;

    final hazardType = hazardSystem.rollForHazard(blocksPlaced);
    if (hazardType != null) {
      hazardSystem.scheduleWarning(hazardType);
    }
  }

  void _applyWindForce(BlockComponent block, double dt) {
    final windForce = hazardSystem.getWindForce();
    if (windForce == 0) return;
    block.position.x += windForce * dt;
  }

  void _updateStatusCallbacks(double dt) {
    _statusTick += dt;
    if (_statusTick < 0.1) return;
    _statusTick = 0;

    final activePowerUp = powerUpSystem.activePowerUp;
    final powerUpRemaining = activePowerUp != null
        ? powerUpSystem.remainingSeconds(activePowerUp)
        : 0;
    onPowerUpStatus?.call(activePowerUp, powerUpRemaining);

    final activeHazard = hazardSystem.activeHazard;
    onHazardStatus?.call(activeHazard, hazardSystem.activeRemaining);
    onHazardWarning?.call(hazardSystem.pendingHazard, hazardSystem.warningRemaining);
  }
}
