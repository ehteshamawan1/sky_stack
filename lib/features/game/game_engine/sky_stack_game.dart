import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'components/crane_component.dart';
import 'components/block_component.dart';
import 'components/tower_component.dart';
import 'components/background_component.dart';
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

  // Components
  late CraneComponent crane;
  late TowerComponent tower;
  late BackgroundComponent background;
  BlockComponent? currentBlock;

  // Systems
  late ScoringSystem scoringSystem;
  late ComboSystem comboSystem;

  // Callbacks for Flutter UI
  Function(int)? onScoreUpdate;
  Function(int)? onComboUpdate;
  Function(int)? onBlocksUpdate;
  Function()? onGameOver;

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

    // Calculate block width based on previous block (or default)
    final blockWidth = tower.blocks.isEmpty
        ? AppConstants.blockWidth
        : tower.topBlockWidth;

    currentBlock = BlockComponent(
      position: crane.hookPosition + Vector2(0, AppConstants.blockHeight / 2 + 10),
      width: blockWidth,
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

    // Check for block collision with tower while falling
    if (currentBlock != null && currentBlock!.state == BlockState.falling) {
      final (shouldLand, targetY, offset) = tower.checkCollision(currentBlock!);
      if (shouldLand) {
        currentBlock!.land(targetY, offset);
      }
    }
  }

  void handleBlockLanded(BlockComponent block, double offset) {
    // Calculate placement quality
    final absOffset = offset.abs();

    PlacementQuality quality;
    if (absOffset <= AppConstants.perfectThreshold) {
      quality = PlacementQuality.perfect;
    } else if (absOffset <= AppConstants.goodThreshold) {
      quality = PlacementQuality.good;
    } else {
      quality = PlacementQuality.bad;
    }

    // Update combo
    if (quality == PlacementQuality.perfect) {
      combo = comboSystem.incrementCombo(combo);
    } else {
      combo = comboSystem.resetCombo();
    }
    onComboUpdate?.call(combo);

    // Calculate and add score
    final points = scoringSystem.calculateScore(quality, combo);
    score += points;
    onScoreUpdate?.call(score);

    // Add block to tower
    tower.addBlock(block);
    blocksPlaced++;
    onBlocksUpdate?.call(blocksPlaced);

    // Spawn next block
    currentBlock = null;
    spawnBlock();
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
    _colorIndex = 0;
    gameState = GameState.ready;

    tower.clear();
    currentBlock?.removeFromParent();
    currentBlock = null;

    spawnBlock();

    onScoreUpdate?.call(score);
    onComboUpdate?.call(combo);
    onBlocksUpdate?.call(blocksPlaced);
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
