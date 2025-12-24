import '../../../../core/constants/asset_paths.dart';

enum PowerUpType {
  slowMotion,
  stabilizer,
  magnetSnap,
}

class PowerUpDefinition {
  final PowerUpType type;
  final String name;
  final String description;
  final double durationSeconds;
  final String iconPath;

  const PowerUpDefinition({
    required this.type,
    required this.name,
    required this.description,
    required this.durationSeconds,
    required this.iconPath,
  });

  static const Map<PowerUpType, PowerUpDefinition> launch = {
    PowerUpType.slowMotion: PowerUpDefinition(
      type: PowerUpType.slowMotion,
      name: 'Slow Motion',
      description: 'Slows crane swing for a short time',
      durationSeconds: 10,
      iconPath: AssetPaths.powerupSlowMotion,
    ),
    PowerUpType.stabilizer: PowerUpDefinition(
      type: PowerUpType.stabilizer,
      name: 'Stabilizer',
      description: 'Reduces tower sway for a short time',
      durationSeconds: 15,
      iconPath: AssetPaths.powerupStabilizer,
    ),
    PowerUpType.magnetSnap: PowerUpDefinition(
      type: PowerUpType.magnetSnap,
      name: 'Magnet Snap',
      description: 'Auto-aligns near-perfect drops',
      durationSeconds: 8,
      iconPath: AssetPaths.powerupMagnet,
    ),
  };
}
