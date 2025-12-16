import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../game_engine/sky_stack_game.dart';
import '../../providers/theme_provider.dart';
import '../widgets/game_hud.dart';
import '../widgets/pause_menu.dart';
import '../widgets/game_over_dialog.dart';

const String _highScoreKey = 'high_score';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late SkyStackGame game;
  String? _currentTheme;
  int currentScore = 0;
  int currentCombo = 0;
  int blocksPlaced = 0;
  int population = 0;
  bool isPaused = false;
  bool isGameOver = false;
  int highScore = 0;
  bool showPerfect = false;

  // Flag to prevent setState during build
  bool _isBuilding = false;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    // Defer game initialization to get theme from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGameWithTheme();
    });
  }

  void _initGameWithTheme() {
    final theme = ref.read(gameThemeProvider);
    _currentTheme = theme;
    _initGame(theme);
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
        _safeSetState(() => currentCombo = combo);
      }
      ..onBlocksUpdate = (blocks) {
        _safeSetState(() => blocksPlaced = blocks);
      }
      ..onPopulationUpdate = (pop) {
        _safeSetState(() => population = pop);
      }
      ..onGameOver = () {
        _safeHandleGameOver();
      }
      ..onPerfectPlacement = () {
        _showPerfectIndicator();
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

  void _safeHandleGameOver() {
    if (_isBuilding) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleGameOver();
        }
      });
    } else {
      _handleGameOver();
    }
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHighScore = prefs.getInt(_highScoreKey) ?? 0;
    setState(() => highScore = savedHighScore);
  }

  Future<void> _saveHighScore(int score) async {
    if (score > highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, score);
      setState(() => highScore = score);
    }
  }

  void _handleGameOver() {
    final isNewHigh = currentScore > highScore;
    if (isNewHigh) {
      _saveHighScore(currentScore);
    }
    setState(() => isGameOver = true);
  }

  void _pauseGame() {
    setState(() => isPaused = true);
    game.pauseGame();
  }

  void _resumeGame() {
    setState(() => isPaused = false);
    game.resumeGame();
  }

  void _restartGame() {
    setState(() {
      isGameOver = false;
      isPaused = false;
      currentScore = 0;
      currentCombo = 0;
      blocksPlaced = 0;
      population = 0;
    });
    game.reset();
  }

  void _exitGame() {
    Navigator.of(context).pop();
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

            // Tap to start overlay
            if (game.gameState == GameState.ready && !isPaused && !isGameOver)
              _TapToStartOverlay(),

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
                onRestart: _restartGame,
                onExit: _exitGame,
              ),

            // Perfect placement indicator
            if (showPerfect)
              const _PerfectIndicator(),
          ],
        ),
      ),
    );
  }
}

class _TapToStartOverlay extends StatelessWidget {
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
                child: const Text(
                  'TAP TO START',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
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
