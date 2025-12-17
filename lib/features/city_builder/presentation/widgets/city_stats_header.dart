import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/city_model.dart';

/// Header widget showing city statistics
class CityStatsHeader extends StatelessWidget {
  final CityModel city;

  const CityStatsHeader({
    super.key,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.location_city_rounded,
            value: '${city.buildingsCount}/${CityModel.totalSlots}',
            label: 'Buildings',
            color: AppColors.primary,
          ),
          _Divider(),
          _StatItem(
            icon: Icons.people_rounded,
            value: _formatNumber(city.totalPopulation),
            label: 'Population',
            color: AppColors.secondary,
          ),
          _Divider(),
          _StatItem(
            icon: Icons.star_rounded,
            value: _formatNumber(city.totalScore),
            label: 'Total Score',
            color: AppColors.perfect,
          ),
          _Divider(),
          _StatItem(
            icon: Icons.height_rounded,
            value: '${city.highestTower}',
            label: 'Highest',
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '$number';
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
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.scoreLarge.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.hudLabel.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.2),
    );
  }
}

/// Compact version of city stats for smaller spaces
class CityStatsCompact extends StatelessWidget {
  final CityModel city;

  const CityStatsCompact({
    super.key,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_city_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${city.buildingsCount}/${CityModel.totalSlots}',
            style: AppTextStyles.hudLabel.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.star_rounded,
            color: AppColors.perfect,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            _formatScore(city.totalScore),
            style: AppTextStyles.hudLabel.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(0)}K';
    }
    return '$score';
  }
}
