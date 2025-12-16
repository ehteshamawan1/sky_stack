import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/svg_cache.dart';
import 'crane_component.dart';

enum BlockState { attached, falling, landed }

class BlockComponent extends PositionComponent with HasGameReference {
  final double initialWidth;
  final double initialHeight;
  final Color color;
  final String theme;

  BlockState state = BlockState.attached;
  CraneComponent? attachedCrane;
  double fallVelocity = 0;
  double remainingWidth;
  double placementOffset = 0;

  // SVG rendering - use cache
  Svg? _blockSvg;
  bool _svgLoaded = false;

  // Static cache reference
  static final SvgCache _svgCache = SvgCache();

  BlockComponent({
    required Vector2 position,
    required double width,
    required double height,
    Color? color,
    this.theme = 'city',
  })  : initialWidth = width,
        initialHeight = height,
        remainingWidth = width,
        color = color ?? AppColors.blockColors[DateTime.now().millisecond % AppColors.blockColors.length],
        super(
          position: position,
          size: Vector2(width, height),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load from cache (much faster than loading each time)
    final path = 'svg/blocks/${theme}_block.svg';
    _blockSvg = await _svgCache.get(path);
    _svgLoaded = _blockSvg != null;
  }

  @override
  void render(Canvas canvas) {
    if (_svgLoaded && _blockSvg != null) {
      // Render SVG scaled to block size
      canvas.save();
      final scaleX = initialWidth / 100;
      final scaleY = initialHeight / 100;
      canvas.scale(scaleX, scaleY);
      _blockSvg!.render(canvas, Vector2(100, 100));
      canvas.restore();
    } else {
      // Fallback: Draw block with color
      final rect = Rect.fromLTWH(0, 0, initialWidth, initialHeight);
      canvas.drawRect(rect, Paint()..color = color);

      // Highlight on top
      final highlightRect = Rect.fromLTWH(0, 0, initialWidth, initialHeight * 0.2);
      canvas.drawRect(highlightRect, Paint()..color = Colors.white.withOpacity(0.3));
    }
  }

  void attachToCrane(CraneComponent crane) {
    attachedCrane = crane;
    state = BlockState.attached;
  }

  void detachFromCrane() {
    attachedCrane = null;
    state = BlockState.falling;
  }

  void drop({
    required Function(BlockComponent, double) onLanded,
    required Function(BlockComponent) onFell,
  }) {
    onLandedCallback = onLanded;
    onFellCallback = onFell;
    detachFromCrane();
  }

  Function(BlockComponent, double)? onLandedCallback;
  Function(BlockComponent)? onFellCallback;

  @override
  void update(double dt) {
    super.update(dt);

    // Only process if not landed (optimization)
    if (state == BlockState.landed) return;

    if (state == BlockState.attached) {
      // Follow crane hook
      if (attachedCrane != null) {
        position = attachedCrane!.hookPosition + Vector2(0, initialHeight / 2 + 10);
      }
    } else if (state == BlockState.falling) {
      // Apply gravity
      fallVelocity += AppConstants.gravity * dt;
      position.y += fallVelocity * dt;

      // Check if fallen off screen
      if (position.y > game.size.y + 100) {
        onFellCallback?.call(this);
        removeFromParent();
      }
    }
  }

  void land(double targetY) {
    state = BlockState.landed;
    position.y = targetY;
    fallVelocity = 0;
    onLandedCallback?.call(this, position.x);
  }
}
