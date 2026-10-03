import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class EmployeeDailyUpdateScreen extends StatefulWidget {
  final String projectTitle;

  const EmployeeDailyUpdateScreen({super.key, required this.projectTitle});

  @override
  State<EmployeeDailyUpdateScreen> createState() => _EmployeeDailyUpdateScreenState();
}

class _EmployeeDailyUpdateScreenState extends State<EmployeeDailyUpdateScreen> {
  final TextEditingController _updateController = TextEditingController();
  final RxList<Map<String, String>> _submittedUpdates = <Map<String, String>>[].obs;
  final RxBool _isSubmitting = false.obs;

  @override
  void dispose() {
    _updateController.dispose();
    super.dispose();
  }

  void _submitDailyUpdate() {
    final text = _updateController.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter what you worked on today.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    _isSubmitting.value = true;
    Future.delayed(const Duration(milliseconds: 600), () {
      _submittedUpdates.insert(0, {
        'date': 'Today, ${_formatTime(DateTime.now())}',
        'content': text,
      });
      _updateController.clear();
      _isSubmitting.value = false;

      Get.snackbar(
        'Success',
        'Daily update recorded successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successColor,
        colorText: Colors.white,
      );
    });
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Daily Update',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              widget.projectTitle,
              fontSize: 12,
              color: AppColors.textColorSecondary,
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Submit Update Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.slate200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    "Today's Update",
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _updateController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'What did you work on today?',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textColorHint),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                      onPressed: _isSubmitting.value ? null : _submitDailyUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const AppText(
                              'Submit Update',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                    )),
                  ),
                ],
              ),
            ),

            // Past Updates Timeline
            Expanded(
              child: Obx(() {
                if (_submittedUpdates.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.note_2, size: 36, color: AppColors.textColorHint),
                          SizedBox(height: 12),
                          AppText(
                            'No Updates Yet',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          SizedBox(height: 4),
                          AppText(
                            'Submit your daily report above to begin tracking project updates.',
                            fontSize: 12,
                            color: AppColors.textColorSecondary,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _submittedUpdates.length,
                  itemBuilder: (context, index) {
                    final update = _submittedUpdates[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primaryColor, width: 2),
                              ),
                            ),
                            if (index != _submittedUpdates.length - 1)
                              Container(
                                width: 2,
                                height: 60,
                                color: AppColors.slate200,
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  update['date']!,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColorSecondary,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.slate200),
                                  ),
                                  child: AppText(
                                    update['content']!,
                                    fontSize: 13,
                                    color: AppColors.textColorPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
