import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// Collection of particle effects for visual feedback
/// Optimized for performance with reduced particle counts
class ParticleEffects {
  static final Random _random = Random();

  /// Creates a burst of golden sparkles for perfect drops
  static ParticleSystemComponent perfectDropEffect(Vector2 position) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 12, // Reduced from 25
        lifespan: 0.5,
        generator: (i) {
          final angle = (_random.nextDouble() * 2 * pi);
          final speed = 60 + _random.nextDouble() * 80;
          final colors = [
            const Color(0xFFFFD700),
            const Color(0xFFFFF176),
            const Color(0xFFFFE082),
          ];

          return AcceleratedParticle(
            acceleration: Vector2(0, 120),
            speed: Vector2(cos(angle) * speed, sin(angle) * speed - 40),
            position: position.clone(),
            child: CircleParticle(
              radius: 2.5,
              paint: Paint()..color = colors[i % colors.length],
            ),
          );
        },
      ),
    );
  }

  /// Creates dust particles when a block lands
  static ParticleSystemComponent dustEffect(Vector2 position, double blockWidth) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 8, // Reduced from 15
        lifespan: 0.3,
        generator: (i) {
          final offsetX = (_random.nextDouble() - 0.5) * blockWidth;
          final speed = Vector2(
            (_random.nextDouble() - 0.5) * 40,
            -15 - _random.nextDouble() * 20,
          );

          return AcceleratedParticle(
            acceleration: Vector2(0, 60),
            speed: speed,
            position: position + Vector2(offsetX, 0),
            child: CircleParticle(
              radius: 2,
              paint: Paint()..color = Colors.grey.withValues(alpha: 0.5),
            ),
          );
        },
      ),
    );
  }

  /// Creates a combo celebration effect with multiple colors
  static ParticleSystemComponent comboEffect(Vector2 position, int comboLevel) {
    final count = (8 + comboLevel).clamp(8, 15); // Reduced and capped

    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: 0.4,
        generator: (i) {
          final angle = (_random.nextDouble() * 2 * pi);
          final speed = 50 + _random.nextDouble() * 60;
          final colors = [
            const Color(0xFFFF5722),
            const Color(0xFFE91E63),
            const Color(0xFF9C27B0),
            const Color(0xFF2196F3),
            const Color(0xFF4CAF50),
          ];

          return AcceleratedParticle(
            acceleration: Vector2(0, 80),
            speed: Vector2(cos(angle) * speed, sin(angle) * speed - 30),
            position: position.clone(),
            child: CircleParticle(
              radius: 2,
              paint: Paint()..color = colors[i % colors.length],
            ),
          );
        },
      ),
    );
  }

  /// Creates stars effect for special achievements
  static ParticleSystemComponent starsEffect(Vector2 position) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 6, // Reduced from 8
        lifespan: 0.6,
        generator: (i) {
          final angle = (i / 6) * 2 * pi;
          final speed = 40 + _random.nextDouble() * 20;

          return AcceleratedParticle(
            acceleration: Vector2(0, 40),
            speed: Vector2(cos(angle) * speed, sin(angle) * speed - 20),
            position: position.clone(),
            child: CircleParticle(
              radius: 3,
              paint: Paint()..color = Colors.yellow,
            ),
          );
        },
      ),
    );
  }

  /// Creates confetti effect for game over celebration
  static ParticleSystemComponent confettiEffect(Vector2 position, Vector2 screenSize) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 25, // Reduced from 50
        lifespan: 1.5,
        generator: (i) {
          final startX = _random.nextDouble() * screenSize.x;
          final colors = [
            const Color(0xFFFF5722),
            const Color(0xFFE91E63),
            const Color(0xFF9C27B0),
            const Color(0xFF2196F3),
            const Color(0xFF4CAF50),
            const Color(0xFFFFEB3B),
          ];

          return AcceleratedParticle(
            acceleration: Vector2((_random.nextDouble() - 0.5) * 15, 80),
            speed: Vector2(
              (_random.nextDouble() - 0.5) * 80,
              -80 - _random.nextDouble() * 150,
            ),
            position: Vector2(startX, -20),
            child: CircleParticle(
              radius: 3,
              paint: Paint()..color = colors[i % colors.length],
            ),
          );
        },
      ),
    );
  }
}
