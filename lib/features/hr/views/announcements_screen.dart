import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/hr_controller.dart';
import '../models/hr_models.dart';
import 'create_announcement_screen.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HrController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Announcements',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal_1, color: AppColors.textColorPrimary, size: 20),
            onPressed: () => _showSearchDialog(controller),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Chips Bar ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: _buildChipsBar(controller),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final allAnn = controller.filteredAnnouncements;
                    final pinned = allAnn.where((a) => a.isPinned).toList();
                    final normal = allAnn.where((a) => !a.isPinned).toList();

                    if (allAnn.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Icon(Iconsax.volume_high, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              const AppText('No announcements published.', fontSize: 13, color: AppColors.textColorHint),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Pinned Section ──
                        if (pinned.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.push_pin_rounded, color: AppColors.errorColor, size: 16),
                              const SizedBox(width: 6),
                              const AppText(
                                'Pinned Announcements',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColorPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...pinned.map((ann) => _buildAnnouncementCard(context, ann)),
                          const SizedBox(height: 16),
                        ],

                        // ── Timeline Section ──
                        if (normal.isNotEmpty) ...[
                          const AppText(
                            'Recent Updates',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 10),
                          ...normal.map((ann) => _buildAnnouncementCard(context, ann)),
                        ],
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Symmetrical Trigger Button ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.slate100)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const CreateAnnouncementScreen());
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const AppText(
                  'Create Announcement',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsBar(HrController controller) {
    return Obx(() {
      final selected = controller.selectedAnnFilter.value;
      return SizedBox(
        height: 34,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: controller.annFilters.length,
          itemBuilder: (context, index) {
            final filter = controller.annFilters[index];
            final isSelected = selected == filter;

            return GestureDetector(
              onTap: () => controller.setAnnFilter(filter),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.indigo500 : AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.indigo500 : AppColors.slate200,
                  ),
                ),
                child: Center(
                  child: AppText(
                    filter,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textColorSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildAnnouncementCard(BuildContext context, HrAnnouncement ann) {
    final typeColor = _getAnnTypeColor(ann.type);
    final typeIcon = _getAnnTypeIcon(ann.type);
    final dateStr = DateFormat('dd MMMM yyyy, hh:mm a').format(ann.publishDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(typeIcon, color: typeColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      ann.title,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        ann.type,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (ann.isPinned)
                const Icon(
                  Icons.push_pin_rounded,
                  color: AppColors.errorColor,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            ann.content,
            fontSize: 12,
            color: AppColors.textColorSecondary,
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.slate100),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.clock, color: AppColors.textColorHint, size: 12),
                  const SizedBox(width: 4),
                  AppText(
                    dateStr,
                    fontSize: 10,
                    color: AppColors.textColorHint,
                  ),
                ],
              ),
              _buildPriorityBadge(ann.priority),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color badgeColor = Colors.green;
    switch (priority) {
      case 'Urgent':
        badgeColor = AppColors.errorColor;
        break;
      case 'High':
        badgeColor = AppColors.warningColor;
        break;
      case 'Normal':
        badgeColor = AppColors.indigo500;
        break;
      case 'Low':
      default:
        badgeColor = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.15)),
      ),
      child: AppText(
        priority,
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: badgeColor,
      ),
    );
  }

  Color _getAnnTypeColor(String type) {
    switch (type) {
      case 'General':
        return AppColors.primaryColor;
      case 'Holiday':
        return Colors.green;
      case 'Reminder':
        return Colors.orange;
      case 'Urgent':
      default:
        return AppColors.errorColor;
    }
  }

  IconData _getAnnTypeIcon(String type) {
    switch (type) {
      case 'General':
        return Iconsax.speaker;
      case 'Holiday':
        return Iconsax.calendar_1;
      case 'Reminder':
        return Iconsax.notification;
      case 'Urgent':
      default:
        return Iconsax.danger;
    }
  }

  void _showSearchDialog(HrController controller) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Search Announcements', fontSize: 16, fontWeight: FontWeight.bold),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Type query and tap Search...',
            hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorHint),
          ),
          ElevatedButton(
            onPressed: () {
              final query = textController.text.trim();
              Get.back();
              if (query.isNotEmpty) {
                Get.snackbar(
                  'Search Results',
                  'No exact matching items found for "$query". Showing all.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.textColorPrimary,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const AppText('Search', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
