import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import 'block_component.dart';
import '../behaviors/wobble_behavior.dart';

class TowerComponent extends Component with HasGameReference {
  final List<BlockComponent> blocks = [];
  late RectangleComponent baseComponent;
  late WobbleBehavior wobbleBehavior;

  // Tower physics
  double _swayAngle = 0; // Current sway angle in radians
  double _swayVelocity = 0; // Angular velocity
  double _baseX = 0; // Base center X position
  double _scrollOffset = 0; // Total amount scrolled up
  double _swayMultiplier = 1.0;

  // Smooth scrolling
  double _targetScrollOffset = 0; // Where we want to scroll to
  double _currentVisualOffset = 0; // Current visual offset (smoothly interpolated)

  // Track last known game size to detect changes
  Vector2 _lastGameSize = Vector2.zero();

  // Constants for sway physics
  static const double swayDamping = 0.98; // How quickly sway reduces (lower = faster decay)
  static const double swayStiffness = 3.0; // How quickly tower tries to return to center
  static const double swayImpactFactor = 0.015; // How much each offset pixel affects sway
  static const double maxSwayPixels = 80.0; // Max visual sway in pixels for top block
  static const double baseHeight = 20.0; // Height of the base platform

  // Topple detection
  double _cumulativeOffset = 0; // Total offset from all block placements

  double get towerHeight {
    return blocks.length * AppConstants.blockHeight;
  }

  double get topY {
    if (blocks.isEmpty) {
      // First block lands on top of the base platform
      // baseY is distance from bottom, so platform top is at game.size.y - baseY
      return game.size.y - AppConstants.baseY + _scrollOffset;
    }
    // For subsequent blocks, land on top of the tower
    // Tower top is platform top minus total tower height
    return game.size.y - AppConstants.baseY - towerHeight + _scrollOffset;
  }

  double get topBlockCenterX {
    if (blocks.isEmpty) {
      return _baseX;
    }
    // Top block position is affected by tower sway
    return blocks.last.position.x;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _baseX = game.size.x / 2;

    // Create base platform (full screen width - road/floor)
    baseComponent = RectangleComponent(
      size: Vector2(game.size.x, AppConstants.baseY),
      position: Vector2(0, game.size.y - AppConstants.baseY),
      paint: Paint()..color = const Color(0xFF2D3436),
    );
    add(baseComponent);

    // Initialize wobble behavior
    wobbleBehavior = WobbleBehavior(blocks: blocks);
    add(wobbleBehavior);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Always keep base position synchronized with current game size
    // This handles cases where game.size changes after onLoad
    final expectedBaseY = game.size.y - AppConstants.baseY + _currentVisualOffset;
    if (baseComponent.position.y != expectedBaseY ||
        baseComponent.size.x != game.size.x ||
        _lastGameSize.x != game.size.x ||
        _lastGameSize.y != game.size.y) {
      _lastGameSize = game.size.clone();
      _updateBasePosition();
    }

    // Smooth scroll animation
    if (_currentVisualOffset != _targetScrollOffset) {
      final diff = _targetScrollOffset - _currentVisualOffset;
      final scrollSpeed = 200.0; // pixels per second
      final step = scrollSpeed * dt;

      if (diff.abs() <= step) {
        _currentVisualOffset = _targetScrollOffset;
      } else {
        _currentVisualOffset += diff.sign * step;
      }

      // Apply visual offset to all blocks
      _applyScrollOffset();
    }

    if (blocks.isEmpty) return;

    // Apply spring physics to sway (tower tries to return to vertical)
    _swayVelocity -= _swayAngle * swayStiffness * dt;
    _swayVelocity *= swayDamping;
    _swayAngle += _swayVelocity * dt;

    // Update block positions based on sway
    _updateBlockPositions();
  }

  void _updateBasePosition() {
    // Update base component to match current game size
    _baseX = game.size.x / 2;
    baseComponent.size = Vector2(game.size.x, AppConstants.baseY);
    baseComponent.position = Vector2(0, game.size.y - AppConstants.baseY + _currentVisualOffset);

    // Also update all block positions to match new game size
    _applyScrollOffset();
  }

  void _applyScrollOffset() {
    // Update block Y positions based on current visual offset (Anchor.center)
    for (int i = 0; i < blocks.length; i++) {
      final blockCenterY = game.size.y - AppConstants.baseY - (i + 1) * AppConstants.blockHeight + AppConstants.blockHeight / 2;
      blocks[i].position.y = blockCenterY + _currentVisualOffset;
    }

    // Update base position
    baseComponent.position.y = game.size.y - AppConstants.baseY + _currentVisualOffset;
  }

  void _updateBlockPositions() {
    // Only apply sway to top 5 blocks for stability
    // Lower blocks remain stable
    const int swayBlockCount = 5;
    final int startSwayIndex = (blocks.length - swayBlockCount).clamp(0, blocks.length);

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];

      double swayOffset = 0;
      if (i >= startSwayIndex) {
        // Calculate sway only for top blocks
        // Sway increases for higher blocks within the sway range
        final swayPosition = i - startSwayIndex + 1; // 1 to 5
        final swayFactor = swayPosition / swayBlockCount; // 0.2 to 1.0
        swayOffset = sin(_swayAngle) * swayFactor * maxSwayPixels * _swayMultiplier; // Max sway in pixels
      }

      block.position.x = _baseX + swayOffset + _getBlockOffset(i);
    }
  }

  // Get the cumulative offset for a block (how off-center it was placed)
  double _getBlockOffset(int index) {
    double offset = 0;
    for (int i = 0; i <= index && i < blocks.length; i++) {
      // Each block adds its placement offset
      offset += blocks[i].placementOffset;
    }
    return offset;
  }

  /// Add a block to the tower and apply impact to sway
  void addBlock(BlockComponent block, double placementOffset) {
    // Store the offset from where it should have been placed
    block.placementOffset = placementOffset;
    blocks.add(block);

    // Track cumulative offset for topple detection
    _cumulativeOffset += placementOffset;

    // Set the correct Y position for this block (Anchor.center)
    // Block center should be at: platformTop - (index+1)*blockHeight + blockHeight/2
    final blockIndex = blocks.length - 1;
    final blockCenterY = game.size.y - AppConstants.baseY - (blockIndex + 1) * AppConstants.blockHeight + AppConstants.blockHeight / 2;
    block.position.y = blockCenterY + _currentVisualOffset;

    // Apply sway based on placement quality
    final absOffset = placementOffset.abs();
    if (absOffset > AppConstants.goodThreshold) {
      // Bad placement - significant sway
      final excessOffset = absOffset - AppConstants.goodThreshold;
      final direction = placementOffset > 0 ? 1.0 : -1.0;
      // More aggressive sway for taller towers
      final heightFactor = 1.0 + (blocks.length * 0.1);
      _swayVelocity += direction * excessOffset * swayImpactFactor * heightFactor * _swayMultiplier;

      // Trigger wobble animation
      final wobbleIntensity = (excessOffset / AppConstants.blockWidth) * AppConstants.maxWobbleAngle;
      wobbleBehavior.triggerWobble(wobbleIntensity);
    } else if (absOffset > AppConstants.comboThreshold) {
      // Mediocre placement - some sway
      final direction = placementOffset > 0 ? 1.0 : -1.0;
      _swayVelocity += direction * absOffset * swayImpactFactor * 0.5 * _swayMultiplier;

      // Slight wobble
      final wobbleIntensity = (absOffset / AppConstants.goodThreshold) * 5.0;
      wobbleBehavior.triggerWobble(wobbleIntensity);
    } else if (absOffset > AppConstants.perfectThreshold) {
      // Good but not perfect - slight wobble only
      final wobbleIntensity = (absOffset / AppConstants.goodThreshold) * 3.0;
      wobbleBehavior.triggerWobble(wobbleIntensity);
    }

    // Scroll view if tower is getting tall
    if (towerHeight > game.size.y * 0.5) {
      scrollUp();
    }
  }

  /// Check if tower has toppled over
  bool hasToppled() {
    // Need at least 3 blocks for topple to be possible
    if (blocks.length < 3) return false;

    // Calculate the visual displacement of the top block from sway
    final topBlockSwayOffset = sin(_swayAngle).abs() * maxSwayPixels * _swayMultiplier;

    // Also consider cumulative offset - if blocks are stacked too far off-center
    final absCumulativeOffset = _cumulativeOffset.abs();

    // Tower height factor - taller towers are more unstable
    final heightInstability = blocks.length * 2.0;

    // Combined instability from sway and cumulative offset
    // Sway contributes directly, cumulative offset contributes based on tower height
    final totalInstability = topBlockSwayOffset + (absCumulativeOffset * blocks.length * 0.05);

    // Topple threshold scales slightly with height (taller = slightly more forgiving visually)
    // but cumulative offset becomes more dangerous
    final toppleThreshold = AppConstants.blockWidth * 0.6 + heightInstability;

    return totalInstability > toppleThreshold;
  }

  void scrollUp() {
    final scrollAmount = AppConstants.blockHeight;

    // Track total scroll offset (for collision calculations)
    _scrollOffset += scrollAmount;

    // Set target for smooth scrolling animation
    _targetScrollOffset += scrollAmount;
  }

  void clear() {
    for (final block in blocks) {
      block.removeFromParent();
    }
    blocks.clear();

    // Reset sway
    _swayAngle = 0;
    _swayVelocity = 0;
    _scrollOffset = 0;
    _targetScrollOffset = 0;
    _currentVisualOffset = 0;
    _cumulativeOffset = 0;

    // Reset wobble
    wobbleBehavior.reset();
    wobbleBehavior.wobbleMultiplier = 1.0;
    _swayMultiplier = 1.0;

    // Reset base position (full width platform)
    _baseX = game.size.x / 2;
    baseComponent.size = Vector2(game.size.x, AppConstants.baseY);
    baseComponent.position = Vector2(0, game.size.y - AppConstants.baseY);

    // Reset last game size to force update on next frame
    _lastGameSize = game.size.clone();
  }

  void setStabilizerMultiplier(double multiplier) {
    _swayMultiplier = multiplier.clamp(0.1, 1.0);
    wobbleBehavior.wobbleMultiplier = _swayMultiplier;
  }

  /// Check if a falling block should land on the tower
  /// Returns (shouldLand, targetY) where targetY is where the block's CENTER should be
  (bool, double) checkCollision(BlockComponent fallingBlock) {
    // With Anchor.center, we need to calculate bottom from center
    final blockBottom = fallingBlock.position.y + fallingBlock.initialHeight / 2;
    final targetCenterY = topY - fallingBlock.initialHeight / 2;

    if (blockBottom >= topY) {
      // Check if block overlaps with the top of tower (or base)
      final topX = topBlockCenterX;
      // First block can land anywhere on the full-width platform
      // Subsequent blocks need to overlap with the previous block
      final topWidth = blocks.isEmpty ? game.size.x : AppConstants.blockWidth;
      final fallingX = fallingBlock.position.x;
      final fallingWidth = fallingBlock.initialWidth;

      // Check horizontal overlap
      final topLeft = topX - topWidth / 2;
      final topRight = topX + topWidth / 2;
      final fallingLeft = fallingX - fallingWidth / 2;
      final fallingRight = fallingX + fallingWidth / 2;

      // There's overlap if the ranges intersect
      final hasOverlap = fallingLeft < topRight && fallingRight > topLeft;

      if (hasOverlap) {
        return (true, targetCenterY);
      }
    }

    return (false, 0);
  }
}
