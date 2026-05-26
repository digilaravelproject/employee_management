import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexagonPainter extends CustomPainter {
  final Color color;

  const HexagonPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;
    
    // Draw an pointy-topped hexagon
    final centerX = width / 2;
    final centerY = height / 2;
    final radius = math.min(width, height) / 2;

    for (int i = 0; i < 6; i++) {
        final angle = (60 * i - 30) * math.pi / 180;
        final x = centerX + radius * math.cos(angle);
        final y = centerY + radius * math.sin(angle);
        if (i == 0) {
            path.moveTo(x, y);
        } else {
            path.lineTo(x, y);
        }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HexagonPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
