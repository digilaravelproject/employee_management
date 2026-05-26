import 'package:flutter/material.dart';

import '../constants/image_constants.dart';
import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const AppLogo({Key? key, this.size = 100, this.showShadow = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 4,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      // ClipOval ensures the image fills the circle perfectly edge-to-edge
      child: ClipOval(
        child: Image.asset(
          ImageConstants.logo,
          fit: BoxFit.cover,
          width: size,
          height: size,
        ),
      ),
    );
  }
}
