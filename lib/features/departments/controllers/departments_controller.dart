import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../models/department_model.dart';

class DepartmentsController extends GetxController {
  // Reactive list of departments
  final RxList<Department> departments = <Department>[].obs;

  // Search state
  final RxString searchQuery = ''.obs;

  // Mock list of all system employees available for assignment
  final List<AppUser> allEmployees = [
    const AppUser(name: 'John Smith', email: 'john.smith@example.com', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150'),
    const AppUser(name: 'Sarah Johnson', email: 'sarah.johnson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
    const AppUser(name: 'Michael Brown', email: 'michael.brown@example.com', avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150'),
    const AppUser(name: 'David Wilson', email: 'david.wilson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'),
    const AppUser(name: 'Emily Davis', email: 'emily.davis@example.com', avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150'),
    const AppUser(name: 'James Anderson', email: 'james.anderson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1463453091185-61582044d556?w=150'),
    const AppUser(name: 'Alex Johnson', email: 'alex.johnson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150'),
    const AppUser(name: 'Lisa Anderson', email: 'lisa.anderson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
    const AppUser(name: 'Robert Taylor', email: 'robert.taylor@example.com', avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150'),
  ];

  // Forms / Creation Observables
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rxn<AppUser> selectedHead = Rxn<AppUser>();
  final RxList<AppUser> selectedEmployees = <AppUser>[].obs;

  // Selected Department for Details / Edit Screen
  final Rxn<Department> selectedDepartment = Rxn<Department>();

  @override
  void onInit() {
    super.onInit();
    _initializeDummyDepartments();
  }

  void _initializeDummyDepartments() {
    // Generate extra dummy users to count up to 25, 12, 18, etc.
    final engineeringEmps = [
      allEmployees[0], // John Smith (Head)
      allEmployees[6], // Alex Johnson
      allEmployees[7], // Lisa Anderson
      allEmployees[8], // Robert Taylor
    ];
    // Fill with generic AppUsers up to 25 count
    for (int i = 1; i <= 21; i++) {
      engineeringEmps.add(AppUser(
        name: 'Developer $i',
        email: 'dev.$i@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      ));
    }

    final hrEmps = [
      allEmployees[1], // Sarah Johnson (Head)
      allEmployees[7], // Lisa Anderson
    ];
    for (int i = 1; i <= 10; i++) {
      hrEmps.add(AppUser(
        name: 'HR Officer $i',
        email: 'hr.$i@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
      ));
    }

    final marketingEmps = [
      allEmployees[2], // Michael Brown (Head)
      allEmployees[8], // Robert Taylor
    ];
    for (int i = 1; i <= 16; i++) {
      marketingEmps.add(AppUser(
        name: 'Marketer $i',
        email: 'marketing.$i@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
      ));
    }

    final financeEmps = [
      allEmployees[3], // David Wilson (Head)
    ];
    for (int i = 1; i <= 9; i++) {
      financeEmps.add(AppUser(
        name: 'Analyst $i',
        email: 'finance.$i@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      ));
    }

    final salesEmps = [
      allEmployees[4], // Emily Davis (Head)
    ];
    for (int i = 1; i <= 21; i++) {
      salesEmps.add(AppUser(
        name: 'Sales Rep $i',
        email: 'sales.$i@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      ));
    }

    final itSupportEmps = [
      allEmployees[5], // James Anderson (Head)
    ];
    for (int i = 1; i <= 7; i++) {
      itSupportEmps.add(AppUser(
        name: 'Support Tech $i',
        email: 'it.$i@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1463453091185-61582044d556?w=150',
      ));
    }

    departments.addAll([
      Department(
        id: '1',
        name: 'Engineering',
        description: 'Handles all engineering and product development activities.',
        head: allEmployees[0], // John Smith
        employees: engineeringEmps,
        teamsCount: 5,
        icon: Iconsax.code,
        themeColor: const Color(0xFF6366F1), // Violet
      ),
      Department(
        id: '2',
        name: 'Human Resources',
        description: 'Manages employee recruitment, onboarding, benefits, and workplace culture.',
        head: allEmployees[1], // Sarah Johnson
        employees: hrEmps,
        teamsCount: 3,
        icon: Iconsax.user_octagon,
        themeColor: const Color(0xFFEC4899), // Pink
      ),
      Department(
        id: '3',
        name: 'Marketing',
        description: 'Promotes brand growth, social media presence, and strategic campaigns.',
        head: allEmployees[2], // Michael Brown
        employees: marketingEmps,
        teamsCount: 4,
        icon: Iconsax.volume_high,
        themeColor: const Color(0xFF10B981), // Emerald Green
      ),
      Department(
        id: '4',
        name: 'Finance',
        description: 'Oversees payroll, budgets, financial audits, and investment metrics.',
        head: allEmployees[3], // David Wilson
        employees: financeEmps,
        teamsCount: 2,
        icon: Iconsax.empty_wallet,
        themeColor: const Color(0xFFF59E0B), // Amber
      ),
      Department(
        id: '5',
        name: 'Sales',
        description: 'Generates client deals, client management, and revenue expansion.',
        head: allEmployees[4], // Emily Davis
        employees: salesEmps,
        teamsCount: 4,
        icon: Iconsax.graph,
        themeColor: const Color(0xFF3B82F6), // Blue
      ),
      Department(
        id: '6',
        name: 'IT Support',
        description: 'Administers server operations, security settings, and technical support.',
        head: allEmployees[5], // James Anderson
        employees: itSupportEmps,
        teamsCount: 2,
        icon: Iconsax.monitor,
        themeColor: const Color(0xFF06B6D4), // Cyan
      ),
    ]);
  }

  // Reactive list of departments filtered by search query
  List<Department> get filteredDepartments {
    if (searchQuery.isEmpty) {
      return departments;
    }
    return departments
        .where((dept) => dept.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  // Clear inputs before creating or editing
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    selectedHead.value = null;
    selectedEmployees.clear();
  }

  // Populate form with existing department data for edit mode
  void populateForm(Department dept) {
    nameController.text = dept.name;
    descriptionController.text = dept.description;
    selectedHead.value = dept.head;
    selectedEmployees.assignAll(dept.employees);
  }

  // Save a brand new department
  void saveDepartment() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Department Name is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final newDept = Department(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      head: selectedHead.value,
      employees: List<AppUser>.from(selectedEmployees),
      teamsCount: 5, // Default team count
      icon: _getIconForDepartmentName(nameController.text.trim()),
      themeColor: _getThemeColorForDepartmentName(nameController.text.trim()),
    );

    departments.add(newDept);
    clearForm();
    Get.back();
    Get.snackbar(
      'Success',
      'Department added successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Update an existing department
  void updateDepartment() {
    final current = selectedDepartment.value;
    if (current == null) return;

    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Department Name is required!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final updated = current.copyWith(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      head: selectedHead.value,
      employees: List<AppUser>.from(selectedEmployees),
    );

    // Update in reactive list
    final idx = departments.indexWhere((dept) => dept.id == current.id);
    if (idx != -1) {
      departments[idx] = updated;
    }
    
    // Update active details state
    selectedDepartment.value = updated;
    
    clearForm();
    Get.back();
    Get.snackbar(
      'Updated',
      'Department updated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2563EB),
      colorText: Colors.white,
    );
  }

  // Delete a department
  void deleteDepartment(String id) {
    departments.removeWhere((dept) => dept.id == id);
    selectedDepartment.value = null;
    Get.back(); // Go back from details or edit screen
    Get.snackbar(
      'Deleted',
      'Department deleted successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  // Toggles user employee selection in check lists
  void toggleEmployeeSelection(AppUser user) {
    if (selectedEmployees.contains(user)) {
      selectedEmployees.remove(user);
    } else {
      selectedEmployees.add(user);
    }
  }

  // Assign head
  void assignHead(AppUser user) {
    selectedHead.value = user;
    // Also add to employees if not present
    if (!selectedEmployees.contains(user)) {
      selectedEmployees.add(user);
    }
  }

  // Unassign head
  void unassignHead() {
    selectedHead.value = null;
  }

  // Remove individual employee from department edit screen
  void removeEmployee(AppUser user) {
    selectedEmployees.remove(user);
    if (selectedHead.value == user) {
      selectedHead.value = null;
    }
  }

  // Icon mapping helpers
  IconData _getIconForDepartmentName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('eng') || lower.contains('code') || lower.contains('dev')) {
      return Iconsax.code;
    } else if (lower.contains('hr') || lower.contains('people') || lower.contains('recruit') || lower.contains('human')) {
      return Iconsax.user_octagon;
    } else if (lower.contains('market') || lower.contains('advert') || lower.contains('social')) {
      return Iconsax.volume_high;
    } else if (lower.contains('finance') || lower.contains('money') || lower.contains('audit') || lower.contains('pay')) {
      return Iconsax.empty_wallet;
    } else if (lower.contains('sale') || lower.contains('deal') || lower.contains('revenue')) {
      return Iconsax.graph;
    } else if (lower.contains('support') || lower.contains('it') || lower.contains('help')) {
      return Iconsax.monitor;
    }
    return Iconsax.category;
  }

  // Color mapping helpers
  Color _getThemeColorForDepartmentName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('eng') || lower.contains('code') || lower.contains('dev')) {
      return const Color(0xFF6366F1); // Violet
    } else if (lower.contains('hr') || lower.contains('people') || lower.contains('recruit') || lower.contains('human')) {
      return const Color(0xFFEC4899); // Pink
    } else if (lower.contains('market') || lower.contains('advert') || lower.contains('social')) {
      return const Color(0xFF10B981); // Emerald Green
    } else if (lower.contains('finance') || lower.contains('money') || lower.contains('audit') || lower.contains('pay')) {
      return const Color(0xFFF59E0B); // Amber
    } else if (lower.contains('sale') || lower.contains('deal') || lower.contains('revenue')) {
      return const Color(0xFF3B82F6); // Blue
    } else if (lower.contains('support') || lower.contains('it') || lower.contains('help')) {
      return const Color(0xFF06B6D4); // Cyan
    }
    return const Color(0xFF8B5CF6); // Default Purple
  }
}
