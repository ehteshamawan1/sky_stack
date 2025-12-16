import '../../../../core/constants/app_constants.dart';

enum PlacementQuality { perfect, good, bad }

class ScoringSystem {
  int calculateScore(PlacementQuality quality, int combo) {
    int baseScore;

    switch (quality) {
      case PlacementQuality.perfect:
        baseScore = AppConstants.perfectScore;
        break;
      case PlacementQuality.good:
        baseScore = AppConstants.goodScore;
        break;
      case PlacementQuality.bad:
        baseScore = AppConstants.badScore;
        break;
    }

    // Apply combo multiplier (1x to 10x based on combo level)
    // Combo 0 = 1x, Combo 1 = 2x, ... Combo 9+ = 10x
    final multiplier = (combo + 1).clamp(1, AppConstants.maxCombo);
    return baseScore * multiplier;
  }
}
