import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/hr_controller.dart';
import '../models/hr_models.dart';
import 'add_policy_screen.dart';

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

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
          'Company Policies',
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
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Banner Card ──
                  _buildHeroBanner(),
                  const SizedBox(height: 16),

                  // ── Categories Deck ──
                  _buildFiltersBar(controller),
                  const SizedBox(height: 16),

                  // ── Dynamic Policies List ──
                  Obx(() {
                    final list = controller.filteredPolicies;
                    if (list.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(Iconsax.document_text, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              const AppText('No policies found in this category.', fontSize: 13, color: AppColors.textColorHint),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final policy = list[index];
                        return _buildPolicyCard(context, policy);
                      },
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Symmetrical Floating Add Footer ──
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
                  Get.to(() => const AddPolicyScreen());
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const AppText(
                  'Add New Policy',
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

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.04),
            AppColors.indigo500.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Illustration Placeholder
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Iconsax.teacher, size: 38, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Company Policies',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
                SizedBox(height: 4),
                AppText(
                  'Guidelines & rules that help us work better together.',
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar(HrController controller) {
    return Obx(() {
      final selected = controller.selectedPolicyFilter.value;
      return SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.policyFilters.length,
          itemBuilder: (context, index) {
            final filter = controller.policyFilters[index];
            final isSelected = selected == filter;

            return GestureDetector(
              onTap: () => controller.setPolicyFilter(filter),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : AppColors.slate200,
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

  Widget _buildPolicyCard(BuildContext context, CompanyPolicy policy) {
    final themeColor = _getPolicyColor(policy.type);
    final themeIcon = _getPolicyIcon(policy.type);
    final dateStr = DateFormat('dd MMM yyyy').format(policy.updatedDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPolicyDetailsSheet(context, policy),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
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
                      AppText(
                        policy.title,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          AppText(
                            policy.type,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                          Container(
                            width: 3,
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.textColorHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          AppText(
                            'Updated on $dateStr',
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                          ),
                        ],
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
  }

  Color _getPolicyColor(String type) {
    switch (type) {
      case 'HR Policies':
        return AppColors.primaryColor;
      case 'Work Policies':
        return AppColors.indigo500;
      case 'Leave Policies':
        return AppColors.successColor;
      default:
        return AppColors.textColorSecondary;
    }
  }

  IconData _getPolicyIcon(String type) {
    switch (type) {
      case 'HR Policies':
        return Iconsax.profile_2user;
      case 'Work Policies':
        return Iconsax.house;
      case 'Leave Policies':
        return Iconsax.calendar_tick;
      default:
        return Iconsax.document;
    }
  }

  void _showPolicyDetailsSheet(BuildContext context, CompanyPolicy policy) {
    final themeColor = _getPolicyColor(policy.type);
    final dateStr = DateFormat('dd MMMM yyyy').format(policy.updatedDate);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      policy.type,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  AppText(
                    'Updated: $dateStr',
                    fontSize: 11,
                    color: AppColors.textColorHint,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppText(
                policy.title,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.slate200),
              const SizedBox(height: 16),
              const AppText(
                'Policy Statement & Details',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 8),
              AppText(
                policy.description,
                fontSize: 13,
                color: AppColors.textColorSecondary,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, color: Colors.green, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText('Compliance Verified', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                          SizedBox(height: 2),
                          AppText('This policy is active and applies to all employees.', fontSize: 10, color: AppColors.textColorSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textColorPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const AppText('Understood & Close', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showSearchDialog(HrController controller) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Search Policies', fontSize: 16, fontWeight: FontWeight.bold),
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
