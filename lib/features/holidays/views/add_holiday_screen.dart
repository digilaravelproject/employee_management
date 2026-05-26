import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../controllers/holidays_controller.dart';

class AddHolidayScreen extends StatelessWidget {
  const AddHolidayScreen({super.key});

  String formatFullDate(DateTime date) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekday = weekdays[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$weekday, ${date.day.toString().padLeft(2, '0')} $monthName ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HolidaysController>();
    final isEditMode = controller.selectedHoliday.value != null;

    // Local description character counter observable
    final RxInt descCharCount = (controller.descriptionController.text.length).obs;
    controller.descriptionController.addListener(() {
      descCharCount.value = controller.descriptionController.text.length;
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textColorPrimary,
                size: 20,
              ),
              onPressed: () {
                // Clear any edits on back
                controller.clearForm();
                Get.back();
              },
            ),
          ),
        ),
        title: AppText(
          isEditMode ? 'Edit Holiday' : 'Add Holiday',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Holiday Name ──
              _buildFieldLabel('Holiday Name'),
              AppInputField(
                controller: controller.nameController,
                hint: 'Enter holiday name',
              ),
              const SizedBox(height: 20),

              // ── Date Selection ──
              _buildFieldLabel('Date'),
              Obx(() {
                final dateSelected = controller.selectedDate.value;
                return InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dateSelected ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primaryColor, // Theme primary color
                              onPrimary: Colors.white,
                              onSurface: AppColors.textColorPrimary,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      controller.selectedDate.value = picked;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          dateSelected != null ? formatFullDate(dateSelected) : 'Select date',
                          fontSize: 13,
                          fontWeight: dateSelected != null ? FontWeight.bold : FontWeight.w500,
                          color: dateSelected != null ? AppColors.textColorPrimary : AppColors.textColorHint,
                        ),
                        const Icon(
                          Iconsax.calendar,
                          color: AppColors.textColorHint,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // ── Holiday Type ──
              _buildFieldLabel('Holiday Type'),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedType.value,
                        icon: const Icon(Iconsax.arrow_down_1, size: 18, color: AppColors.textColorSecondary),
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                        onChanged: (type) {
                          if (type != null) {
                            controller.selectedType.value = type;
                          }
                        },
                        items: controller.holidayTypes.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),

              // ── Location ──
              _buildFieldLabel('Location'),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedLocation.value,
                        icon: const Icon(Iconsax.arrow_down_1, size: 18, color: AppColors.textColorSecondary),
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                        onChanged: (loc) {
                          if (loc != null) {
                            controller.selectedLocation.value = loc;
                          }
                        },
                        items: controller.locations.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),

              // ── Repeat Every Year ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'Repeat Every Year',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColorPrimary,
                  ),
                  Obx(() => Switch(
                        value: controller.repeatEveryYear.value,
                        onChanged: (val) => controller.repeatEveryYear.value = val,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.primaryColor,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColors.slate300,
                      )),
                ],
              ),
              const SizedBox(height: 20),

              // ── Description ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'Description (Optional)',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColorPrimary,
                  ),
                  Obx(() => AppText(
                        '${descCharCount.value}/200',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: descCharCount.value > 200 ? Colors.redAccent : AppColors.textColorHint,
                      )),
                ],
              ),
              const SizedBox(height: 8),
              AppInputField(
                controller: controller.descriptionController,
                hint: 'Enter description',
                maxLines: 4,
              ),
              const SizedBox(height: 40),

              // ── Cancel & Save Buttons ──
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearForm();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.slate200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const AppText(
                        'Cancel',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Save Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (isEditMode) {
                          controller.updateHoliday();
                        } else {
                          controller.saveHoliday();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor, // Theme Primary Color Save button
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: AppText(
                        isEditMode ? 'Save Changes' : 'Save Holiday',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Field Title Helper with required Red Asterisk
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textColorPrimary,
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
