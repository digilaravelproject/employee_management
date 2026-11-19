import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String hint;
  final String? label;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const AppDropdown({
    Key? key,
    this.value,
    required this.items,
    required this.hint,
    this.label,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveHint = items.isEmpty ? 'No data available' : hint;
    final validValue = items.any((item) => item.value == value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColorSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: validValue,
          items: items,
          onChanged: items.isEmpty ? null : onChanged,
          validator: validator,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorSecondary),
          decoration: InputDecoration(
            hintText: effectiveHint,
          ),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textColorPrimary,
            fontFamily: 'Regular', // Ensure consistent font
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }
}
