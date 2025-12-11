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
                Text(
                  'PAUSED',
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: 32),

                // Resume button
                _MenuButton(
                  onPressed: onResume,
                  icon: Icons.play_arrow,
                  label: 'Resume',
                  isPrimary: true,
                ),
                const SizedBox(height: 16),

                // Restart button
                _MenuButton(
                  onPressed: onRestart,
                  icon: Icons.refresh,
                  label: 'Restart',
                ),
                const SizedBox(height: 16),

                // Exit button
                _MenuButton(
                  onPressed: onExit,
                  icon: Icons.exit_to_app,
                  label: 'Exit',
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
  final bool isPrimary;

  const _MenuButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.accent : AppColors.surfaceLight,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
