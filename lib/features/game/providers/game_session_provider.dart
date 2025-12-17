import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/game_mode.dart';

/// Represents the current game session state
class GameSessionState {
  final GameMode mode;
  final int score;
  final int combo;
  final int lives;
  final int blocksPlaced;
  final int population;
  final bool isGameOver;
  final int continuesUsed;

  /// For City Builder mode - which slot we're building on
  final int? citySlotIndex;

  const GameSessionState({
    this.mode = GameMode.classic,
    this.score = 0,
    this.combo = 0,
    this.lives = ClassicModeConfig.initialLives,
    this.blocksPlaced = 0,
    this.population = 0,
    this.isGameOver = false,
    this.continuesUsed = 0,
    this.citySlotIndex,
  });

  /// Whether the player can continue (watch ad to revive)
  bool get canContinue =>
      isGameOver &&
      continuesUsed < ClassicModeConfig.maxContinues &&
      lives == 0;

  /// Whether the player has any lives remaining
  bool get hasLives => lives > 0;

  GameSessionState copyWith({
    GameMode? mode,
    int? score,
    int? combo,
    int? lives,
    int? blocksPlaced,
    int? population,
    bool? isGameOver,
    int? continuesUsed,
    int? citySlotIndex,
  }) {
    return GameSessionState(
      mode: mode ?? this.mode,
      score: score ?? this.score,
      combo: combo ?? this.combo,
      lives: lives ?? this.lives,
      blocksPlaced: blocksPlaced ?? this.blocksPlaced,
      population: population ?? this.population,
      isGameOver: isGameOver ?? this.isGameOver,
      continuesUsed: continuesUsed ?? this.continuesUsed,
      citySlotIndex: citySlotIndex ?? this.citySlotIndex,
    );
  }
}

/// Notifier that manages the game session state
class GameSessionNotifier extends StateNotifier<GameSessionState> {
  GameSessionNotifier() : super(const GameSessionState());

  /// Start a new game session
  void startGame({
    GameMode mode = GameMode.classic,
    int? citySlotIndex,
  }) {
    state = GameSessionState(
      mode: mode,
      lives: ClassicModeConfig.initialLives,
      citySlotIndex: citySlotIndex,
    );
  }

  /// Add score points
  void addScore(int points) {
    state = state.copyWith(score: state.score + points);
  }

  /// Set the current combo level
  void setCombo(int combo) {
    state = state.copyWith(combo: combo);
  }

  /// Increment blocks placed
  void incrementBlocks() {
    state = state.copyWith(blocksPlaced: state.blocksPlaced + 1);
  }

  /// Add to population count
  void addPopulation(int count) {
    state = state.copyWith(population: state.population + count);
  }

  /// Lose a life - returns true if game should end
  bool loseLife() {
    final newLives = state.lives - 1;
    if (newLives <= 0) {
      state = state.copyWith(lives: 0, isGameOver: true);
      return true;
    } else {
      state = state.copyWith(lives: newLives);
      return false;
    }
  }

  /// Use a continue (after watching rewarded ad)
  /// Returns true if continue was successful
  bool useContinue() {
    if (!state.canContinue) return false;

    state = state.copyWith(
      lives: 1, // Give one life back
      isGameOver: false,
      continuesUsed: state.continuesUsed + 1,
    );
    return true;
  }

  /// End the game
  void endGame() {
    state = state.copyWith(isGameOver: true);
  }

  /// Reset the session for a new game
  void reset() {
    state = GameSessionState(
      mode: state.mode,
      citySlotIndex: state.citySlotIndex,
    );
  }

  /// Update multiple values at once (used for syncing with game engine)
  void syncState({
    int? score,
    int? combo,
    int? blocksPlaced,
    int? population,
  }) {
    state = state.copyWith(
      score: score,
      combo: combo,
      blocksPlaced: blocksPlaced,
      population: population,
    );
  }
}

/// Provider for the game session
final gameSessionProvider =
    StateNotifierProvider<GameSessionNotifier, GameSessionState>((ref) {
  return GameSessionNotifier();
});
