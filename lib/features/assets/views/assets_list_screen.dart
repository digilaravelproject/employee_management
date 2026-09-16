import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/assets_controller.dart';
import '../models/asset_model.dart';
import 'add_asset_screen.dart';
import 'asset_details_screen.dart';

class AssetsListScreen extends StatelessWidget {
  const AssetsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssetsController());

    return Scaffold(
      backgroundColor: AppColors.slate50,
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Assets',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              'Manage company assets',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () {
                controller.resetAddAssetForm();
                Get.to(() => const AddAssetScreen());
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const AppText('Add Asset', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Metrics row ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            // decoration: BoxDecoration(
                            //   color: Colors.white,
                            //   borderRadius: BorderRadius.circular(14),
                            //   border: Border.all(color: AppColors.slate200),
                            // ),
                            // padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: [
                                // const Icon(Iconsax.search_normal, color: AppColors.slate400, size: 20),
                                // const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    onChanged: (val) => controller.searchQuery.value = val,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Iconsax.search_normal, color: AppColors.slate400, size: 20),
                                      hintText: 'Search assets...',
                                      hintStyle: TextStyle(color: AppColors.slate400, fontSize: 13),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Dynamic Metrics Row (Premium 2x2 Grid)
                  Obx(() {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildMetricCard(
                            label: 'Total Assets',
                            value: controller.totalAssetsCount.toString(),
                            bgColor: AppColors.primaryLight,
                            iconColor: AppColors.primaryColor,
                            icon: Iconsax.monitor,
                          ),
                          _buildMetricCard(
                            label: 'Assigned',
                            value: controller.assignedAssetsCount.toString(),
                            bgColor: AppColors.indigo500.withValues(alpha: 0.08),
                            iconColor: AppColors.indigo500,
                            icon: Iconsax.user_tick,
                          ),
                          _buildMetricCard(
                            label: 'Available',
                            value: controller.availableAssetsCount.toString(),
                            bgColor: AppColors.successColor.withValues(alpha: 0.08),
                            iconColor: AppColors.successColor,
                            icon: Iconsax.box_tick,
                          ),
                          _buildMetricCard(
                            label: 'Under Maint.',
                            value: controller.maintenanceAssetsCount.toString(),
                            bgColor: AppColors.warningColor.withValues(alpha: 0.08),
                            iconColor: AppColors.warningColor,
                            icon: Iconsax.setting_4,
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 22),

                  // Section Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: AppText(
                      'All Assets',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Category filter capsules
                  SizedBox(
                    height: 40,
                    child: Obx(() {
                      final currentTab = controller.selectedCategoryTab.value;
                      final tabs = ['All', 'Laptop', 'Mobile', 'Accessories', 'Others'];

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tabs.length,
                        itemBuilder: (context, idx) {
                          final tab = tabs[idx];
                          final isSelected = tab == currentTab;

                          return GestureDetector(
                            onTap: () => controller.selectedCategoryTab.value = tab,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryColor : AppColors.slate100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryColor : AppColors.slate200,
                                  width: 1.0,
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ] : null,
                              ),
                              child: AppText(
                                tab,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textColorSecondary,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // List of filtered assets
                  Obx(() {
                    final filtered = controller.filteredAssets;
                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.slate100),
                                ),
                                child: const Icon(Iconsax.monitor, size: 28, color: AppColors.slate400),
                              ),
                              const SizedBox(height: 12),
                              const AppText('No assets match your search.', fontSize: 13, color: AppColors.textColorHint),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, idx) {
                        final asset = filtered[idx];
                        return _buildAssetCard(context, controller, asset);
                      },
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color bgColor,
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  label,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColorSecondary,
                ),
                const SizedBox(height: 2),
                AppText(
                  value,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(BuildContext context, AssetsController controller, AssetModel asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.selectedAsset.value = asset;
            controller.selectedDetailsTabIdx.value = 0;
            Get.to(() => const AssetDetailsScreen());
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Asset Thumbnail / Icon
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.slate100),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: asset.imageUrl != null
                            ? Image.network(
                                asset.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildCategoryIcon(asset.category),
                              )
                            : _buildCategoryIcon(asset.category),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Metadata details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppText(
                                  asset.name,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                ),
                              ),
                              _buildStatusBadge(asset.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            '${asset.category} • ${asset.type}',
                            fontSize: 10,
                            color: AppColors.textColorHint,
                            fontWeight: FontWeight.w500,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            asset.serialNumber,
                            fontSize: 10,
                            color: AppColors.textColorSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Padding(
                      padding: EdgeInsets.only(top: 18.0),
                      child: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.slate400, size: 14),
                    ),
                  ],
                ),

                // Assigned Roster bar
                if (asset.status == 'Assigned' && asset.assignedTo != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.slate100),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.slate100),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: asset.assignedTo!.avatarUrl.isNotEmpty
                              ? Image.network(asset.assignedTo!.avatarUrl, fit: BoxFit.cover)
                              : Container(
                                  color: AppColors.slate200,
                                  child: const Icon(Icons.person, size: 12, color: Colors.grey),
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            asset.assignedTo!.name,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const AppText(
                            'UI/UX Designer', // Custom fallback subtitle
                            fontSize: 8,
                            color: AppColors.textColorHint,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    IconData icon;
    Color color;

    switch (category.toLowerCase()) {
      case 'laptop':
        icon = Iconsax.monitor;
        color = AppColors.indigo500;
        break;
      case 'mobile':
        icon = Iconsax.mobile;
        color = AppColors.successColor;
        break;
      case 'accessories':
        icon = Iconsax.headphone;
        color = AppColors.warningColor;
        break;
      default:
        icon = Iconsax.box;
        color = AppColors.slate500;
    }

    return Container(
      color: color.withValues(alpha: 0.06),
      alignment: Alignment.center,
      child: Icon(icon, size: 22, color: color),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'assigned':
        bgColor = AppColors.successColor.withValues(alpha: 0.08);
        textColor = AppColors.successColor;
        break;
      case 'available':
        bgColor = AppColors.primaryLight;
        textColor = AppColors.primaryColor;
        break;
      case 'maintenance':
      default:
        bgColor = AppColors.warningColor.withValues(alpha: 0.08);
        textColor = AppColors.warningColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(
        status,
        fontSize: 8,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
    );
  }
}
