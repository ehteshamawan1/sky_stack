import 'dart:math';
import '../../data/models/hazard_model.dart';

class HazardSystem {
  final Random _random = Random();

  HazardType? _activeHazard;
  double _activeRemaining = 0;

  HazardType? _pendingHazard;
  double _warningRemaining = 0;

  double _windStrength = 0;
  double _windDirection = 1;

  HazardType? get activeHazard => _activeHazard;
  HazardType? get pendingHazard => _pendingHazard;
  double get activeRemaining => _activeRemaining;
  double get warningRemaining => _warningRemaining;

  bool get hasActiveHazard => _activeHazard != null;
  bool get hasWarning => _pendingHazard != null;

  void update(double dt) {
    if (_warningRemaining > 0) {
      _warningRemaining -= dt;
      if (_warningRemaining <= 0 && _pendingHazard != null) {
        final type = _pendingHazard!;
        _pendingHazard = null;
        _warningRemaining = 0;
        _activate(type);
      }
    }

    if (_activeRemaining > 0) {
      _activeRemaining -= dt;
      if (_activeRemaining <= 0) {
        _activeHazard = null;
        _activeRemaining = 0;
        _windStrength = 0;
      }
    }
  }

  void clear() {
    _activeHazard = null;
    _activeRemaining = 0;
    _pendingHazard = null;
    _warningRemaining = 0;
    _windStrength = 0;
  }

  HazardType? rollForHazard(int blocksPlaced) {
    final eligible = HazardDefinition.launch.values
        .where((hazard) => blocksPlaced >= hazard.startBlock)
        .toList();
    if (eligible.isEmpty) return null;

    eligible.shuffle(_random);
    for (final hazard in eligible) {
      if (_random.nextDouble() < hazard.probability) {
        return hazard.type;
      }
    }

    return null;
  }

  void scheduleWarning(HazardType type, {double warningSeconds = 1.2}) {
    _pendingHazard = type;
    _warningRemaining = warningSeconds;
  }

  double getCraneSpeedMultiplier() {
    return _activeHazard == HazardType.fastCrane ? 1.5 : 1.0;
  }

  double getWindForce() {
    if (_activeHazard != HazardType.wind) return 0;
    return _windStrength * _windDirection;
  }

  void _activate(HazardType type) {
    _activeHazard = type;
    final definition = HazardDefinition.launch[type]!;
    _activeRemaining = definition.durationSeconds;

    if (type == HazardType.wind) {
      _windDirection = _random.nextBool() ? 1 : -1;
      _windStrength = 120 + _random.nextDouble() * 80;
    }
  }
}
