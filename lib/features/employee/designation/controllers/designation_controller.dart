import 'package:get/get.dart';
import '../models/designation_model.dart';
import '../models/designation_request_model.dart';
import '../repositories/designation_repository.dart';
import '../../management/controllers/employee_controller.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../../../core/utils/logger.dart';

class DesignationController extends GetxController {
  final DesignationRepository? repository;

  DesignationController({this.repository});

  final RxList<DesignationModel> designations = <DesignationModel>[].obs;
  final RxList<DesignationModel> filteredDesignations = <DesignationModel>[].obs;
  final RxBool isSaving = false.obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (repository != null) {
      fetchDesignations();
    } else {
      _initializeDummyDesignations();
    }
  }

  Future<void> fetchDesignations() async {
    if (repository == null) return;
    
    try {
      isLoading.value = true;
      final response = await repository!.getDesignations();
      
      if (response.status) {
        designations.assignAll(response.data);
        filteredDesignations.assignAll(designations);
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      Logger.e('DesignationController -> Failed to fetch designations: $e');
      CustomSnackbar.showError('Failed to fetch designations');
    } finally {
      isLoading.value = false;
    }
  }

  Future<DesignationModel?> fetchDesignationDetails(String id) async {
    if (repository == null) return null;
    
    try {
      final response = await repository!.getDesignationDetails(id);
      if (response.status && response.data != null) {
        return response.data;
      } else {
        CustomSnackbar.showError(response.message);
        return null;
      }
    } catch (e) {
      Logger.e('DesignationController -> Failed to fetch designation details: $e');
      CustomSnackbar.showError('Failed to fetch designation details');
      return null;
    }
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

  Future<bool> addDesignation(String name, String level, {List<String> skills = const []}) async {
    if (name.isEmpty) return false;

    if (repository == null) {
      // Fallback to local logic if no repository injected (e.g. older screens)
      designations.add(
        DesignationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          hierarchyLevel: level,
          skills: skills,
        ),
      );
      filteredDesignations.assignAll(designations);
      return true;
    }

    try {
      isSaving.value = true;
      final request = DesignationRequestModel(
        name: name,
        hierarchyLevel: level,
        skills: skills,
      );

      final response = await repository!.createDesignation(request);

      if (response.status && response.data != null) {
        designations.add(response.data!);
        filteredDesignations.assignAll(designations);
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('DesignationController -> Failed to add designation: $e');
      CustomSnackbar.showError('Something went wrong');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateDesignation(String id, String name, String level, {List<String> skills = const []}) async {
    final index = designations.indexWhere((d) => d.id == id);
    if (index == -1 || name.isEmpty) return false;

    if (repository == null) {
      final oldName = designations[index].name;
      designations[index] = DesignationModel(
        id: id,
        name: name,
        hierarchyLevel: level,
        skills: skills,
      );
      filteredDesignations.assignAll(designations);

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
      return true;
    }

    try {
      isSaving.value = true;
      final request = DesignationRequestModel(
        name: name,
        hierarchyLevel: level,
        skills: skills,
      );

      final response = await repository!.updateDesignation(id, request);

      if (response.status && response.data != null) {
        designations[index] = response.data!;
        filteredDesignations.assignAll(designations);
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('DesignationController -> Failed to update designation: $e');
      CustomSnackbar.showError('Something went wrong');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteDesignation(String id) async {
    final designation = designations.firstWhereOrNull((d) => d.id == id);
    if (designation == null) return false;

    if (repository == null) {
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
      return true;
    }

    try {
      final response = await repository!.deleteDesignation(id);
      
      if (response.status) {
        designations.removeWhere((d) => d.id == id);
        filteredDesignations.assignAll(designations);
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('DesignationController -> Failed to delete designation: $e');
      CustomSnackbar.showError('Failed to delete designation');
      return false;
    }
  }

  Future<bool> removeEmployeeFromDesignation(String designationId, String employeeId) async {
    if (repository == null) return false;

    try {
      isSaving.value = true;
      final response = await repository!.removeEmployeeFromDesignation(designationId, employeeId);
      
      if (response.status) {
        return true;
      } else {
        CustomSnackbar.showError(response.message);
        return false;
      }
    } catch (e) {
      Logger.e('DesignationController -> Failed to remove employee: $e');
      CustomSnackbar.showError('Failed to remove employee');
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
