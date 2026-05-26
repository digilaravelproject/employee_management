import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_input_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../controllers/designation_controller.dart';

class AddDesignationScreen extends StatelessWidget {
  const AddDesignationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DesignationController>();
    final nameController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const AppText('Add Designation', fontSize: 18, fontWeight: FontWeight.w700),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Designation Name',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 8),
            AppInputField(
              hint: 'e.g. Senior Flutter Developer',
              controller: nameController,
              icon: Iconsax.user_tag,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Designation',
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  CustomSnackbar.showError('Please enter designation name');
                  return;
                }
                controller.addDesignation(nameController.text.trim());
                CustomSnackbar.showSuccess('Designation added successfully');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
