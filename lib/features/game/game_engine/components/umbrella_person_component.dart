import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';
import '../utils/svg_cache.dart';

/// A little person floating down with an umbrella
/// They appear when blocks are placed and float into the building
class UmbrellaPersonComponent extends PositionComponent with HasGameReference {
  final Vector2 targetPosition;
  final VoidCallback? onArrived;
  final String theme;

  // Movement parameters
  static const double floatSpeed = 80.0;
  static const double swayAmplitude = 20.0;
  static const double swayFrequency = 3.0;

  double _elapsedTime = 0;
  double _initialX = 0;
  bool _hasArrived = false;

  // SVG sprite - use cache
  Svg? _personSvg;
  bool _svgLoaded = false;
  static final SvgCache _svgCache = SvgCache();

  UmbrellaPersonComponent({
    required Vector2 startPosition,
    required this.targetPosition,
    this.onArrived,
    this.theme = 'city',
  }) : super(
    position: startPosition,
    size: Vector2(30, 40),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initialX = position.x;

    // Load from cache
    final path = 'svg/characters/${theme}_umbrella_person.svg';
    _personSvg = await _svgCache.get(path);
    _svgLoaded = _personSvg != null;
  }

  @override
  void render(Canvas canvas) {
    if (_svgLoaded && _personSvg != null) {
      _personSvg!.render(canvas, size);
    } else {
      _renderFallback(canvas);
    }
  }

  void _renderFallback(Canvas canvas) {
    final random = Random(hashCode);
    final personColor = Color.fromRGBO(
      100 + random.nextInt(100),
      100 + random.nextInt(100),
      150 + random.nextInt(100),
      1,
    );

    // Umbrella top
    final umbrellaPaint = Paint()..color = Colors.red.shade400;
    canvas.drawOval(
      Rect.fromLTWH(size.x * 0.1, 0, size.x * 0.8, size.y * 0.25),
      umbrellaPaint,
    );

    // Umbrella handle
    final handlePaint = Paint()..color = Colors.brown.shade600;
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.45, size.y * 0.2, size.x * 0.1, size.y * 0.25),
      handlePaint,
    );

    // Person head
    final skinPaint = Paint()..color = const Color(0xFFFFDBB4);
    canvas.drawCircle(
      Offset(size.x * 0.5, size.y * 0.55),
      size.x * 0.12,
      skinPaint,
    );

    // Person body
    final bodyPaint = Paint()..color = personColor;
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.35, size.y * 0.65, size.x * 0.3, size.y * 0.3),
      bodyPaint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_hasArrived) return;

    _elapsedTime += dt;

    final distanceToTarget = targetPosition.y - position.y;

    if (distanceToTarget > 5) {
      position.y += floatSpeed * dt;
      position.x = _initialX + sin(_elapsedTime * swayFrequency) * swayAmplitude;
    } else {
      _hasArrived = true;
      onArrived?.call();

      Future.delayed(const Duration(milliseconds: 300), () {
        removeFromParent();
      });
    }
  }
}
