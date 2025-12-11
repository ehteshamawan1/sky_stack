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

    // Apply combo multiplier
    final multiplier = 1 + (combo * AppConstants.comboMultiplier);
    return (baseScore * multiplier).round();
  }
}
