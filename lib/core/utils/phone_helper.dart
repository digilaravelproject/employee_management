import 'package:country_picker/country_picker.dart' as cp;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class PhoneHelper {
  static void showCountryPicker({
    required BuildContext context,
    required RxString selectedCode,
    void Function(String)? onSelected,
  }) {
    cp.showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (cp.Country country) {
        final code = '+${country.phoneCode}';
        selectedCode.value = code;
        if (onSelected != null) onSelected(code);
      },
      countryListTheme: cp.CountryListThemeData(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        inputDecoration: InputDecoration(
          hintText: 'Search country...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryColor),
          ),
        ),
      ),
    );
  }
}
