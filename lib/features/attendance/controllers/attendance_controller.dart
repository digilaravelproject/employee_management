import 'package:get/get.dart';

class AttendanceController extends GetxController {
  final RxInt selectedTab = 0.obs;
  final Rx<DateTime> selectedDate = DateTime(2025, 5, 20).obs;

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void changeDate(DateTime date) {
    selectedDate.value = date;
  }
}
