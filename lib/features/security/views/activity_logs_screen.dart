import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/security_controller.dart';

class ActivityLogsScreen extends StatelessWidget {
  const ActivityLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SecurityController>();
    final searchController = TextEditingController(text: controller.activitySearchQuery.value);

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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textColorPrimary,
                size: 18,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'User Activity Logs',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── SEARCH BAR ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (val) => controller.filterActivityLogsList(val),
                  decoration: const InputDecoration(
                    hintText: 'Search activity, user or module...',
                    hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    prefixIcon: Icon(Iconsax.search_normal, color: Color(0xFF94A3B8), size: 18),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // ── ACTION FILTERS ──
            Obx(() {
              final activeTab = controller.selectedActivityTab.value;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    _buildFilterBtn('All', activeTab == 'All', () => controller.changeActivityCategoryTab('All')),
                    const SizedBox(width: 8),
                    _buildFilterBtn('User Activities', activeTab == 'User Activities', () => controller.changeActivityCategoryTab('User Activities')),
                    const SizedBox(width: 8),
                    _buildFilterBtn('Data Changes', activeTab == 'Data Changes', () => controller.changeActivityCategoryTab('Data Changes')),
                    const SizedBox(width: 8),
                    _buildFilterBtn('Actions', activeTab == 'Actions', () => controller.changeActivityCategoryTab('Actions')),
                  ],
                ),
              );
            }),

            const SizedBox(height: 14),

            // ── TIMELINE LOG FEED ──
            Expanded(
              child: Obx(() {
                final list = controller.filteredActivityLogs;
                if (list.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.document_text, size: 48, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 8),
                        AppText(
                          'No activities recorded',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  );
                }

                // Group activities by dateHeader
                final Map<String, List<ActivityLogEntry>> grouped = {};
                for (var log in list) {
                  grouped.putIfAbsent(log.dateHeader, () => []).add(log);
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, idx) {
                    final key = grouped.keys.elementAt(idx);
                    final logs = grouped[key]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: AppText(
                            key,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF475569),
                          ),
                        ),

                        // Timeline box of grouped logs
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFEEF2FF)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: logs.length,
                            separatorBuilder: (context, i) => const Divider(color: Color(0xFFF1F5F9), height: 16),
                            itemBuilder: (context, i) {
                              final item = logs[i];
                              return _ActivityLogTile(item: item);
                            },
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

  Widget _buildFilterBtn(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        child: AppText(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isSelected ? Colors.white : const Color(0xFF475569),
        ),
      ),
    );
  }
}

class _ActivityLogTile extends StatelessWidget {
  final ActivityLogEntry item;

  const _ActivityLogTile({required this.item});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if (item.category == 'Data Changes') {
      icon = Iconsax.edit;
      color = const Color(0xFF3B82F6);
    } else if (item.category == 'Actions') {
      icon = Iconsax.trash;
      color = const Color(0xFFEF4444);
    } else {
      icon = Iconsax.user;
      color = const Color(0xFF10B981);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Action Category Circle
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 14),

          // User Context & Action
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      height: 1.35,
                    ),
                    children: [
                      TextSpan(
                        text: '${item.name} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      TextSpan(
                        text: item.action,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                AppText(
                  item.time,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
