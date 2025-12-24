import 'dart:math';
import 'package:flame/components.dart';
import '../../../../core/constants/app_constants.dart';

/// Handles tower wobble animation when blocks are placed imperfectly
/// Optimized to only affect top blocks
class WobbleBehavior extends Component {
  final List<PositionComponent> blocks;
  double wobbleIntensity = 0;
  double wobblePhase = 0;
  double wobbleMultiplier = 1.0;

  // Only wobble top N blocks for performance
  static const int maxWobbleBlocks = 8;

  WobbleBehavior({required this.blocks});

  /// Trigger wobble with given intensity (based on placement offset)
  void triggerWobble(double intensity) {
    wobbleIntensity = intensity.clamp(0, AppConstants.maxWobbleAngle);
  }

  @override
  void update(double dt) {
    // Early exit if no wobble
    if (wobbleIntensity <= 0.1) {
      // Only reset if we were wobbling before
      if (wobblePhase != 0) {
        _resetAngles();
        wobblePhase = 0;
      }
      wobbleIntensity = 0;
      return;
    }

    wobblePhase += dt * 10;

    // Only process top blocks for performance
    final startIndex = (blocks.length - maxWobbleBlocks).clamp(0, blocks.length);
    final wobbleBlockCount = blocks.length - startIndex;

    if (wobbleBlockCount <= 0) return;

    for (int i = startIndex; i < blocks.length; i++) {
      final block = blocks[i];
      // Higher blocks wobble more
      final relativeIndex = i - startIndex;
      final heightMultiplier = (relativeIndex + 1) / wobbleBlockCount;
      final angle = sin(wobblePhase) * (wobbleIntensity * wobbleMultiplier) * heightMultiplier;
      block.angle = angle * (pi / 180);
    }

    // Decay wobble
    wobbleIntensity *= AppConstants.wobbleDecay;
  }

  void _resetAngles() {
    // Only reset angles for blocks that might have been wobbled
    final startIndex = (blocks.length - maxWobbleBlocks).clamp(0, blocks.length);
    for (int i = startIndex; i < blocks.length; i++) {
      blocks[i].angle = 0;
    }
  }

  /// Reset wobble state
  void reset() {
    wobbleIntensity = 0;
    wobblePhase = 0;
    for (final block in blocks) {
      block.angle = 0;
    }
  }
}
