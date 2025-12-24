import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';
import 'routing/routes.dart';

class SkyStackApp extends ConsumerWidget {
  const SkyStackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Sky Stack',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
