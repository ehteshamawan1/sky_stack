import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class CraneComponent extends PositionComponent with HasGameReference {
  final double gameWidth;
  double swingAngle = 0;
  double swingDirection = 1;
  double _speedMultiplier = 1.0;

  // Visual elements
  late RectangleComponent armComponent;
  late RectangleComponent ropeComponent;
  late RectangleComponent hookComponent;

  CraneComponent({
    required Vector2 position,
    required this.gameWidth,
  }) : super(position: position);

  Vector2 get hookPosition {
    final swingOffset = sin(swingAngle) * (gameWidth / 2 - 60);
    return Vector2(
      gameWidth / 2 + swingOffset,
      position.y + 50,
    );
  }

  void setSpeedMultiplier(double multiplier) {
    _speedMultiplier = multiplier;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Crane arm (horizontal bar at top)
    armComponent = RectangleComponent(
      size: Vector2(gameWidth - 60, 12),
      position: Vector2(-gameWidth / 2 + 30, -6),
      paint: Paint()
        ..color = const Color(0xFF7F8C8D)
        ..style = PaintingStyle.fill,
    );
    add(armComponent);

    // Vertical support
    final support = RectangleComponent(
      size: Vector2(16, 30),
      position: Vector2(-8, -30),
      paint: Paint()..color = const Color(0xFF95A5A6),
    );
    add(support);

    // Rope (will be updated dynamically)
    ropeComponent = RectangleComponent(
      size: Vector2(3, 40),
      position: Vector2(-1.5, 6),
      paint: Paint()..color = const Color(0xFFBDC3C7),
    );
    add(ropeComponent);

    // Hook
    hookComponent = RectangleComponent(
      size: Vector2(20, 12),
      position: Vector2(-10, 46),
      paint: Paint()..color = const Color(0xFFE74C3C),
    );
    add(hookComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Swing back and forth
    swingAngle += AppConstants.swingSpeed * dt * swingDirection * _speedMultiplier;

    // Reverse direction at edges
    final maxAngle = pi / 3; // 60 degrees
    if (swingAngle.abs() >= maxAngle) {
      swingDirection *= -1;
      swingAngle = swingAngle.clamp(-maxAngle, maxAngle);
    }

    // Update rope and hook positions based on swing
    final hookPos = hookPosition;
    final ropeStartX = gameWidth / 2;
    final ropeEndX = hookPos.x;

    // Update rope angle and position
    final ropeLength = 40.0;
    final angle = atan2(ropeEndX - ropeStartX, ropeLength);
    ropeComponent.angle = angle;
    ropeComponent.position = Vector2(
      ropeEndX - ropeStartX - 1.5,
      6,
    );

    // Update hook position
    hookComponent.position = Vector2(
      ropeEndX - ropeStartX - 10,
      46,
    );
  }
}
