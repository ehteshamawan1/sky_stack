import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import 'block_component.dart';

class TowerComponent extends Component with HasGameReference {
  final List<BlockComponent> blocks = [];
  late RectangleComponent baseComponent;

  double get towerHeight {
    return blocks.length * AppConstants.blockHeight;
  }

  double get topY {
    if (blocks.isEmpty) {
      return game.size.y - AppConstants.baseY;
    }
    return game.size.y - AppConstants.baseY - towerHeight;
  }

  double get topBlockCenterX {
    if (blocks.isEmpty) {
      return game.size.x / 2;
    }
    return blocks.last.position.x;
  }

  double get topBlockWidth {
    if (blocks.isEmpty) {
      return AppConstants.blockWidth;
    }
    return blocks.last.remainingWidth;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create base platform
    baseComponent = RectangleComponent(
      size: Vector2(AppConstants.blockWidth + 40, 20),
      position: Vector2(
        game.size.x / 2 - (AppConstants.blockWidth + 40) / 2,
        game.size.y - AppConstants.baseY,
      ),
      paint: Paint()..color = const Color(0xFF2D3436),
    );
    add(baseComponent);
  }

  void addBlock(BlockComponent block) {
    blocks.add(block);

    // Scroll view if tower is getting tall
    if (towerHeight > game.size.y * 0.5) {
      scrollUp();
    }
  }

  void scrollUp() {
    final scrollAmount = AppConstants.blockHeight;

    // Move all blocks down visually (camera scrolls up)
    for (final block in blocks) {
      block.position.y += scrollAmount;
    }

    // Move base down too
    baseComponent.position.y += scrollAmount;
  }

  void clear() {
    for (final block in blocks) {
      block.removeFromParent();
    }
    blocks.clear();

    // Reset base position
    baseComponent.position = Vector2(
      game.size.x / 2 - (AppConstants.blockWidth + 40) / 2,
      game.size.y - AppConstants.baseY,
    );
  }

  /// Check if a falling block should land on the tower
  /// Returns (shouldLand, targetY, horizontalOffset)
  (bool, double, double) checkCollision(BlockComponent fallingBlock) {
    final blockBottom = fallingBlock.position.y + fallingBlock.initialHeight / 2;
    final targetY = topY - fallingBlock.initialHeight / 2;

    if (blockBottom >= targetY) {
      // Calculate horizontal offset from center of top block (or base)
      final offset = fallingBlock.position.x - topBlockCenterX;

      // Check if block is within bounds (allowing some overhang)
      final maxOffset = (topBlockWidth / 2) + (fallingBlock.remainingWidth / 2);

      if (offset.abs() <= maxOffset) {
        return (true, targetY, offset);
      }
    }

    return (false, 0, 0);
  }
}
