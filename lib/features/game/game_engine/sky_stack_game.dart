import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'components/crane_component.dart';
import 'components/block_component.dart';
import 'components/tower_component.dart';
import 'components/background_component.dart';
import 'components/umbrella_person_component.dart';
import 'systems/scoring_system.dart';
import 'systems/combo_system.dart';
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

  // Random for umbrella people spawning
  final Random _random = Random();

  // Callbacks for Flutter UI
  Function(int)? onScoreUpdate;
  Function(int)? onComboUpdate;
  Function(int)? onBlocksUpdate;
  Function(int)? onPopulationUpdate;
  Function()? onGameOver;
  Function()? onPerfectPlacement;

  // Block color index for variety
  int _colorIndex = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize systems
    scoringSystem = ScoringSystem();
    comboSystem = ComboSystem();

    // Add background
    background = BackgroundComponent();
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
    // Get next color
    final color = AppColors.blockColors[_colorIndex % AppColors.blockColors.length];
    _colorIndex++;

    // Blocks are always full width (Anchor.center)
    currentBlock = BlockComponent(
      position: crane.hookPosition + Vector2(0, AppConstants.blockHeight / 2 + 10),
      width: AppConstants.blockWidth,
      height: AppConstants.blockHeight,
      color: color,
    );
    currentBlock!.attachToCrane(crane);
    add(currentBlock!);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameState == GameState.ready) {
      gameState = GameState.playing;
    }

    if (gameState == GameState.playing && currentBlock != null) {
      dropBlock();
    }
  }

  void dropBlock() {
    if (currentBlock == null) return;

    currentBlock!.drop(
      onLanded: handleBlockLanded,
      onFell: handleBlockFell,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState != GameState.playing) return;

    // Check for block collision with tower while falling
    if (currentBlock != null && currentBlock!.state == BlockState.falling) {
      final (shouldLand, targetY) = tower.checkCollision(currentBlock!);
      if (shouldLand) {
        currentBlock!.land(targetY);
      }
    }

    // Check if tower has toppled
    if (tower.hasToppled()) {
      gameState = GameState.gameOver;
      onGameOver?.call();
    }
  }

  void handleBlockLanded(BlockComponent block, double blockX) {
    // Calculate offset from where the block should have landed (center of top block or base)
    final targetX = tower.topBlockCenterX;
    final offset = blockX - targetX;
    final absOffset = offset.abs();

    // First block always lands on the base - no combo possible
    final isFirstBlock = tower.blocks.isEmpty;

    PlacementQuality quality;
    bool isPerfect = absOffset <= AppConstants.perfectThreshold;
    bool isComboWorthy = absOffset <= AppConstants.comboThreshold;

    if (isPerfect) {
      quality = PlacementQuality.perfect;
      // Trigger perfect placement indicator
      onPerfectPlacement?.call();
    } else if (absOffset <= AppConstants.goodThreshold) {
      quality = PlacementQuality.good;
    } else {
      quality = PlacementQuality.bad;
    }

    // Update combo (only after first block)
    // Combo builds for placements within comboThreshold (5px), which includes perfect (2px)
    if (!isFirstBlock && isComboWorthy) {
      combo = comboSystem.incrementCombo(combo);
    } else if (!isFirstBlock) {
      combo = comboSystem.resetCombo();
    }
    onComboUpdate?.call(combo);

    // Calculate and add score
    final points = scoringSystem.calculateScore(quality, combo);
    score += points;
    onScoreUpdate?.call(score);

    // Add block to tower with its placement offset
    tower.addBlock(block, offset);
    blocksPlaced++;
    onBlocksUpdate?.call(blocksPlaced);

    // Spawn umbrella people based on placement quality
    _spawnUmbrellaPeople(block, quality, isComboWorthy);

    // Spawn next block
    currentBlock = null;
    spawnBlock();
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
          onArrived: () {
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

    currentBlock = null;
    gameState = GameState.gameOver;
    onGameOver?.call();
  }

  void reset() {
    score = 0;
    combo = 0;
    blocksPlaced = 0;
    population = 0;
    _colorIndex = 0;
    gameState = GameState.ready;

    tower.clear();
    currentBlock?.removeFromParent();
    currentBlock = null;

    // Remove any floating umbrella people
    children.whereType<UmbrellaPersonComponent>().toList().forEach((p) => p.removeFromParent());

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
}
