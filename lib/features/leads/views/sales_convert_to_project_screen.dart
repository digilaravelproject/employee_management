import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../employee/management/models/employee_model.dart';
import '../../projects/controllers/projects_controller.dart';
import '../../projects/models/create_project_model.dart';
import '../../projects/views/project_details_screen.dart';
import 'sales_executive_tele_crm_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 📁 CLIENT HANDOVER ATTACHMENT MODEL
// ─────────────────────────────────────────────────────────────────────────────
class HandoverAttachmentItem {
  final String fileName;
  final String filePath;
  final int fileSize;
  final String categoryTag; // BRD / Brief, Proposal, Contract, Advance Receipt, Assets, Other
  final String extension;

  HandoverAttachmentItem({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.categoryTag,
    required this.extension,
  });

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'filePath': filePath,
        'fileSize': fileSize,
        'categoryTag': categoryTag,
        'extension': extension,
      };

  factory HandoverAttachmentItem.fromJson(Map<String, dynamic> json) => HandoverAttachmentItem(
        fileName: json['fileName'] ?? '',
        filePath: json['filePath'] ?? '',
        fileSize: json['fileSize'] is int ? json['fileSize'] : 0,
        categoryTag: json['categoryTag'] ?? 'Document',
        extension: json['extension'] ?? '',
      );

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🚀 LEAD PROJECT HANDOVER MODEL & PERSISTENCE
// ─────────────────────────────────────────────────────────────────────────────
class LeadProjectHandoverModel {
  final int leadId;
  final String leadCode;
  final String projectName;
  final String clientName;
  final String category;
  final double agreedBudget;
  final double advanceReceived;
  final String paymentMode;
  final int durationDays;
  final DateTime startDate;
  final DateTime targetEndDate;
  final String scopeOfWork;
  final String clientInstructions;
  final List<HandoverAttachmentItem> attachments;
  final List<String> assignedEmployeeIds;
  final List<String> assignedEmployeeNames;
  final String priority;
  final String? createdProjectId;
  final DateTime createdAt;

  LeadProjectHandoverModel({
    required this.leadId,
    required this.leadCode,
    required this.projectName,
    required this.clientName,
    required this.category,
    required this.agreedBudget,
    required this.advanceReceived,
    required this.paymentMode,
    required this.durationDays,
    required this.startDate,
    required this.targetEndDate,
    required this.scopeOfWork,
    this.clientInstructions = '',
    required this.attachments,
    this.assignedEmployeeIds = const [],
    this.assignedEmployeeNames = const [],
    this.priority = 'Standard',
    this.createdProjectId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'leadId': leadId,
        'leadCode': leadCode,
        'projectName': projectName,
        'clientName': clientName,
        'category': category,
        'agreedBudget': agreedBudget,
        'advanceReceived': advanceReceived,
        'paymentMode': paymentMode,
        'durationDays': durationDays,
        'startDate': startDate.toIso8601String(),
        'targetEndDate': targetEndDate.toIso8601String(),
        'scopeOfWork': scopeOfWork,
        'clientInstructions': clientInstructions,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'assignedEmployeeIds': assignedEmployeeIds,
        'assignedEmployeeNames': assignedEmployeeNames,
        'priority': priority,
        'createdProjectId': createdProjectId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LeadProjectHandoverModel.fromJson(Map<String, dynamic> json) => LeadProjectHandoverModel(
        leadId: json['leadId'] is int ? json['leadId'] : int.tryParse(json['leadId']?.toString() ?? '') ?? 0,
        leadCode: json['leadCode'] ?? '',
        projectName: json['projectName'] ?? 'Project',
        clientName: json['clientName'] ?? '',
        category: json['category'] ?? 'Web Development',
        agreedBudget: (json['agreedBudget'] as num?)?.toDouble() ?? 0.0,
        advanceReceived: (json['advanceReceived'] as num?)?.toDouble() ?? 0.0,
        paymentMode: json['paymentMode'] ?? 'Bank Transfer',
        durationDays: json['durationDays'] is int ? json['durationDays'] : 30,
        startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
        targetEndDate: DateTime.tryParse(json['targetEndDate']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 30)),
        scopeOfWork: json['scopeOfWork'] ?? '',
        clientInstructions: json['clientInstructions'] ?? '',
        attachments: (json['attachments'] as List<dynamic>?)
                ?.map((a) => HandoverAttachmentItem.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
        assignedEmployeeIds: (json['assignedEmployeeIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        assignedEmployeeNames: (json['assignedEmployeeNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        priority: json['priority'] ?? 'Standard',
        createdProjectId: json['createdProjectId']?.toString(),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

class LeadProjectHandoverManager {
  static const String _storageKey = 'employee_lead_project_handovers_v1';
  static final RxMap<int, LeadProjectHandoverModel> handovers = <int, LeadProjectHandoverModel>{}.obs;
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    loadHandovers();
  }

  static void loadHandovers() {
    try {
      final jsonStr = SharedPrefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map<String, dynamic>) {
          final Map<int, LeadProjectHandoverModel> map = {};
          decoded.forEach((key, val) {
            final id = int.tryParse(key);
            if (id != null && val is Map<String, dynamic>) {
              map[id] = LeadProjectHandoverModel.fromJson(val);
            }
          });
          handovers.assignAll(map);
        }
      }
    } catch (_) {}
  }

  static Future<void> saveHandover(LeadProjectHandoverModel handover) async {
    handovers[handover.leadId] = handover;
    try {
      final mapToSave = <String, dynamic>{};
      handovers.forEach((id, h) {
        mapToSave[id.toString()] = h.toJson();
      });
      await SharedPrefs.setString(_storageKey, jsonEncode(mapToSave));
    } catch (_) {}
  }

  static LeadProjectHandoverModel? getHandover(int leadId) => handovers[leadId];

  static bool hasProject(int leadId) => handovers.containsKey(leadId);
}

// ─────────────────────────────────────────────────────────────────────────────
// 🚀 SALES CONVERT TO PROJECT SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class SalesConvertToProjectScreen extends StatefulWidget {
  final TeleCrmLeadItem lead;
  final VoidCallback? onProjectCreated;

  const SalesConvertToProjectScreen({
    super.key,
    required this.lead,
    this.onProjectCreated,
  });

  @override
  State<SalesConvertToProjectScreen> createState() => _SalesConvertToProjectScreenState();
}

class _SalesConvertToProjectScreenState extends State<SalesConvertToProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  late final TextEditingController _projectNameController;
  late final TextEditingController _budgetController;
  late final TextEditingController _advanceController;
  late final TextEditingController _scopeController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _paymentRefController;

  // Domain & Category
  String _selectedCategory = 'Web Development';
  final List<String> _categories = [
    'Web Development',
    'Mobile App (Android/iOS)',
    'UI/UX Design',
    'E-Commerce Store',
    'Custom ERP / CRM',
    'Digital Marketing & SEO',
    'Enterprise Solution',
    'Graphic & Branding',
  ];

  // Timeline
  int _durationDays = 30;
  DateTime _startDate = DateTime.now();
  late DateTime _targetEndDate;

  // Financials
  String _paymentMode = 'UPI / Online';
  final List<String> _paymentModes = ['UPI / Online', 'Bank Transfer (NEFT/IMPS)', 'Cheque', 'Cash'];

  // Priority
  String _priority = 'Standard'; // Standard, High Priority, Urgent ⚡

  // Attachments
  final List<HandoverAttachmentItem> _attachments = [];

  // Team Assignment
  final List<EmployeeModel> _selectedEmployees = [];
  bool _isLoadingEmployees = false;
  List<EmployeeModel> _availableEmployees = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    LeadProjectHandoverManager.init();

    _targetEndDate = _startDate.add(Duration(days: _durationDays));

    // Smart pre-fill
    final req = widget.lead.requirement.trim();
    final cleanReq = (req.isNotEmpty && req != 'N/A') ? req : 'Project Handover';
    _projectNameController = TextEditingController(text: '${widget.lead.customerName} - $cleanReq');

    final budgetVal = widget.lead.potentialValue > 0 ? widget.lead.potentialValue.toStringAsFixed(0) : '50000';
    _budgetController = TextEditingController(text: budgetVal);

    // Initial 20% advance token calculation suggestion
    final suggestedAdvance = (widget.lead.potentialValue * 0.20).clamp(0, double.infinity);
    _advanceController = TextEditingController(
      text: suggestedAdvance > 0 ? suggestedAdvance.toStringAsFixed(0) : '10000',
    );

    _scopeController = TextEditingController(
      text: widget.lead.lastCallNote.isNotEmpty
          ? 'Client Requirement: $cleanReq\nDiscussion Notes: ${widget.lead.lastCallNote}'
          : 'Client Requirement: $cleanReq\nDeliverables discussed during lead conversion.',
    );
    _instructionsController = TextEditingController();
    _paymentRefController = TextEditingController();

    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoadingEmployees = true);
    try {
      final projectsCtrl = Get.isRegistered<ProjectsController>()
          ? Get.find<ProjectsController>()
          : Get.put(ProjectsController());

      if (projectsCtrl.employeesList.isNotEmpty) {
        _availableEmployees = projectsCtrl.employeesList;
      } else {
        await projectsCtrl.fetchEmployees();
        _availableEmployees = projectsCtrl.employeesList;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingEmployees = false);
    }
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _budgetController.dispose();
    _advanceController.dispose();
    _scopeController.dispose();
    _instructionsController.dispose();
    _paymentRefController.dispose();
    super.dispose();
  }

  void _updateDuration(int days) {
    setState(() {
      _durationDays = days;
      _targetEndDate = _startDate.add(Duration(days: days));
    });
  }

  Future<void> _pickAttachment(String categoryTag) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg', 'xls', 'xlsx', 'zip', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (final f in result.files) {
            if (f.path != null && f.path!.isNotEmpty) {
              _attachments.add(
                HandoverAttachmentItem(
                  fileName: f.name,
                  filePath: f.path!,
                  fileSize: f.size,
                  categoryTag: categoryTag,
                  extension: f.extension ?? '',
                ),
              );
            }
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        'Attachment Error',
        'Could not pick file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  void _showAddDocumentDialog() {
    String selectedTag = '📄 BRD / Requirement Brief';
    final tags = [
      '📄 BRD / Requirement Brief',
      '📝 Proposal & Quotation',
      '📑 Signed Agreement / Contract',
      '💳 Advance Payment Receipt',
      '🖼️ Brand Assets / Logo / References',
      '📁 Other Client Document',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AppText(
                    'Select Document Category',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  const SizedBox(height: 4),
                  const AppText(
                    'Tag the client file for clear handover to operations & PM',
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(height: 16),
                  ...tags.map((tag) {
                    final isSel = selectedTag == tag;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setSheetState(() => selectedTag = tag),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                              width: isSel ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    color: isSel ? const Color(0xFF1D4ED8) : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                              if (isSel) const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _pickAttachment(selectedTag);
                      },
                      icon: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 18),
                      label: const Text('Browse & Upload File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitProjectHandover() async {
    if (!_formKey.currentState!.validate()) return;

    final projectName = _projectNameController.text.trim();
    final budget = double.tryParse(_budgetController.text.trim()) ?? widget.lead.potentialValue;
    final advance = double.tryParse(_advanceController.text.trim()) ?? 0.0;
    final scope = _scopeController.text.trim();
    final instructions = _instructionsController.text.trim();
    final paymentRef = _paymentRefController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      final projectsCtrl = Get.isRegistered<ProjectsController>()
          ? Get.find<ProjectsController>()
          : Get.put(ProjectsController());

      final sDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final eDateStr = DateFormat('yyyy-MM-dd').format(_targetEndDate);

      final empIds = _selectedEmployees.map((e) => e.id.toString()).toList();
      final filePaths = _attachments.map((a) => a.filePath).toList();

      final fullDescription = StringBuffer();
      fullDescription.writeln('🎯 Converted from Lead: ${widget.lead.customerName} (${widget.lead.id})');
      fullDescription.writeln('💰 Agreed Deal Value: ₹${budget.toStringAsFixed(0)} | Advance: ₹${advance.toStringAsFixed(0)} ($_paymentMode)');
      if (paymentRef.isNotEmpty) fullDescription.writeln('🧾 Ref: $paymentRef');
      fullDescription.writeln('⏱️ Estimated Delivery: $_durationDays Days (Target: $eDateStr)');
      fullDescription.writeln('\n📋 Scope of Work:\n$scope');
      if (instructions.isNotEmpty) fullDescription.writeln('\n📌 Client Notes:\n$instructions');

      final request = CreateProjectRequestModel(
        name: projectName,
        description: fullDescription.toString(),
        category: _selectedCategory,
        startDate: sDateStr,
        endDate: eDateStr,
        status: 'Not Started',
        progress: 0,
        employeeIds: empIds,
        filePaths: filePaths,
      );

      final response = await projectsCtrl.repository.createProject(request);

      String? createdProjectId;
      if (response.status && response.data != null) {
        createdProjectId = response.data!.id.toString();
        projectsCtrl.projects.insert(0, response.data!.toProject());
        projectsCtrl.fetchProjects(isRefresh: true);
      }

      // Save local Handover Record linked to this Lead
      final handover = LeadProjectHandoverModel(
        leadId: widget.lead.rawId,
        leadCode: widget.lead.id,
        projectName: projectName,
        clientName: widget.lead.customerName,
        category: _selectedCategory,
        agreedBudget: budget,
        advanceReceived: advance,
        paymentMode: _paymentMode,
        durationDays: _durationDays,
        startDate: _startDate,
        targetEndDate: _targetEndDate,
        scopeOfWork: scope,
        clientInstructions: instructions,
        attachments: _attachments,
        assignedEmployeeIds: empIds,
        assignedEmployeeNames: _selectedEmployees.map((e) => e.name).toList(),
        priority: _priority,
        createdProjectId: createdProjectId,
        createdAt: DateTime.now(),
      );

      await LeadProjectHandoverManager.saveHandover(handover);

      // Append Process step to timeline
      widget.lead.processSteps.insert(
        0,
        ExecLeadProcessStep(
          title: 'Project Handover Created 🚀',
          date: DateFormat('dd MMM yyyy').format(DateTime.now()),
          time: DateFormat('hh:mm a').format(DateTime.now()),
          note: 'Project "$projectName" created. Target delivery: $_durationDays days. ${_attachments.length} client documents attached.',
          performedBy: 'You',
          isCompleted: true,
        ),
      );

      setState(() => _isSubmitting = false);
      widget.onProjectCreated?.call();

      _showSuccessCelebration(handover, createdProjectId);
    } catch (e) {
      setState(() => _isSubmitting = false);
      Get.snackbar(
        'Submission Notice',
        'Project record saved locally. Server response: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD97706),
        colorText: Colors.white,
        borderRadius: 14,
      );
    }
  }

  void _showSuccessCelebration(LeadProjectHandoverModel handover, String? createdProjectId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF16A34A), size: 34),
                ),
                const SizedBox(height: 16),
                const AppText(
                  'Project Created Successfully! 🎉',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Project "${handover.projectName}" has been created and handed over with ${handover.attachments.length} attached documents.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Agreed Deal', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(
                            '₹${(handover.agreedBudget / 1000).toStringAsFixed(0)}k',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          const Text('Duration', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(
                            '${handover.durationDays} Days',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          const Text('Documents', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(
                            '${handover.attachments.length}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (createdProjectId != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx); // Close dialog
                        Navigator.pop(context); // Close convert screen
                        Get.to(() => ProjectDetailsScreen(projectId: createdProjectId));
                      },
                      icon: const Icon(Icons.folder_special_rounded, color: Colors.white, size: 18),
                      label: const Text('View Project in Projects Hub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back to Leads CRM', style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('Create Project from Lead', fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            Text(
              'Handover deal to operations • ${widget.lead.id}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Agreed Value', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                    Text(
                      '₹${_budgetController.text.isNotEmpty ? _budgetController.text : '0'}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      'Target: $_durationDays Days Delivery',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitProjectHandover,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                  label: Text(
                    _isSubmitting ? 'Creating Project...' : 'Create Project 🚀',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // ── HERO CLIENT DEAL CARD ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF86EFAC), size: 13),
                            const SizedBox(width: 5),
                            Text(
                              'Deal Won & Converted 🎉',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.lead.id,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE2E8F0)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Text(
                          widget.lead.customerName.isNotEmpty ? widget.lead.customerName[0].toUpperCase() : 'C',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.lead.customerName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.lead.phone} • ${widget.lead.city}',
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFFE0E7FF)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Deal Budget', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                            Text(
                              '₹${(widget.lead.potentialValue / 1000).toStringAsFixed(0)}k',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 1. PROJECT IDENTITY & DOMAIN ──
            _buildSectionHeader('1. Project Identity & Domain', Icons.business_center_rounded),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Project Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _projectNameController,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter project name' : null,
                    decoration: InputDecoration(
                      hintText: 'e.g. Acme Corp - E-Commerce App Development',
                      prefixIcon: const Icon(Icons.rocket_rounded, size: 18, color: Color(0xFF64748B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Domain / Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat);
                        },
                        selectedColor: AppColors.primaryColor,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  const Text('Project Priority', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Standard', 'High Priority', 'Urgent ⚡'].map((p) {
                      final isSel = _priority == p;
                      Color c = p.contains('Urgent')
                          ? const Color(0xFFDC2626)
                          : (p.contains('High') ? const Color(0xFFD97706) : const Color(0xFF2563EB));
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            onTap: () => setState(() => _priority = p),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel ? c.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSel ? c : const Color(0xFFE2E8F0), width: isSel ? 1.6 : 1),
                              ),
                              child: Center(
                                child: Text(
                                  p,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                    color: isSel ? c : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 2. TIMELINE & DURATION ("kitne din me complete karna hai") ──
            _buildSectionHeader('2. Delivery Timeline & Duration', Icons.timer_rounded),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Completion Target Presets', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildDurationChip(15, '15 Days (Sprint)'),
                      _buildDurationChip(30, '30 Days (1 Month)'),
                      _buildDurationChip(45, '45 Days (Standard)'),
                      _buildDurationChip(60, '60 Days (2 Months)'),
                      _buildDurationChip(90, '90 Days (Quarter)'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dates Pickers
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final p = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 7)),
                              lastDate: DateTime.now().add(const Duration(days: 730)),
                            );
                            if (p != null) {
                              setState(() {
                                _startDate = p;
                                _targetEndDate = _startDate.add(Duration(days: _durationDays));
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Start Date', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF2563EB)),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormat('dd MMM yyyy').format(_startDate),
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final p = await showDatePicker(
                              context: context,
                              initialDate: _targetEndDate,
                              firstDate: _startDate,
                              lastDate: _startDate.add(const Duration(days: 730)),
                            );
                            if (p != null) {
                              setState(() {
                                _targetEndDate = p;
                                _durationDays = _targetEndDate.difference(_startDate).inDays;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Target Delivery Date', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.event_available_rounded, size: 14, color: Color(0xFF16A34A)),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormat('dd MMM yyyy').format(_targetEndDate),
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Duration Highlight banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, size: 16, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Committed Delivery: $_durationDays Calendar Days (${DateFormat('dd MMM yyyy').format(_targetEndDate)})',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 3. FINANCIALS & ADVANCE PAYMENT ──
           /* _buildSectionHeader('3. Commercials & Payment Handover', Icons.account_balance_wallet_rounded),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Agreed Budget (₹) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _budgetController,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter deal value' : null,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 16, color: Color(0xFF64748B)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Advance Collected (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _advanceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF16A34A)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  const Text('Payment Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _paymentMode,
                    items: _paymentModes.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12.5)))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _paymentMode = v);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _paymentRefController,
                    decoration: InputDecoration(
                      labelText: 'Payment Transaction Ref / Cheque No. (Optional)',
                      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),*/

            // ── 4. SCOPE OF WORK & CLIENT DETAILS ("jo details client se sales team ko milta hai") ──
            _buildSectionHeader('4. Scope of Work & Client Deliverables', Icons.assignment_rounded),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Key Deliverables & Specifications *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _scopeController,
                    maxLines: 4,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter scope of work' : null,
                    decoration: InputDecoration(
                      hintText: 'e.g. 5-page custom mobile responsive website, payment gateway integration, admin dashboard...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('Client Special Instructions / Milestones', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _instructionsController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. Client requested dark mode design; weekly progress review call every Monday...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 5. CLIENT DOCUMENTS & ATTACHMENTS ("jo bhi documents use milenge client ke side se") ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('5. Client Documents & Assets (${_attachments.length})', Icons.attach_file_rounded),
                TextButton.icon(
                  onPressed: _showAddDocumentDialog,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                  label: const Text('Add File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_attachments.isEmpty) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.upload_file_rounded, size: 28, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No Client Documents Attached Yet',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Attach Proposal, Requirement BRD, Signed Agreement, or Payment Screenshot',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _showAddDocumentDialog,
                              icon: const Icon(Icons.attach_file_rounded, size: 16, color: Colors.white),
                              label: const Text('Attach Client Document', style: TextStyle(fontSize: 12, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    ..._attachments.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final att = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                att.extension.toLowerCase().contains('pdf')
                                    ? Icons.picture_as_pdf_rounded
                                    : (att.extension.toLowerCase().contains('doc')
                                        ? Icons.description_rounded
                                        : Icons.insert_drive_file_rounded),
                                color: const Color(0xFF2563EB),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    att.fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDBEAFE),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          att.categoryTag,
                                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        att.formattedSize,
                                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFDC2626)),
                              onPressed: () {
                                setState(() => _attachments.removeAt(idx));
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showAddDocumentDialog,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('+ Add Another Document', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── 6. OPS HANDOVER TEAM / PROJECT MANAGER ──
            _buildSectionHeader('6. Assign Project Manager / Team (Optional)', Icons.group_add_rounded),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Ops Lead / Project Manager', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  if (_isLoadingEmployees)
                    const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                  else if (_availableEmployees.isEmpty)
                    const Text('No employees found to assign. Handover will be routed to Ops Head.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableEmployees.take(12).map((emp) {
                        final isSelected = _selectedEmployees.any((e) => e.id == emp.id);
                        return FilterChip(
                          avatar: CircleAvatar(
                            radius: 12,
                            backgroundImage: (emp.profilePic != null && emp.profilePic!.isNotEmpty) ? NetworkImage(emp.profilePic!) : null,
                            child: (emp.profilePic == null || emp.profilePic!.isEmpty)
                                ? Text(emp.name.isNotEmpty ? emp.name[0] : 'E', style: const TextStyle(fontSize: 10))
                                : null,
                          ),
                          label: Text(emp.name),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedEmployees.add(emp);
                              } else {
                                _selectedEmployees.removeWhere((e) => e.id == emp.id);
                              }
                            });
                          },
                          selectedColor: const Color(0xFFDBEAFE),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF334155),
                          ),
                          backgroundColor: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        AppText(
          title,
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
        ),
      ],
    );
  }

  Widget _buildDurationChip(int days, String label) {
    final isSelected = _durationDays == days;
    return InkWell(
      onTap: () => _updateDuration(days),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}
