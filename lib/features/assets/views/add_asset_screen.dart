import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../controllers/assets_controller.dart';

class AddAssetScreen extends StatelessWidget {
  const AddAssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AssetsController>();

    final categories = ['Laptop', 'Mobile', 'Accessories', 'Others'];
    final types = ['IT Equipment', 'Mobile Phone', 'Headphone', 'Monitor'];

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
          'Add Asset',
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
                  // Asset Name
                  AppInputField(
                    label: 'Asset Name *',
                    controller: controller.nameController,
                    hint: 'Enter asset name',
                    icon: Iconsax.box,
                  ),
                  const SizedBox(height: 16),

                  // Asset Category & Type in dropdowns
                  Obx(() {
                    return AppDropdown<String>(
                      label: 'Asset Category *',
                      value: controller.selectedCategory.value,
                      hint: 'Select Category',
                      items: categories.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: AppText(item, fontSize: 13, color: AppColors.textColorPrimary),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedCategory.value = val;
                          // Auto adjust asset type option
                          if (val == 'Laptop') controller.selectedType.value = 'IT Equipment';
                          if (val == 'Mobile') controller.selectedType.value = 'Mobile Phone';
                          if (val == 'Accessories') controller.selectedType.value = 'Headphone';
                          if (val == 'Others') controller.selectedType.value = 'Monitor';
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 16),

                  Obx(() {
                    return AppDropdown<String>(
                      label: 'Asset Type *',
                      value: controller.selectedType.value,
                      hint: 'Select Type',
                      items: types.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: AppText(item, fontSize: 13, color: AppColors.textColorPrimary),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedType.value = val;
                      },
                    );
                  }),
                  const SizedBox(height: 16),

                  // Brand & Model
                  AppInputField(
                    label: 'Brand',
                    controller: controller.brandController,
                    hint: 'Enter brand name',
                    icon: Iconsax.info_circle,
                  ),
                  const SizedBox(height: 16),

                  AppInputField(
                    label: 'Model',
                    controller: controller.modelController,
                    hint: 'Enter model',
                    icon: Iconsax.category,
                  ),
                  const SizedBox(height: 16),

                  // Serial Number
                  AppInputField(
                    label: 'Serial Number / ID *',
                    controller: controller.serialNumberController,
                    hint: 'Enter serial number',
                    icon: Iconsax.barcode,
                  ),
                  const SizedBox(height: 16),

                  // Purchase Date & Cost row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Obx(() {
                          return AppInputField(
                            label: 'Purchase Date',
                            readOnly: true,
                            controller: TextEditingController(text: _formatDate(controller.purchaseDate.value)),
                            hint: 'Select Date',
                            icon: Iconsax.calendar,
                            onTap: () => _selectPurchaseDate(context, controller),
                          );
                        }),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppInputField(
                          label: 'Purchase Cost',
                          controller: controller.purchaseCostController,
                          hint: 'Enter cost',
                          icon: Iconsax.empty_wallet,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Upload image dotted box
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6.0, left: 2),
                    child: AppText(
                      'Upload Image',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                  Obx(() {
                    final hasImage = controller.selectedImage.value.isNotEmpty;

                    return GestureDetector(
                      onTap: () => _mockPickImage(controller),
                      child: Container(
                        width: double.infinity,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryColor.withValues(alpha: 0.3),
                            width: 1.5,
                            style: BorderStyle.solid, // Custom fallback for dotted
                          ),
                        ),
                        child: hasImage
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  controller.selectedImage.value,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Iconsax.cloud_change, size: 28, color: AppColors.primaryColor),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const AppText('Tap to upload ', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                      AppText('or browse', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    );
                  }),
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
                onPressed: () => controller.addAsset(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const AppText(
                  'Save Asset',
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



  void _selectPurchaseDate(BuildContext context, AssetsController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.purchaseDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
      controller.purchaseDate.value = picked;
    }
  }

  void _mockPickImage(AssetsController controller) {
    // Generate beautiful Unsplash image corresponding to selected category
    String url;
    final cat = controller.selectedCategory.value.toLowerCase();
    if (cat == 'laptop') {
      url = 'https://images.unsplash.com/photo-1496181130204-7552cc14ac1b?w=400';
    } else if (cat == 'mobile') {
      url = 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400';
    } else if (cat == 'accessories') {
      url = 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400';
    } else {
      url = 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=400';
    }

    controller.selectedImage.value = url;
    Get.snackbar(
      'Image Uploaded',
      'High-fidelity preview image loaded successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successColor,
      colorText: Colors.white,
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
