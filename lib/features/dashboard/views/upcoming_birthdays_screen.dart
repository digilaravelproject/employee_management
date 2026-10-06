import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/widgets/app_text.dart';
import '../../employee/management/controllers/employee_controller.dart';
import '../controllers/birthdays_controller.dart';
import '../models/upcoming_birthdays_model.dart';

class UpcomingBirthdaysScreen extends StatelessWidget {
  const UpcomingBirthdaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<BirthdaysController>()
        ? Get.find<BirthdaysController>()
        : Get.put(BirthdaysController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          children: [
            AppText('Upcoming Birthdays', fontSize: 17, fontWeight: FontWeight.w700),
            AppText('Celebrate & wish your team', fontSize: 11, color: AppColors.textColorSecondary),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textColorPrimary, size: 20),
            onPressed: () => controller.fetchUpcomingBirthdays(isRefresh: true),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryColor),
                SizedBox(height: 12),
                AppText('Loading birthdays...', fontSize: 13, color: AppColors.textColorSecondary),
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty && controller.birthdays.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.danger, color: AppColors.errorColor, size: 40),
                  const SizedBox(height: 12),
                  AppText(
                    controller.errorMessage.value,
                    fontSize: 13,
                    color: AppColors.textColorSecondary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchUpcomingBirthdays(isRefresh: true),
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                    label: const AppText('Try Again', color: Colors.white, fontWeight: FontWeight.bold),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.birthdays.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchUpcomingBirthdays(isRefresh: true),
            color: AppColors.primaryColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.cake, size: 48, color: AppColors.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      const AppText('No Upcoming Birthdays', fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: AppText(
                          'No upcoming birthdays found at the moment.',
                          fontSize: 12,
                          color: AppColors.textColorSecondary,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final bdays = controller.birthdays;

        return RefreshIndicator(
          onRefresh: () => controller.fetchUpcomingBirthdays(isRefresh: true),
          color: AppColors.primaryColor,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(16),
            itemCount: bdays.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = bdays[index];
              return _buildBirthdayCard(context, item, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildBirthdayCard(
    BuildContext context,
    UpcomingBirthdayItem item,
    BirthdaysController controller,
  ) {
    final isToday = item.isToday || item.daysUntil == 0;
    final hasAvatar = item.avatar != null &&
        item.avatar!.trim().isNotEmpty &&
        Uri.tryParse(item.avatar!)?.isAbsolute == true;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showBirthdayDetailModal(context, item, controller),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isToday ? const Color(0xFFF43F5E) : AppColors.slate200,
              width: isToday ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isToday
                    ? const Color(0xFFF43F5E).withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with celebration indicator
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: isToday
                        ? const Color(0xFFFFE4E6)
                        : AppColors.primaryLight,
                    backgroundImage: hasAvatar ? NetworkImage(item.avatar!) : null,
                    onBackgroundImageError: hasAvatar ? (e, s) {} : null,
                    child: !hasAvatar
                        ? Text(
                            item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isToday ? const Color(0xFFE11D48) : AppColors.primaryColor,
                            ),
                          )
                        : null,
                  ),
                  if (isToday)
                    const Positioned(
                      bottom: -2,
                      right: -2,
                      child: Text('🎂', style: TextStyle(fontSize: 14)),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Employee details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AppText(
                            item.name,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const AppText(
                              'TODAY',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      item.designation.isNotEmpty ? item.designation : 'Team Member',
                      fontSize: 12,
                      color: AppColors.textColorSecondary,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (item.employeeId.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText(
                              item.employeeId,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate600,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const Icon(Iconsax.calendar_1, size: 13, color: AppColors.primaryColor),
                        const SizedBox(width: 4),
                        AppText(
                          item.birthdayLabel.isNotEmpty ? item.birthdayLabel : item.birthday,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Days countdown badge
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isToday
                      ? const Color(0xFFFFF1F2)
                      : AppColors.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isToday
                        ? const Color(0xFFFECDD3)
                        : AppColors.primaryColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      isToday ? 'Today' : '${item.daysUntil}',
                      fontSize: isToday ? 11 : 16,
                      fontWeight: FontWeight.w800,
                      color: isToday ? const Color(0xFFE11D48) : AppColors.primaryColor,
                    ),
                    if (!isToday)
                      AppText(
                        item.daysUntil == 1 ? 'Day' : 'Days',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Click interaction: opens a comprehensive, beautiful celebration modal sheet
  void _showBirthdayDetailModal(
    BuildContext context,
    UpcomingBirthdayItem item,
    BirthdaysController controller,
  ) {
    final isToday = item.isToday || item.daysUntil == 0;
    final hasAvatar = item.avatar != null &&
        item.avatar!.trim().isNotEmpty &&
        Uri.tryParse(item.avatar!)?.isAbsolute == true;

    // Retrieve cached employee contacts if available
    final empController = Get.isRegistered<EmployeeController>()
        ? Get.find<EmployeeController>()
        : Get.put(EmployeeController());
    final cached = empController.employees.firstWhereOrNull(
      (e) => e.id == item.id.toString() || e.employeeId.toLowerCase() == item.employeeId.toLowerCase(),
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Celebration header icon & avatar
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isToday
                            ? [const Color(0xFFF43F5E), const Color(0xFFFB7185)]
                            : [AppColors.primaryColor, const Color(0xFF6366F1)],
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 37,
                      backgroundColor: isToday ? const Color(0xFFFFE4E6) : AppColors.primaryLight,
                      backgroundImage: hasAvatar ? NetworkImage(item.avatar!) : null,
                      onBackgroundImageError: hasAvatar ? (e, s) {} : null,
                      child: !hasAvatar
                          ? Text(
                              item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isToday ? const Color(0xFFE11D48) : AppColors.primaryColor,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(isToday ? '🎂' : '🎈', style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Name & Role
              AppText(item.name, fontSize: 18, fontWeight: FontWeight.w800),
              const SizedBox(height: 3),
              AppText(
                item.designation.isNotEmpty ? item.designation : 'Team Member',
                fontSize: 13,
                color: AppColors.textColorSecondary,
              ),
              if (item.employeeId.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppText(
                    'ID: ${item.employeeId}',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate700,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Birthday Details Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFFFFF1F2) : AppColors.slate50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isToday ? const Color(0xFFFECDD3) : AppColors.slate200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isToday ? const Color(0xFFFFE4E6) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isToday ? Iconsax.cake : Iconsax.calendar_1,
                        color: isToday ? const Color(0xFFE11D48) : AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            isToday ? 'Birthday Celebration Today!' : 'Birthday Date: ${item.birthdayLabel}',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isToday ? const Color(0xFFE11D48) : AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            isToday
                                ? 'Don\'t forget to share your warm wishes!'
                                : (item.daysUntil == 1
                                    ? 'Coming up tomorrow! Get ready to celebrate.'
                                    : '${item.daysUntil} days left (${item.birthday})'),
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons: WhatsApp Wish, Email Wish, View Profile
              Row(
                children: [
                  // WhatsApp Wish Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.openWhatsAppWish(item, phone: cached?.mobile);
                      },
                      icon: const Icon(Icons.chat_bubble_rounded, size: 18, color: Color(0xFF25D366)),
                      label: const AppText(
                        'WhatsApp',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF25D366), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Email Wish Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.openEmailWish(item, email: cached?.email);
                      },
                      icon: const Icon(Icons.email_outlined, size: 18, color: Color(0xFF0284C7)),
                      label: const AppText(
                        'Email Wish',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF0284C7), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Copy message option
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    final wishText = 'Wishing you a very Happy Birthday, ${item.name}! 🎂🎉 Hope you have a wonderful year ahead!';
                    Clipboard.setData(ClipboardData(text: wishText));
                    CustomSnackbar.showSuccess('Birthday wish copied to clipboard!');
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textColorSecondary),
                  label: const AppText(
                    'Copy Birthday Message',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // View Full Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    controller.openEmployeeProfile(item);
                  },
                  icon: const Icon(Iconsax.user, size: 16, color: Colors.white),
                  label: const AppText(
                    'View Employee Profile',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
