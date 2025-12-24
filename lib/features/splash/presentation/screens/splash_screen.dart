import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/player_data_provider.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/hive_service.dart';
import '../../../game/game_engine/utils/svg_cache.dart';
import '../../../../routing/routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  double _progress = 0.0;
  String _message = 'Loading...';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _progress = 0.0;
      _message = 'Starting...';
      _errorMessage = null;
    });

    try {
      setState(() {
        _progress = 0.1;
        _message = 'Initializing storage...';
      });
      await HiveService().initialize();

      setState(() {
        _progress = 0.25;
        _message = 'Loading your profile...';
      });
      await ref.read(playerDataProvider.notifier).refresh();

      final themeId = ref.read(selectedThemeProvider);
      setState(() {
        _progress = 0.45;
        _message = 'Loading graphics...';
      });
      await SvgCache().preloadTheme(themeId);

      setState(() {
        _progress = 0.65;
        _message = 'Loading audio...';
      });
      await AudioService().initialize();

      setState(() {
        _progress = 0.8;
        _message = 'Preparing ads...';
      });
      await AdService().initialize();

      setState(() {
        _progress = 0.95;
        _message = 'Almost ready...';
      });
      await Future.delayed(const Duration(milliseconds: 200));

      setState(() {
        _progress = 1.0;
        _message = 'Ready!';
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load game data. Please retry.';
          _message = 'Loading failed';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF3949AB),
              Color(0xFF4ECDC4),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.layers,
                size: 96,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'SKY STACK',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 240,
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 4,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _message,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadAssets,
                        child: const Text('Retry'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
