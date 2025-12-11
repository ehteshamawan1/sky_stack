import 'package:flame/game.dart';
import 'package:flutter/material.dart';
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
  bool isPaused = false;
  bool isGameOver = false;
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _initGame();
  }

  void _initGame() {
    game = SkyStackGame()
      ..onScoreUpdate = (score) {
        setState(() => currentScore = score);
      }
      ..onComboUpdate = (combo) {
        setState(() => currentCombo = combo);
      }
      ..onBlocksUpdate = (blocks) {
        setState(() => blocksPlaced = blocks);
      }
      ..onGameOver = () {
        _handleGameOver();
      };
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
    });
    game.reset();
  }

  void _exitGame() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                highScore: highScore,
                isNewHighScore: currentScore > 0 && currentScore >= highScore,
                onRestart: _restartGame,
                onExit: _exitGame,
              ),
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
