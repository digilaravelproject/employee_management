import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/assets_controller.dart';
import '../models/asset_model.dart';
import 'assign_asset_screen.dart';

class AssetDetailsScreen extends StatelessWidget {
  const AssetDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AssetsController>();

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
        title: const AppText(
          'Asset Details',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
      ),
      body: Obx(() {
        final asset = controller.selectedAsset.value;
        if (asset == null) {
          return const Center(child: AppText('Asset not found', fontSize: 14, color: AppColors.textColorHint));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 1. Header Information Card
                    _buildHeaderCard(asset),

                    // 2. Custom Horizontal Capsule Tabs
                    _buildTabSelector(controller),

                    // 3. Dynamic Tab Content
                    _buildTabContent(context, controller, asset),
                  ],
                ),
              ),
            ),

            // 4. Bottom context-driven Action row
            _buildBottomActionBar(controller, asset),
          ],
        );
      }),
    );
  }

  // ── Header Panel Widget ──
  Widget _buildHeaderCard(AssetModel asset) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.slate100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: asset.imageUrl != null
                    ? Image.network(
                        asset.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildCategoryFallbackIcon(asset.category),
                      )
                    : _buildCategoryFallbackIcon(asset.category),
              ),
            ),
            const SizedBox(width: 16),

            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          asset.name,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                      ),
                      _buildStatusBadge(asset.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    '${asset.category} • ${asset.type}',
                    fontSize: 11,
                    color: AppColors.textColorHint,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: AppText(
                      asset.serialNumber,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFallbackIcon(String category) {
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
      color: color.withValues(alpha: 0.05),
      alignment: Alignment.center,
      child: Icon(icon, size: 28, color: color),
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

  // ── Tab Selection Row ──
  Widget _buildTabSelector(AssetsController controller) {
    final tabs = ['Overview', 'History', 'Maintenance', 'Files'];

    return Container(
      height: 54,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, idx) {
          final tabName = tabs[idx];
          final isSelected = controller.selectedDetailsTabIdx.value == idx;

          return GestureDetector(
            onTap: () => controller.selectedDetailsTabIdx.value = idx,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : AppColors.slate100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : AppColors.slate200,
                  width: 1,
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
                tabName,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textColorSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Tab Content Router ──
  Widget _buildTabContent(BuildContext context, AssetsController controller, AssetModel asset) {
    switch (controller.selectedDetailsTabIdx.value) {
      case 1:
        return _buildHistoryTab(asset);
      case 2:
        return _buildMaintenanceTab(controller, asset);
      case 3:
        return _buildFilesTab(asset);
      case 0:
      default:
        return _buildOverviewTab(context, controller, asset);
    }
  }

  // ── OVERVIEW TAB ──
  Widget _buildOverviewTab(BuildContext context, AssetsController controller, AssetModel asset) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Technical Specs Grid
          const AppText('Technical Specs', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildSpecTile('Brand', asset.brand, Iconsax.info_circle),
              _buildSpecTile('Model', asset.model, Iconsax.category),
              _buildSpecTile('Purchase Cost', '₹${asset.purchaseCost.toStringAsFixed(0)}', Iconsax.empty_wallet),
              _buildSpecTile('Purchase Date', _formatDate(asset.purchaseDate), Iconsax.calendar),
            ],
          ),

          const SizedBox(height: 22),

          // 2. Stepper Timeline Workflow
          const AppText('Asset Workflow Status', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
          const SizedBox(height: 12),
          _buildTimelineStepper(asset.status),

          const SizedBox(height: 22),

          // 3. Assignment Status
          const AppText('Assignment Status', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
          const SizedBox(height: 8),
          if (asset.status == 'Assigned' && asset.assignedTo != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(19),
                          child: asset.assignedTo!.avatarUrl.isNotEmpty
                              ? Image.network(asset.assignedTo!.avatarUrl, fit: BoxFit.cover)
                              : Container(
                                  color: AppColors.slate200,
                                  child: const Icon(Icons.person, size: 18, color: Colors.grey),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              asset.assignedTo!.name,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                            AppText(
                              asset.assignedTo!.email,
                              fontSize: 10,
                              color: AppColors.textColorHint,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.slate100),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText('Assigned On', fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textColorHint),
                            const SizedBox(height: 2),
                            AppText(
                              asset.assignedDate != null ? _formatDate(asset.assignedDate!) : 'N/A',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText('Expected Return', fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textColorHint),
                            const SizedBox(height: 2),
                            AppText(
                              asset.expectedReturnDate != null ? _formatDate(asset.expectedReturnDate!) : 'Indefinite',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (asset.notes != null && asset.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.slate100),
                    const SizedBox(height: 10),
                    const AppText('Notes', fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textColorHint),
                    const SizedBox(height: 2),
                    AppText(
                      asset.notes!,
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Iconsax.user_tag, size: 24, color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 12),
                  const AppText(
                    'Asset is currently Available',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 4),
                  const AppText(
                    'This asset has no active assignees. You can allocate it to any system employee.',
                    fontSize: 10,
                    color: AppColors.textColorHint,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.prepareAssignForm(asset);
                      Get.to(() => const AssignAssetScreen());
                    },
                    icon: const Icon(Iconsax.user_add, size: 16, color: Colors.white),
                    label: const AppText('Assign Asset Now', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSpecTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.slate500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(label, fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textColorHint),
                const SizedBox(height: 1),
                AppText(
                  value,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Linear Workflow Progress Stepper (Assigned -> In Use -> Returned -> Closed)
  Widget _buildTimelineStepper(String status) {
    final steps = ['Procured', 'Available', 'Assigned', 'Maintenance'];
    
    // Determine active index
    int activeIdx = 0;
    if (status.toLowerCase() == 'available') activeIdx = 1;
    if (status.toLowerCase() == 'assigned') activeIdx = 2;
    if (status.toLowerCase() == 'maintenance') activeIdx = 3;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: List.generate(steps.length, (idx) {
          final stepName = steps[idx];
          final isCompleted = idx <= activeIdx;
          final isActive = idx == activeIdx;
          
          Color stepColor = AppColors.slate400; // standard grey
          if (isCompleted) {
            stepColor = isActive ? AppColors.primaryColor : AppColors.successColor;
          }

          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isCompleted ? stepColor.withValues(alpha: 0.1) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: stepColor, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: isCompleted && !isActive
                          ? const Icon(Icons.check, size: 10, color: AppColors.successColor)
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive ? stepColor : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      stepName,
                      fontSize: 8,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      color: isActive ? AppColors.textColorPrimary : AppColors.textColorHint,
                    ),
                  ],
                ),
                if (idx != steps.length - 1)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: Container(
                        height: 2,
                        color: idx < activeIdx ? AppColors.successColor : AppColors.slate200,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── HISTORY TAB ──
  Widget _buildHistoryTab(AssetModel asset) {
    if (asset.history.isEmpty) {
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
                child: const Icon(Iconsax.document_text, size: 28, color: AppColors.slate400),
              ),
              const SizedBox(height: 12),
              const AppText('No history logs found.', fontSize: 13, color: AppColors.textColorHint),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Asset Logs History', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: asset.history.length,
            itemBuilder: (context, idx) {
              final log = asset.history[idx];
              final isLast = idx == asset.history.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline nodes and connectors
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _getHistoryTypeColor(log.type).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getHistoryTypeIcon(log.type),
                            size: 14,
                            color: _getHistoryTypeColor(log.type),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              color: AppColors.slate200,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Log Content details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            log.title,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            _formatDateTime(log.timestamp),
                            fontSize: 9,
                            color: AppColors.textColorHint,
                            fontWeight: FontWeight.w500,
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getHistoryTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'assigned':
        return Iconsax.user_add;
      case 'returned':
        return Iconsax.tick_square;
      case 'maintenance':
        return Iconsax.setting_2;
      case 'added':
      default:
        return Iconsax.box_add;
    }
  }

  Color _getHistoryTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'assigned':
        return AppColors.indigo500;
      case 'returned':
        return AppColors.successColor;
      case 'maintenance':
        return AppColors.warningColor;
      case 'added':
      default:
        return AppColors.slate500;
    }
  }

  // ── MAINTENANCE TAB ──
  Widget _buildMaintenanceTab(AssetsController controller, AssetModel asset) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Maintenance History', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
              if (asset.status != 'Maintenance')
                ElevatedButton.icon(
                  onPressed: () {
                    controller.reportDamage(asset.id);
                  },
                  icon: const Icon(Iconsax.setting_3, size: 14, color: AppColors.errorColor),
                  label: const AppText('Schedule Maintenance', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.errorColor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorColor.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (asset.maintenanceList.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: const Column(
                children: [
                  Icon(Iconsax.shield_tick, size: 30, color: AppColors.successColor),
                  SizedBox(height: 10),
                  AppText('Asset is in Great Shape!', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                  SizedBox(height: 4),
                  AppText('No maintenance or damage claims documented.', fontSize: 10, color: AppColors.textColorHint),
                ],
              ),
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: asset.maintenanceList.length,
              itemBuilder: (context, idx) {
                final maint = asset.maintenanceList[idx];
                final isCompleted = maint.status.toLowerCase() == 'completed';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCompleted ? AppColors.successColor.withValues(alpha: 0.08) : AppColors.warningColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Iconsax.verify : Iconsax.timer,
                          size: 18,
                          color: isCompleted ? AppColors.successColor : AppColors.warningColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              maint.issue,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                            const SizedBox(height: 3),
                            AppText(
                              'Date Scheduled: ${_formatDate(maint.dateScheduled)}',
                              fontSize: 9,
                              color: AppColors.textColorHint,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCompleted ? AppColors.successColor.withValues(alpha: 0.08) : AppColors.warningColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: AppText(
                          maint.status,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? AppColors.successColor : AppColors.warningColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ── FILES TAB ──
  Widget _buildFilesTab(AssetModel asset) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Asset Documentation', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
          const SizedBox(height: 12),
          if (asset.files.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: const Column(
                children: [
                  Icon(Iconsax.folder_open, size: 30, color: AppColors.slate400),
                  SizedBox(height: 10),
                  AppText('No attached documents', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                  SizedBox(height: 4),
                  AppText('Warranty certificates or invoices not uploaded yet.', fontSize: 10, color: AppColors.textColorHint),
                ],
              ),
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: asset.files.length,
              itemBuilder: (context, idx) {
                final file = asset.files[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Iconsax.document_text, size: 20, color: AppColors.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              file,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                            const SizedBox(height: 2),
                            const AppText(
                              'PDF File • 1.2 MB',
                              fontSize: 9,
                              color: AppColors.textColorHint,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.import, color: AppColors.primaryColor, size: 18),
                        onPressed: () {
                          Get.snackbar(
                            'Downloading file',
                            'Saving $file to system downloads...',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primaryColor,
                            colorText: Colors.white,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ── Bottom Action Panel Widget ──
  Widget _buildBottomActionBar(AssetsController controller, AssetModel asset) {
    if (asset.status == 'Assigned') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.slate100, width: 1.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => controller.markAsReturned(asset.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const AppText(
                    'Mark as Returned',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => controller.reportDamage(asset.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorColor,
                    side: const BorderSide(color: AppColors.errorColor, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const AppText(
                    'Report Damage',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.errorColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (asset.status == 'Available') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.slate100, width: 1.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    controller.prepareAssignForm(asset);
                    Get.to(() => const AssignAssetScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const AppText(
                    'Assign Asset',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => controller.reportDamage(asset.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorColor,
                    side: const BorderSide(color: AppColors.errorColor, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const AppText(
                    'Report Damage',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.errorColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Under Maintenance actions
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.slate100, width: 1.5)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => controller.markAsReturned(asset.id), // sets it back to Available
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const AppText(
              'Mark Maintenance Fixed & Available',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hr = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year} at $hr:$min';
  }
}
