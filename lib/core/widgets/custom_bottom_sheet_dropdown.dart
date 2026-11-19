import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';

class CustomBottomSheetDropdown extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final String? hintText;
  final List<String> items;
  final Function(String) onChanged;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final Color? prefixIconBgColor;
  final Color? borderColor;

  const CustomBottomSheetDropdown({
    super.key,
    required this.label,
    required this.selectedValue,
    this.hintText,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.prefixIconColor,
    this.prefixIconBgColor,
    this.borderColor,
  });

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText('Select $label', fontSize: 16, fontWeight: FontWeight.bold),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textColorSecondary),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.slate200),
              // List or Empty state
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.slate100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Iconsax.info_circle, size: 28, color: AppColors.slate400),
                              ),
                              const SizedBox(height: 12),
                              AppText(
                                'No ${label.toLowerCase()} available',
                                fontSize: 14,
                                color: AppColors.textColorSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = item == selectedValue;

                          return InkWell(
                            onTap: () {
                              onChanged(item);
                              Get.back();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              color: isSelected ? AppColors.primaryLight : Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  AppText(
                                    item,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                                  ),
                                  if (isSelected)
                                    const Icon(Iconsax.tick_circle, color: AppColors.primaryColor, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValidSelection = selectedValue != null &&
        selectedValue!.isNotEmpty &&
        items.contains(selectedValue);
    final String defaultHint = items.isEmpty ? 'No ${label.toLowerCase()} available' : 'Select $label';
    final displayText = hasValidSelection ? selectedValue! : (hintText ?? defaultHint);

    return GestureDetector(
      onTap: () => _showBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor ?? AppColors.slate200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: prefixIconBgColor ?? AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(prefixIcon, color: prefixIconColor ?? AppColors.primaryColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: AppText(
                      displayText,
                      fontSize: 14,
                      fontWeight: hasValidSelection ? FontWeight.w600 : FontWeight.normal,
                      color: hasValidSelection ? AppColors.textColorPrimary : AppColors.textColorHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textColorSecondary),
          ],
        ),
      ),
    );
  }
}
