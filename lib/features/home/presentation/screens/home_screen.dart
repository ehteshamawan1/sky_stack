import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../routing/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Title
                Text(
                  'SKY STACK',
                  style: AppTextStyles.gameTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Build the tallest tower!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const Spacer(flex: 2),

                // Play Button
                _PlayButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.game);
                  },
                ),

                const SizedBox(height: 40),

                // High Score display
                FutureBuilder<int>(
                  future: _getHighScore(),
                  builder: (context, snapshot) {
                    final highScore = snapshot.data ?? 0;
                    return Column(
                      children: [
                        Text(
                          'HIGH SCORE',
                          style: AppTextStyles.hudLabel,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          highScore.toString(),
                          style: AppTextStyles.scoreLarge,
                        ),
                      ],
                    );
                  },
                ),

                const Spacer(flex: 3),

                // Settings button
                IconButton(
                  onPressed: () {
                    // TODO: Navigate to settings
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<int> _getHighScore() async {
    // TODO: Implement with shared preferences
    return 0;
  }
}

class _PlayButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PlayButton({required this.onPressed});

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: 64,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          elevation: 8,
          shadowColor: AppColors.accent.withValues(alpha: 0.5),
        ),
        child: Text(
          'PLAY',
          style: AppTextStyles.buttonLarge,
        ),
      ),
    );
  }
}
