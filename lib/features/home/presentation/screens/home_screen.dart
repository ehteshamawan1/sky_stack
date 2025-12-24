import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/player_data_provider.dart';
import '../../../../core/services/asset_preloader.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../routing/routes.dart';
import '../../../game/providers/theme_provider.dart';
import '../../../city_builder/providers/city_provider.dart';
import '../widgets/theme_selector_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final AssetPreloader _preloader = AssetPreloader();
  final AudioService _audioService = AudioService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh player data when returning to this screen
    ref.read(playerDataProvider.notifier).refresh();
    // Preload game assets in background
    _preloader.preloadAssets(context);
    // Also preload the selected theme
    final selectedTheme = ref.read(gameThemeProvider);
    _preloader.preloadTheme(selectedTheme);
    // Load audio settings
    _initAudioSettings();
  }

  void _initAudioSettings() {
    final playerData = ref.read(playerDataProvider);
    if (playerData != null) {
      _audioService.updateSettings(
        soundEnabled: playerData.settings.soundEnabled,
        musicEnabled: playerData.settings.musicEnabled,
        masterVolume: playerData.settings.masterVolume,
        sfxVolume: playerData.settings.sfxVolume,
        musicVolume: playerData.settings.musicVolume,
      );
    }
  }

  void _navigateToGame() async {
    _audioService.playTap();
    await Navigator.pushNamed(context, Routes.game);
    // Refresh data when returning from game
    ref.read(playerDataProvider.notifier).refresh();
  }

  void _navigateToCityBuilder() async {
    _audioService.playTap();
    await Navigator.pushNamed(context, Routes.cityBuilder);
    // Refresh data when returning
    ref.read(playerDataProvider.notifier).refresh();
    ref.read(cityProvider.notifier).refresh();
  }

  void _navigateToProfile() {
    _audioService.playTap();
    Navigator.pushNamed(context, Routes.profile);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(gameThemeProvider);
    final theme = GameTheme.all.firstWhere((t) => t.id == currentTheme);
    final highScore = ref.watch(highScoreProvider);
    final city = ref.watch(cityProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.homeGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                top: 150,
                left: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),

              // Profile button (top-right)
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: _navigateToProfile,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),

              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // App Icon with glow
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'assets/svg/ui/app_icon.svg',
                          width: 80,
                          height: 80,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title with shadow
                      Text(
                        'SKY STACK',
                        style: AppTextStyles.gameTitle.copyWith(
                          fontSize: 36,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Build the tallest tower!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Game Mode Buttons
                      _GameModeButton(
                        icon: Icons.play_arrow_rounded,
                        title: 'CLASSIC',
                        subtitle: 'Endless stacking',
                        gradient: AppColors.successGradient,
                        glowColor: AppColors.secondary,
                        onPressed: _navigateToGame,
                        isPrimary: true,
                      ),

                      const SizedBox(height: 16),

                      _GameModeButton(
                        icon: Icons.location_city_rounded,
                        title: 'CITY BUILDER',
                        subtitle: city != null
                            ? '${city.buildingsCount}/9 buildings'
                            : 'Build your city',
                        gradient: AppColors.accentGradient,
                        glowColor: AppColors.accent,
                        onPressed: _navigateToCityBuilder,
                      ),

                      const SizedBox(height: 32),

                      // High Score Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                gradient: AppColors.goldGradient,
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                'assets/svg/ui/icon_star.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'HIGH SCORE',
                                  style: AppTextStyles.hudLabel.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  highScore.toString(),
                                  style: AppTextStyles.scoreLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Theme selector button
                      GestureDetector(
                        onTap: () {
                          _audioService.playTap();
                          showThemeSelector(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: theme.previewColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                theme.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

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
}

class _GameModeButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final Color glowColor;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _GameModeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.glowColor,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_GameModeButton> createState() => _GameModeButtonState();
}

class _GameModeButtonState extends State<_GameModeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPrimary) {
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
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );

    if (!widget.isPrimary) {
      return button;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: _glowAnimation.value),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: button,
    );
  }
}
