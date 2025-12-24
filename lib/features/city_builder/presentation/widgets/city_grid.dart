import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/city_model.dart';
import 'building_slot_widget.dart';

/// 3x3 grid of building slots for the city
class CityGrid extends StatelessWidget {
  final CityModel city;
  final Function(int) onSlotTap;
  final Function(int)? onSlotLongPress;

  const CityGrid({
    super.key,
    required this.city,
    required this.onSlotTap,
    this.onSlotLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal size for slots
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final gridSize = availableWidth < availableHeight
            ? availableWidth
            : availableHeight * 0.9;
        final slotSize = (gridSize - 24) / 3; // 3 slots with spacing

        return Center(
          child: SizedBox(
            width: gridSize,
            height: gridSize,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: CityModel.totalSlots,
              itemBuilder: (context, index) {
                final slot = city.getSlot(index);
                return BuildingSlotWidget(
                  slot: slot,
                  size: slotSize,
                  onTap: () => onSlotTap(index),
                  onLongPress: onSlotLongPress != null
                      ? () => onSlotLongPress!(index)
                      : null,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Widget showing city progress as a visual bar
class CityProgressBar extends StatelessWidget {
  final int buildingsCount;
  final int totalSlots;

  const CityProgressBar({
    super.key,
    required this.buildingsCount,
    required this.totalSlots,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSlots > 0 ? buildingsCount / totalSlots : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'City Progress',
                style: AppTextStyles.hudLabel.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '$buildingsCount / $totalSlots',
                style: AppTextStyles.hudLabel.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppColors.perfect : AppColors.secondary,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
