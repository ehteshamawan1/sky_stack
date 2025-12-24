import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// Animated score popup that floats up and fades out
class ScorePopupComponent extends PositionComponent {
  final int score;
  final bool isPerfect;
  final bool isCombo;
  final int comboLevel;

  late TextComponent _textComponent;

  ScorePopupComponent({
    required this.score,
    required Vector2 position,
    this.isPerfect = false,
    this.isCombo = false,
    this.comboLevel = 0,
  }) : super(
    position: position,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Build the text
    String text = '+$score';
    if (isPerfect) {
      text = 'PERFECT!\n+$score';
    } else if (isCombo && comboLevel > 1) {
      text = 'x$comboLevel COMBO!\n+$score';
    }

    // Determine color based on type
    Color textColor;
    double fontSize;

    if (isPerfect) {
      textColor = const Color(0xFFFFD700); // Gold
      fontSize = 24;
    } else if (isCombo && comboLevel >= 5) {
      textColor = const Color(0xFFFF5722); // Orange for high combo
      fontSize = 22;
    } else if (isCombo) {
      textColor = const Color(0xFFFFA726); // Light orange
      fontSize = 20;
    } else {
      textColor = Colors.white;
      fontSize = 18;
    }

    _textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
    );
    add(_textComponent);

    // Float up animation
    add(
      MoveEffect.by(
        Vector2(0, -60),
        EffectController(
          duration: 0.8,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Scale pop effect at start
    add(
      ScaleEffect.by(
        Vector2.all(1.3),
        EffectController(
          duration: 0.1,
          reverseDuration: 0.15,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Scale down to simulate fade out
    add(
      SequenceEffect([
        // Wait a bit before scaling down
        MoveEffect.by(
          Vector2.zero(),
          EffectController(duration: 0.5),
        ),
        // Then scale down to disappear
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.3),
        ),
      ])..onComplete = removeFromParent,
    );
  }
}

/// Perfect placement indicator with elastic animation
class PerfectIndicatorComponent extends PositionComponent {
  late TextComponent _textComponent;

  PerfectIndicatorComponent({
    required Vector2 position,
  }) : super(
    position: position,
    anchor: Anchor.center,
    scale: Vector2.zero(),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _textComponent = TextComponent(
      text: 'PERFECT!',
      textRenderer: TextPaint(
        style: TextStyle(
          color: const Color(0xFFFFD700),
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.6),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
            const Shadow(
              color: Color(0xFFFFE082),
              offset: Offset(0, 0),
              blurRadius: 10,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
    );
    add(_textComponent);

    // Elastic scale in
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(
          duration: 0.3,
          curve: Curves.elasticOut,
        ),
      ),
    );

    // Slight float up
    add(
      MoveEffect.by(
        Vector2(0, -20),
        EffectController(
          duration: 0.6,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Hold and scale out
    add(
      SequenceEffect([
        // Hold
        MoveEffect.by(
          Vector2.zero(),
          EffectController(duration: 0.3),
        ),
        // Scale down to disappear
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.2),
        ),
      ])..onComplete = removeFromParent,
    );
  }
}

/// Combo multiplier indicator
class ComboIndicatorComponent extends PositionComponent {
  final int comboLevel;
  late TextComponent _textComponent;

  ComboIndicatorComponent({
    required this.comboLevel,
    required Vector2 position,
  }) : super(
    position: position,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Color intensity based on combo level
    final intensity = (comboLevel / 10).clamp(0.5, 1.0);
    final color = Color.lerp(
      const Color(0xFFFFA726), // Light orange
      const Color(0xFFFF5722), // Deep orange
      intensity,
    )!;

    _textComponent = TextComponent(
      text: 'x${comboLevel + 1}',
      textRenderer: TextPaint(
        style: TextStyle(
          color: color,
          fontSize: 28 + (comboLevel * 0.5),
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
    );
    add(_textComponent);

    // Pop animation
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(
          duration: 0.15,
          reverseDuration: 0.1,
        ),
      ),
    );

    // Wait then scale down to disappear
    add(
      SequenceEffect([
        MoveEffect.by(Vector2.zero(), EffectController(duration: 0.4)),
        ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.2)),
      ])..onComplete = removeFromParent,
    );
  }
}
