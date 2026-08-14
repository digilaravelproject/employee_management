import 'package:get/get.dart';
import '../models/designation_model.dart';

class DesignationController extends GetxController {
  final RxList<DesignationModel> designations = <DesignationModel>[].obs;
  final RxList<DesignationModel> filteredDesignations = <DesignationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDummyDesignations();
  }

  void _initializeDummyDesignations() {
    designations.addAll([
      DesignationModel(id: '1', name: 'Senior Flutter Developer', hierarchyLevel: 'Senior'),
      DesignationModel(id: '2', name: 'HR Manager', hierarchyLevel: 'Manager'),
      DesignationModel(id: '3', name: 'PHP Developer', hierarchyLevel: 'Junior'),
      DesignationModel(id: '4', name: 'UI/UX Designer', hierarchyLevel: 'Junior'),
      DesignationModel(id: '5', name: 'Sales Executive', hierarchyLevel: 'Junior'),
      DesignationModel(id: '6', name: 'Project Manager', hierarchyLevel: 'Manager'),
    ]);
    filteredDesignations.assignAll(designations);
  }

  void searchDesignation(String query) {
    if (query.isEmpty) {
      filteredDesignations.assignAll(designations);
    } else {
      filteredDesignations.assignAll(
        designations.where((d) => d.name.toLowerCase().contains(query.toLowerCase())).toList(),
      );
    }
  }

  void addDesignation(String name, String level) {
    if (name.isNotEmpty) {
      designations.add(
        DesignationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          hierarchyLevel: level,
        ),
      );
      filteredDesignations.assignAll(designations);
    }
  }
}
