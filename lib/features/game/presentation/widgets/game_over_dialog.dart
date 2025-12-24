import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final int blocksPlaced;
  final int population;
  final int? highScore;
  final bool isNewHighScore;
  final bool canContinue;
  final bool isAdLoading;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final VoidCallback? onContinue;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.blocksPlaced,
    required this.population,
    this.highScore,
    this.isNewHighScore = false,
    this.canContinue = false,
    this.isAdLoading = false,
    required this.onRestart,
    required this.onExit,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    gradient: isNewHighScore
                        ? AppColors.goldGradient
                        : AppColors.accentGradient,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (isNewHighScore) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'NEW HIGH SCORE!',
                          style: AppTextStyles.comboText.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.flag_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'GAME OVER',
                          style: AppTextStyles.screenTitle.copyWith(
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Score Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Column(
                    children: [
                      // Main Score
                      Text(
                        score.toString(),
                        style: AppTextStyles.scoreDisplay.copyWith(
                          color: AppColors.textDark,
                          fontSize: 56,
                        ),
                      ),
                      Text(
                        'POINTS',
                        style: AppTextStyles.hudLabel.copyWith(
                          color: AppColors.textDarkSecondary,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stats Row
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.textDark.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              icon: Icons.layers_rounded,
                              value: blocksPlaced.toString(),
                              label: 'Blocks',
                              color: AppColors.primary,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.textDark.withValues(alpha: 0.1),
                            ),
                            _StatItem(
                              icon: Icons.people_rounded,
                              value: population.toString(),
                              label: 'People',
                              color: AppColors.secondary,
                            ),
                            if (highScore != null) ...[
                              Container(
                                width: 1,
                                height: 40,
                                color: AppColors.textDark.withValues(alpha: 0.1),
                              ),
                              _StatItem(
                                icon: Icons.emoji_events_rounded,
                                value: highScore.toString(),
                                label: 'Best',
                                color: AppColors.perfect,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Continue Button (Watch Ad)
                      if (canContinue && onContinue != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isAdLoading ? null : onContinue,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.goldGradient,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.perfect.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isAdLoading)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      const SizedBox(width: 12),
                                      Text(
                                        isAdLoading ? 'Loading...' : 'Continue',
                                        style: AppTextStyles.buttonMedium.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (!isAdLoading) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.videocam_rounded,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'AD',
                                                style: AppTextStyles.hudLabel.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Play Again Button
                      SizedBox(
                        width: double.infinity,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onRestart,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: AppColors.successGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.replay_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Play Again',
                                    style: AppTextStyles.buttonMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Exit button
                      TextButton(
                        onPressed: onExit,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.home_rounded,
                              color: AppColors.textDarkSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Back to Menu',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textDarkSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.scoreLarge.copyWith(
            color: AppColors.textDark,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.hudLabel.copyWith(
            color: AppColors.textDarkSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
