import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../routes/route_helper.dart';
import '../controllers/designation_controller.dart';

class DesignationListScreen extends StatelessWidget {
  const DesignationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DesignationController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const AppText('Designations', fontSize: 18, fontWeight: FontWeight.w700),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              height: 50,
              // padding: const EdgeInsets.symmetric(horizontal: 16),
              // decoration: BoxDecoration(
              //   color: Colors.white,
              //   borderRadius: BorderRadius.circular(16),
              //   border: Border.all(color: AppColors.slate200),
              // ),
              child: Row(
                children: [
                  // const Icon(Iconsax.search_normal, size: 18, color: AppColors.textColorHint),
                  // const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: controller.searchDesignation,
                      decoration: const InputDecoration(
                        hintText: 'Search designation...',
                        prefixIcon:const Icon(Iconsax.search_normal, size: 18, color: AppColors.textColorHint),
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.textColorHint),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── List ──
          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.filteredDesignations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final designation = controller.filteredDesignations[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryColor.withValues(alpha: 0.1),
                                AppColors.primaryColor.withValues(alpha: 0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Iconsax.user_tag, color: AppColors.primaryColor, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                designation,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColorPrimary,
                              ),
                              // const SizedBox(height: 2),
                              // AppText(
                              //   'Tap to edit or view members',
                              //   fontSize: 11,
                              //   color: AppColors.textColorSecondary.withValues(alpha: 0.7),
                              // ),
                            ],
                          ),
                        ),
                        // Container(
                        //   padding: const EdgeInsets.all(6),
                        //   decoration: BoxDecoration(
                        //     color: AppColors.slate100,
                        //     shape: BoxShape.circle,
                        //   ),
                        //   child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textColorSecondary),
                        // ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteHelper.getAddDesignationRoute()),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
