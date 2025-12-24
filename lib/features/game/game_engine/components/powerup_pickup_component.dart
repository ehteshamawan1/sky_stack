import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';
import '../../data/models/powerup_model.dart';
import '../utils/svg_cache.dart';

class PowerUpPickupComponent extends PositionComponent with HasGameReference {
  final PowerUpType type;
  final double radius;
  final Function(PowerUpType)? onCollected;
  double _lifetimeSeconds = 6.0;

  Svg? _svg;
  bool _svgLoaded = false;

  static final SvgCache _svgCache = SvgCache();

  PowerUpPickupComponent({
    required this.type,
    required Vector2 position,
    this.radius = 22,
    this.onCollected,
  }) : super(
          position: position,
          size: Vector2.all(44),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final definition = PowerUpDefinition.launch[type]!;
    final path = definition.iconPath.replaceFirst('assets/', '');
    _svg = await _svgCache.get(path);
    _svgLoaded = _svg != null;

    add(
      MoveEffect.by(
        Vector2(0, -8),
        EffectController(
          duration: 0.6,
          reverseDuration: 0.6,
          infinite: true,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetimeSeconds -= dt;
    if (_lifetimeSeconds <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_svgLoaded && _svg != null) {
      canvas.save();
      final scale = size.x / 64;
      canvas.scale(scale, scale);
      _svg!.render(canvas, Vector2(64, 64));
      canvas.restore();
    } else {
      final paint = Paint()..color = const Color(0xFFFFD166);
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    }
  }

  bool isCollidingWith(Vector2 point) {
    return point.distanceTo(position) <= radius;
  }

  void collect() {
    onCollected?.call(type);
    add(
      ScaleEffect.to(
        Vector2.all(1.4),
        EffectController(duration: 0.15),
      ),
    );
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.2),
      )..onComplete = removeFromParent,
    );
  }
}
