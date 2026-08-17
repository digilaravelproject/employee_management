import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class EmployeeDailyUpdateScreen extends StatelessWidget {
  final String projectTitle;

  const EmployeeDailyUpdateScreen({super.key, required this.projectTitle});

  @override
  Widget build(BuildContext context) {
    // Mock past updates
    final pastUpdates = [
      {
        'date': 'Yesterday, 5:30 PM',
        'content': 'Completed the UI for the login module and integrated the auth API.',
      },
      {
        'date': 'Aug 12, 6:00 PM',
        'content': 'Worked on the routing setup and state management structure.',
      },
      {
        'date': 'Aug 11, 5:45 PM',
        'content': 'Initial project setup and dependency installation. Created base theme.',
      },
    ];

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
              projectTitle,
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
                    child: ElevatedButton(
                      onPressed: () {
                        Get.snackbar(
                          'Success',
                          'Daily update submitted successfully!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.successColor,
                          colorText: Colors.white,
                        );
                        // Clear or navigate back
                        Future.delayed(const Duration(seconds: 1), () => Get.back());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const AppText(
                        'Submit Update',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Past Updates Timeline
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: pastUpdates.length,
                itemBuilder: (context, index) {
                  final update = pastUpdates[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline dot and line
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
                          if (index != pastUpdates.length - 1)
                            Container(
                              width: 2,
                              height: 60,
                              color: AppColors.slate200,
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Content
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
                                 // height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
