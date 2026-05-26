import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CleanAuthBackground extends StatelessWidget {
  final Widget child;

  const CleanAuthBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBFA), // Very soft warm white
      ),
      child: Stack(
        children: [
          // Subtle Saffron Gradient Accent (Top Left)
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.08),
                    AppColors.primaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Subtle Saffron Gradient Accent (Bottom Right)
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.05),
                    AppColors.primaryColor.withValues(alpha: 0.0),
                  ],
                ),
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
