import 'package:flutter/material.dart';
import 'routes.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/game/presentation/screens/game_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case Routes.game:
        return MaterialPageRoute(
          builder: (_) => const GameScreen(),
        );

      // TODO: Add more routes as features are implemented

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
