import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/security_controller.dart';

class LoginHistoryScreen extends StatelessWidget {
  const LoginHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SecurityController>();
    final searchController = TextEditingController(text: controller.loginSearchQuery.value);

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
          'Login History',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
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
                  onChanged: (val) => controller.filterLoginHistoryList(val),
                  decoration: const InputDecoration(
                    hintText: 'Search by name, email or IP...',
                    hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    prefixIcon: Icon(Iconsax.search_normal, color: Color(0xFF94A3B8), size: 18),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // ── TIME TABS ──
            Obx(() {
              final activeTab = controller.selectedLoginTab.value;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    _buildTabBtn('Today', activeTab == 'Today', () => controller.changeLoginTab('Today')),
                    const SizedBox(width: 8),
                    _buildTabBtn('Yesterday', activeTab == 'Yesterday', () => controller.changeLoginTab('Yesterday')),
                    const SizedBox(width: 8),
                    _buildTabBtn('This Week', activeTab == 'This Week', () => controller.changeLoginTab('This Week')),
                    const SizedBox(width: 8),
                    _buildTabBtn('Custom', activeTab == 'Custom', () => controller.changeLoginTab('Custom')),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            // ── LOGIN DIRECTORY LIST ──
            Expanded(
              child: Obx(() {
                final list = controller.filteredLoginHistory;
                if (list.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.clock, size: 48, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 8),
                        AppText(
                          'No login logs found',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = list[index];
                    return _LoginHistoryCard(log: log);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBtn(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        child: AppText(
          label,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: isSelected ? Colors.white : const Color(0xFF475569),
        ),
      ),
    );
  }
}

class _LoginHistoryCard extends StatelessWidget {
  final LoginHistoryEntry log;

  const _LoginHistoryCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final isSuccess = log.status == 'Success';
    final statusBg = isSuccess ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
    final statusText = isSuccess ? const Color(0xFF059669) : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF2FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Profile details & Status
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(log.avatarUrl),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      log.name,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      log.email,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  log.status,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: statusText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.more_vert, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),

          // Row 2: Timing details
          Row(
            children: [
              const Icon(Iconsax.calendar, size: 12, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              AppText(
                log.time,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
              const SizedBox(width: 20),
              const Icon(Iconsax.monitor, size: 12, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: AppText(
                  'IP: ${log.ipAddress}',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: Device & Location details
          Row(
            children: [
              const Icon(Iconsax.mobile, size: 12, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              AppText(
                log.device,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 20),
              const Icon(Iconsax.location, size: 12, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: AppText(
                  log.location,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
