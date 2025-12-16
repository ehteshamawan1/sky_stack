import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../game_engine/sky_stack_game.dart';
import '../widgets/game_hud.dart';
import '../widgets/pause_menu.dart';
import '../widgets/game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SkyStackGame game;
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
    _initGame();
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

  void _initGame() {
    game = SkyStackGame()
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
    // TODO: Load from shared preferences
    setState(() => highScore = 0);
  }

  Future<void> _saveHighScore(int score) async {
    // TODO: Save to shared preferences
    if (score > highScore) {
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
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: 1.2),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 200),
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
              horizontal: 32,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Text(
              'PERFECT!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
