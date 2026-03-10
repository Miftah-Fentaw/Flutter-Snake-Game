import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game/state/game_state2.dart';

class VerticalGamePainter extends CustomPainter {
  final VerticalGameState gameState;
  final ThemeData theme;
  final Size screenSize;

  VerticalGamePainter({
    required this.gameState,
    required this.theme,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!gameState.imagesLoaded) return;

    final double scaleX = size.width / gameState.worldWidth;
    final double scaleY = size.height / gameState.worldHeight;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    _drawBackground(canvas, size);
    _drawEnvironmentEffects(canvas);
    _drawWorldObjects(canvas);
    _drawSnakeBody(canvas);
    _drawSnakeHead(canvas);

    canvas.restore();
  }

  void _drawBackground(Canvas canvas, Size size) {
    final themeIndex = gameState.selectedThemeIndex;
    final paint = Paint();
    final worldRect = Rect.fromLTWH(
      0,
      0,
      gameState.worldWidth,
      gameState.worldHeight,
    );

    switch (themeIndex) {
      case 1: // Neon City
        paint.color = const Color(0xFF0D0221);
        canvas.drawRect(worldRect, paint);

        // Draw neon grid
        final gridPaint = Paint()
          ..color = Colors.purpleAccent.withValues(alpha: 0.1)
          ..strokeWidth = 1;
        for (double i = 0; i < gameState.worldWidth; i += 40) {
          canvas.drawLine(
            Offset(i, 0),
            Offset(i, gameState.worldHeight),
            gridPaint,
          );
        }
        for (double i = 0; i < gameState.worldHeight; i += 40) {
          canvas.drawLine(
            Offset(0, i),
            Offset(gameState.worldWidth, i),
            gridPaint,
          );
        }
        break;
      case 2: // Forest
        paint.shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade900,
            Colors.green.shade800,
            Colors.brown.shade900,
          ],
        ).createShader(worldRect);
        canvas.drawRect(worldRect, paint);
        break;
      case 3: // Abyss
        paint.shader = RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [Colors.blue.shade900, Colors.black],
        ).createShader(worldRect);
        canvas.drawRect(worldRect, paint);
        break;
      case 0: // Deep Space
      default:
        paint.color = const Color(0xFF0A0A1F);
        canvas.drawRect(worldRect, paint);
        // Add star field
        final random = Random(1234);
        for (int i = 0; i < 50; i++) {
          final sPaint = Paint()
            ..color = Colors.white.withValues(alpha: random.nextDouble() * 0.1);
          canvas.drawCircle(
            Offset(
              random.nextDouble() * gameState.worldWidth,
              random.nextDouble() * gameState.worldHeight,
            ),
            random.nextDouble() * 1.5,
            sPaint,
          );
        }
    }
  }

  void _drawEnvironmentEffects(Canvas canvas) {
    // Motion lines to give a sense of speed
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    final random = Random(42); // Seeded for consistency
    for (int i = 0; i < 15; i++) {
      double x = random.nextDouble() * gameState.worldWidth;
      double y =
          (gameState.pulseValue * gameState.worldHeight +
              random.nextDouble() * 200) %
          gameState.worldHeight;
      double length = 20 + random.nextDouble() * 40;
      canvas.drawLine(Offset(x, y), Offset(x, y + length), linePaint);
    }
  }

  void _drawWorldObjects(Canvas canvas) {
    final brickPaint = Paint()..color = Colors.brown[700]!;
    final woodPaint = Paint()
      ..color = Colors.orange[900]!.withValues(alpha: 0.8);

    for (var obj in gameState.worldObjects) {
      if (!obj.isActive) continue;

      if (obj.type == VerticalObjectType.food) {
        if (obj.imagePath != null &&
            gameState.loadedImages.containsKey(obj.imagePath)) {
          final image = gameState.loadedImages[obj.imagePath]!;
          final rect = Rect.fromCenter(
            center: obj.position,
            width: 50,
            height: 50,
          );
          paintImage(
            canvas: canvas,
            rect: rect,
            image: image,
            fit: BoxFit.contain,
          );
        }
      } else {
        // Draw Obstacle
        final rect = Rect.fromCenter(
          center: obj.position,
          width: obj.type == VerticalObjectType.brick ? 60 : 80,
          height: obj.type == VerticalObjectType.brick ? 40 : 30,
        );

        final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
        canvas.drawRRect(
          rRect,
          obj.type == VerticalObjectType.brick ? brickPaint : woodPaint,
        );

        // Add texture/detail
        final detailPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRRect(rRect, detailPaint);
      }
    }
  }

  void _drawSnakeBody(Canvas canvas) {
    if (gameState.bodySegments.isEmpty) return;

    final skinColor = _getSkinColor();
    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 35.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bodyPath = Path();
    bodyPath.moveTo(gameState.headPos.dx, gameState.headPos.dy);
    for (var pos in gameState.bodySegments) {
      bodyPath.lineTo(pos.dx, pos.dy);
    }

    // Draw shadow
    canvas.save();
    canvas.translate(0, 10);
    canvas.drawPath(bodyPath, shadowPaint);
    canvas.restore();

    // Draw main body
    final bodyPaint = Paint()
      ..color = skinColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 35.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(bodyPath, bodyPaint);
  }

  void _drawSnakeHead(Canvas canvas) {
    canvas.save();
    canvas.translate(gameState.headPos.dx, gameState.headPos.dy);

    // Determine the direction the snake is moving
    double angle = 0;
    if (gameState.bodySegments.isNotEmpty) {
      final firstSegment = gameState.bodySegments.first;
      angle = atan2(
        firstSegment.dy - gameState.headPos.dy,
        firstSegment.dx - gameState.headPos.dx,
      );
    }

    // We want the face pointing "forward", so angle + pi
    canvas.rotate(angle + pi);

    final skinColor = _getSkinColor();
    final headRadius = 24.0;

    // Head Base
    final headPaint = Paint()
      ..color = skinColor
      ..style = PaintingStyle.fill;

    // Add a snout extending forwards to fit the mouth shape
    final snoutPath = Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: headRadius))
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, -18, 20, 36),
          const Radius.circular(16),
        ),
      );

    canvas.drawPath(snoutPath, headPaint);

    // Eyes: white base with inner pupils
    final whitePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()
      ..color = const Color(0xFF1B3B6B); // Deep blue matching the tongue/body

    // Left eye (looking "up" slightly when facing right)
    canvas.drawCircle(const Offset(4, -12), 8, whitePaint);
    canvas.drawCircle(const Offset(6, -12), 4, pupilPaint);
    // Right eye
    canvas.drawCircle(const Offset(4, 12), 8, whitePaint);
    canvas.drawCircle(const Offset(6, 12), 4, pupilPaint);

    // Mouth (D-shape cut into the head or added as dark)
    final mouthPaint = Paint()..color = const Color(0xFF1B3B6B);
    final mouthPath = Path()
      ..moveTo(10, -8)
      ..quadraticBezierTo(22, -8, 22, 0)
      ..quadraticBezierTo(22, 8, 10, 8)
      ..close();
    canvas.drawPath(mouthPath, mouthPaint);

    // Fangs
    final fangPaint = Paint()..color = Colors.white;
    final topFang = Path()
      ..moveTo(12, -7)
      ..lineTo(16, -7)
      ..lineTo(14, -3)
      ..close();
    final bottomFang = Path()
      ..moveTo(12, 7)
      ..lineTo(16, 7)
      ..lineTo(14, 3)
      ..close();

    canvas.drawPath(topFang, fangPaint);
    canvas.drawPath(bottomFang, fangPaint);

    canvas.restore();
  }

  Color _getSkinColor() {
    switch (gameState.selectedSkin) {
      case 'Cyber':
        return Colors.cyanAccent;
      case 'Lava':
        return Colors.orangeAccent;
      case 'Ghost':
        return Colors.white70;
      case 'Classic':
      default:
        // solid flat blue as per image
        return const Color(0xFF4C6BEE);
    }
  }

  @override
  bool shouldRepaint(covariant VerticalGamePainter oldDelegate) => true;
}
