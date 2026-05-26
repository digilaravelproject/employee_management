import 'package:get/get.dart';

class DesignationController extends GetxController {
  final RxList<String> designations = [
    'Senior Flutter Developer',
    'HR Manager',
    'PHP Developer',
    'UI/UX Designer',
    'Sales Executive',
    'Project Manager',
  ].obs;

  final RxList<String> filteredDesignations = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredDesignations.assignAll(designations);
  }

  void searchDesignation(String query) {
    if (query.isEmpty) {
      filteredDesignations.assignAll(designations);
    } else {
      filteredDesignations.assignAll(
        designations.where((d) => d.toLowerCase().contains(query.toLowerCase())).toList(),
      );
    }
  }

  void addDesignation(String name) {
    if (name.isNotEmpty) {
      designations.add(name);
      filteredDesignations.assignAll(designations);
    }
  }
}
