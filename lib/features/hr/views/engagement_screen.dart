import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/hr_controller.dart';
import '../models/hr_models.dart';

class EngagementScreen extends StatelessWidget {
  const EngagementScreen({super.key});

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
          'Employee Engagement',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal_1, color: AppColors.textColorPrimary, size: 20),
            onPressed: () => _showEngagementInfoDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Workplace Banner ──
                  _buildHeroBanner(),
                  const SizedBox(height: 20),

                  // ── Engagement Categories Menus ──
                  _buildActionsGrid(context, controller),
                  const SizedBox(height: 24),

                  // ── Recent Engagement timeline section ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        'Recent Engagement',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      TextButton(
                        onPressed: () {
                          Get.snackbar('Engagement', 'You are already viewing the latest milestones.');
                        },
                        child: const AppText(
                          'View All',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Obx(() {
                    final list = controller.recentEngagements;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return _buildEngagementCard(item);
                      },
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.05),
            const Color(0xFF047857).withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        "Let's build a great\nworkplace together!",
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF065F46),
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        "Your feedback and participation matter a lot.",
                        fontSize: 11,
                        color: const Color(0xFF065F46).withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🙌',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsGrid(BuildContext context, HrController controller) {
    final items = [
      {
        'title': 'Feedback & Surveys',
        'subtitle': 'Share your feedback',
        'icon': Iconsax.document_text,
        'color': AppColors.primaryColor,
        'onTap': () => _showSurveysDialog(),
      },
      {
        'title': 'Suggestions',
        'subtitle': 'Share your ideas',
        'icon': Iconsax.lamp_on,
        'color': Colors.orange,
        'onTap': () => _showSuggestionsDialog(controller),
      },
      {
        'title': 'Kudos & Recognition',
        'subtitle': 'Appreciate your peers',
        'icon': Iconsax.star,
        'color': AppColors.indigo500,
        'onTap': () => _showKudosDialog(controller),
      },
      {
        'title': 'Events & Activities',
        'subtitle': 'View upcoming events',
        'icon': Iconsax.calendar,
        'color': Colors.green,
        'onTap': () => _showEventsDialog(),
      },
      {
        'title': 'Engagement Updates',
        'subtitle': 'See all engagement updates',
        'icon': Iconsax.message_text,
        'color': Colors.teal,
        'onTap': () => _showEngagementInfoDialog(),
      },
    ];

    return Column(
      children: items.map((item) {
        final color = item['color'] as Color;
        final icon = item['icon'] as IconData;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item['onTap'] as VoidCallback?,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            item['title'] as String,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            item['subtitle'] as String,
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textColorHint,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEngagementCard(EngagementUpdate item) {
    final themeColor = _getEngagementColor(item.category);
    final themeIcon = _getEngagementIcon(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(themeIcon, color: themeColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      item.title,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    AppText(
                      item.timeAgo,
                      fontSize: 10,
                      color: AppColors.textColorHint,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AppText(
                  item.description,
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                ),
                if (item.category == 'Team Outing') ...[
                  const SizedBox(height: 10),
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate100),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.gallery, color: AppColors.textColorHint, size: 16),
                          const SizedBox(width: 6),
                          AppText('Photo Attachment: Imagicaa_Trip.jpg', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEngagementColor(String category) {
    switch (category) {
      case 'Team Outing':
        return Colors.green;
      case 'Work Anniversary':
        return Colors.purple;
      case 'Employee of the Month':
        return Colors.orange;
      case 'Wellness Webinar':
        return Colors.blue;
      case 'Kudos & Recognition':
      default:
        return AppColors.indigo500;
    }
  }

  IconData _getEngagementIcon(String category) {
    switch (category) {
      case 'Team Outing':
        return Iconsax.location;
      case 'Work Anniversary':
        return Iconsax.award;
      case 'Employee of the Month':
        return Iconsax.star1;
      case 'Wellness Webinar':
        return Iconsax.activity;
      case 'Kudos & Recognition':
      default:
        return Iconsax.like_1;
    }
  }

  void _showSuggestionsDialog(HrController controller) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Iconsax.lamp_on, color: Colors.orange),
            SizedBox(width: 10),
            AppText('Anonymous Suggestions', fontSize: 16, fontWeight: FontWeight.bold),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Your suggestions are highly valuable to build a better work environment. This form is completely anonymous.',
              fontSize: 12,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: textController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your ideas or workplace suggestions...',
                hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 12),
                filled: true,
                fillColor: AppColors.slate50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorHint),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                controller.submitSuggestion(text);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const AppText('Submit Suggestion', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showKudosDialog(HrController controller) {
    final nameController = TextEditingController();
    final msgController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Iconsax.star, color: AppColors.indigo500),
            SizedBox(width: 10),
            AppText('Kudos & Peer Recognition', fontSize: 16, fontWeight: FontWeight.bold),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Send kudos to appreciate a colleague\'s outstanding effort or peer support!',
              fontSize: 12,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Colleague\'s Name (e.g. Priya Sharma)',
                hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 12),
                filled: true,
                fillColor: AppColors.slate50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: msgController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a short message (e.g. Thanks for helping with database migration today!)',
                hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 12),
                filled: true,
                fillColor: AppColors.slate50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorHint),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final msg = msgController.text.trim();
              if (name.isNotEmpty && msg.isNotEmpty) {
                controller.submitKudos(name, msg);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const AppText('Send Kudos', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showSurveysDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const AppText('Workplace Surveys', fontSize: 16, fontWeight: FontWeight.bold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.message_programming, color: AppColors.primaryColor, size: 48),
            const SizedBox(height: 12),
            const AppText('Active Surveys', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
            const SizedBox(height: 6),
            const AppText('There are no active surveys to fill right now. We will notify you when a new survey is rolled out.', fontSize: 12, color: AppColors.textColorSecondary, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Close', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  void _showEventsDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const AppText('Events & Activities', fontSize: 16, fontWeight: FontWeight.bold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventRow('25 June 2026', 'Company Annual Day Celebration', 'Active'),
            const SizedBox(height: 10),
            _buildEventRow('10 July 2026', 'Quarterly Town Hall Meet', 'Scheduled'),
            const SizedBox(height: 10),
            _buildEventRow('15 July 2026', 'Health & Fitness Camp', 'Planned'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Dismiss', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildEventRow(String date, String title, String status) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.circle, color: AppColors.primaryColor, size: 8),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(date, fontSize: 11, color: AppColors.textColorSecondary),
                  AppText(status, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEngagementInfoDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const AppText('Engagement Wall', fontSize: 16, fontWeight: FontWeight.bold),
        content: const AppText(
          'The Engagement Wall displays live celebrations, wellness announcements, and peer peer peer kudos updates across the company.',
          fontSize: 13,
          color: AppColors.textColorSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Okay', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }
}
