import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/compliance_controller.dart';

class ComplianceTrackingScreen extends StatelessWidget {
  const ComplianceTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComplianceController>();
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          'Compliance Tracking',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Horizontal Filter Chips Deck ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Obx(() {
              final activeFilter = controller.selectedTrackingFilter.value;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterTab(controller, 'All', 180, activeFilter == 'All'),
                    const SizedBox(width: 8),
                    _buildFilterTab(controller, 'Acknowledged', 156, activeFilter == 'Acknowledged'),
                    const SizedBox(width: 8),
                    _buildFilterTab(controller, 'Pending', 24, activeFilter == 'Pending'),
                    const SizedBox(width: 8),
                    _buildFilterTab(controller, 'Overdue', 0, activeFilter == 'Overdue'),
                  ],
                ),
              );
            }),
          ),

          // ── Search Deck ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) => controller.trackingSearchQuery.value = val,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      hintText: 'Search employee...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                      prefixIcon: const Icon(Iconsax.search_normal_1, color: Color(0xFF64748B), size: 18),
                      suffixIcon: Obx(() {
                        final q = controller.trackingSearchQuery.value;
                        if (q.isEmpty) return const SizedBox();
                        return IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 18),
                          onPressed: () {
                            searchController.clear();
                            controller.trackingSearchQuery.value = '';
                          },
                        );
                      }),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Employee List ──
          Expanded(
            child: Obx(() {
              final list = controller.filteredAcknowledgements;
              if (list.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.profile_remove, color: Color(0xFF94A3B8), size: 40),
                      SizedBox(height: 12),
                      AppText('No records matching search filter.', fontSize: 13, color: Color(0xFF64748B)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final ack = list[index];
                  Color stateCol = const Color(0xFF10B981);
                  if (ack.status == 'Pending') stateCol = const Color(0xFFF59E0B);
                  if (ack.status == 'Overdue') stateCol = const Color(0xFFEF4444);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEEF2FF)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(ack.avatarUrl),
                          backgroundColor: const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                ack.employeeName,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                              ),
                              const SizedBox(height: 3),
                              AppText(
                                ack.designation,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: stateCol.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: AppText(
                                ack.status,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: stateCol,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              ack.acknowledgedTime ?? 'Not acknowledged yet',
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                        if (ack.status != 'Acknowledged') ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => controller.triggerReminder(ack, 'Code of Conduct Policy'),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.notification,
                                color: Color(0xFF6366F1),
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(ComplianceController controller, String label, int count, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.selectedTrackingFilter.value = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            AppText(
              label,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: AppText(
                '$count',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
