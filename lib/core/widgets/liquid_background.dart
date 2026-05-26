import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LiquidBackground extends StatefulWidget {
  final Widget child;

  const LiquidBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground> with SingleTickerProviderStateMixin {
  late AnimationController _liquidController;

  final Color primaryNavy = const Color(0xFF1E3A6F);
  final Color accentGold = const Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid White Base
        Container(color: AppColors.white),
        
        // Animated Liquid Layers
        AnimatedBuilder(
          animation: _liquidController,
          builder: (context, child) {
            return Stack(
              children: [
                CustomPaint(
                  painter: LiquidSplashPainter(
                    color: primaryNavy.withOpacity(0.04),
                    animationValue: _liquidController.value,
                  ),
                  size: Size.infinite,
                ),
                CustomPaint(
                  painter: LiquidSplashPainter(
                    color: accentGold.withOpacity(0.03),
                    animationValue: (_liquidController.value + 0.5) % 1.0,
                  ),
                  size: Size.infinite,
                ),
              ],
            );
          },
        ),
        
        // Foreground Content
        widget.child,
      ],
    );
  }
}

class LiquidSplashPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  LiquidSplashPainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    
    double centerX = size.width * 0.2;
    double centerY = size.height * 0.2;
    double radius = 250 + (30 * math.sin(animationValue * 2 * math.pi));

    path.moveTo(centerX, centerY - radius);
    for (int i = 0; i < 360; i += 30) {
      double angle = i * math.pi / 180;
      double variation = 40 * math.sin((i + animationValue * 360) * math.pi / 180);
      double x = centerX + (radius + variation) * math.cos(angle);
      double y = centerY + (radius + variation) * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    final path2 = Path();
    double centerX2 = size.width * 0.9;
    double centerY2 = size.height * 0.8;
    double radius2 = 200 + (25 * math.cos(animationValue * 2 * math.pi));

    for (int i = 0; i < 360; i += 30) {
      double angle = i * math.pi / 180;
      double variation = 30 * math.cos((i + animationValue * 360) * math.pi / 180);
      double x = centerX2 + (radius2 + variation) * math.cos(angle);
      double y = centerY2 + (radius2 + variation) * math.sin(angle);
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidSplashPainter oldDelegate) => 
    oldDelegate.animationValue != animationValue;
}
