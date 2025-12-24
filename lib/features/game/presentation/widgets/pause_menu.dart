import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(28),
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
                // Pause icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.homeGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pause_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'PAUSED',
                  style: AppTextStyles.screenTitle.copyWith(
                    color: AppColors.textDark,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 28),

                // Resume button (primary)
                _MenuButton(
                  onPressed: onResume,
                  icon: Icons.play_arrow_rounded,
                  label: 'Resume',
                  gradient: AppColors.successGradient,
                ),
                const SizedBox(height: 12),

                // Restart button
                _MenuButton(
                  onPressed: onRestart,
                  icon: Icons.refresh_rounded,
                  label: 'Restart',
                  gradient: AppColors.accentGradient,
                ),
                const SizedBox(height: 12),

                // Exit button (text style)
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
                        'Exit to Menu',
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
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Gradient gradient;

  const _MenuButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (gradient.colors.first).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
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
