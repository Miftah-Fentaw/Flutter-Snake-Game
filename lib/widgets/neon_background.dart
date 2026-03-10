import 'package:flutter/material.dart';

class NeonBackground extends StatelessWidget {
  final double progress;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? backgroundColor;

  const NeonBackground({
    super.key,
    required this.progress,
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? colorScheme.surface;
    final primary = primaryColor ?? colorScheme.primary;
    final secondary = secondaryColor ?? colorScheme.secondary;

    return Stack(
      children: [
        // Grid
        Positioned.fill(
          child: CustomPaint(
            painter: _NeonGridPainter(
              progress: progress,
              primaryColor: primary,
              secondaryColor: secondary,
            ),
          ),
        ),
        // Vignette
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Colors.transparent, bg.withValues(alpha: 0.8)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NeonGridPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  _NeonGridPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double step = 60.0;
    final double offset = progress * step;

    // Draw horizontal lines
    for (double y = 0; y < size.height + step; y += step) {
      double currentY = y + (offset % step);
      double progress = (currentY / size.height).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = primaryColor.withValues(alpha: 0.03 * (1 - progress))
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, currentY), Offset(size.width, currentY), paint);
    }

    // Draw vertical lines (perspective effect)
    final centerX = size.width / 2;
    for (double x = -size.width; x < size.width * 2; x += step) {
      paint.color = primaryColor.withValues(alpha: 0.3);
      canvas.drawLine(Offset(centerX, -100), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NeonGridPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
