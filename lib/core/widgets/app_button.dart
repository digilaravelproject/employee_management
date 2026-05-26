import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final Widget? icon;
  final bool isFullWidth;
  final OutlinedBorder? shape;
  final BorderSide? borderSide;
  final double? fontSize;
  final FontWeight? fontWeight;

  final EdgeInsetsGeometry? padding;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.shape,
    this.borderSide,
    this.fontSize,
    this.fontWeight,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryColor;
    final effectiveTextColor = textColor ?? AppColors.white;

    return SizedBox(
      width: width ?? (isFullWidth ? double.infinity : null),
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: effectiveColor.withOpacity(0.6),
          elevation: 0,
          //fontFamily: GoogleFonts.outfit().fontFamily,
          shape: shape ?? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide ?? BorderSide.none,
          ),
          padding: padding ?? EdgeInsets.symmetric(horizontal: icon != null ? 12 : 16),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize ?? 16,
                      fontWeight: fontWeight ?? FontWeight.w600,
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      color: effectiveTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
      ),
    );
  }

  factory AppButton.outline({
    required String text,
    VoidCallback? onPressed,
    Color? color,
    double? width,
    double height = 56,
    double borderRadius = 12,
    Widget? icon,
    bool isFullWidth = true,
    double? fontSize,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      color: AppColors.transparent,
      textColor: color ?? AppColors.primaryColor,
      width: width,
      height: height,
      borderRadius: borderRadius,
      icon: icon,
      isFullWidth: isFullWidth,
      borderSide: BorderSide(color: color ?? AppColors.primaryColor, width: 1.5),
      fontSize: fontSize,
    );
  }
}
