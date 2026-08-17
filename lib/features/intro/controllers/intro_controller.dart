import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/route_helper.dart';

class IntroController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<Map<String, String>> introData = [
    {
      'image': 'assets/images/intro_img_1.png',
      'title': 'Track Employee Attendance',
      'description':
      'Manage daily staff attendance easily with a smart and simple tracking system.',
    },
    {
      'image': 'assets/images/intro_img_2.png',
      'title': 'Location Based Check-In',
      'description':
      'Allow employees to mark attendance securely with real-time location support.',
    },
    {
      'image': 'assets/images/intro_img_3.png',
      'title': 'Reports & Attendance History',
      'description':
      'View attendance records, history, and reports anytime in one professional dashboard.',
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < introData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      getStarted();
    }
  }

  void backPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void getStarted() {
    Get.offAllNamed(RouteHelper.getRoleSelectionRoute());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}