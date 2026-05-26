import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/assets_controller.dart';
import '../models/asset_model.dart';
import '../../role_permissions/models/role_permission_models.dart';

class AssignAssetScreen extends StatelessWidget {
  const AssignAssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AssetsController>();

    // Filter to get only available assets for assignment when not pre-selected
    final availableAssets = controller.assets.where((a) => a.status == 'Available').toList();

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Assign Asset',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Asset Selection Section
                  _buildFormHeader('Select Asset to Assign *'),
                  Obx(() {
                    final preSelectedAsset = controller.selectedAssetToAssign.value;

                    // Case A: Asset is pre-selected (came from Asset details/list action)
                    if (preSelectedAsset != null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.slate200),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: preSelectedAsset.imageUrl != null
                                    ? Image.network(preSelectedAsset.imageUrl!, fit: BoxFit.cover)
                                    : const Icon(Iconsax.monitor, size: 20, color: AppColors.primaryColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    preSelectedAsset.name,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColorPrimary,
                                  ),
                                  const SizedBox(height: 2),
                                  AppText(
                                    '${preSelectedAsset.category} • SN: ${preSelectedAsset.serialNumber.replaceAll('SN: ', '')}',
                                    fontSize: 10,
                                    color: AppColors.textColorSecondary,
                                  ),
                                ],
                              ),
                            ),
                            // Action to reset selection if they want to choose something else
                            IconButton(
                              icon: const Icon(Iconsax.close_circle, color: AppColors.slate400, size: 20),
                              onPressed: () {
                                controller.selectedAssetToAssign.value = null;
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    // Case B: No asset pre-selected, show dropdown list of available assets
                    if (availableAssets.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.errorColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.errorColor.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Iconsax.info_circle, color: AppColors.errorColor, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: AppText(
                                'No available assets in inventory. Please add an asset first.',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.errorColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AssetModel>(
                          hint: const AppText('Choose Available Asset', fontSize: 13, color: AppColors.slate400),
                          value: controller.selectedAssetToAssign.value,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.slate400),
                          items: availableAssets.map((asset) {
                            return DropdownMenuItem<AssetModel>(
                              value: asset,
                              child: Row(
                                children: [
                                  Icon(
                                    asset.category.toLowerCase() == 'laptop'
                                        ? Iconsax.monitor
                                        : asset.category.toLowerCase() == 'mobile'
                                            ? Iconsax.mobile
                                            : Iconsax.box,
                                    size: 16,
                                    color: AppColors.primaryColor,
                                  ),
                                  const SizedBox(width: 10),
                                  AppText(
                                    '${asset.name} (${asset.brand})',
                                    fontSize: 13,
                                    color: AppColors.textColorPrimary,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            controller.selectedAssetToAssign.value = val;
                          },
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 18),

                  // 2. Employee Selection Section
                  _buildFormHeader('Assign to Employee *'),
                  Obx(() {
                    final employees = controller.allEmployees;
                    if (employees.isEmpty) {
                      return const SizedBox();
                    }

                    return Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AppUser>(
                          value: controller.selectedEmployeeToAssign.value,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.slate400),
                          items: employees.map((employee) {
                            return DropdownMenuItem<AppUser>(
                              value: employee,
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(shape: BoxShape.circle),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: employee.avatarUrl.isNotEmpty
                                          ? Image.network(employee.avatarUrl, fit: BoxFit.cover)
                                          : Container(
                                              color: AppColors.slate200,
                                              child: const Icon(Icons.person, size: 12, color: Colors.grey),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  AppText(
                                    employee.name,
                                    fontSize: 13,
                                    color: AppColors.textColorPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            controller.selectedEmployeeToAssign.value = val;
                          },
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 18),

                  // 3. Date Row (Assign Date & Expected Return Date)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormHeader('Assign Date *'),
                            Obx(() {
                              return GestureDetector(
                                onTap: () => _selectAssignDate(context, controller),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.slate200),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText(
                                        _formatDate(controller.assignDate.value),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textColorPrimary,
                                      ),
                                      const Icon(Iconsax.calendar, size: 18, color: AppColors.slate400),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormHeader('Expected Return'),
                            Obx(() {
                              final retDate = controller.expectedReturnDate.value;
                              return GestureDetector(
                                onTap: () => _selectReturnDate(context, controller),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.slate200),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText(
                                        retDate != null ? _formatDate(retDate) : 'Not specified',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: retDate != null ? AppColors.textColorPrimary : AppColors.textColorHint,
                                      ),
                                      const Icon(Iconsax.calendar, size: 18, color: AppColors.slate400),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 4. Notes Section
                  _buildFormHeader('Assignment Notes'),
                  Container(
                    // decoration: BoxDecoration(
                    //   color: Colors.white,
                    //   borderRadius: BorderRadius.circular(12),
                    //   border: Border.all(color: AppColors.slate200),
                    // ),
                    // padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                     child:
                     Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                        // const Padding(
                        //   padding: EdgeInsets.only(top: 4.0),
                        //   child: Icon(Iconsax.document_text, color: AppColors.slate400, size: 18),
                        // ),
                       // const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: controller.notesController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              //prefixIcon: Icon(Iconsax.document_text, color: AppColors.slate400, size: 18),
                              hintText: 'Enter assignment details, condition status, or policies...',
                              hintStyle: TextStyle(color: AppColors.slate400, fontSize: 13),
                              // border: InputBorder.none,
                              // isDense: true,
                            ),
                            style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                          ),
                        ),
                       ],
                     ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.slate100, width: 1.5)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => controller.assignAsset(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const AppText(
                  'Assign Asset',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2),
      child: AppText(
        text,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.textColorSecondary,
      ),
    );
  }

  void _selectAssignDate(BuildContext context, AssetsController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.assignDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.assignDate.value = picked;
    }
  }

  void _selectReturnDate(BuildContext context, AssetsController controller) async {
    final initialDate = controller.expectedReturnDate.value ?? DateTime.now().add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: controller.assignDate.value,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.expectedReturnDate.value = picked;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
