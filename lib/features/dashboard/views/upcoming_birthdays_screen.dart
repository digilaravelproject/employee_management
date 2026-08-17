import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class UpcomingBirthdaysScreen extends StatelessWidget {
  const UpcomingBirthdaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('Upcoming Birthdays', fontSize: 18, fontWeight: FontWeight.w700),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildBirthdayItem('Rohit Sharma', 'UI/UX Designer', 'Today', 0, 'https://i.pravatar.cc/150?u=rohit'),
          const SizedBox(height: 16),
          _buildBirthdayItem('Neha Gupta', 'Marketing Executive', '22 May', 2, 'https://i.pravatar.cc/150?u=neha'),
          const SizedBox(height: 16),
          _buildBirthdayItem('Karan Joshi', 'QA Engineer', '25 May', 5, 'https://i.pravatar.cc/150?u=karan'),
          const SizedBox(height: 16),
          _buildBirthdayItem('Arjun Patel', 'Software Developer', '28 May', 8, 'https://i.pravatar.cc/150?u=arjun'),
        ],
      ),
    );
  }

  Widget _buildBirthdayItem(String name, String role, String dateStr, int daysLeft, String imgUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(imgUrl)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(name, fontSize: 15, fontWeight: FontWeight.w700),
                const SizedBox(height: 2),
                AppText(role, fontSize: 12, color: AppColors.textColorSecondary),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Iconsax.calendar_1, size: 14, color: AppColors.primaryColor),
                    const SizedBox(width: 4),
                    AppText(dateStr, fontSize: 12, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: daysLeft == 0 ? Colors.red.withValues(alpha: 0.1) : AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                AppText(
                  daysLeft == 0 ? 'Today' : '$daysLeft', 
                  fontSize: daysLeft == 0 ? 12 : 16, 
                  fontWeight: FontWeight.w800,
                  color: daysLeft == 0 ? Colors.red : AppColors.primaryColor,
                ),
                if (daysLeft > 0)
                  const AppText('Days', fontSize: 10, color: AppColors.primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
