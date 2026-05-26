import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../controllers/leads_controller.dart';
import '../../models/lead_model.dart';

class FollowUpsTab extends StatefulWidget {
  const FollowUpsTab({super.key});

  @override
  State<FollowUpsTab> createState() => _FollowUpsTabState();
}

class _FollowUpsTabState extends State<FollowUpsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeadsController>();

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textColorHint,
            indicatorColor: AppColors.primaryColor,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Upcoming Tab view
              Obx(() {
                final upcoming = controller.upcomingFollowUps;
                if (upcoming.isEmpty) {
                  return _buildEmptyState('No upcoming follow-ups scheduled.');
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: upcoming.length,
                  itemBuilder: (context, index) {
                    final followup = upcoming[index];
                    return _FollowupItemCard(followup: followup, isCompletedTab: false);
                  },
                );
              }),

              // Completed Tab view
              Obx(() {
                final completed = controller.completedFollowUps;
                if (completed.isEmpty) {
                  return _buildEmptyState('No completed follow-up records found.');
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: completed.length,
                  itemBuilder: (context, index) {
                    final followup = completed[index];
                    return _FollowupItemCard(followup: followup, isCompletedTab: true);
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.calendar_tick, size: 40, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 16),
          AppText(
            msg,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }
}

class _FollowupItemCard extends StatelessWidget {
  final LeadFollowUp followup;
  final bool isCompletedTab;
  
  const _FollowupItemCard({
    required this.followup,
    required this.isCompletedTab,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeadsController>();
    final parentLead = controller.getParentLeadOfFollowUp(followup.id);
    
    if (parentLead == null) return const SizedBox();

    final formattedDateTime = "${DateFormat('dd MMM yyyy').format(followup.dateTime)}, ${DateFormat('hh:mm a').format(followup.dateTime)}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Lead initials
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.1),
                    AppColors.indigo500.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Center(
                child: AppText(
                  parentLead.name.substring(0, 2).toUpperCase(),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Details info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    parentLead.name,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        followup.type == 'call' ? Iconsax.call : Iconsax.document_text,
                        size: 11,
                        color: AppColors.textColorHint,
                      ),
                      const SizedBox(width: 4),
                      AppText(
                        formattedDateTime,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    followup.title,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),

            // Call Icon or Checkmark Switch
            if (!isCompletedTab) ...[
              IconButton(
                icon: const Icon(Iconsax.call, color: AppColors.primaryColor, size: 22),
                onPressed: () {
                  Get.snackbar(
                    'Simulating Call 📞',
                    'Dialing ${parentLead.name} (${parentLead.mobile})...',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primaryColor,
                    colorText: Colors.white,
                  );
                },
              ),
              const SizedBox(width: 6),
              // Mark complete checkbox
              IconButton(
                icon: const Icon(Iconsax.tick_square, color: AppColors.textColorHint, size: 22),
                onPressed: () {
                  controller.markFollowupCompleted(parentLead.id, followup.id);
                },
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const AppText(
                  'Done',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
