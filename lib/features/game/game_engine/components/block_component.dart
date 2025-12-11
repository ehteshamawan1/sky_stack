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

    // Block visual (colored rectangle with gradient effect)
    blockVisual = RectangleComponent(
      size: Vector2(initialWidth, initialHeight),
      position: Vector2(-initialWidth / 2, -initialHeight / 2),
      paint: Paint()..color = color,
    );
    add(blockVisual);

    // Highlight on top
    highlightVisual = RectangleComponent(
      size: Vector2(initialWidth, initialHeight * 0.2),
      position: Vector2(-initialWidth / 2, -initialHeight / 2),
      paint: Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
    add(highlightVisual);
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

  void land(double targetY, double offset) {
    state = BlockState.landed;
    position.y = targetY;
    fallVelocity = 0;

    // Trim overhanging portion
    if (offset.abs() > AppConstants.perfectThreshold) {
      final overhang = offset.abs();
      final newWidth = remainingWidth - overhang;

      if (newWidth <= 10) {
        // Block mostly missed - will fall
        remainingWidth = 0;
        onFellCallback?.call(this);
        removeFromParent();
        return;
      }

      remainingWidth = newWidth;

      // Update visuals
      blockVisual.size = Vector2(remainingWidth, initialHeight);
      highlightVisual.size = Vector2(remainingWidth, initialHeight * 0.2);

      // Adjust position to center the remaining block
      if (offset > 0) {
        // Overhang was on the right
        blockVisual.position = Vector2(-remainingWidth / 2, -initialHeight / 2);
        highlightVisual.position = Vector2(-remainingWidth / 2, -initialHeight / 2);
        position.x -= overhang / 2;
      } else {
        // Overhang was on the left
        blockVisual.position = Vector2(-remainingWidth / 2, -initialHeight / 2);
        highlightVisual.position = Vector2(-remainingWidth / 2, -initialHeight / 2);
        position.x += overhang / 2;
      }

      size = Vector2(remainingWidth, initialHeight);
    }

    onLandedCallback?.call(this, offset);
  }
}
