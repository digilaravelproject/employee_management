import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PremiumAuthBackground extends StatelessWidget {
  final Widget child;
  final bool showSecondaryCircle;

  const PremiumAuthBackground({
    Key? key,
    required this.child,
    this.showSecondaryCircle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF9F2),
            AppColors.white,
            AppColors.white,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative Blurred Circle 1 (Top Right)
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withValues(alpha: 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          // Decorative Blurred Circle 2 (Bottom Left)
          if (showSecondaryCircle)
            Positioned(
              bottom: -50,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withValues(alpha: 0.05),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

          // Main Content
          child,
        ],
      ),
    );
  }
}
