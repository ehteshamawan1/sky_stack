import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Service for managing haptic feedback and vibration
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _isEnabled = true;
  bool _hasVibrator = false;
  bool _hasAmplitudeControl = false;
  bool _isInitialized = false;

  bool get isEnabled => _isEnabled;

  /// Initialize the haptic service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _hasVibrator = await Vibration.hasVibrator() ?? false;
      _hasAmplitudeControl = await Vibration.hasAmplitudeControl() ?? false;
      _isInitialized = true;
    } catch (e) {
      _hasVibrator = false;
      _hasAmplitudeControl = false;
    }
  }

  /// Enable or disable haptic feedback
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Light tap feedback (UI interactions)
  Future<void> lightTap() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium tap feedback (button presses)
  Future<void> mediumTap() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap feedback (important actions)
  Future<void> heavyTap() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection feedback
  Future<void> selection() async {
    if (!_isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Block drop feedback - quick light vibration
  Future<void> blockDrop() async {
    if (!_isEnabled || !_hasVibrator) return;

    if (_hasAmplitudeControl) {
      await Vibration.vibrate(duration: 30, amplitude: 64);
    } else {
      await HapticFeedback.lightImpact();
    }
  }

  /// Perfect placement feedback - satisfying double pulse
  Future<void> perfectPlacement() async {
    if (!_isEnabled || !_hasVibrator) return;

    if (_hasAmplitudeControl) {
      await Vibration.vibrate(
        pattern: [0, 40, 60, 40],
        intensities: [0, 128, 0, 200],
      );
    } else {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
    }
  }

  /// Good placement feedback - medium pulse
  Future<void> goodPlacement() async {
    if (!_isEnabled || !_hasVibrator) return;

    if (_hasAmplitudeControl) {
      await Vibration.vibrate(duration: 50, amplitude: 100);
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Bad placement feedback - weak pulse
  Future<void> badPlacement() async {
    if (!_isEnabled || !_hasVibrator) return;

    if (_hasAmplitudeControl) {
      await Vibration.vibrate(duration: 30, amplitude: 50);
    } else {
      await HapticFeedback.lightImpact();
    }
  }

  /// Block fall/game over feedback - longer warning vibration
  Future<void> blockFall() async {
    if (!_isEnabled || !_hasVibrator) return;

    if (_hasAmplitudeControl) {
      await Vibration.vibrate(
        pattern: [0, 100, 50, 100],
        intensities: [0, 200, 0, 150],
      );
    } else {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
    }
  }

  /// Game over feedback - dramatic vibration
  Future<void> gameOver() async {
    if (!_isEnabled || !_hasVibrator) return;

    if (_hasAmplitudeControl) {
      await Vibration.vibrate(
        pattern: [0, 150, 100, 150, 100, 200],
        intensities: [0, 255, 0, 200, 0, 150],
      );
    } else {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.mediumImpact();
    }
  }

  /// Combo feedback - intensity based on combo level
  Future<void> combo(int level) async {
    if (!_isEnabled || !_hasVibrator) return;

    final intensity = (level.clamp(1, 10) * 20 + 50).clamp(50, 255);

    if (_hasAmplitudeControl) {
      await Vibration.vibrate(duration: 40, amplitude: intensity);
    } else {
      if (level >= 5) {
        await HapticFeedback.heavyImpact();
      } else {
        await HapticFeedback.mediumImpact();
      }
    }
  }

  /// Achievement unlocked feedback
  Future<void> achievement() async {
    if (!_isEnabled || !_hasVibrator) return;

    if (_hasAmplitudeControl) {
      await Vibration.vibrate(
        pattern: [0, 50, 50, 50, 50, 100],
        intensities: [0, 150, 0, 200, 0, 255],
      );
    } else {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
    }
  }

  /// Cancel any ongoing vibration
  Future<void> cancel() async {
    if (_hasVibrator) {
      await Vibration.cancel();
    }
  }
}
