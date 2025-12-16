import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class CraneComponent extends Component with HasGameReference {
  double swingAngle = 0; // Current angle in radians (0 = straight down)
  double swingDirection = 1;
  double _speedMultiplier = 1.0;

  // Pendulum parameters
  double ropeLength = 150.0; // Length of the rope
  double maxSwingAngle = pi / 2.5; // ~72 degrees max swing (full screen width)

  // Pivot point (top center where rope attaches) - in game coordinates
  Vector2 pivotPoint;
  final double _pivotY;

  CraneComponent({
    required Vector2 position,
    required double gameWidth,
  }) : _pivotY = position.y,
       pivotPoint = Vector2(gameWidth / 2, position.y);

  Vector2 get hookPosition {
    // Pendulum motion: hook swings in an arc from the pivot point
    // X = pivotX + ropeLength * sin(angle)
    // Y = pivotY + ropeLength * cos(angle)
    return Vector2(
      pivotPoint.x + ropeLength * sin(swingAngle),
      pivotPoint.y + ropeLength * cos(swingAngle),
    );
  }

  void setSpeedMultiplier(double multiplier) {
    _speedMultiplier = multiplier;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set pivot point at top center of screen
    pivotPoint = Vector2(game.size.x / 2, _pivotY);

    // Shorter rope for better visuals
    ropeLength = 150.0;

    // Fixed 60 degree swing angle
    maxSwingAngle = pi / 3; // 60 degrees
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update pivot in case game size changed
    pivotPoint = Vector2(game.size.x / 2, _pivotY);

    // Swing back and forth (pendulum motion)
    swingAngle += AppConstants.swingSpeed * dt * swingDirection * _speedMultiplier;

    // Reverse direction at edges
    if (swingAngle >= maxSwingAngle) {
      swingDirection = -1;
      swingAngle = maxSwingAngle;
    } else if (swingAngle <= -maxSwingAngle) {
      swingDirection = 1;
      swingAngle = -maxSwingAngle;
    }
  }

  @override
  void render(Canvas canvas) {
    final hook = hookPosition;

    // Draw pivot/pulley at top center
    final pivotPaint = Paint()..color = const Color(0xFF7F8C8D);
    canvas.drawCircle(
      Offset(pivotPoint.x, pivotPoint.y),
      12,
      pivotPaint,
    );

    // Draw rope from pivot to hook
    final ropePaint = Paint()
      ..color = const Color(0xFF95A5A6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(pivotPoint.x, pivotPoint.y),
      Offset(hook.x, hook.y),
      ropePaint,
    );

    // Draw small hook connector at end of rope
    final hookPaint = Paint()..color = const Color(0xFFE67E22);
    canvas.drawCircle(
      Offset(hook.x, hook.y),
      8,
      hookPaint,
    );
  }
}
