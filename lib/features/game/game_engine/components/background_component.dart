import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BackgroundComponent extends PositionComponent with HasGameReference {
  final String theme;
  RectangleComponent? _backgroundRect;
  Vector2 _lastSize = Vector2.zero();

  BackgroundComponent({this.theme = 'city'});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // For Phase 1, use a simple gradient background
    // In Phase 2, we'll add parallax SVG layers
    _backgroundRect = RectangleComponent(
      size: game.size,
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a237e),
            Color(0xFF4a148c),
            Color(0xFF6a1b9a),
          ],
        ).createShader(Rect.fromLTWH(0, 0, game.size.x, game.size.y)),
    );
    add(_backgroundRect!);
    _lastSize = game.size.clone();

    // Add some stars for visual interest
    _addStars();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update background size if game size changed
    if (_backgroundRect != null &&
        (_lastSize.x != game.size.x || _lastSize.y != game.size.y)) {
      _lastSize = game.size.clone();
      _backgroundRect!.size = game.size;
      _backgroundRect!.paint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a237e),
            Color(0xFF4a148c),
            Color(0xFF6a1b9a),
          ],
        ).createShader(Rect.fromLTWH(0, 0, game.size.x, game.size.y));
    }
  }

  void _addStars() {
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 30; i++) {
      final x = ((random + i * 137) % game.size.x.toInt()).toDouble();
      final y = ((random + i * 73) % (game.size.y * 0.6).toInt()).toDouble();
      final radius = 1.0 + (i % 3) * 0.5;

      add(CircleComponent(
        radius: radius,
        position: Vector2(x, y),
        paint: Paint()..color = Colors.white.withValues(alpha: 0.3 + (i % 5) * 0.1),
      ));
    }
  }
}
