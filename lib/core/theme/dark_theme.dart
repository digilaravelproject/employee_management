import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'text_theme.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.outfit().fontFamily,
  primaryColor: AppColors.darkPrimaryColor,
  scaffoldBackgroundColor: AppColors.darkScaffoldBackgroundColor,
  colorScheme: ColorScheme.dark(
    primary: AppColors.darkPrimaryColor,
    secondary: AppColors.darkSecondaryColor,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    surface: AppColors.darkCardColor,
    error: AppColors.errorColor,
  ),
  cardTheme: CardThemeData(
    color: AppColors.darkCardColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: AppColors.darkBorderColor, width: 1),
    ),
    margin: EdgeInsets.zero,
  ),
  dividerColor: AppColors.darkDividerColor,
  textTheme: GoogleFonts.outfitTextTheme(AppTextTheme.darkTextTheme),
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.darkBackgroundColor,
    foregroundColor: AppColors.darkTextColorPrimary,
    iconTheme: const IconThemeData(color: AppColors.darkTextColorPrimary),
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: AppColors.darkTextColorPrimary,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: AppColors.darkCardColor,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkBorderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkPrimaryColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.errorColor),
    ),
    hintStyle: const TextStyle(color: AppColors.darkTextColorHint),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimaryColor,
      foregroundColor: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
);
