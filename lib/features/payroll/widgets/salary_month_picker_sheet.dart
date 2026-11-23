import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

/// Shows a responsive, beautiful Month & Year Picker Bottom Sheet for Salaries.
/// - Restricts selection so future months cannot be selected.
/// - Allows navigating back to previous years (e.g. last year, 2025, 2024, etc.).
/// - Fits completely without any RenderFlex overflow on any mobile screen.
void showSalaryMonthPickerSheet({
  required BuildContext context,
  required String initialMonthCode, // e.g. "2026-11"
  required Function(String code, String label) onMonthSelected,
}) {
  final now = DateTime.now();

  int selectedYear = now.year;
  int selectedMonth = now.month;

  try {
    if (initialMonthCode.isNotEmpty) {
      final parts = initialMonthCode.split('-');
      if (parts.length >= 2) {
        selectedYear = int.tryParse(parts[0]) ?? now.year;
        selectedMonth = int.tryParse(parts[1]) ?? now.month;
      }
    }
  } catch (_) {}

  int viewYear = selectedYear;

  const monthNames = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
  ];

  const shortMonthNames = [
    'Jan', 'Feb', 'Mar', 'Apr',
    'May', 'Jun', 'Jul', 'Aug',
    'Sep', 'Oct', 'Nov', 'Dec'
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          final isCurrentYear = viewYear == now.year;
          final canGoForward = viewYear < now.year;

          final screenHeight = MediaQuery.of(context).size.height;
          return Container(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Drag Handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.slate300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        'Select Salary Month',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textColorSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Year Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppColors.textColorPrimary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () {
                            setState(() {
                              viewYear--;
                            });
                          },
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.calendar, size: 16, color: AppColors.primaryColor),
                            const SizedBox(width: 8),
                            AppText(
                              '$viewYear',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                            if (isCurrentYear) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const AppText(
                                  'Current',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: canGoForward ? AppColors.textColorPrimary : AppColors.slate300,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: canGoForward
                              ? () {
                                  setState(() {
                                    viewYear++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Months Grid (4x3)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final monthNum = index + 1;
                      final isFutureMonth = viewYear > now.year ||
                          (viewYear == now.year && monthNum > now.month);
                      final isSelected = viewYear == selectedYear && monthNum == selectedMonth;

                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: isFutureMonth
                            ? null
                            : () {
                                final code = '$viewYear-${monthNum.toString().padLeft(2, '0')}';
                                final label = '${monthNames[index]} $viewYear';
                                Get.back();
                                onMonthSelected(code, label);
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor
                                : (isFutureMonth ? AppColors.slate100.withValues(alpha: 0.5) : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : (isFutureMonth ? AppColors.slate200.withValues(alpha: 0.5) : AppColors.slate200),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withValues(alpha: 0.25),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(
                                shortMonthNames[index],
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isFutureMonth
                                        ? AppColors.textColorHint.withValues(alpha: 0.4)
                                        : AppColors.textColorPrimary),
                              ),
                              AppText(
                                monthNames[index],
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : (isFutureMonth
                                        ? AppColors.textColorHint.withValues(alpha: 0.3)
                                        : AppColors.textColorSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
        },
      );
    },
  );
}
