import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/player_data_provider.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/haptic_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final AudioService _audioService = AudioService();
  final HapticService _hapticService = HapticService();

  @override
  Widget build(BuildContext context) {
    final playerData = ref.watch(playerDataProvider);
    final stats = playerData?.stats;
    final settings = playerData?.settings;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.homeGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Card
                      _buildProfileCard(playerData?.displayName ?? 'Player'),

                      const SizedBox(height: 24),

                      // Stats Section
                      _buildSectionTitle('Statistics'),
                      const SizedBox(height: 12),
                      _buildStatsCard(stats),

                      const SizedBox(height: 24),

                      // Settings Section
                      _buildSectionTitle('Settings'),
                      const SizedBox(height: 12),
                      _buildSettingsCard(settings),

                      const SizedBox(height: 24),

                      // About Section
                      _buildSectionTitle('About'),
                      const SizedBox(height: 12),
                      _buildAboutCard(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _audioService.playBack();
              _hapticService.lightTap();
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
          Text(
            'Profile & Settings',
            style: AppTextStyles.screenTitle.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String displayName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              gradient: AppColors.accentGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.screenTitle.copyWith(
                    color: AppColors.textDark,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tower Builder',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textDarkSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditNameDialog(displayName),
            icon: Icon(
              Icons.edit_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.screenTitle.copyWith(
        color: Colors.white,
        fontSize: 18,
      ),
    );
  }

  Widget _buildStatsCard(dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.emoji_events_rounded,
                  AppColors.perfect,
                  'High Score',
                  '${stats?.highScore ?? 0}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.games_rounded,
                  AppColors.primary,
                  'Games Played',
                  '${stats?.totalGamesPlayed ?? 0}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.view_module_rounded,
                  AppColors.secondary,
                  'Blocks Placed',
                  '${stats?.totalBlocksPlaced ?? 0}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.people_rounded,
                  AppColors.accent,
                  'Total Population',
                  '${stats?.totalPopulationHoused ?? 0}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.star_rounded,
                  Colors.amber,
                  'Perfect Drops',
                  '${stats?.totalPerfectDrops ?? 0}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.local_fire_department_rounded,
                  Colors.deepOrange,
                  'Best Combo',
                  '${stats?.longestCombo ?? 0}x',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.apartment_rounded,
                  AppColors.textDark,
                  'Highest Tower',
                  '${stats?.highestTower ?? 0}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.timer_rounded,
                  Colors.teal,
                  'Play Time',
                  _formatPlayTime(stats?.totalPlayTimeSeconds ?? 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDarkSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(dynamic settings) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            Icons.volume_up_rounded,
            'Sound Effects',
            settings?.soundEnabled ?? true,
            (value) {
              ref.read(playerDataProvider.notifier).updateSettings(
                    soundEnabled: value,
                  );
              _audioService.updateSettings(soundEnabled: value);
              if (value) _audioService.playTap();
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            Icons.music_note_rounded,
            'Music',
            settings?.musicEnabled ?? true,
            (value) {
              ref.read(playerDataProvider.notifier).updateSettings(
                    musicEnabled: value,
                  );
              _audioService.updateSettings(musicEnabled: value);
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            Icons.vibration_rounded,
            'Vibration',
            settings?.vibrationEnabled ?? true,
            (value) {
              ref.read(playerDataProvider.notifier).updateSettings(
                    vibrationEnabled: value,
                  );
              _hapticService.setEnabled(value);
              if (value) _hapticService.mediumTap();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildAboutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAboutTile(
            Icons.privacy_tip_rounded,
            'Privacy Policy',
            () => _openUrl('https://cyberixdigital.com/privacy'),
          ),
          _buildDivider(),
          _buildAboutTile(
            Icons.description_rounded,
            'Terms of Service',
            () => _openUrl('https://cyberixdigital.com/terms'),
          ),
          _buildDivider(),
          _buildAboutTile(
            Icons.info_rounded,
            'App Version',
            null,
            trailing: Text(
              '1.0.0',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textDarkSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTile(
    IconData icon,
    String title,
    VoidCallback? onTap, {
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textDarkSecondary,
                ),
          ],
        ),
      ),
    );
  }

  String _formatPlayTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${(seconds / 60).floor()}m';
    final hours = (seconds / 3600).floor();
    final mins = ((seconds % 3600) / 60).floor();
    return '${hours}h ${mins}m';
  }

  Future<void> _openUrl(String url) async {
    _audioService.playTap();
    _hapticService.lightTap();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showEditNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
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
                ref.read(playerDataProvider.notifier).updateDisplayName(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
