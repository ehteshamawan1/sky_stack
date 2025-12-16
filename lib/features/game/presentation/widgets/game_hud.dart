import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class GameHUD extends StatelessWidget {
  final int score;
  final int combo;
  final int population;
  final VoidCallback onPause;

  const GameHUD({
    super.key,
    required this.score,
    required this.combo,
    required this.population,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Left side: Score and Population
            Positioned(
              left: 0,
              top: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Score
                  Text(
                    'SCORE',
                    style: AppTextStyles.hudLabel,
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      score.toString(),
                      key: ValueKey(score),
                      style: AppTextStyles.hudValue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Population
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/ui/icon_person.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textSecondary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          population.toString(),
                          key: ValueKey(population),
                          style: AppTextStyles.hudLabel.copyWith(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Center: Combo indicator (absolutely positioned)
            if (combo > 0)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      'COMBO x$combo',
                      style: AppTextStyles.comboText,
                    ),
                  ),
                ),
              ),

            // Right side: Pause button
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: onPause,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    'assets/svg/ui/btn_pause.svg',
                    width: 28,
                    height: 28,
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
