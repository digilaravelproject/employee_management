import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppTextStyle { heading, subheading, body, caption, label }

class AppText extends StatelessWidget {
  final String text;
  final AppTextStyle style;
  final Color? color;
  final TextAlign? align;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  const AppText(
    this.text, {
    Key? key,
    this.style = AppTextStyle.body,
    this.color,
    this.align,
    this.textAlign,
    this.maxLines,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.overflow,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? align,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      style: _resolveStyle(),
    );
  }

  TextStyle _resolveStyle() {
    switch (style) {
      case AppTextStyle.heading:
        return TextStyle(
          fontSize: fontSize ?? 26,
          fontWeight: fontWeight ?? FontWeight.w800,
          color: color ?? AppColors.textColorPrimary,
          height: 1.2,
          letterSpacing: letterSpacing ?? -0.4,
          decoration: decoration,
        );
      case AppTextStyle.subheading:
        return TextStyle(
          fontSize: fontSize ?? 18,
          fontWeight: fontWeight ?? FontWeight.w700,
          color: color ?? AppColors.textColorPrimary,
          height: 1.3,
          letterSpacing: letterSpacing,
          decoration: decoration,
        );
      case AppTextStyle.label:
        return TextStyle(
          fontSize: fontSize ?? 12,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: color ?? AppColors.textColorSecondary,
          letterSpacing: letterSpacing ?? 0.5,
          decoration: decoration,
        );
      case AppTextStyle.caption:
        return TextStyle(
          fontSize: fontSize ?? 12,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color ?? AppColors.textColorHint,
          height: 1.5,
          letterSpacing: letterSpacing,
          decoration: decoration,
        );
      case AppTextStyle.body:
      default:
        return TextStyle(
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color ?? AppColors.textColorSecondary,
          height: 1.6,
          letterSpacing: letterSpacing,
          decoration: decoration,
        );
    }
  }
}
