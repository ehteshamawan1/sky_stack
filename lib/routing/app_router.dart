import 'package:flutter/material.dart';
import 'routes.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/profile_screen.dart';
import '../features/game/presentation/screens/game_screen.dart';
import '../features/game/data/models/game_mode.dart';
import '../features/city_builder/presentation/screens/city_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case Routes.game:
        // Parse arguments for game mode
        final args = settings.arguments as Map<String, dynamic>?;
        final mode = args?['mode'] as GameMode? ?? GameMode.classic;
        final slotIndex = args?['slotIndex'] as int?;

        return MaterialPageRoute(
          builder: (_) => GameScreen(
            mode: mode,
            citySlotIndex: slotIndex,
          ),
        );

      case Routes.cityBuilder:
        return MaterialPageRoute(
          builder: (_) => const CityScreen(),
        );

      case Routes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      // TODO: Add more routes as features are implemented
      // case Routes.settings:
      // case Routes.leaderboard:
      // case Routes.shop:
      // case Routes.achievements:
      // case Routes.challenges:
      // case Routes.story:

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
