import 'package:flutter/material.dart';

class AppColors {
  // Theme Colors
  static const Color primaryColor = Color(0xFF3B206A); // Vibrant Primary (Deep Purple)
  static const Color primaryLight = Color(0xFFF5F0FB); // Soft tint of primary
  static const Color primaryDark = Color(0xFF261042); // Darker shade of primary
  static const Color secondaryColor = Color(0xFF10B981); // Emerald Secondary/Success remains

  // Two-Tone Card Gradient Colors (One Light, One Dark in Primary Palette)
  static const Color primaryGradientLight = Color(0xFF702F9B); // Vibrant lighter purple
  static const Color primaryGradientDark = Color(0xFF261042);  // Rich deep dark purple

  // Primary Palette Scale (for light and dark shades across the app)
  static const Color primaryShade50 = Color(0xFFFAF7FD);
  static const Color primaryShade100 = Color(0xFFF3EDFB);
  static const Color primaryShade200 = Color(0xFFE0D2F4);
  static const Color primaryShade300 = Color(0xFFC4ADEC);
  static const Color primaryShade400 = Color(0xFF9168C4);
  static const Color primaryShade500 = Color(0xFF702F9B);
  static const Color primaryShade600 = Color(0xFF3B206A); // primaryColor
  static const Color primaryShade700 = Color(0xFF2E1953);
  static const Color primaryShade800 = Color(0xFF22123D);
  static const Color primaryShade900 = Color(0xFF160B27);

  // Gradient for headers / cards (Two distinct tones: one light, one dark)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientLight, primaryGradientDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryCardGradient = LinearGradient(
    colors: [primaryGradientLight, primaryGradientDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color backgroundColor = Color(0xFFFFFFFF); // Pure White BG
  static const Color scaffoldBackgroundColor = Color(0xFFF9FAFB); // Very Light Grey/White
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textColorPrimary = Color(0xFF1E293B); // Slate 800
  static const Color textColorSecondary = Color(0xFF475569); // Slate 600
  static const Color textColorHint = Color(0xFF94A3B8); // Slate 400
  
  // State Colors
  static const Color successColor = Color(0xFF10B981); // Emerald 500
  static const Color errorColor = Color(0xFFEF4444); // Red 500
  static const Color warningColor = Color(0xFFF59E0B); // Amber 500
  static const Color infoColor = Color(0xFF742eed); // Violet 500

  // Utility Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color black = Color(0xFF000000);
  static const Color black87 = Color(0xDD000000);
  static const Color errorColorAccent = Color(0xFFFFE0E0);

  // Dark Theme Constants (Backwards Compatibility & SaaS Dark Mode)
  static const Color darkPrimaryColor = Color(0xFFA855F7); // Purple for Dark Mode
  static const Color darkSecondaryColor = Color(0xFF34D399); // Emerald 400
  static const Color darkBackgroundColor = Color(0xFF0F172A); // Slate 900
  static const Color darkScaffoldBackgroundColor = Color(0xFF020617); // Slate 950
  static const Color darkCardColor = Color(0xFF1E293B); // Slate 800
  static const Color darkTextColorPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextColorSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextColorHint = Color(0xFF64748B); // Slate 500
  static const Color darkBorderColor = Color(0xFF334155); // Slate 700
  static const Color darkDividerColor = Color(0xFF1E293B); // Slate 800

  // Divider & Borders
  static const Color borderColor = Color(0xFFE2E8F0); // Slate 200
  static const Color dividerColor = Color(0xFFE2E8F0); // Slate 200

  // Slate Scale (Shadows & Surfaces)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color indigo500 = Color(0xFF702F9B);
  static const Color white70 = Colors.white70;
}
