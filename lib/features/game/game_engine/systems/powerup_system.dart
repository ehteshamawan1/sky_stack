import '../../data/models/powerup_model.dart';

class PowerUpSystem {
  final Map<PowerUpType, double> _timers = {};
  PowerUpType? _activePowerUp;

  PowerUpType? get activePowerUp => _activePowerUp;

  bool get hasActivePowerUp => _activePowerUp != null;

  double remainingSeconds(PowerUpType type) => _timers[type] ?? 0;

  void activate(PowerUpType type, double durationSeconds) {
    _timers.clear();
    _activePowerUp = type;
    if (durationSeconds > 0) {
      _timers[type] = durationSeconds;
    }
  }

  void clear() {
    _timers.clear();
    _activePowerUp = null;
  }

  void update(double dt) {
    if (_timers.isEmpty) return;

    final expired = <PowerUpType>[];
    _timers.forEach((type, remaining) {
      final next = remaining - dt;
      _timers[type] = next;
      if (next <= 0) {
        expired.add(type);
      }
    });

    for (final type in expired) {
      _timers.remove(type);
      if (_activePowerUp == type) {
        _activePowerUp = null;
      }
    }
  }

  bool isActive(PowerUpType type) => _timers.containsKey(type);

  double getSwingSpeedMultiplier() {
    return isActive(PowerUpType.slowMotion) ? 0.5 : 1.0;
  }

  double getWobbleMultiplier() {
    return isActive(PowerUpType.stabilizer) ? 0.2 : 1.0;
  }

  double getMagnetSnapRange() {
    return isActive(PowerUpType.magnetSnap) ? 20.0 : 0.0;
  }
}
