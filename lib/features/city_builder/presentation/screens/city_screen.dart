import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../routing/routes.dart';
import '../../../game/data/models/game_mode.dart';
import '../../providers/city_provider.dart';
import '../widgets/city_grid.dart';
import '../widgets/city_stats_header.dart';

/// City Builder screen showing the 3x3 grid of building slots
class CityScreen extends ConsumerStatefulWidget {
  const CityScreen({super.key});

  @override
  ConsumerState<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends ConsumerState<CityScreen> {
  final AudioService _audioService = AudioService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh city data when returning to this screen
    ref.read(cityProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(cityProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.skyGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // City Stats
              if (city != null) CityStatsHeader(city: city),

              // City Grid
              Expanded(
                child: city == null
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: CityGrid(
                          city: city,
                          onSlotTap: (slotIndex) {
                            _navigateToGame(slotIndex);
                          },
                          onSlotLongPress: (slotIndex) {
                            _showSlotOptions(slotIndex);
                          },
                        ),
                      ),
              ),

              // Bottom info
              _buildBottomInfo(city),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final city = ref.watch(cityProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              _audioService.playBack();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city?.name ?? 'My City',
                  style: AppTextStyles.screenTitle.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'Tap a slot to build!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Settings/Options button
          GestureDetector(
            onTap: () {
              _audioService.playTap();
              _showCityOptions();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(dynamic city) {
    final buildingsCount = city?.buildingsCount ?? 0;
    const totalSlots = 9;
    final isComplete = city?.isComplete ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (isComplete)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.perfect.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'CITY COMPLETE!',
                    style: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
                  ),
                ],
              ),
            )
          else
            Text(
              '$buildingsCount / $totalSlots buildings complete',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToGame(int slotIndex) async {
    _audioService.playTap();
    await Navigator.pushNamed(
      context,
      Routes.game,
      arguments: {
        'mode': GameMode.cityBuilder,
        'slotIndex': slotIndex,
      },
    );
    // Refresh when returning
    ref.read(cityProvider.notifier).refresh();
  }

  void _showSlotOptions(int slotIndex) {
    final cityNotifier = ref.read(cityProvider.notifier);
    final slot = cityNotifier.getSlot(slotIndex);

    if (slot == null || !slot.isBuilt) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Building ${slotIndex + 1}',
              style: AppTextStyles.screenTitle.copyWith(
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${slot.towerHeight} floors • ${slot.population} residents',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDarkSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Rebuild option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              ),
              title: Text(
                'Rebuild',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Start over on this slot',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDarkSecondary,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToGame(slotIndex);
              },
            ),

            // Demolish option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bad.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: AppColors.bad),
              ),
              title: Text(
                'Demolish',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Clear this building',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDarkSecondary,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDemolish(slotIndex);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDemolish(int slotIndex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Demolish Building?'),
        content: const Text(
          'This will permanently remove this building from your city. '
          'The score and population will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cityProvider.notifier).clearSlot(slotIndex);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.bad),
            child: const Text('Demolish'),
          ),
        ],
      ),
    );
  }

  void _showCityOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'City Options',
              style: AppTextStyles.screenTitle.copyWith(
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),

            // Rename city
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_rounded, color: AppColors.primary),
              ),
              title: Text(
                'Rename City',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog();
              },
            ),

            // Reset city
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bad.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restart_alt_rounded, color: AppColors.bad),
              ),
              title: Text(
                'Reset City',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Clear all buildings',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDarkSecondary,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmReset();
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog() {
    final controller = TextEditingController(
      text: ref.read(cityProvider)?.name ?? 'My City',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename City'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter city name',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(cityProvider.notifier).renameCity(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset City?'),
        content: const Text(
          'This will permanently delete all buildings in your city. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cityProvider.notifier).resetCity();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.bad),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
