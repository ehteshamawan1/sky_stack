import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/city_model.dart';

/// Widget representing a single building slot in the city grid
class BuildingSlotWidget extends StatelessWidget {
  final BuildingSlot slot;
  final double size;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const BuildingSlotWidget({
    super.key,
    required this.slot,
    required this.size,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: slot.isBuilt
              ? Colors.white
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: slot.isBuilt
                ? AppColors.secondary.withOpacity(0.5)
                : Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: slot.isBuilt
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: slot.isBuilt ? _buildBuiltSlot() : _buildEmptySlot(),
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_rounded,
            color: Colors.white.withOpacity(0.8),
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'TAP TO\nBUILD',
          textAlign: TextAlign.center,
          style: AppTextStyles.hudLabel.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildBuiltSlot() {
    final floors = slot.towerHeight ?? 0;
    final pop = slot.population ?? 0;
    final score = slot.score ?? 0;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Building icon with floor count
          Stack(
            alignment: Alignment.center,
            children: [
              _buildBuildingIcon(floors),
            ],
          ),
          const SizedBox(height: 4),

          // Floor count
          Text(
            '$floors floors',
            style: AppTextStyles.hudLabel.copyWith(
              color: AppColors.textDark,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Population and score
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_rounded,
                size: 10,
                color: AppColors.textDarkSecondary,
              ),
              const SizedBox(width: 2),
              Text(
                '$pop',
                style: TextStyle(
                  color: AppColors.textDarkSecondary,
                  fontSize: 9,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.star_rounded,
                size: 10,
                color: AppColors.perfect,
              ),
              const SizedBox(width: 2),
              Text(
                _formatScore(score),
                style: TextStyle(
                  color: AppColors.textDarkSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingIcon(int floors) {
    // Different building appearance based on height
    Color buildingColor;
    IconData buildingIcon;

    if (floors >= 20) {
      buildingColor = AppColors.perfect;
      buildingIcon = Icons.apartment_rounded;
    } else if (floors >= 15) {
      buildingColor = AppColors.secondary;
      buildingIcon = Icons.business_rounded;
    } else if (floors >= 10) {
      buildingColor = AppColors.primary;
      buildingIcon = Icons.location_city_rounded;
    } else if (floors >= 5) {
      buildingColor = AppColors.good;
      buildingIcon = Icons.home_work_rounded;
    } else {
      buildingColor = AppColors.textDarkSecondary;
      buildingIcon = Icons.home_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: buildingColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        buildingIcon,
        color: buildingColor,
        size: 28,
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return '$score';
  }
}

/// Animated building slot with pulse effect for empty slots
class AnimatedBuildingSlot extends StatefulWidget {
  final BuildingSlot slot;
  final double size;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const AnimatedBuildingSlot({
    super.key,
    required this.slot,
    required this.size,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<AnimatedBuildingSlot> createState() => _AnimatedBuildingSlotState();
}

class _AnimatedBuildingSlotState extends State<AnimatedBuildingSlot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (!widget.slot.isBuilt) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedBuildingSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.slot.isBuilt && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    } else if (!widget.slot.isBuilt && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slot.isBuilt) {
      return BuildingSlotWidget(
        slot: widget.slot,
        size: widget.size,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
      );
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: BuildingSlotWidget(
        slot: widget.slot,
        size: widget.size,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
      ),
    );
  }
}
