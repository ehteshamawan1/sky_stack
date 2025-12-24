import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/powerup_model.dart';
import '../../data/models/hazard_model.dart';

class GameHUD extends StatelessWidget {
  final int score;
  final int combo;
  final int population;
  final PowerUpType? activePowerUp;
  final double powerUpRemaining;
  final HazardType? activeHazard;
  final double hazardRemaining;
  final HazardType? warningHazard;
  final double warningRemaining;
  final VoidCallback onPause;

  const GameHUD({
    super.key,
    required this.score,
    required this.combo,
    required this.population,
    this.activePowerUp,
    this.powerUpRemaining = 0,
    this.activeHazard,
    this.hazardRemaining = 0,
    this.warningHazard,
    this.warningRemaining = 0,
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

            if (warningHazard != null && warningRemaining > 0)
              Positioned(
                left: 0,
                right: 0,
                top: combo > 0 ? 46 : 0,
                child: Center(
                  child: _StatusPill(
                    label: '${_hazardLabel(warningHazard!)} INCOMING',
                    backgroundColor: const Color(0xFFB83232),
                    foregroundColor: Colors.white,
                    iconAsset: AssetPaths.iconStar,
                  ),
                ),
              ),

            // Right side: Pause button
            Positioned(
              right: 0,
              top: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
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
                  if (activePowerUp != null && powerUpRemaining > 0) ...[
                    const SizedBox(height: 10),
                    _StatusPill(
                      label: _powerUpLabel(activePowerUp!),
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      iconAsset: PowerUpDefinition.launch[activePowerUp!]!.iconPath,
                      timeRemaining: powerUpRemaining,
                    ),
                  ],
                  if (activeHazard != null && hazardRemaining > 0) ...[
                    const SizedBox(height: 10),
                    _StatusPill(
                      label: _hazardLabel(activeHazard!),
                      backgroundColor: const Color(0xFF8A2E2E),
                      foregroundColor: Colors.white,
                      iconAsset: AssetPaths.iconStar,
                      timeRemaining: hazardRemaining,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _powerUpLabel(PowerUpType type) {
    return PowerUpDefinition.launch[type]?.name ?? 'Power Up';
  }

  String _hazardLabel(HazardType type) {
    return HazardDefinition.launch[type]?.name.toUpperCase() ?? 'HAZARD';
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final String iconAsset;
  final double? timeRemaining;

  const _StatusPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.iconAsset,
    this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final showTime = timeRemaining != null && timeRemaining! > 0;
    final timeText = showTime ? '${timeRemaining!.ceil()}s' : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(
              foregroundColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.hudLabel.copyWith(
              fontSize: 12,
              color: foregroundColor,
            ),
          ),
          if (timeText != null) ...[
            const SizedBox(width: 6),
            Text(
              timeText,
              style: AppTextStyles.hudLabel.copyWith(
                fontSize: 12,
                color: foregroundColor.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
