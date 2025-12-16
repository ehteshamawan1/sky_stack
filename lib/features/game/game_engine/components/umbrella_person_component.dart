import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A little person floating down with an umbrella
/// They appear when blocks are placed and float into the building
class UmbrellaPersonComponent extends PositionComponent with HasGameReference {
  final Vector2 targetPosition;
  final VoidCallback? onArrived;

  // Movement parameters
  static const double floatSpeed = 80.0;
  static const double swayAmplitude = 20.0;
  static const double swayFrequency = 3.0;

  double _elapsedTime = 0;
  double _initialX = 0;
  bool _hasArrived = false;

  // Visual components
  late RectangleComponent umbrellaTop;
  late RectangleComponent umbrellaHandle;
  late RectangleComponent personBody;
  late RectangleComponent personHead;

  UmbrellaPersonComponent({
    required Vector2 startPosition,
    required this.targetPosition,
    this.onArrived,
  }) : super(
    position: startPosition,
    size: Vector2(20, 30),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initialX = position.x;

    // Random color for variety
    final random = Random();
    final personColor = Color.fromRGBO(
      100 + random.nextInt(100),
      100 + random.nextInt(100),
      150 + random.nextInt(100),
      1,
    );

    // Umbrella top (dome shape approximated with rectangle)
    umbrellaTop = RectangleComponent(
      size: Vector2(18, 8),
      position: Vector2(-9, -15),
      paint: Paint()..color = Colors.red.shade400,
    );
    add(umbrellaTop);

    // Umbrella handle
    umbrellaHandle = RectangleComponent(
      size: Vector2(2, 10),
      position: Vector2(-1, -7),
      paint: Paint()..color = Colors.brown.shade600,
    );
    add(umbrellaHandle);

    // Person head
    personHead = RectangleComponent(
      size: Vector2(6, 6),
      position: Vector2(-3, 3),
      paint: Paint()..color = const Color(0xFFFFDBB4), // Skin tone
    );
    add(personHead);

    // Person body
    personBody = RectangleComponent(
      size: Vector2(8, 10),
      position: Vector2(-4, 9),
      paint: Paint()..color = personColor,
    );
    add(personBody);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_hasArrived) return;

    _elapsedTime += dt;

    // Float down towards target
    final distanceToTarget = targetPosition.y - position.y;

    if (distanceToTarget > 5) {
      // Move down
      position.y += floatSpeed * dt;

      // Gentle side-to-side sway while floating
      position.x = _initialX + sin(_elapsedTime * swayFrequency) * swayAmplitude;
    } else {
      // Arrived at building
      _hasArrived = true;
      onArrived?.call();

      // Fade out and remove after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        removeFromParent();
      });
    }
  }
}
