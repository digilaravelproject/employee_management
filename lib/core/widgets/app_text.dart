import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppTextStyle { heading, subheading, body, caption, label, button }

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
  final double? height;
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
    this.height,
    this.overflow,
    this.decoration,
  }) : super(key: key);

  static String cleanText(String input) {
    if (input.isEmpty) return input;
    final lower = input.trim().toLowerCase();
    if (lower == 'something went wrong' ||
        lower == 'something went wrong.' ||
        lower == 'something went wrong. please try again.' ||
        lower == 'something went wrong. please try again' ||
        lower == 'something_went_wrong' ||
        lower == 'failed_to_load_data_message') {
      return 'No internet connection. Please check your connection and try again.';
    }

    // Don't format emails, URLs, file paths, dates, or expressions with special characters
    if (input.contains('@') ||
        input.contains('://') ||
        input.contains('/') ||
        input.contains('\\') ||
        input.contains('.pdf') ||
        input.contains('.jpg') ||
        input.contains('.png') ||
        input.contains('.jpeg') ||
        input.contains('.doc') ||
        input.contains('.svg') ||
        input.contains('{') ||
        input.contains('}')) {
      return input;
    }

    // Check if the string is purely a snake_case identifier like 'leave_type' or 'in_progress' or 'no_internet_connection'
    final snakeCaseRegex = RegExp(r'^[a-zA-Z]+(_[a-zA-Z0-9]+)+$');
    if (snakeCaseRegex.hasMatch(input.trim())) {
      final words = input.trim().split('_');
      return words.map((w) {
        if (w.isEmpty) return '';
        return w[0].toUpperCase() + w.substring(1).toLowerCase();
      }).join(' ');
    }

    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      cleanText(text),
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
          height: height ?? 1.2,
          letterSpacing: letterSpacing ?? -0.4,
          decoration: decoration,
        );
      case AppTextStyle.subheading:
        return TextStyle(
          fontSize: fontSize ?? 18,
          fontWeight: fontWeight ?? FontWeight.w700,
          color: color ?? AppColors.textColorPrimary,
          height: height ?? 1.25,
          letterSpacing: letterSpacing,
          decoration: decoration,
        );
      case AppTextStyle.button:
        return TextStyle(
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: color ?? AppColors.white,
          height: height ?? 1.1,
          letterSpacing: letterSpacing ?? 0.3,
          decoration: decoration,
        );
      case AppTextStyle.label:
        return TextStyle(
          fontSize: fontSize ?? 12,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: color ?? AppColors.textColorSecondary,
          height: height ?? 1.15,
          letterSpacing: letterSpacing ?? 0.5,
          decoration: decoration,
        );
      case AppTextStyle.caption:
        return TextStyle(
          fontSize: fontSize ?? 12,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color ?? AppColors.textColorHint,
          height: height ?? 1.3,
          letterSpacing: letterSpacing,
          decoration: decoration,
        );
      case AppTextStyle.body:
      default:
        return TextStyle(
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color ?? AppColors.textColorSecondary,
          height: height ?? 1.25,
          letterSpacing: letterSpacing,
          decoration: decoration,
        );
    }
  }
}
