import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/departments_controller.dart';
import '../models/department_api_model.dart';
import '../repositories/department_repository.dart';

class DepartmentPickerBottomSheet extends StatefulWidget {
  final String? selectedDepartmentName;
  final ValueChanged<DepartmentApiModel> onDepartmentSelected;

  const DepartmentPickerBottomSheet({
    super.key,
    this.selectedDepartmentName,
    required this.onDepartmentSelected,
  });

  static Future<DepartmentApiModel?> show(
    BuildContext context, {
    String? selectedDepartmentName,
    ValueChanged<DepartmentApiModel>? onSelect,
  }) async {
    return await Get.bottomSheet<DepartmentApiModel>(
      DepartmentPickerBottomSheet(
        selectedDepartmentName: selectedDepartmentName,
        onDepartmentSelected: onSelect ?? (_) {},
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<DepartmentPickerBottomSheet> createState() => _DepartmentPickerBottomSheetState();
}

class _DepartmentPickerBottomSheetState extends State<DepartmentPickerBottomSheet> {
  late final DepartmentsController _controller;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<DepartmentsController>()) {
      _controller = Get.find<DepartmentsController>();
    } else {
      _controller = Get.put(DepartmentsController(
        repository: DepartmentRepository(apiClient: Get.find<ApiClient>()),
      ));
    }

    // If apiDepartments is empty, fetch from API
    if (_controller.apiDepartments.isEmpty) {
      _controller.fetchDepartments();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Drag Handle ──
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Sheet Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.hierarchy, color: AppColors.primaryColor, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Select Department',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      SizedBox(height: 2),
                      AppText(
                        'Assign organizational department to this role',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textColorSecondary, size: 20),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.slate200),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                decoration: InputDecoration(
                  hintText: 'Search department by name...',
                  hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                  prefixIcon: const Icon(Iconsax.search_normal_1, color: AppColors.textColorHint, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textColorHint),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // ── Department List ──
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value && _controller.apiDepartments.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                );
              }

              final allDepts = _controller.apiDepartments;
              final filtered = allDepts.where((dept) {
                if (_searchQuery.isEmpty) return true;
                final nameMatch = dept.name.toLowerCase().contains(_searchQuery);
                final descMatch = (dept.description ?? '').toLowerCase().contains(_searchQuery);
                return nameMatch || descMatch;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Iconsax.building_3, size: 40, color: AppColors.textColorHint.withValues(alpha: 0.4)),
                        ),
                        const SizedBox(height: 14),
                        AppText(
                          _searchQuery.isEmpty ? 'No departments available' : 'No matching departments found',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          _searchQuery.isEmpty ? 'Add a department to get started' : 'Try searching for another keyword',
                          fontSize: 11,
                          color: AppColors.textColorHint,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final dept = filtered[index];
                  final isSelected = widget.selectedDepartmentName != null &&
                      (widget.selectedDepartmentName!.toLowerCase() == dept.name.toLowerCase());
                  final themeColor = _getThemeColor(dept.name);
                  final icon = _getIcon(dept.name);

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        widget.onDepartmentSelected(dept);
                        Get.back(result: dept);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? themeColor.withValues(alpha: 0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? themeColor : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: themeColor.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            else
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.01),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // ── Department Icon Circle ──
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: themeColor, size: 20),
                            ),
                            const SizedBox(width: 14),

                            // ── Department Name Only ──
                            Expanded(
                              child: AppText(
                                dept.name,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? themeColor : AppColors.textColorPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // ── Radio Selection Indicator ──
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isSelected ? themeColor : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? themeColor : const Color(0xFFCBD5E1),
                                  width: isSelected ? 0 : 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                  : null,
                            ),
                          ],
                        ),
                      ),
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

  Color _getThemeColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('eng') || lower.contains('code') || lower.contains('dev') || lower.contains('product')) return const Color(0xFF6366F1);
    if (lower.contains('hr') || lower.contains('people') || lower.contains('recruit') || lower.contains('human')) return const Color(0xFFEC4899);
    if (lower.contains('market') || lower.contains('advert') || lower.contains('social')) return const Color(0xFF10B981);
    if (lower.contains('finance') || lower.contains('money') || lower.contains('audit') || lower.contains('pay')) return const Color(0xFFF59E0B);
    if (lower.contains('sale') || lower.contains('deal') || lower.contains('revenue')) return const Color(0xFF3B82F6);
    if (lower.contains('support') || lower.contains('it') || lower.contains('help')) return const Color(0xFF06B6D4);
    return const Color(0xFF8B5CF6);
  }

  IconData _getIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('eng') || lower.contains('code') || lower.contains('dev') || lower.contains('product')) return Iconsax.code;
    if (lower.contains('hr') || lower.contains('people') || lower.contains('recruit') || lower.contains('human')) return Iconsax.user_octagon;
    if (lower.contains('market') || lower.contains('advert') || lower.contains('social')) return Iconsax.volume_high;
    if (lower.contains('finance') || lower.contains('money') || lower.contains('audit') || lower.contains('pay')) return Iconsax.empty_wallet;
    if (lower.contains('sale') || lower.contains('deal') || lower.contains('revenue')) return Iconsax.graph;
    if (lower.contains('support') || lower.contains('it') || lower.contains('help')) return Iconsax.monitor;
    return Iconsax.hierarchy;
  }
}
