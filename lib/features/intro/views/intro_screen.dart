import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/intro_controller.dart';

class IntroScreen extends GetView<IntroController> {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    itemCount: controller.introData.length,
                    itemBuilder: (context, index) {
                      final data = controller.introData[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 80),

                          /*  Container(
                             height: 420,
                              width: double.infinity,
                             // padding: const EdgeInsets.all(18),
                             //  decoration: BoxDecoration(
                             //    gradient: LinearGradient(
                             //      colors: [
                             //        AppColors.primaryColor.withValues(alpha: 0.12),
                             //        AppColors.primaryLight.withValues(alpha: 0.22),
                             //      ],
                             //      begin: Alignment.topLeft,
                             //      end: Alignment.bottomRight,
                             //    ),
                             //    borderRadius: BorderRadius.circular(32),
                             //  ),
                              child:
                              ClipRRect(
                               borderRadius: BorderRadius.circular(26),
                                child: Image.asset(
                                  data['image']!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),*/

                            ClipRRect(
                              //borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                height: 420,
                                width: double.infinity,
                                child: Image.asset(
                                  data['image']!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),


                            const SizedBox(height: 42),

                            AppText(
                              data['title']!,
                              style: AppTextStyle.heading,
                              align: TextAlign.center,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColorPrimary,
                            ),

                            const SizedBox(height: 14),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: AppText(
                                data['description']!,
                                style: AppTextStyle.body,
                                align: TextAlign.center,
                                fontSize: 15,
                                color: AppColors.textColorSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: Column(
                    children: [
                      Obx(
                            () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.introData.length,
                                (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 7,
                              width: controller.currentPage.value == index ? 28 : 7,
                              decoration: BoxDecoration(
                                color: controller.currentPage.value == index
                                    ? AppColors.primaryColor
                                    : AppColors.slate200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Obx(
                            () => Row(
                          children: [
                            if (controller.currentPage.value != 0)
                              InkWell(
                                onTap: controller.backPage,
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.slate200),
                                  ),
                                  child: const Icon(
                                    Iconsax.arrow_left_2,
                                    color: AppColors.textColorPrimary,
                                    size: 20,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 50),

                            const SizedBox(width: 14),

                            Expanded(
                              child: AppButton(
                                text: controller.currentPage.value ==
                                    controller.introData.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                onPressed: controller.nextPage,
                                height: 52,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              top: 14,
              right: 18,
              child: TextButton(
                onPressed: controller.getStarted,
                child: const AppText(
                  'Skip',
                  style: AppTextStyle.body,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColorSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}