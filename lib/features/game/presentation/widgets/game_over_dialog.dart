import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final int blocksPlaced;
  final int population;
  final int? highScore;
  final bool isNewHighScore;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.blocksPlaced,
    required this.population,
    this.highScore,
    this.isNewHighScore = false,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          color: AppColors.surface,
          margin: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game Over title
                Text(
                  'GAME OVER',
                  style: AppTextStyles.screenTitle.copyWith(
                    color: AppColors.bad,
                  ),
                ),

                const SizedBox(height: 24),

                // New high score indicator
                if (isNewHighScore)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.perfect,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'NEW HIGH SCORE!',
                      style: AppTextStyles.comboText.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),

                // Score
                Text(
                  'SCORE',
                  style: AppTextStyles.hudLabel,
                ),
                Text(
                  score.toString(),
                  style: AppTextStyles.scoreDisplay,
                ),

                const SizedBox(height: 16),

                // Blocks placed
                Text(
                  'BLOCKS PLACED',
                  style: AppTextStyles.hudLabel,
                ),
                Text(
                  blocksPlaced.toString(),
                  style: AppTextStyles.scoreLarge,
                ),

                const SizedBox(height: 16),

                // Population
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'POPULATION: $population',
                      style: AppTextStyles.hudLabel,
                    ),
                  ],
                ),

                if (highScore != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'BEST: $highScore',
                    style: AppTextStyles.bodySmall,
                  ),
                ],

                const SizedBox(height: 32),

                // Restart button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRestart,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Play Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Exit button
                TextButton(
                  onPressed: onExit,
                  child: Text(
                    'Exit',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
