import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class GameHUD extends StatelessWidget {
  final int score;
  final int combo;
  final VoidCallback onPause;

  const GameHUD({
    super.key,
    required this.score,
    required this.combo,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
              ],
            ),

            // Combo indicator
            if (combo > 0)
              AnimatedContainer(
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

            // Pause button
            IconButton(
              onPressed: onPause,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pause,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
