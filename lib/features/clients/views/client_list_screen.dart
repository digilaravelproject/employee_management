import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/clients_controller.dart';
import '../models/client_model.dart';
import 'client_details_screen.dart';
import 'add_edit_client_screen.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller in memory
    final controller = Get.put(ClientsController());

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Clients',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit, color: AppColors.textColorSecondary, size: 22),
            onPressed: () {
              // Quick clear and add client
              controller.clearForm();
              Get.to(() => const AddEditClientScreen(isEditMode: false));
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0, top: 8.0, bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                controller.clearForm();
                Get.to(() => const AddEditClientScreen(isEditMode: false));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter Section ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate100),
                    ),
                    child: TextField(
                      onChanged: (value) => controller.searchQuery.value = value,
                      decoration: const InputDecoration(
                        hintText: 'Search clients...',
                        hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 14),
                        prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate100),
                  ),
                  child: const Icon(Iconsax.setting_4, color: AppColors.textColorSecondary, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Symmetrical Horizontal Status Filter deck ──
          SizedBox(
            height: 42,
            child: Obx(() {
              return ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterTab(
                    controller,
                    label: 'All',
                    count: controller.totalClientsCount,
                    isSelected: controller.selectedStatusFilter.value == 'All',
                    onTap: () => controller.selectedStatusFilter.value = 'All',
                  ),
                  _buildFilterTab(
                    controller,
                    label: 'Active',
                    count: controller.activeClientsCount,
                    isSelected: controller.selectedStatusFilter.value == 'Active',
                    onTap: () => controller.selectedStatusFilter.value = 'Active',
                  ),
                  _buildFilterTab(
                    controller,
                    label: 'Inactive',
                    count: controller.inactiveClientsCount,
                    isSelected: controller.selectedStatusFilter.value == 'Inactive',
                    onTap: () => controller.selectedStatusFilter.value = 'Inactive',
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),

          // ── Client List Feed ──
          Expanded(
            child: Obx(() {
              final list = controller.filteredClients;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.people, size: 64, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const AppText('No Clients Found', fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      const AppText('Add a new client to get started.', fontSize: 12, color: AppColors.textColorHint),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final client = list[index];
                  return _ClientCardItem(client: client);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    ClientsController controller, {
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeColor = label == 'Inactive' 
        ? AppColors.errorColor 
        : (label == 'Active' ? AppColors.successColor : AppColors.primaryColor);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.slate200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              label,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? activeColor : AppColors.textColorSecondary,
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : AppColors.slate100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText(
                '$count',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textColorSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientCardItem extends StatelessWidget {
  final Client client;
  const _ClientCardItem({required this.client});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientsController>();
    final statusColor = client.status == 'Active' ? AppColors.successColor : AppColors.errorColor;

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.selectedClient.value = client;
            Get.to(() => const ClientDetailsScreen());
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Symmetrical Initials Avatar Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.15),
                        AppColors.indigo500.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: AppColors.slate100, width: 1.5),
                  ),
                  child: Center(
                    child: AppText(
                      client.name.isNotEmpty 
                          ? client.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                          : 'CL',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Core Info Block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        client.name,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        client.email,
                        fontSize: 12,
                        color: AppColors.textColorSecondary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        client.mobile,
                        fontSize: 11,
                        color: AppColors.textColorHint,
                      ),
                    ],
                  ),
                ),

                // Status Badge & Chevron Action Right
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        client.status,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textColorHint,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
