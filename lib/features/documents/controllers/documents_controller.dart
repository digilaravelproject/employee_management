import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/document_model.dart';

class DocumentsController extends GetxController {
  // Flag to toggle between Admin View and Employee View dynamically for review/demo purposes
  final RxBool isAdminView = true.obs;

  // Search and filter query
  final RxString searchQuery = ''.obs;

  // Selected folder for filter details
  final Rxn<DocumentFolder> selectedFolder = Rxn<DocumentFolder>();

  // Folder Lists (Admin vs Employee)
  final RxList<DocumentFolder> adminFolders = <DocumentFolder>[].obs;
  final RxList<DocumentFolder> employeeFolders = <DocumentFolder>[].obs;

  // Document Lists
  final RxList<AppDocument> adminDocuments = <AppDocument>[].obs;
  final RxList<AppDocument> employeeDocuments = <AppDocument>[].obs;
  final RxList<AppDocument> sharedDocuments = <AppDocument>[].obs;

  // Access lists (specifically for the clicked document, e.g. Company Policy.pdf)
  final RxList<DocumentAccess> activeAccessList = <DocumentAccess>[].obs;

  // Version lists
  final RxList<DocumentVersion> versionsList = <DocumentVersion>[].obs;

  // Activity list
  final RxList<DocumentActivity> activityList = <DocumentActivity>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  void toggleRoleView() {
    isAdminView.value = !isAdminView.value;
    selectedFolder.value = null; // Clear active folder when switching modes
    Get.snackbar(
      'View Switched',
      'Showing ${isAdminView.value ? "Admin" : "Employee"} Side Document screens',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isAdminView.value ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void selectFolder(DocumentFolder? folder) {
    selectedFolder.value = folder;
  }

  // Action methods
  void addFolder(String name) {
    if (name.trim().isEmpty) return;
    final newFolder = DocumentFolder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      fileCount: 0,
    );

    if (isAdminView.value) {
      adminFolders.insert(0, newFolder);
    } else {
      employeeFolders.insert(0, newFolder);
    }

    Get.snackbar(
      'Folder Created',
      'Folder "$name" was successfully created.',
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
    );
  }

  void uploadFile(String name, String type, String folderName, String status) {
    if (name.trim().isEmpty) return;
    
    // Add extension if not present
    var finalName = name.trim();
    if (!finalName.toLowerCase().endsWith('.$type')) {
      finalName = '$finalName.$type';
    }

    final newDoc = AppDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: finalName,
      type: type,
      size: '1.2 MB',
      folderName: folderName,
      uploadedBy: isAdminView.value ? 'Admin' : 'Neha Kapoor',
      uploadedDate: 'Today',
      lastModified: 'Today',
      status: status,
      filePath: '',
      description: 'Newly uploaded file in folder $folderName.',
    );

    if (isAdminView.value) {
      adminDocuments.insert(0, newDoc);
      // Increment file count in corresponding folder
      final folderIdx = adminFolders.indexWhere((f) => f.name == folderName);
      if (folderIdx != -1) {
        adminFolders[folderIdx] = adminFolders[folderIdx].copyWith(
          fileCount: adminFolders[folderIdx].fileCount + 1,
        );
      }
    } else {
      employeeDocuments.insert(0, newDoc);
      final folderIdx = employeeFolders.indexWhere((f) => f.name == folderName);
      if (folderIdx != -1) {
        employeeFolders[folderIdx] = employeeFolders[folderIdx].copyWith(
          fileCount: employeeFolders[folderIdx].fileCount + 1,
        );
      }
    }

    Get.snackbar(
      'File Uploaded',
      'File "$finalName" uploaded successfully under $folderName.',
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
    );
  }

  void deleteDocument(AppDocument doc) {
    if (isAdminView.value) {
      adminDocuments.removeWhere((d) => d.id == doc.id);
      final folderIdx = adminFolders.indexWhere((f) => f.name == doc.folderName);
      if (folderIdx != -1 && adminFolders[folderIdx].fileCount > 0) {
        adminFolders[folderIdx] = adminFolders[folderIdx].copyWith(
          fileCount: adminFolders[folderIdx].fileCount - 1,
        );
      }
    } else {
      employeeDocuments.removeWhere((d) => d.id == doc.id);
      final folderIdx = employeeFolders.indexWhere((f) => f.name == doc.folderName);
      if (folderIdx != -1 && employeeFolders[folderIdx].fileCount > 0) {
        employeeFolders[folderIdx] = employeeFolders[folderIdx].copyWith(
          fileCount: employeeFolders[folderIdx].fileCount - 1,
        );
      }
    }

    Get.snackbar(
      'Document Deleted',
      'Moved "${doc.name}" to Recycle Bin.',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  // Access Control logic
  void updateAccessRole(String accessId, String newRole) {
    final idx = activeAccessList.indexWhere((a) => a.id == accessId);
    if (idx != -1) {
      activeAccessList[idx] = activeAccessList[idx].copyWith(role: newRole);
      activeAccessList.refresh();
      Get.snackbar(
        'Access Updated',
        'Updated permission to $newRole for ${activeAccessList[idx].name}.',
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void revokeAccess(String accessId) {
    final item = activeAccessList.firstWhere((a) => a.id == accessId);
    activeAccessList.removeWhere((a) => a.id == accessId);
    Get.snackbar(
      'Access Revoked',
      'Removed access permission for ${item.name}.',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  void grantNewAccess(String name, String type, String role) {
    final newAccess = DocumentAccess(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      details: type == 'Group' ? '15 Members' : '${name.toLowerCase().replaceAll(' ', '')}@example.com',
      role: role,
      type: type,
    );
    activeAccessList.add(newAccess);
    Get.snackbar(
      'Access Granted',
      'Granted $role access to $name.',
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
    );
  }

  // Filter helper lists based on search query
  List<DocumentFolder> get filteredFolders {
    final query = searchQuery.value.toLowerCase().trim();
    final source = isAdminView.value ? adminFolders : employeeFolders;
    if (query.isEmpty) return source;
    return source.where((f) => f.name.toLowerCase().contains(query)).toList();
  }

  List<AppDocument> get filteredDocuments {
    final query = searchQuery.value.toLowerCase().trim();
    final source = isAdminView.value ? adminDocuments : employeeDocuments;
    
    List<AppDocument> list = source;
    if (selectedFolder.value != null) {
      list = list.where((d) => d.folderName == selectedFolder.value!.name).toList();
    }
    
    if (query.isEmpty) return list;
    return list.where((d) => d.name.toLowerCase().contains(query) || d.folderName.toLowerCase().contains(query)).toList();
  }

  void _initializeData() {
    // Populate folders for ADMIN Side
    adminFolders.addAll([
      DocumentFolder(id: 'a1', name: 'HR Documents', fileCount: 256),
      DocumentFolder(id: 'a2', name: 'Employee Documents', fileCount: 412),
      DocumentFolder(id: 'a3', name: 'Projects', fileCount: 628),
      DocumentFolder(id: 'a4', name: 'Policies', fileCount: 78),
      DocumentFolder(id: 'a5', name: 'Payroll', fileCount: 215),
      DocumentFolder(id: 'a6', name: 'Invoices', fileCount: 166),
      DocumentFolder(id: 'a7', name: 'Legal', fileCount: 94),
      DocumentFolder(id: 'a8', name: 'Assets', fileCount: 102),
    ]);

    // Populate folders for EMPLOYEE Side
    employeeFolders.addAll([
      DocumentFolder(id: 'e1', name: 'My Documents', fileCount: 12),
      DocumentFolder(id: 'e2', name: 'Salary Slips', fileCount: 24),
      DocumentFolder(id: 'e3', name: 'Certificates', fileCount: 6),
      DocumentFolder(id: 'e4', name: 'HR Letters', fileCount: 8),
    ]);

    // Populate Admin documents
    adminDocuments.addAll([
      AppDocument(
        id: 'ad1',
        name: 'Company Policy.pdf',
        type: 'pdf',
        size: '2.4 MB',
        folderName: 'Policies',
        uploadedBy: 'Admin',
        uploadedDate: '20 May 2024, 10:30 AM',
        lastModified: '22 May 2024, 03:15 PM',
        status: 'Public',
        filePath: '',
        description: 'Standard company rules and regulatory compliance guidelines governing all employees.',
      ),
      AppDocument(
        id: 'ad2',
        name: 'Salary Structure.xlsx',
        type: 'xlsx',
        size: '1.2 MB',
        folderName: 'HR Documents',
        uploadedBy: 'HR Manager',
        uploadedDate: '19 May 2024, 11:20 AM',
        lastModified: '19 May 2024, 11:20 AM',
        status: 'HR Only',
        filePath: '',
        description: 'Complete breakdown of internal salary structure slabs and allowances structure for FY 24-25.',
      ),
      AppDocument(
        id: 'ad3',
        name: 'Project Proposal.pdf',
        type: 'pdf',
        size: '4.8 MB',
        folderName: 'Projects',
        uploadedBy: 'Project Manager',
        uploadedDate: '18 May 2024, 04:45 PM',
        lastModified: '20 May 2024, 02:30 PM',
        status: 'Team',
        filePath: '',
        description: 'Approved commercial bid and architecture diagram proposal document for client TechSolutions.',
      ),
      AppDocument(
        id: 'ad4',
        name: 'Employee Handbook.docx',
        type: 'docx',
        size: '3.1 MB',
        folderName: 'HR Documents',
        uploadedBy: 'HR Admin',
        uploadedDate: '17 May 2024, 09:15 AM',
        lastModified: '17 May 2024, 09:15 AM',
        status: 'Public',
        filePath: '',
        description: 'Onboarding guide outlining company values, processes, structures, and work guidelines.',
      ),
    ]);

    // Populate Employee documents
    employeeDocuments.addAll([
      AppDocument(
        id: 'ed1',
        name: 'Offer Letter.pdf',
        type: 'pdf',
        size: '1.5 MB',
        folderName: 'HR Letters',
        uploadedBy: 'HR Department',
        uploadedDate: '20 May 2024',
        lastModified: '20 May 2024',
        status: 'HR Only',
        filePath: '',
        description: 'Official employment offer letter issued by Tech Solutions Pvt. Ltd.',
      ),
      AppDocument(
        id: 'ed2',
        name: 'Salary Slip - May 2024.pdf',
        type: 'pdf',
        size: '850 KB',
        folderName: 'Salary Slips',
        uploadedBy: 'Payroll Team',
        uploadedDate: '19 May 2024',
        lastModified: '19 May 2024',
        status: 'HR Only',
        filePath: '',
        description: 'Monthly payroll earnings, allowances and tax deductions statement for May 2024.',
      ),
      AppDocument(
        id: 'ed3',
        name: 'ID Card.pdf',
        type: 'pdf',
        size: '600 KB',
        folderName: 'My Documents',
        uploadedBy: 'Security Dept',
        uploadedDate: '18 May 2024',
        lastModified: '18 May 2024',
        status: 'Public',
        filePath: '',
        description: 'Digital copy of the secure employee corporate identification card badge.',
      ),
    ]);

    // Populate Shared documents (Employee View)
    sharedDocuments.addAll([
      AppDocument(
        id: 'sd1',
        name: 'Project Proposal.pdf',
        type: 'pdf',
        size: '4.8 MB',
        folderName: 'Shared',
        uploadedBy: 'Amit Singh',
        uploadedDate: '20 May 2024',
        lastModified: '20 May 2024',
        status: 'Team',
        filePath: '',
        description: 'Commercial proposal for project review.',
      ),
      AppDocument(
        id: 'sd2',
        name: 'Design Mockups.zip',
        type: 'zip',
        size: '22 MB',
        folderName: 'Shared',
        uploadedBy: 'Neha Kapoor',
        uploadedDate: '17 May 2024',
        lastModified: '17 May 2024',
        status: 'Team',
        filePath: '',
        description: 'High-fidelity Figma mockups and image exports bundle.',
      ),
      AppDocument(
        id: 'sd3',
        name: 'Meeting Notes.docx',
        type: 'docx',
        size: '1.2 MB',
        folderName: 'Shared',
        uploadedBy: 'Vikas Yadav',
        uploadedDate: '16 May 2024',
        lastModified: '16 May 2024',
        status: 'Public',
        filePath: '',
        description: 'Minutes and action items from product sync with engineers.',
      ),
      AppDocument(
        id: 'sd4',
        name: 'Employee Handbook.pdf',
        type: 'pdf',
        size: '3.1 MB',
        folderName: 'Shared',
        uploadedBy: 'HR Team',
        uploadedDate: '15 May 2024',
        lastModified: '15 May 2024',
        status: 'Public',
        filePath: '',
        description: 'Corporate handbook guidelines.',
      ),
    ]);

    // Populate Access Control (for Company Policy.pdf)
    activeAccessList.addAll([
      DocumentAccess(id: 'ac1', name: 'All Employees', details: '120 Employees', role: 'Viewer', type: 'Group'),
      DocumentAccess(id: 'ac2', name: 'HR Department', details: '12 Members', role: 'Editor', type: 'Department'),
      DocumentAccess(id: 'ac3', name: 'Management Team', details: '8 Members', role: 'Viewer', type: 'Group'),
      DocumentAccess(id: 'ac4', name: 'Rahul Sharma', details: 'rahul@example.com', role: 'Viewer', type: 'Individual'),
      DocumentAccess(id: 'ac5', name: 'Neha Kapoor', details: 'neha@example.com', role: 'Editor', type: 'Individual'),
    ]);

    // Populate Version list
    versionsList.addAll([
      DocumentVersion(version: 'v1.2', updatedDate: '22 May 2024, 03:15 PM', updatedBy: 'Admin', changeLog: 'Updated regulatory provisions clause regarding remote working policy.'),
      DocumentVersion(version: 'v1.1', updatedDate: '21 May 2024, 01:10 PM', updatedBy: 'HR Admin', changeLog: 'Fixed minor spelling corrections in leaves criteria section.'),
      DocumentVersion(version: 'v1.0', updatedDate: '20 May 2024, 10:30 AM', updatedBy: 'Admin', changeLog: 'Initial release document publication.'),
    ]);

    // Populate Activity Logs
    activityList.addAll([
      DocumentActivity(id: 'act1', activity: 'Document Shared', user: 'Neha Kapoor', timestamp: '22 May 2024, 04:30 PM', iconType: 'share'),
      DocumentActivity(id: 'act2', activity: 'Document Version v1.2 Uploaded', user: 'Admin', timestamp: '22 May 2024, 03:15 PM', iconType: 'update'),
      DocumentActivity(id: 'act3', activity: 'Downloaded Document', user: 'Rahul Sharma', timestamp: '21 May 2024, 11:45 AM', iconType: 'download'),
      DocumentActivity(id: 'act4', activity: 'Viewed Document Details', user: 'Neha Kapoor', timestamp: '20 May 2024, 02:00 PM', iconType: 'view'),
    ]);
  }
}
