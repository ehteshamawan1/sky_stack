import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/hive_service.dart';
import 'core/services/ad_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/haptic_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1a237e),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services in parallel where possible
  await Future.wait([
    // Initialize Firebase
    Firebase.initializeApp(),
    // Initialize Hive for local storage
    HiveService().initialize(),
  ]);

  // Initialize AdMob (can be done after app starts)
  AdService().initialize();

  // Initialize audio and haptic services
  AudioService().initialize();
  HapticService().initialize();

  runApp(
    const ProviderScope(
      child: SkyStackApp(),
    ),
  );
}
