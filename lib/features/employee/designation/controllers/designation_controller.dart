import 'package:get/get.dart';
import '../models/designation_model.dart';
import '../../management/controllers/employee_controller.dart';

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
      DesignationModel(
        id: '1',
        name: 'Senior Flutter Developer',
        hierarchyLevel: 'Senior',
        skills: ['Flutter', 'Dart', 'GetX', 'REST API'],
      ),
      DesignationModel(
        id: '2',
        name: 'HR Manager',
        hierarchyLevel: 'Manager',
        skills: ['Recruitment', 'Communication', 'Management'],
      ),
      DesignationModel(
        id: '3',
        name: 'PHP Developer',
        hierarchyLevel: 'Junior',
        skills: ['PHP', 'Laravel', 'MySQL'],
      ),
      DesignationModel(
        id: '4',
        name: 'UI/UX Designer',
        hierarchyLevel: 'Junior',
        skills: ['Figma', 'Wireframing', 'User Research'],
      ),
      DesignationModel(
        id: '5',
        name: 'Sales Executive',
        hierarchyLevel: 'Junior',
        skills: ['Negotiation', 'Communication', 'Client Handling'],
      ),
      DesignationModel(
        id: '6',
        name: 'Project Manager',
        hierarchyLevel: 'Manager',
        skills: ['Agile', 'Scrum', 'Team Leadership'],
      ),
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

  void addDesignation(String name, String level, {List<String> skills = const []}) {
    if (name.isNotEmpty) {
      designations.add(
        DesignationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          hierarchyLevel: level,
          skills: skills,
        ),
      );
      filteredDesignations.assignAll(designations);
    }
  }

  void updateDesignation(String id, String name, String level, {List<String> skills = const []}) {
    final index = designations.indexWhere((d) => d.id == id);
    if (index != -1 && name.isNotEmpty) {
      final oldName = designations[index].name;
      designations[index] = DesignationModel(
        id: id,
        name: name,
        hierarchyLevel: level,
        skills: skills,
      );
      filteredDesignations.assignAll(designations);

      // If designation name changed, update assigned employees
      if (oldName.toLowerCase() != name.toLowerCase()) {
        if (Get.isRegistered<EmployeeController>()) {
          final empController = Get.find<EmployeeController>();
          for (final emp in empController.employees) {
            if (emp.designation.toLowerCase() == oldName.toLowerCase()) {
              empController.updateEmployee(emp.copyWith(designation: name));
            }
          }
        }
      }
    }
  }

  void deleteDesignation(String id) {
    final designation = designations.firstWhereOrNull((d) => d.id == id);
    if (designation != null) {
      // Clear designation for any assigned employees
      if (Get.isRegistered<EmployeeController>()) {
        final empController = Get.find<EmployeeController>();
        for (final emp in empController.employees) {
          if (emp.designation.toLowerCase() == designation.name.toLowerCase()) {
            empController.updateEmployee(emp.copyWith(designation: ''));
          }
        }
      }

      designations.removeWhere((d) => d.id == id);
      filteredDesignations.assignAll(designations);
    }
  }
}
