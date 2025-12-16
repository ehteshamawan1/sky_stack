import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';
import '../utils/svg_cache.dart';

/// Time of day variations for backgrounds
enum TimeOfDay { day, sunset, night }

/// Parallax background with 4 layers that move at different speeds
class BackgroundComponent extends PositionComponent with HasGameReference {
  String _theme;
  TimeOfDay _timeOfDay = TimeOfDay.day;

  // Parallax layers (back to front)
  Svg? _skyLayer;
  Svg? _farLayer;
  Svg? _midLayer;
  Svg? _nearLayer;

  bool _layersLoaded = false;

  // SVG cache
  static final SvgCache _svgCache = SvgCache();

  // Parallax scroll offset (smoothly interpolated)
  double _scrollOffset = 0;
  double _targetScrollOffset = 0;
  static const double _scrollLerpSpeed = 5.0;

  // Parallax speeds for each layer (0 = static, 1 = full speed)
  static const double _skySpeed = 0.0;
  static const double _farSpeed = 0.1;
  static const double _midSpeed = 0.3;
  static const double _nearSpeed = 0.6;

  BackgroundComponent({String theme = 'city', TimeOfDay timeOfDay = TimeOfDay.day})
      : _theme = theme,
        _timeOfDay = timeOfDay;

  String get theme => _theme;
  TimeOfDay get timeOfDay => _timeOfDay;

  set theme(String newTheme) {
    if (_theme != newTheme) {
      _theme = newTheme;
      _loadLayers();
    }
  }

  set timeOfDay(TimeOfDay newTimeOfDay) {
    _timeOfDay = newTimeOfDay;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadLayers();
  }

  Future<void> _loadLayers() async {
    _layersLoaded = false;

    try {
      _skyLayer = await _svgCache.get('svg/backgrounds/${_theme}_sky.svg');
      _farLayer = await _svgCache.get('svg/backgrounds/${_theme}_far.svg');
      _midLayer = await _svgCache.get('svg/backgrounds/${_theme}_mid.svg');
      _nearLayer = await _svgCache.get('svg/backgrounds/${_theme}_near.svg');
      _layersLoaded = _skyLayer != null && _farLayer != null && _midLayer != null && _nearLayer != null;
    } catch (e) {
      _layersLoaded = false;
    }
  }

  /// Update the parallax scroll based on tower height
  void updateScroll(double towerHeight) {
    _targetScrollOffset = towerHeight;
  }

  /// Reset scroll position to initial state
  void resetScroll() {
    _scrollOffset = 0;
    _targetScrollOffset = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Smoothly interpolate scroll offset towards target
    if (_scrollOffset != _targetScrollOffset) {
      final diff = _targetScrollOffset - _scrollOffset;
      if (diff.abs() < 0.5) {
        _scrollOffset = _targetScrollOffset;
      } else {
        _scrollOffset += diff * _scrollLerpSpeed * dt;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    if (_layersLoaded) {
      // Calculate scale to fit screen width (SVG viewBox is 400x800)
      final scaleX = screenWidth / 400;
      final scaleY = screenHeight / 800;
      final scale = scaleX > scaleY ? scaleX : scaleY;

      // Render each layer with parallax offset
      _renderLayer(canvas, _skyLayer!, _skySpeed, scale, screenWidth, screenHeight);
      _renderLayer(canvas, _farLayer!, _farSpeed, scale, screenWidth, screenHeight);
      _renderLayer(canvas, _midLayer!, _midSpeed, scale, screenWidth, screenHeight);
      _renderLayer(canvas, _nearLayer!, _nearSpeed, scale, screenWidth, screenHeight);
    } else {
      // Fallback gradient background
      _renderFallbackBackground(canvas, screenWidth, screenHeight);
    }

    // Apply time-of-day overlay
    _renderTimeOfDayOverlay(canvas, screenWidth, screenHeight);
  }

  /// Render a color overlay based on time of day
  void _renderTimeOfDayOverlay(Canvas canvas, double width, double height) {
    Color overlayColor;
    double opacity;

    switch (_timeOfDay) {
      case TimeOfDay.day:
        return;
      case TimeOfDay.sunset:
        overlayColor = const Color(0xFFFF6B35);
        opacity = 0.15;
        break;
      case TimeOfDay.night:
        overlayColor = const Color(0xFF1A1A40);
        opacity = 0.4;
        break;
    }

    final overlayPaint = Paint()
      ..color = overlayColor.withOpacity(opacity)
      ..blendMode = BlendMode.multiply;

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), overlayPaint);

    if (_timeOfDay == TimeOfDay.night && _theme != 'space') {
      _renderNightStars(canvas, width, height);
    }
  }

  void _renderNightStars(Canvas canvas, double width, double height) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final starPaint = Paint()..color = Colors.white;

    for (int i = 0; i < 30; i++) {
      final x = ((random + i * 137) % width.toInt()).toDouble();
      final y = ((random + i * 73) % (height * 0.5).toInt()).toDouble();
      final radius = 0.5 + (i % 3) * 0.5;
      final alpha = 0.4 + (i % 5) * 0.12;

      starPaint.color = Colors.white.withOpacity(alpha);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  void _renderLayer(Canvas canvas, Svg svg, double speed, double scale,
      double screenWidth, double screenHeight) {
    canvas.save();

    final yOffset = _scrollOffset * speed;
    final scaledWidth = 400 * scale;
    final xOffset = (screenWidth - scaledWidth) / 2;

    canvas.translate(xOffset, yOffset);
    canvas.scale(scale, scale);
    svg.render(canvas, Vector2(400, 800));

    canvas.restore();
  }

  void _renderFallbackBackground(Canvas canvas, double width, double height) {
    List<Color> colors;
    switch (_theme) {
      case 'desert':
        colors = [const Color(0xFFFF8F00), const Color(0xFFFFB74D), const Color(0xFFFFE0B2)];
        break;
      case 'underwater':
        colors = [const Color(0xFF006064), const Color(0xFF00838F), const Color(0xFF00ACC1)];
        break;
      case 'space':
        colors = [const Color(0xFF0D0D1A), const Color(0xFF1A1A2E), const Color(0xFF16213E)];
        break;
      case 'fantasy':
        colors = [const Color(0xFF4A148C), const Color(0xFF7B1FA2), const Color(0xFFAB47BC)];
        break;
      case 'city':
      default:
        colors = [const Color(0xFF1A237E), const Color(0xFF283593), const Color(0xFF3949AB)];
    }

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

    if (_theme == 'space') {
      _renderStars(canvas, width, height);
    }
  }

  void _renderStars(Canvas canvas, double width, double height) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final starPaint = Paint()..color = Colors.white;

    for (int i = 0; i < 50; i++) {
      final x = ((random + i * 137) % width.toInt()).toDouble();
      final y = ((random + i * 73) % height.toInt()).toDouble();
      final radius = 0.5 + (i % 3) * 0.5;
      final alpha = 0.3 + (i % 5) * 0.15;

      starPaint.color = Colors.white.withOpacity(alpha);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }
}
