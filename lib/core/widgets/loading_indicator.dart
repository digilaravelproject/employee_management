import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const LoadingIndicator({
    Key? key,
    this.size = 28,
    this.strokeWidth = 2.5,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primaryColor;
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(c),
        backgroundColor: c.withOpacity(0.12),
      ),
    );
  }
}
