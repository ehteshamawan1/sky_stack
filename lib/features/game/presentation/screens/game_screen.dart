import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/providers/player_data_provider.dart';
import '../../../city_builder/providers/city_provider.dart';
import '../../data/models/game_mode.dart';
import '../../game_engine/sky_stack_game.dart';
import '../../providers/theme_provider.dart';
import '../widgets/game_hud.dart';
import '../widgets/pause_menu.dart';
import '../widgets/game_over_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  final GameMode mode;
  final int? citySlotIndex;

  const GameScreen({
    super.key,
    this.mode = GameMode.classic,
    this.citySlotIndex,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late SkyStackGame game;
  String? _currentTheme;
  int currentScore = 0;
  int currentCombo = 0;
  int maxCombo = 0;
  int blocksPlaced = 0;
  int population = 0;
  int perfectDrops = 0;
  bool isPaused = false;
  bool isGameOver = false;
  int highScore = 0;
  bool showPerfect = false;
  int continuesUsed = 0;
  bool isAdLoading = false;
  DateTime? _gameStartTime;

  // Flag to track if waiting for first tap to start
  bool _isWaitingForFirstTap = true;

  // Flag to prevent setState during build
  bool _isBuilding = false;

  // Services
  final AdService _adService = AdService();
  final AudioService _audioService = AudioService();
  final HapticService _hapticService = HapticService();

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _initAdService();
    _initAudioSettings();
    // Defer game initialization to get theme from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGameWithTheme();
    });
  }

  @override
  void dispose() {
    // Stop game music when leaving
    _audioService.stopMusic();
    super.dispose();
  }

  void _initAudioSettings() {
    // Load audio/vibration settings from player data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerData = ref.read(playerDataProvider);
      if (playerData != null) {
        _audioService.updateSettings(
          soundEnabled: playerData.settings.soundEnabled,
          musicEnabled: playerData.settings.musicEnabled,
          masterVolume: playerData.settings.masterVolume,
          sfxVolume: playerData.settings.sfxVolume,
          musicVolume: playerData.settings.musicVolume,
        );
        _hapticService.setEnabled(playerData.settings.vibrationEnabled);
      }
    });
  }

  Future<void> _initAdService() async {
    await _adService.initialize();
  }

  void _initGameWithTheme() {
    final theme = ref.read(gameThemeProvider);
    _currentTheme = theme;
    _initGame(theme);
    _gameStartTime = DateTime.now();
    // Start game music for this theme
    _audioService.playGameMusic(theme);
  }

  /// Safely call setState, deferring if we're currently building
  void _safeSetState(VoidCallback fn) {
    if (_isBuilding) {
      // Defer the setState to after the current frame
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(fn);
        }
      });
    } else {
      setState(fn);
    }
  }

  void _initGame([String theme = 'city']) {
    game = SkyStackGame()
      ..currentTheme = theme
      ..onScoreUpdate = (score) {
        _safeSetState(() => currentScore = score);
      }
      ..onComboUpdate = (combo) {
        _safeSetState(() {
          currentCombo = combo;
          if (combo > maxCombo) maxCombo = combo;
        });
        // Play combo sound
        if (combo > 0) {
          _audioService.playCombo(combo);
          _hapticService.combo(combo);
        }
      }
      ..onBlocksUpdate = (blocks) {
        _safeSetState(() => blocksPlaced = blocks);
      }
      ..onPopulationUpdate = (pop) {
        _safeSetState(() => population = pop);
      }
      ..onGameOver = () {
        _handleBlockFell();
      }
      ..onPerfectPlacement = () {
        _safeSetState(() => perfectDrops++);
        _showPerfectIndicator();
      }
      ..onGameStart = () {
        // Hide "tap to start" overlay once game begins
        _safeSetState(() => _isWaitingForFirstTap = false);
      }
      ..onBlockDrop = () {
        _audioService.playBlockDrop();
        _hapticService.blockDrop();
      }
      ..onBlockLand = (quality) {
        // quality: 0=bad, 1=good, 2=perfect
        switch (quality) {
          case 2:
            _audioService.playBlockLand(PlacementQuality.perfect);
            _hapticService.perfectPlacement();
            break;
          case 1:
            _audioService.playBlockLand(PlacementQuality.good);
            _hapticService.goodPlacement();
            break;
          default:
            _audioService.playBlockLand(PlacementQuality.bad);
            _hapticService.badPlacement();
        }
      }
      ..onBlockFall = () {
        _audioService.playBlockFall();
        _hapticService.blockFall();
      };
    setState(() {}); // Trigger rebuild with game ready
  }

  void _showPerfectIndicator() {
    _safeSetState(() => showPerfect = true);
    // Hide after animation duration
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _safeSetState(() => showPerfect = false);
      }
    });
  }

  /// Called when a block falls off - game over
  void _handleBlockFell() {
    if (_isBuilding) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _processBlockFell();
        }
      });
    } else {
      _processBlockFell();
    }
  }

  void _processBlockFell() {
    // Block fell off - game over
    setState(() {
      isGameOver = true;
    });
    _handleGameOver();
  }

  Future<void> _loadHighScore() async {
    final playerData = ref.read(playerDataProvider);
    if (mounted) {
      setState(() => highScore = playerData?.stats.highScore ?? 0);
    }
  }

  void _handleGameOver() {
    // Play game over haptic
    _hapticService.gameOver();

    // Calculate play time
    final playTime = _gameStartTime != null
        ? DateTime.now().difference(_gameStartTime!).inSeconds
        : 0;

    // Update player data with Hive
    ref.read(playerDataProvider.notifier).recordGameSession(
          score: currentScore,
          blocksPlaced: blocksPlaced,
          population: population,
          perfectDrops: perfectDrops,
          maxCombo: maxCombo,
          towerHeight: blocksPlaced,
          playTimeSeconds: playTime,
        );

    // Update high score for display
    if (currentScore > highScore) {
      setState(() => highScore = currentScore);
    }

    // If City Builder mode, save to city slot
    if (widget.mode == GameMode.cityBuilder && widget.citySlotIndex != null) {
      ref.read(cityProvider.notifier).updateSlot(
            slotIndex: widget.citySlotIndex!,
            towerHeight: blocksPlaced,
            score: currentScore,
            population: population,
          );
    }
  }

  void _pauseGame() {
    _audioService.playTap();
    _hapticService.lightTap();
    setState(() => isPaused = true);
    game.pauseGame();
  }

  void _resumeGame() {
    _audioService.playTap();
    _hapticService.lightTap();
    setState(() => isPaused = false);
    game.resumeGame();
  }

  void _restartGame() {
    _audioService.playTap();
    _hapticService.lightTap();
    _gameStartTime = DateTime.now();
    setState(() {
      isGameOver = false;
      isPaused = false;
      currentScore = 0;
      currentCombo = 0;
      maxCombo = 0;
      blocksPlaced = 0;
      population = 0;
      perfectDrops = 0;
      continuesUsed = 0;
      _isWaitingForFirstTap = true; // Show tap to start again
    });
    game.reset();
  }

  /// Handle continue after watching ad
  Future<void> _handleContinue() async {
    _audioService.playTap();
    _hapticService.lightTap();

    final maxContinues = widget.mode == GameMode.cityBuilder
        ? CityBuilderModeConfig.maxContinues
        : ClassicModeConfig.maxContinues;
    if (continuesUsed >= maxContinues) return;

    setState(() => isAdLoading = true);

    // Stop game engine and music during ad to reduce lag
    game.pauseEngine();
    await _audioService.stopMusic();

    final rewarded = await _adService.showRewardedAd();

    if (rewarded && mounted) {
      setState(() {
        isAdLoading = false;
        isGameOver = false;
        continuesUsed++;
      });

      // Restart music after ad
      await _audioService.playGameMusic(_currentTheme ?? 'city');

      // Clean up any existing block before spawning new one
      game.currentBlock?.removeFromParent();
      game.currentBlock = null;

      // Resume the game directly in playing state (no tap to start)
      game.gameState = GameState.playing;
      game.spawnBlock();
      game.resumeEngine();
    } else if (mounted) {
      setState(() => isAdLoading = false);
      // Resume game engine and restart music even if ad failed
      game.resumeEngine();
      await _audioService.playGameMusic(_currentTheme ?? 'city');
      // Show snackbar that ad failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad not available. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _exitGame() {
    _audioService.playBack();
    _hapticService.lightTap();
    Navigator.of(context).pop();
  }

  /// Whether the player can continue (watch ad to revive)
  bool get _canContinue {
    final maxContinues = widget.mode == GameMode.cityBuilder
        ? CityBuilderModeConfig.maxContinues
        : ClassicModeConfig.maxContinues;
    return isGameOver &&
        continuesUsed < maxContinues &&
        _adService.isRewardedAdReady;
  }

  @override
  Widget build(BuildContext context) {
    _isBuilding = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _isBuilding = false;
    });

    // Show loading if game not initialized yet
    if (_currentTheme == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (isGameOver) {
            _exitGame();
          } else if (isPaused) {
            _resumeGame();
          } else {
            _pauseGame();
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Game
            GameWidget(game: game),

            // HUD
            if (!isGameOver)
              GameHUD(
                score: currentScore,
                combo: currentCombo,
                population: population,
                onPause: _pauseGame,
              ),

            // Tap to start overlay - only on initial game start
            if (_isWaitingForFirstTap && !isPaused && !isGameOver)
              _TapToStartOverlay(
                isCityBuilder: widget.mode == GameMode.cityBuilder,
              ),

            // Pause Menu Overlay
            if (isPaused)
              PauseMenu(
                onResume: _resumeGame,
                onRestart: _restartGame,
                onExit: _exitGame,
              ),

            // Game Over Dialog
            if (isGameOver)
              GameOverDialog(
                score: currentScore,
                blocksPlaced: blocksPlaced,
                population: population,
                highScore: highScore,
                isNewHighScore: currentScore > 0 && currentScore >= highScore,
                canContinue: _canContinue,
                isAdLoading: isAdLoading,
                onContinue: _canContinue ? _handleContinue : null,
                onRestart: _restartGame,
                onExit: _exitGame,
              ),

            // Perfect placement indicator
            if (showPerfect) const _PerfectIndicator(),
          ],
        ),
      ),
    );
  }
}

class _TapToStartOverlay extends StatelessWidget {
  final bool isCityBuilder;

  const _TapToStartOverlay({this.isCityBuilder = false});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 200),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'TAP TO START',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    if (isCityBuilder) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Build the tallest tower for your city!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerfectIndicator extends StatelessWidget {
  const _PerfectIndicator();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 100), // Below the crane
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 150),
                  builder: (context, opacity, _) {
                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text(
                  'PERFECT!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
