import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game/state/game_state.dart';

class GamePainter extends CustomPainter {
  final GameState gameState;
  final ThemeData theme;
  final Size screenSize;

  GamePainter({
    required this.gameState,
    required this.theme,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw Grid / Background
    _drawBackground(canvas, size);

    // Draw Snake Bodies
    for (var snake in gameState.snakes) {
      if (!snake.isDead) {
        _drawSnakeBody(canvas, snake);
      }
    }

    // Draw Foods
    for (var food in gameState.foods) {
      final pos = _logicalToPhysical(food.position);
      final foodSize = 40.0;

      // Pulse effect slightly offset by position so they aren't all perfectly synced
      final pulse =
          1.0 +
          0.1 *
              sin(
                (DateTime.now().millisecondsSinceEpoch / 200) +
                    food.position.dx,
              );

      paint.color = theme.colorScheme.secondary.withValues(alpha: 0.2);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(pos, foodSize * 0.8 * pulse, paint);
      paint.maskFilter = null;

      _drawFoodImage(canvas, pos, foodSize * pulse, food.image);
    }

    // Draw Snake Heads
    for (var snake in gameState.snakes) {
      if (!snake.isDead) {
        _drawHead(canvas, snake);
      }
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final themeIndex = gameState.selectedThemeIndex;
    final paint = Paint();

    switch (themeIndex) {
      case 1: // Neon Grid
        paint.color = const Color(0xFF000510);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

        paint.color = Colors.cyan.withOpacity(0.15);
        paint.strokeWidth = 1.0;
        const spacing = 50.0;
        for (double i = 0; i < size.width; i += spacing) {
          canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
        }
        for (double i = 0; i < size.height; i += spacing) {
          canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
        }
        break;

      case 2: // Minimalist
        paint.color = const Color(0xFF121212);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

        paint.color = Colors.white.withOpacity(0.05);
        paint.strokeWidth = 0.5;
        const spacing = 40.0;
        for (double i = 0; i < size.width; i += spacing) {
          canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
        }
        for (double i = 0; i < size.height; i += spacing) {
          canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
        }
        break;

      case 3: // Matrix
        paint.color = const Color(0xFF000800);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

        paint.color = Colors.green.withOpacity(0.1);
        paint.strokeWidth = 1.0;
        final rand = Random(123);
        for (double i = 0; i < size.width; i += 20) {
          if (rand.nextBool()) {
            canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
          }
        }
        break;

      case 0: // Deep Space (Default)
      default:
        paint.color = const Color(0xFF0A0A1A);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

        // Stars
        final rand = Random(42);
        paint.color = Colors.white.withOpacity(0.2);
        for (int i = 0; i < 100; i++) {
          canvas.drawCircle(
            Offset(
              rand.nextDouble() * size.width,
              rand.nextDouble() * size.height,
            ),
            rand.nextDouble() * 1.5,
            paint,
          );
        }
        break;
    }
  }

  void _drawSnakeBody(Canvas canvas, SnakeData snake) {
    final segments = snake.bodySegments;
    if (segments.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final skinColor = snake.isPlayer ? _getSkinColor() : snake.color;

    // Draw body segments with thickness variations for "real snake" look and swallowing
    for (int i = segments.length - 1; i >= 0; i--) {
      final pos = _logicalToPhysical(segments[i]);

      // Base thickness tapers towards the tail
      double baseThickness = 18.0 - (i / segments.length) * 8.0;

      // Apply swallowing bulge
      for (final anim in snake.swallowAnimations) {
        double segmentProgress = i / segments.length; // 0 (head) to 1 (tail)
        // Adjust progress based on snake length for better mapping
        double dist = (segmentProgress - anim.progress).abs();
        if (dist < 0.1) {
          double bulge = (1.0 - (dist / 0.1)) * 8.0;
          baseThickness += bulge;
        }
      }

      final rect = Rect.fromCircle(center: pos, radius: baseThickness);

      // Tubular shading (light top, dark bottom)
      final hsl = HSLColor.fromColor(skinColor);
      final lightColor = hsl
          .withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0))
          .toColor();
      final darkColor = hsl
          .withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0))
          .toColor();

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lightColor, skinColor, darkColor],
        stops: const [0.0, 0.4, 1.0],
      );

      paint.shader = gradient.createShader(rect);
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(pos, baseThickness, paint);

      // Scale pattern
      if (i % 3 == 0) {
        paint.shader = null;
        paint.color = Colors.white.withOpacity(0.05);
        canvas.drawCircle(pos, baseThickness * 0.6, paint);
      }
    }
  }

  void _drawHead(Canvas canvas, SnakeData snake) {
    final headSize = 22.0;
    final paint = Paint();
    final skinColor = snake.isPlayer ? _getSkinColor() : snake.color;
    final pos = _logicalToPhysical(snake.headPos);
    final angle = snake.headAngle;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    // Head Shape
    final headPath = Path()
      ..moveTo(-5, -headSize * 0.5)
      ..cubicTo(10, -headSize * 0.6, 25, -headSize * 0.4, 25, 0)
      ..cubicTo(25, headSize * 0.4, 10, headSize * 0.6, -5, headSize * 0.5)
      ..close();

    final headGradient = LinearGradient(
      colors: [skinColor, skinColor.withBlue(100).withRed(50)],
    );
    paint.shader = headGradient.createShader(Rect.fromLTWH(-10, -20, 40, 40));
    canvas.drawPath(headPath, paint);
    paint.shader = null;

    // Eyes
    paint.color = Colors.black;
    canvas.drawCircle(const Offset(12, -8), 4, paint);
    canvas.drawCircle(const Offset(12, 8), 4, paint);

    // Slit pupils
    paint.color = const Color(0xFF00FF00);
    canvas.drawRect(const Rect.fromLTWH(13, -10, 1, 4), paint);
    canvas.drawRect(const Rect.fromLTWH(13, 6, 1, 4), paint);

    // Tongue
    if ((DateTime.now().millisecondsSinceEpoch / 500).floor() % 2 == 0) {
      paint.color = Colors.redAccent;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      final tongue = Path()
        ..moveTo(22, 0)
        ..lineTo(35, 0)
        ..moveTo(35, 0)
        ..lineTo(40, -4)
        ..moveTo(35, 0)
        ..lineTo(40, 4);
      canvas.drawPath(tongue, paint);
    }

    canvas.restore();

    // Draw snake size on head (upright)
    final textSpan = TextSpan(
      text: snake.size.toString(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
        ],
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  Color _getSkinColor() {
    switch (gameState.selectedSkin) {
      case 'Emerald':
        return const Color(0xFF00FF88);
      case 'Ruby':
        return const Color(0xFFFF3366);
      case 'Gold':
        return const Color(0xFFFFCC00);
      default:
        return const Color(0xFF00F2FF);
    }
  }

  void _drawFoodImage(
    Canvas canvas,
    Offset pos,
    double size,
    String assetPath,
  ) {
    final uiImage = gameState.loadedImages[assetPath];
    if (uiImage != null) {
      final src = Rect.fromLTWH(
        0,
        0,
        uiImage.width.toDouble(),
        uiImage.height.toDouble(),
      );
      final dst = Rect.fromCenter(center: pos, width: size, height: size);
      canvas.drawImageRect(uiImage, src, dst, Paint());
    }
  }

  Offset _logicalToPhysical(Offset logical) {
    return Offset(
      (logical.dx / gameState.worldWidth) * screenSize.width,
      (logical.dy / gameState.worldHeight) * screenSize.height,
    );
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return true; // Always repaint for animations
  }
}
