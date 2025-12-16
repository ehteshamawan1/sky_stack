import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import 'crane_component.dart';

enum BlockState { attached, falling, landed }

class BlockComponent extends PositionComponent with HasGameReference {
  final double initialWidth;
  final double initialHeight;
  final Color color;

  BlockState state = BlockState.attached;
  CraneComponent? attachedCrane;
  double fallVelocity = 0;
  double remainingWidth;
  double placementOffset = 0; // How far off-center this block was placed

  Function(BlockComponent, double)? onLandedCallback;
  Function(BlockComponent)? onFellCallback;

  // Visual
  late RectangleComponent blockVisual;
  late RectangleComponent highlightVisual;

  BlockComponent({
    required Vector2 position,
    required double width,
    required double height,
    Color? color,
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

    // Don't add child visuals - we'll render directly in this component
    // This avoids any confusion with child positioning
  }

  @override
  void render(Canvas canvas) {
    // Draw block directly without child components
    // With Anchor.center in Flame, (0,0) is at top-left of component bounds
    // So draw from (0,0) to fill the component area correctly
    final rect = Rect.fromLTWH(0, 0, initialWidth, initialHeight);

    // Main block color
    canvas.drawRect(rect, Paint()..color = color);

    // Highlight on top (top 20% of block)
    final highlightRect = Rect.fromLTWH(
      0,
      0,
      initialWidth,
      initialHeight * 0.2,
    );
    canvas.drawRect(highlightRect, Paint()..color = Colors.white.withOpacity(0.3));
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

  @override
  void update(double dt) {
    super.update(dt);

    switch (state) {
      case BlockState.attached:
        // Follow crane hook
        if (attachedCrane != null) {
          position = attachedCrane!.hookPosition + Vector2(0, initialHeight / 2 + 10);
        }
        break;

      case BlockState.falling:
        // Apply gravity
        fallVelocity += AppConstants.gravity * dt;
        position.y += fallVelocity * dt;

        // Check if fallen off screen
        if (position.y > game.size.y + 100) {
          onFellCallback?.call(this);
          removeFromParent();
        }
        break;

      case BlockState.landed:
        // Block is stationary
        break;
    }
  }

  void land(double targetY) {
    state = BlockState.landed;
    position.y = targetY;
    fallVelocity = 0;

    // The horizontal position stays where it landed (offset from center adds to tower lean)
    onLandedCallback?.call(this, position.x);
  }
}
