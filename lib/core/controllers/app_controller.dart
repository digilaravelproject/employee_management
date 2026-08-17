import 'package:get/get.dart';

class AppController extends GetxController {
  // Store the selected role. 'admin' or 'employee'
  final RxString userRole = 'admin'.obs;

  void setRole(String role) {
    userRole.value = role;
  }
}
