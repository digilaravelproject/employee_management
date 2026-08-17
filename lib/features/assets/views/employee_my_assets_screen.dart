import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class EmployeeMyAssetsScreen extends StatelessWidget {
  const EmployeeMyAssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Assets
    final assets = [
      {
        'name': 'MacBook Pro 16"',
        'id': 'AST-MBP-012',
        'category': 'Laptop',
        'dateAssigned': '10 Jan 2026',
        'status': 'Assigned',
        'icon': Iconsax.monitor,
        'color': Colors.blue,
      },
      {
        'name': 'Magic Mouse 2',
        'id': 'AST-MSE-045',
        'category': 'Accessories',
        'dateAssigned': '12 Jan 2026',
        'status': 'Assigned',
        'icon': Iconsax.mouse,
        'color': Colors.orange,
      },
      {
        'name': 'Office Desk Chair',
        'id': 'AST-FUR-102',
        'category': 'Furniture',
        'dateAssigned': '15 Jan 2026',
        'status': 'Assigned',
        'icon': Iconsax.box,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          'My Assets',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: assets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final asset = assets[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (asset['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      asset['icon'] as IconData,
                      color: asset['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          asset['name'] as String,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColorPrimary,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            AppText(
                              'ID: ${asset['id']}',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColorSecondary,
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.circle, size: 4, color: AppColors.textColorHint),
                            const SizedBox(width: 8),
                            AppText(
                              asset['category'] as String,
                              fontSize: 12,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              'Assigned: ${asset['dateAssigned']}',
                              fontSize: 11,
                              color: AppColors.textColorHint,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppText(
                                asset['status'] as String,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.successColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
