import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../role_permissions/models/role_permission_models.dart';
import '../../projects/controllers/projects_controller.dart';
import '../models/asset_model.dart';

class AssetsController extends GetxController {
  // Main reactive assets list
  final RxList<AssetModel> assets = <AssetModel>[].obs;

  // Search & Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryTab = 'All'.obs; // All, Laptop, Mobile, Accessories, Others

  // Selected Asset for details view
  final Rxn<AssetModel> selectedAsset = Rxn<AssetModel>();

  // Add Asset Form observables/controllers
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final serialNumberController = TextEditingController();
  final purchaseCostController = TextEditingController();
  
  final RxString selectedCategory = 'Laptop'.obs;
  final RxString selectedType = 'IT Equipment'.obs;
  final Rx<DateTime> purchaseDate = DateTime(2024, 5, 15).obs;
  final RxString selectedImage = ''.obs;

  // Assign Asset Form observables/controllers
  final Rxn<AssetModel> selectedAssetToAssign = Rxn<AssetModel>();
  final Rxn<AppUser> selectedEmployeeToAssign = Rxn<AppUser>();
  final Rx<DateTime> assignDate = DateTime(2024, 5, 15).obs;
  final Rxn<DateTime> expectedReturnDate = Rxn<DateTime>();
  final notesController = TextEditingController();

  // Selected Asset Details Tab Index
  final RxInt selectedDetailsTabIdx = 0.obs;

  // Helper to safely fetch system employees
  List<AppUser> get allEmployees {
    try {
      if (Get.isRegistered<ProjectsController>()) {
        return Get.find<ProjectsController>().allEmployees;
      }
    } catch (_) {}
    return const [
      AppUser(name: 'John Smith', email: 'john.smith@example.com', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150'),
      AppUser(name: 'Sarah Johnson', email: 'sarah.johnson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
      AppUser(name: 'Michael Brown', email: 'michael.brown@example.com', avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150'),
      AppUser(name: 'David Wilson', email: 'david.wilson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'),
      AppUser(name: 'Emily Davis', email: 'emily.davis@example.com', avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150'),
      AppUser(name: 'James Anderson', email: 'james.anderson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1463453091185-61582044d556?w=150'),
      AppUser(name: 'Alex Johnson', email: 'alex.johnson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150'),
      AppUser(name: 'Lisa Anderson', email: 'lisa.anderson@example.com', avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
      AppUser(name: 'Robert Taylor', email: 'robert.taylor@example.com', avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150'),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    _initializeDummyAssets();
  }

  // Initial stats indicators
  int get totalAssetsCount => assets.length;
  int get assignedAssetsCount => assets.where((a) => a.status == 'Assigned').length;
  int get availableAssetsCount => assets.where((a) => a.status == 'Available').length;
  int get maintenanceAssetsCount => assets.where((a) => a.status == 'Maintenance').length;

  // Reactive filtered assets list
  List<AssetModel> get filteredAssets {
    var list = assets.toList();

    // 1. Filter by category tab
    if (selectedCategoryTab.value != 'All') {
      list = list.where((a) => a.category.toLowerCase() == selectedCategoryTab.value.toLowerCase()).toList();
    }

    // 2. Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((a) => 
        a.name.toLowerCase().contains(q) || 
        a.serialNumber.toLowerCase().contains(q) ||
        a.brand.toLowerCase().contains(q) ||
        (a.assignedTo?.name.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    return list;
  }

  void _initializeDummyAssets() {
    final employees = allEmployees;
    assets.assignAll([
      AssetModel(
        id: 'ast1',
        name: 'MacBook Pro 14"',
        category: 'Laptop',
        type: 'IT Equipment',
        brand: 'Apple',
        model: 'MacBook Pro 14-inch',
        serialNumber: 'SN: MBP14-2024-001',
        purchaseDate: DateTime(2024, 1, 10),
        purchaseCost: 165000.0,
        imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=150',
        status: 'Assigned',
        assignedTo: employees.isNotEmpty ? employees[0] : null, // John Smith
        assignedDate: DateTime(2024, 5, 15),
        expectedReturnDate: DateTime(2025, 5, 15),
        notes: 'Assigned to the Lead UI/UX Designer.',
        history: [
          AssetHistoryLog(id: 'h1_1', title: 'Asset assigned to John Smith', timestamp: DateTime(2024, 5, 15, 10, 30), type: 'assigned'),
          AssetHistoryLog(id: 'h1_2', title: 'Maintenance scheduled', timestamp: DateTime(2024, 4, 1, 11, 00), type: 'maintenance'),
          AssetHistoryLog(id: 'h1_3', title: 'Asset added to inventory', timestamp: DateTime(2024, 1, 10, 9, 15), type: 'added'),
        ],
        maintenanceList: [
          AssetMaintenanceLog(id: 'm1_1', issue: 'Keyboard replacement & internal cleanup', dateScheduled: DateTime(2024, 4, 1), status: 'Completed'),
        ],
        files: ['Invoice_MBP_2024.pdf', 'Warranty_Card.pdf'],
      ),
      AssetModel(
        id: 'ast2',
        name: 'iPhone 15 Pro',
        category: 'Mobile',
        type: 'Mobile Phone',
        brand: 'Apple',
        model: 'iPhone 15 Pro Max',
        serialNumber: 'SN: IP15P-2024-042',
        purchaseDate: DateTime(2024, 2, 20),
        purchaseCost: 134000.0,
        imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=150',
        status: 'Assigned',
        assignedTo: employees.length > 1 ? employees[1] : null, // Sarah Johnson
        assignedDate: DateTime(2024, 3, 10),
        expectedReturnDate: DateTime(2025, 3, 10),
        notes: 'Assigned to Marketing Executive for social media handles.',
        history: [
          AssetHistoryLog(id: 'h2_1', title: 'Asset assigned to Sarah Johnson', timestamp: DateTime(2024, 3, 10, 14, 0), type: 'assigned'),
          AssetHistoryLog(id: 'h2_2', title: 'Asset added to inventory', timestamp: DateTime(2024, 2, 20, 10, 30), type: 'added'),
        ],
        maintenanceList: [],
        files: ['Invoice_IP15P.pdf'],
      ),
      AssetModel(
        id: 'ast3',
        name: 'Sony WH-1000XM5',
        category: 'Accessories',
        type: 'Headphone',
        brand: 'Sony',
        model: 'WH-1000XM5 ANC Headset',
        serialNumber: 'SN: SONY-2024-021',
        purchaseDate: DateTime(2024, 3, 05),
        purchaseCost: 29999.0,
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=150',
        status: 'Available',
        history: [
          AssetHistoryLog(id: 'h3_1', title: 'Asset returned to inventory', timestamp: DateTime(2024, 5, 01, 17, 0), type: 'returned'),
          AssetHistoryLog(id: 'h3_2', title: 'Asset added to inventory', timestamp: DateTime(2024, 3, 05, 11, 45), type: 'added'),
        ],
        maintenanceList: [],
        files: [],
      ),
      AssetModel(
        id: 'ast4',
        name: 'Dell 24" Monitor',
        category: 'Others',
        type: 'Monitor',
        brand: 'Dell',
        model: 'P2422H 24-inch Monitor',
        serialNumber: 'SN: DELL-2024-017',
        purchaseDate: DateTime(2023, 11, 15),
        purchaseCost: 15499.0,
        imageUrl: 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=150',
        status: 'Maintenance',
        history: [
          AssetHistoryLog(id: 'h4_1', title: 'Scheduled for display servicing', timestamp: DateTime(2024, 5, 02, 11, 0), type: 'maintenance'),
          AssetHistoryLog(id: 'h4_2', title: 'Asset added to inventory', timestamp: DateTime(2023, 11, 15, 15, 00), type: 'added'),
        ],
        maintenanceList: [
          AssetMaintenanceLog(id: 'm4_1', issue: 'Backlight flicker inspection', dateScheduled: DateTime(2024, 5, 12), status: 'Scheduled'),
        ],
        files: [],
      ),
    ]);
  }

  // Populate Add Asset Screen form
  void resetAddAssetForm() {
    nameController.clear();
    brandController.clear();
    modelController.clear();
    serialNumberController.clear();
    purchaseCostController.clear();
    selectedCategory.value = 'Laptop';
    selectedType.value = 'IT Equipment';
    purchaseDate.value = DateTime.now();
    selectedImage.value = '';
  }

  // Save new asset to list
  void addAsset() {
    if (nameController.text.trim().isEmpty || serialNumberController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Failed',
        'Asset Name and Serial Number are required fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final newAsset = AssetModel(
      id: 'ast_${DateTime.now().millisecondsSinceEpoch}',
      name: nameController.text.trim(),
      category: selectedCategory.value,
      type: selectedType.value,
      brand: brandController.text.trim().isNotEmpty ? brandController.text.trim() : 'Generic',
      model: modelController.text.trim().isNotEmpty ? modelController.text.trim() : 'Standard',
      serialNumber: serialNumberController.text.trim(),
      purchaseDate: purchaseDate.value,
      purchaseCost: double.tryParse(purchaseCostController.text) ?? 0.0,
      imageUrl: selectedImage.value.isNotEmpty ? selectedImage.value : null,
      status: 'Available',
      history: [
        AssetHistoryLog(
          id: 'h_add_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Asset added to inventory',
          timestamp: DateTime.now(),
          type: 'added',
        )
      ],
      maintenanceList: [],
      files: [],
    );

    assets.insert(0, newAsset);
    resetAddAssetForm();
    Get.back();
    Get.snackbar(
      'Success',
      'New asset added successfully to inventory!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // Populate Assign Form fields
  void prepareAssignForm(AssetModel? asset) {
    selectedAssetToAssign.value = asset;
    selectedEmployeeToAssign.value = allEmployees.isNotEmpty ? allEmployees[0] : null;
    assignDate.value = DateTime.now();
    expectedReturnDate.value = DateTime.now().add(const Duration(days: 365));
    notesController.clear();
  }

  // Assign resource
  void assignAsset() {
    final asset = selectedAssetToAssign.value;
    final employee = selectedEmployeeToAssign.value;

    if (asset == null || employee == null) {
      Get.snackbar(
        'Validation Failed',
        'Please select both an asset and an assignee.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final index = assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      final updated = assets[index].copyWith(
        status: 'Assigned',
        assignedTo: employee,
        assignedDate: assignDate.value,
        expectedReturnDate: expectedReturnDate.value,
        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
        history: [
          AssetHistoryLog(
            id: 'h_asgn_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Asset assigned to ${employee.name}',
            timestamp: DateTime.now(),
            type: 'assigned',
          ),
          ...assets[index].history,
        ],
      );

      assets[index] = updated;
      
      // Update selectedAsset if in details view
      if (selectedAsset.value?.id == asset.id) {
        selectedAsset.value = updated;
      }
      
      Get.back();
      Get.snackbar(
        'Resource Allocated',
        '${asset.name} has been assigned to ${employee.name}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4F46E5),
        colorText: Colors.white,
      );
    }
  }

  // Return resource
  void markAsReturned(String assetId) {
    final index = assets.indexWhere((a) => a.id == assetId);
    if (index != -1) {
      final employeeName = assets[index].assignedTo?.name ?? 'employee';
      final updated = assets[index].copyWith(
        status: 'Available',
        assignedTo: null,
        assignedDate: null,
        expectedReturnDate: null,
        notes: null,
        history: [
          AssetHistoryLog(
            id: 'h_ret_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Asset returned by $employeeName',
            timestamp: DateTime.now(),
            type: 'returned',
          ),
          ...assets[index].history,
        ],
      );

      assets[index] = updated;
      
      if (selectedAsset.value?.id == assetId) {
        selectedAsset.value = updated;
      }

      Get.snackbar(
        'Asset Returned',
        'Asset inventory status set back to Available.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    }
  }

  // Report Damage / Set to Maintenance
  void reportDamage(String assetId) {
    final index = assets.indexWhere((a) => a.id == assetId);
    if (index != -1) {
      final currentLogs = assets[index].maintenanceList;
      final newMaintenanceLog = AssetMaintenanceLog(
        id: 'm_dmg_${DateTime.now().millisecondsSinceEpoch}',
        issue: 'Damage reported. Pending repair evaluation.',
        dateScheduled: DateTime.now(),
        status: 'Scheduled',
      );

      final updated = assets[index].copyWith(
        status: 'Maintenance',
        assignedTo: null,
        assignedDate: null,
        expectedReturnDate: null,
        notes: null,
        history: [
          AssetHistoryLog(
            id: 'h_maint_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Damage reported & maintenance scheduled',
            timestamp: DateTime.now(),
            type: 'maintenance',
          ),
          ...assets[index].history,
        ],
        maintenanceList: [newMaintenanceLog, ...currentLogs],
      );

      assets[index] = updated;
      
      if (selectedAsset.value?.id == assetId) {
        selectedAsset.value = updated;
      }

      Get.snackbar(
        'Damage Reported',
        'Asset moved to Maintenance list.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
}
