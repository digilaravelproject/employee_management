import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../employee/management/models/employee_model.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../models/create_project_model.dart';
import '../models/project_model.dart';
import '../repositories/project_repository.dart';
import '../repositories/project_repository_interface.dart';
import '../../tasks/controllers/tasks_controller.dart';

class ProjectsController extends GetxController {
  final ProjectRepositoryInterface repository;

  ProjectsController({ProjectRepositoryInterface? repository})
      : repository = repository ??
            (Get.isRegistered<ProjectRepositoryInterface>()
                ? Get.find<ProjectRepositoryInterface>()
                : ProjectRepository(
                    apiClient: Get.isRegistered<ApiClient>()
                        ? Get.find<ApiClient>()
                        : Get.put(ApiClient(), permanent: true),
                  ));

  // Live Employee List from API
  final RxList<EmployeeModel> employeesList = <EmployeeModel>[].obs;
  final RxBool isLoadingEmployees = false.obs;
  final RxList<EmployeeModel> selectedTeamEmployees = <EmployeeModel>[].obs;
  final RxString employeeSearchQuery = ''.obs;
  final RxBool isCreatingProject = false.obs;
  final RxBool isUpdatingProject = false.obs;
  final RxBool isDeletingProject = false.obs;
  final RxDouble progressValue = 0.0.obs;
  final RxList<PlatformFile> attachedRealFiles = <PlatformFile>[].obs;
  // Reactive projects list
  final RxList<Project> projects = <Project>[].obs;

  // Search & Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedTab = 'All'.obs; // All, In Progress, Completed, On Hold, Not Started

  // Dynamically mapped from employeesList (live API)
  List<AppUser> get allEmployees {
    if (employeesList.isNotEmpty) {
      return employeesList.map((e) => AppUser(
        name: e.name,
        email: e.email,
        avatarUrl: e.profilePic ?? '',
        designation: e.designation,
      )).toList();
    }
    return const [];
  }

  // Form State Observables
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedCategory = 'Web Development'.obs;
  final RxString selectedStatus = 'Not Started'.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 30)).obs;
  final RxList<AppUser> selectedEmployees = <AppUser>[].obs;
  final RxList<ProjectFile> selectedFiles = <ProjectFile>[].obs;

  // Selected Project for details view
  final Rxn<Project> selectedProject = Rxn<Project>();
  
  // Project Details selected tab index
  final RxInt selectedDetailsTabIdx = 0.obs;

  // Pagination & Loading States for Projects Feed
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final RxBool isLoadingProjects = false.obs;
  final RxBool isSearchingProjects = false.obs;
  final RxBool isLoadingMoreProjects = false.obs;
  final RxString projectErrorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalProjectsCount = 0.obs;
  final int perPage = 20;

  // Project Details State
  final RxBool isLoadingProjectDetails = false.obs;
  final RxString projectDetailsError = ''.obs;
  final Rxn<ProjectApiData> projectDetailsRaw = Rxn<ProjectApiData>();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchEmployees();
    fetchProjects(isRefresh: true);

    ever(selectedTab, (_) {
      if (searchQuery.value.trim().isEmpty) {
        fetchProjects(isRefresh: false);
      }
    });

    debounce(searchQuery, (query) {
      final q = query.trim();
      if (q.isNotEmpty) {
        searchProjectsApi(q);
      } else {
        fetchProjects(isRefresh: false);
      }
    }, time: const Duration(milliseconds: 350));
  }

  void _scrollListener() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMoreProjects();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Filtered projects feed
  List<Project> get filteredProjects {
    List<Project> results = projects;

    // Filter by tab status if not 'All'
    if (selectedTab.value != 'All') {
      results = results
          .where((p) => p.status.toLowerCase() == selectedTab.value.toLowerCase())
          .toList();
    }

    return results;
  }

  // Fetch projects from live API with pagination
  Future<void> fetchProjects({bool isRefresh = false}) async {
    currentPage.value = 1;
    // Only show full-screen loader on initial load when list is empty
    if (projects.isEmpty && isRefresh) {
      isLoadingProjects.value = true;
    }
    projectErrorMessage.value = '';

    try {
      final statusParam = selectedTab.value == 'All' ? 'all' : selectedTab.value;
      Logger.d('ProjectsController => Fetching projects (status: $statusParam, page: 1, perPage: $perPage)');

      final response = await repository.getProjects(
        status: statusParam,
        page: 1,
        perPage: perPage,
      );

      if (response.status) {
        final fetchedList = response.data.map((e) => e.toProject()).toList();
        projects.assignAll(fetchedList);

        currentPage.value = response.pagination?.currentPage ?? 1;
        lastPage.value = response.pagination?.lastPage ?? 1;
        totalProjectsCount.value = response.pagination?.total ?? response.total;
        projectErrorMessage.value = '';
      } else {
        if (projects.isEmpty) {
          projectErrorMessage.value = response.message.isNotEmpty
              ? response.message
              : 'Failed to load projects.';
        }
      }
    } catch (e) {
      Logger.e('ProjectsController => fetchProjects error: $e');
      if (projects.isEmpty) {
        projectErrorMessage.value = 'Failed to load projects: $e';
      }
    } finally {
      isLoadingProjects.value = false;
    }
  }

  // Search projects via GET /api/admin/projects/search?query=...&per_page=...
  Future<void> searchProjectsApi(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      fetchProjects(isRefresh: false);
      return;
    }

    currentPage.value = 1;
    isSearchingProjects.value = true;

    try {
      Logger.d('ProjectsController => Searching projects with query: "$q"');
      final response = await repository.searchProjects(
        query: q,
        page: 1,
        perPage: perPage,
      );

      if (response.status) {
        final fetchedList = response.data.map((e) => e.toProject()).toList();
        projects.assignAll(fetchedList);

        currentPage.value = response.pagination?.currentPage ?? 1;
        lastPage.value = response.pagination?.lastPage ?? 1;
        totalProjectsCount.value = response.pagination?.total ?? response.total;
        projectErrorMessage.value = '';
      } else {
        if (response.data.isEmpty) {
          projects.clear();
          totalProjectsCount.value = 0;
        }
      }
    } catch (e) {
      Logger.e('ProjectsController => searchProjectsApi error: $e');
    } finally {
      isSearchingProjects.value = false;
    }
  }

  // Load more projects for infinite scrolling pagination
  Future<void> loadMoreProjects() async {
    if (isLoadingProjects.value || isLoadingMoreProjects.value || isSearchingProjects.value) return;
    if (currentPage.value >= lastPage.value) return;

    isLoadingMoreProjects.value = true;
    try {
      final nextPage = currentPage.value + 1;
      final q = searchQuery.value.trim();

      final ProjectListResponseModel response;
      if (q.isNotEmpty) {
        Logger.d('ProjectsController => Loading more search results (query: "$q", page: $nextPage)');
        response = await repository.searchProjects(
          query: q,
          page: nextPage,
          perPage: perPage,
        );
      } else {
        final statusParam = selectedTab.value == 'All' ? 'all' : selectedTab.value;
        Logger.d('ProjectsController => Loading more projects (status: $statusParam, page: $nextPage)');
        response = await repository.getProjects(
          status: statusParam,
          page: nextPage,
          perPage: perPage,
        );
      }

      if (response.status) {
        final fetchedList = response.data.map((e) => e.toProject()).toList();
        final existingIds = projects.map((p) => p.id).toSet();
        final newItems = fetchedList.where((p) => !existingIds.contains(p.id));
        projects.addAll(newItems);

        currentPage.value = response.pagination?.currentPage ?? nextPage;
        lastPage.value = response.pagination?.lastPage ?? lastPage.value;
        totalProjectsCount.value = response.pagination?.total ?? response.total;
      }
    } catch (e) {
      Logger.e('ProjectsController => loadMoreProjects error: $e');
    } finally {
      isLoadingMoreProjects.value = false;
    }
  }

  // Fetch full project details by project id via GET /api/admin/projects/:id
  Future<void> fetchProjectDetails(dynamic id) async {
    if (id == null) return;
    isLoadingProjectDetails.value = true;
    projectDetailsError.value = '';

    try {
      Logger.d('ProjectsController => Fetching project details for id: $id');
      final response = await repository.getProjectDetails(id);

      if (response.status && response.data != null) {
        projectDetailsRaw.value = response.data;
        final project = response.data!.toProject();
        selectedProject.value = project;

        // Sync with projects list
        final idx = projects.indexWhere((p) => p.id == project.id);
        if (idx != -1) {
          projects[idx] = project;
        }
        projectDetailsError.value = '';
      } else {
        projectDetailsError.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to retrieve project details.';
      }
    } catch (e) {
      Logger.e('ProjectsController => fetchProjectDetails error: $e');
      projectDetailsError.value = 'Failed to load project details: $e';
    } finally {
      isLoadingProjectDetails.value = false;
    }
  }

  // Clear creation form
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    selectedCategory.value = 'Web Development';
    selectedStatus.value = 'Not Started';
    startDate.value = DateTime.now();
    endDate.value = DateTime.now().add(const Duration(days: 30));
    progressValue.value = 0.0;
    selectedEmployees.clear();
    selectedFiles.clear();
    selectedTeamEmployees.clear();
    attachedRealFiles.clear();
    employeeSearchQuery.value = '';
  }

  // Populate form for editing
  void populateForm(Project p) {
    nameController.text = p.name;
    descriptionController.text = p.description;
    selectedCategory.value = p.category;
    selectedStatus.value = p.status;
    startDate.value = p.startDate;
    endDate.value = p.endDate;

    final prog = p.progress ?? 0.0;
    progressValue.value = (prog <= 1.0 && prog > 0) ? (prog * 100).toDouble() : prog.toDouble();

    selectedEmployees.assignAll(p.teamMembers);
    selectedFiles.assignAll(p.files);

    if (employeesList.isEmpty) {
      fetchEmployees();
    }

    selectedTeamEmployees.clear();
    final rawData = projectDetailsRaw.value;
    if (rawData != null && rawData.id.toString() == p.id.toString() && rawData.team.isNotEmpty) {
      for (final tm in rawData.team) {
        final existing = employeesList.firstWhereOrNull(
          (e) => e.id.toString() == tm.id.toString() ||
                 (tm.employeeId.isNotEmpty && e.employeeId == tm.employeeId) ||
                 (tm.email.isNotEmpty && e.email.toLowerCase() == tm.email.toLowerCase()),
        );
        if (existing != null) {
          selectedTeamEmployees.add(existing);
        } else {
          selectedTeamEmployees.add(tm.toEmployeeModel());
        }
      }
    } else {
      for (final tm in p.teamMembers) {
        final existing = employeesList.firstWhereOrNull(
          (e) => (tm.employeeId != null && tm.employeeId!.isNotEmpty && e.employeeId == tm.employeeId) ||
                 (tm.email.isNotEmpty && e.email.toLowerCase() == tm.email.toLowerCase()) ||
                 (tm.name.isNotEmpty && e.name.toLowerCase() == tm.name.toLowerCase()),
        );
        if (existing != null) {
          selectedTeamEmployees.add(existing);
        } else {
          selectedTeamEmployees.add(
            EmployeeModel(
              id: tm.employeeId ?? tm.name.hashCode.toString(),
              employeeId: tm.employeeId ?? '',
              name: tm.name,
              mobile: '',
              email: tm.email,
              designation: tm.designation ?? '',
              joiningDate: '',
              address: '',
              profilePic: tm.avatarUrl.isNotEmpty ? tm.avatarUrl : null,
              isActive: tm.status?.toLowerCase() == 'active',
            ),
          );
        }
      }
    }
  }

  // Fetch employees from API
  Future<void> fetchEmployees() async {
    try {
      isLoadingEmployees.value = true;
      final response = await repository.getEmployees();
      if (response.status && response.data.isNotEmpty) {
        employeesList.assignAll(response.data);

        // Re-sync selectedTeamEmployees with loaded employees
        if (selectedTeamEmployees.isNotEmpty) {
          final List<EmployeeModel> synced = [];
          for (final sel in selectedTeamEmployees) {
            final match = response.data.firstWhereOrNull(
              (e) => e.id.toString() == sel.id.toString() ||
                     (sel.employeeId.isNotEmpty && e.employeeId == sel.employeeId) ||
                     (sel.email.isNotEmpty && e.email.toLowerCase() == sel.email.toLowerCase()),
            );
            synced.add(match ?? sel);
          }
          selectedTeamEmployees.assignAll(synced);
        }
      }
    } catch (e) {
      Logger.e('ProjectsController => fetchEmployees error: $e');
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  // Filtered employees list for Assign Team bottom sheet
  List<EmployeeModel> get filteredEmployeesList {
    if (employeeSearchQuery.value.trim().isEmpty) {
      return employeesList;
    }
    final q = employeeSearchQuery.value.trim().toLowerCase();
    return employeesList.where((emp) {
      return emp.name.toLowerCase().contains(q) ||
          emp.email.toLowerCase().contains(q) ||
          emp.employeeId.toLowerCase().contains(q) ||
          emp.designation.toLowerCase().contains(q) ||
          emp.department.toLowerCase().contains(q);
    }).toList();
  }

  // Toggle selection for live EmployeeModel
  void toggleTeamEmployee(EmployeeModel emp) {
    final idx = selectedTeamEmployees.indexWhere(
      (e) => e.id.toString() == emp.id.toString() ||
             (emp.employeeId.isNotEmpty && e.employeeId == emp.employeeId),
    );
    if (idx != -1) {
      selectedTeamEmployees.removeAt(idx);
    } else {
      selectedTeamEmployees.add(emp);
    }
  }

  // Pick real files from device
  Future<void> pickRealFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null && file.path!.isNotEmpty) {
            // Avoid duplicate path
            if (!attachedRealFiles.any((f) => f.path == file.path)) {
              attachedRealFiles.add(file);
              final sizeMb = (file.size / (1024 * 1024));
              final ext = file.extension?.toUpperCase() ?? 'FILE';
              selectedFiles.add(
                ProjectFile(
                  id: 'f_${DateTime.now().millisecondsSinceEpoch}_${file.name.hashCode}',
                  name: file.name,
                  sizeMb: double.parse(sizeMb.toStringAsFixed(2)),
                  type: ext,
                  localPath: file.path,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      Logger.e('ProjectsController => pickRealFiles error: $e');
      Get.snackbar(
        'File Selection',
        'Could not attach files: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    }
  }

  void removeAttachedFile(int index) {
    if (index >= 0 && index < attachedRealFiles.length) {
      attachedRealFiles.removeAt(index);
    }
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
    }
  }

  // Create Project via Live API
  Future<bool> createProjectApi() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Project Name is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    if (endDate.value.isBefore(startDate.value)) {
      Get.snackbar(
        'Validation Error',
        'End date cannot be earlier than start date!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    }

    isCreatingProject.value = true;

    try {
      final sDateStr = DateFormat('yyyy-MM-dd').format(startDate.value);
      final eDateStr = DateFormat('yyyy-MM-dd').format(endDate.value);

      // Collect employee IDs from selectedTeamEmployees
      final empIds = selectedTeamEmployees
          .map((e) => e.id.toString())
          .where((id) => id.isNotEmpty)
          .toList();

      // Collect file paths from attachedRealFiles
      final filePaths = attachedRealFiles
          .map((f) => f.path)
          .whereType<String>()
          .where((p) => p.isNotEmpty)
          .toList();

      final request = CreateProjectRequestModel(
        name: name,
        description: descriptionController.text.trim(),
        category: selectedCategory.value,
        startDate: sDateStr,
        endDate: eDateStr,
        status: selectedStatus.value,
        progress: selectedStatus.value == 'Completed'
            ? 100
            : (selectedStatus.value == 'In Progress' ? 25 : 0),
        employeeIds: empIds,
        filePaths: filePaths,
      );

      final response = await repository.createProject(request);

      if (response.status && response.data != null) {
        final newProj = response.data!.toProject();
        projects.insert(0, newProj);
        clearForm();
        Get.back();
        fetchProjects(isRefresh: true);
        Get.snackbar(
          'Success',
          response.message.isNotEmpty ? response.message : 'Project created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to create project.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Logger.e('ProjectsController => createProjectApi error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isCreatingProject.value = false;
    }
  }

  // Save new project
  void saveProject() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Project Name is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final newProj = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      category: selectedCategory.value,
      status: selectedStatus.value,
      startDate: startDate.value,
      endDate: endDate.value,
      teamMembers: List<AppUser>.from(selectedEmployees),
      tasks: [
        // Automatically add standard kick-off tasks
        ProjectTask(
          id: 't_kickoff_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Initial Kickoff & Architecture Alignment',
          category: 'Design',
          status: selectedStatus.value == 'Completed' ? 'Done' : 'To Do',
          dueDate: endDate.value,
          assignee: selectedEmployees.isNotEmpty ? selectedEmployees.first : null,
        )
      ],
      timeline: [
        ProjectTimelineEvent(
          id: 'm_created_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Project Created',
          subtitle: 'System logged project initialization',
          date: startDate.value,
          isCompleted: true,
        ),
      ],
      files: List<ProjectFile>.from(selectedFiles),
    );

    projects.add(newProj);
    clearForm();
    Get.back();
    Get.snackbar(
      'Success',
      'Project created successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Update existing project via PATCH /api/admin/projects/:id
  Future<void> updateProject() async {
    final current = selectedProject.value;
    if (current == null) {
      Get.snackbar(
        'Error',
        'No project selected to update.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Project Name is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isUpdatingProject.value = true;

      // Collect employee IDs as integers
      final employeeIds = selectedTeamEmployees
          .map((e) => int.tryParse(e.id.toString()) ?? e.id)
          .toList();

      final request = UpdateProjectRequestModel(
        name: name,
        status: selectedStatus.value,
        progress: progressValue.value.toInt(),
        employeeIds: employeeIds,
        description: descriptionController.text.trim(),
        category: selectedCategory.value,
        startDate: DateFormat('yyyy-MM-dd').format(startDate.value),
        endDate: DateFormat('yyyy-MM-dd').format(endDate.value),
      );

      Logger.d('ProjectsController => Updating project ${current.id} with body: ${request.toJson()}');
      final response = await repository.updateProject(current.id, request);

      if (response.status) {
        if (response.data != null) {
          final updatedProject = response.data!.toProject();
          selectedProject.value = updatedProject;
          final idx = projects.indexWhere((p) => p.id == current.id);
          if (idx != -1) {
            projects[idx] = updatedProject;
          }
        } else {
          await fetchProjectDetails(current.id);
        }

        // Refresh project list in background
        fetchProjects(isRefresh: true);

        clearForm();
        Get.back(); // Pop CreateProjectScreen

        Get.snackbar(
          'Success',
          response.message.isNotEmpty ? response.message : 'Project updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Update Failed',
          response.message.isNotEmpty ? response.message : 'Failed to update project.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Logger.e('ProjectsController => updateProject error: $e');
      Get.snackbar(
        'Error',
        'Could not update project: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isUpdatingProject.value = false;
    }
  }

  // Delete project via DELETE /api/admin/projects/:id
  Future<bool> deleteProject(dynamic id) async {
    try {
      isDeletingProject.value = true;
      Logger.d('ProjectsController => Deleting project with id: $id');
      final response = await repository.deleteProject(id);

      if (response.status) {
        projects.removeWhere((p) => p.id.toString() == id.toString());
        if (selectedProject.value?.id.toString() == id.toString()) {
          selectedProject.value = null;
        }

        // Refresh projects list in background
        fetchProjects(isRefresh: true);
        return true;
      } else {
        Get.snackbar(
          'Delete Failed',
          response.message.isNotEmpty ? response.message : 'Failed to delete project.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Logger.e('ProjectsController => deleteProject error: $e');
      Get.snackbar(
        'Error',
        'Could not delete project: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isDeletingProject.value = false;
    }
  }

  // Toggle checklist assignment of team members in bottom sheet form
  void toggleEmployeeSelection(AppUser emp) {
    if (selectedEmployees.contains(emp)) {
      selectedEmployees.remove(emp);
    } else {
      selectedEmployees.add(emp);
    }
  }

  // Add a task to the active project (Jira-style with module and submodule)
  void addTaskToProject(
    String title,
    String category,
    AppUser? assignee,
    DateTime due, {
    String moduleName = 'General',
    String subModuleName = 'Default',
  }) {
    final current = selectedProject.value;
    if (current == null) return;

    final newTask = ProjectTask(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      status: 'To Do',
      dueDate: due,
      assignee: assignee,
      moduleName: moduleName,
      subModuleName: subModuleName,
    );

    // Create a new tasks list and deep copy
    final updatedTasks = List<ProjectTask>.from(current.tasks)..add(newTask);
    final updated = current.copyWith(tasks: updatedTasks);

    // Update main database
    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;

    Get.snackbar(
      'Task Added',
      'New task allocated to ${assignee?.name ?? "unassigned"} in [$moduleName]',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Toggle/Change status of a task inside a project
  void changeTaskStatus(String taskId, String newStatus) {
    final current = selectedProject.value;
    if (current == null) return;

    final updatedTasks = current.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(status: newStatus);
      }
      return task;
    }).toList();

    // Auto-update project overall status based on tasks progress
    String projectOverallStatus = current.status;
    final totalTasks = updatedTasks.length;
    final doneTasks = updatedTasks.where((t) => t.status == 'Done' || t.status == 'Completed').length;
    final inProgressTasks = updatedTasks.where((t) => t.status == 'In Progress' || t.status == 'Testing').length;

    if (totalTasks > 0 && doneTasks == totalTasks) {
      projectOverallStatus = 'Completed';
    } else if (inProgressTasks > 0 || doneTasks > 0) {
      if (projectOverallStatus == 'Not Started') {
        projectOverallStatus = 'In Progress';
      }
    }

    final updated = current.copyWith(tasks: updatedTasks, status: projectOverallStatus);

    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;

    // Sync back to TasksController if registered
    if (Get.isRegistered<TasksController>()) {
      Get.find<TasksController>().syncStatusFromProject(taskId, newStatus);
    }
  }

  // Remove member from project details/edit screen
  void removeMember(AppUser emp) {
    final current = selectedProject.value;
    if (current == null) return;

    final updatedMembers = List<AppUser>.from(current.teamMembers)..remove(emp);
    final updated = current.copyWith(teamMembers: updatedMembers);

    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;
  }

  // Add multiple members to active project - newly added members get access to all past tasks and project history!
  void assignMembersToProject(List<AppUser> members) {
    final current = selectedProject.value;
    if (current == null) return;

    final updatedMembers = Set<AppUser>.from(current.teamMembers)..addAll(members);
    
    // Add timeline milestone for newly onboarded member
    final newEvents = members.map((m) => ProjectTimelineEvent(
      id: 'onboard_${DateTime.now().millisecondsSinceEpoch}_${m.name.hashCode}',
      title: '${m.name} joined project team',
      subtitle: 'Granted full access to all past tasks, modules, and work history',
      date: DateTime.now(),
      isCompleted: true,
    )).toList();

    final updatedTimeline = List<ProjectTimelineEvent>.from(current.timeline)..addAll(newEvents);
    final updated = current.copyWith(
      teamMembers: updatedMembers.toList(),
      timeline: updatedTimeline,
    );

    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;

    Get.snackbar(
      'Member Added',
      '${members.map((m) => m.name).join(", ")} added to project with full past work history.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Add Jira Module to Project
  void addModuleToProject(String name, String description, List<String> subModuleNames) {
    final current = selectedProject.value;
    if (current == null) return;

    final subModules = subModuleNames.map((s) => ProjectSubModule(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}_${s.hashCode}',
      name: s.trim(),
    )).toList();

    final newModule = ProjectModule(
      id: 'mod_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      description: description.trim(),
      subModules: subModules,
    );

    final updatedModules = List<ProjectModule>.from(current.modules)..add(newModule);
    final updated = current.copyWith(modules: updatedModules);

    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;

    Get.snackbar(
      'Module Created',
      'Module "$name" with ${subModules.length} sub-modules created successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Add sub-module to existing module
  void addSubModuleToModule(String moduleId, String subModuleName) {
    final current = selectedProject.value;
    if (current == null) return;

    final updatedModules = current.modules.map((m) {
      if (m.id == moduleId) {
        final newSub = ProjectSubModule(
          id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
          name: subModuleName.trim(),
        );
        return m.copyWith(subModules: List<ProjectSubModule>.from(m.subModules)..add(newSub));
      }
      return m;
    }).toList();

    final updated = current.copyWith(modules: updatedModules);
    final idx = projects.indexWhere((p) => p.id == current.id);
    if (idx != -1) {
      projects[idx] = updated;
    }
    selectedProject.value = updated;
  }

  // Mock upload / attach file helper
  void addMockFile(String name, double size, String ext) {
    final file = ProjectFile(
      id: 'f_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      sizeMb: size,
      type: ext.toUpperCase(),
    );
    selectedFiles.add(file);
  }
}
