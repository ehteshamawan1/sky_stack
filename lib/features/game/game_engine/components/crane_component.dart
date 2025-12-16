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

    // Draw crane beam at top (industrial girder look)
    _drawCraneBeam(canvas);

    // Draw cable from pulley to hook
    _drawCable(canvas, hook);

    // Draw pulley wheel
    _drawPulley(canvas);

    // Draw hook at the end
    _drawHook(canvas, hook);
  }

  void _drawCraneBeam(Canvas canvas) {
    final beamWidth = game.size.x * 0.7;
    final beamLeft = (game.size.x - beamWidth) / 2;
    final beamTop = pivotPoint.y - 25;
    final beamHeight = 20.0;

    // Main beam background (dark steel)
    final beamBgPaint = Paint()..color = const Color(0xFF455A64);
    canvas.drawRect(
      Rect.fromLTWH(beamLeft, beamTop, beamWidth, beamHeight),
      beamBgPaint,
    );

    // Beam highlight (top edge)
    final highlightPaint = Paint()..color = const Color(0xFF78909C);
    canvas.drawRect(
      Rect.fromLTWH(beamLeft, beamTop, beamWidth, 4),
      highlightPaint,
    );

    // Cross-bracing pattern (industrial girder look)
    final bracePaint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw X patterns along the beam
    final segments = 8;
    final segmentWidth = beamWidth / segments;
    for (int i = 0; i < segments; i++) {
      final x = beamLeft + i * segmentWidth;
      // X pattern
      canvas.drawLine(
        Offset(x, beamTop + 4),
        Offset(x + segmentWidth, beamTop + beamHeight - 2),
        bracePaint,
      );
      canvas.drawLine(
        Offset(x + segmentWidth, beamTop + 4),
        Offset(x, beamTop + beamHeight - 2),
        bracePaint,
      );
    }

    // Support brackets on ends
    final bracketPaint = Paint()..color = const Color(0xFF37474F);
    // Left bracket
    canvas.drawRect(
      Rect.fromLTWH(beamLeft - 5, beamTop - 10, 15, beamHeight + 15),
      bracketPaint,
    );
    // Right bracket
    canvas.drawRect(
      Rect.fromLTWH(beamLeft + beamWidth - 10, beamTop - 10, 15, beamHeight + 15),
      bracketPaint,
    );
  }

  void _drawCable(Canvas canvas, Vector2 hook) {
    // Main cable
    final cablePaint = Paint()
      ..color = const Color(0xFF607D8B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(pivotPoint.x, pivotPoint.y),
      Offset(hook.x, hook.y),
      cablePaint,
    );

    // Cable highlight (thin lighter line)
    final cableHighlightPaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(pivotPoint.x - 1, pivotPoint.y),
      Offset(hook.x - 1, hook.y),
      cableHighlightPaint,
    );
  }

  void _drawPulley(Canvas canvas) {
    final pulleyCenter = Offset(pivotPoint.x, pivotPoint.y);

    // Pulley outer ring (dark steel)
    final outerPaint = Paint()..color = const Color(0xFF455A64);
    canvas.drawCircle(pulleyCenter, 14, outerPaint);

    // Pulley groove (darker middle)
    final groovePaint = Paint()..color = const Color(0xFF37474F);
    canvas.drawCircle(pulleyCenter, 10, groovePaint);

    // Pulley center hub
    final hubPaint = Paint()..color = const Color(0xFF607D8B);
    canvas.drawCircle(pulleyCenter, 5, hubPaint);

    // Highlight on pulley
    final highlightPaint = Paint()..color = const Color(0xFF78909C);
    canvas.drawCircle(
      Offset(pulleyCenter.dx - 3, pulleyCenter.dy - 3),
      3,
      highlightPaint,
    );

    // Mounting bracket behind pulley
    final bracketPaint = Paint()..color = const Color(0xFF37474F);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(pulleyCenter.dx, pulleyCenter.dy - 18),
        width: 12,
        height: 12,
      ),
      bracketPaint,
    );
  }

  void _drawHook(Canvas canvas, Vector2 hook) {
    final hookCenter = Offset(hook.x, hook.y);

    // Hook connector plate (top part)
    final platePaint = Paint()..color = const Color(0xFFE67E22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: hookCenter, width: 20, height: 12),
        const Radius.circular(3),
      ),
      platePaint,
    );

    // Hook highlight
    final highlightPaint = Paint()..color = const Color(0xFFF39C12);
    canvas.drawRect(
      Rect.fromLTWH(hookCenter.dx - 8, hookCenter.dy - 5, 16, 3),
      highlightPaint,
    );

    // Hook bolt (center rivet)
    final boltPaint = Paint()..color = const Color(0xFFD35400);
    canvas.drawCircle(hookCenter, 3, boltPaint);
    canvas.drawCircle(
      Offset(hookCenter.dx - 0.5, hookCenter.dy - 0.5),
      1.5,
      highlightPaint,
    );

    // Hook body (curved part below)
    final hookBodyPaint = Paint()
      ..color = const Color(0xFFE67E22)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final hookPath = Path();
    hookPath.moveTo(hookCenter.dx - 6, hookCenter.dy + 6);
    hookPath.quadraticBezierTo(
      hookCenter.dx - 8, hookCenter.dy + 18,
      hookCenter.dx, hookCenter.dy + 20,
    );
    hookPath.quadraticBezierTo(
      hookCenter.dx + 8, hookCenter.dy + 18,
      hookCenter.dx + 6, hookCenter.dy + 10,
    );
    canvas.drawPath(hookPath, hookBodyPaint);

    // Hook inner highlight
    final hookHighlightPaint = Paint()
      ..color = const Color(0xFFF39C12)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final highlightPath = Path();
    highlightPath.moveTo(hookCenter.dx - 4, hookCenter.dy + 8);
    highlightPath.quadraticBezierTo(
      hookCenter.dx - 5, hookCenter.dy + 15,
      hookCenter.dx, hookCenter.dy + 16,
    );
    canvas.drawPath(highlightPath, hookHighlightPaint);
  }
}
