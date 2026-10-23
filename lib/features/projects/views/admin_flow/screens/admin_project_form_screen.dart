import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/admin_flow_controller.dart';
import '../models/admin_flow_models.dart';
import '../widgets/admin_flow_widgets.dart';
import '../../../models/project_model.dart';
import '../../project_file_viewer_screen.dart';

class AdminProjectFormScreen extends StatefulWidget {
  final bool isEditMode;
  final AdminFlowProject? project;

  const AdminProjectFormScreen({
    super.key,
    required this.isEditMode,
    this.project,
  });

  @override
  State<AdminProjectFormScreen> createState() => _AdminProjectFormScreenState();
}

class _AdminProjectFormScreenState extends State<AdminProjectFormScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _codeCtrl;
  late String _selectedCategory;
  late String _selectedStatus;
  late DateTime _startDate;
  late DateTime _endDate;
  late double _progressValue;
  final List<ProjectFile> _attachedFiles = [];
  final List<AdminFlowMember> _selectedTeamMembers = [];

  final List<String> _categories = [
    'Web Development',
    'Mobile Development',
    'Software Integration',
    'Digital Marketing',
    'Design & Branding',
    'QA & Testing',
  ];

  final List<String> _statuses = [
    'Not Started',
    'In Progress',
    'On Hold',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _nameCtrl = TextEditingController(text: p?.title ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _codeCtrl = TextEditingController(text: p?.code ?? '');

    _selectedCategory = (p != null && _categories.contains(p.category))
        ? p.category
        : _categories.first;

    _selectedStatus = (p != null && _statuses.contains(p.status))
        ? p.status
        : 'Active';

    if (!_statuses.contains(_selectedStatus)) {
      _selectedStatus = 'In Progress';
    }

    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 30));
    _progressValue = (p?.progress ?? 0.0) * 100;

    if (p != null) {
      _selectedTeamMembers.addAll(p.members);
    } else {
      // Default initial members from controller
      final adminCtrl = AdminFlowController.to;
      if (adminCtrl.allMembers.isNotEmpty) {
        _selectedTeamMembers.addAll(adminCtrl.allMembers.take(2));
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminFlowTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AdminFlowTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg', 'zip'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (final f in result.files) {
            final sizeMb = double.parse((f.size / (1024 * 1024)).toStringAsFixed(2));
            _attachedFiles.add(ProjectFile(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: f.name,
              sizeMb: sizeMb,
              type: (f.extension ?? 'file').toUpperCase(),
              localPath: f.path,
            ));
          }
        });
      }
    } catch (e) {
      Get.snackbar('Files', 'Could not open file picker');
    }
  }

  void _showTeamSelectorBottomSheet(AdminFlowController controller) {
    final searchCtrl = TextEditingController();
    final allMembers = controller.allMembers;
    final filteredMembers = List<AdminFlowMember>.from(allMembers).obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Team Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminFlowTheme.textDark)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 10),
              // Search
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AdminFlowTheme.cardBorder),
                ),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (query) {
                    if (query.trim().isEmpty) {
                      filteredMembers.assignAll(allMembers);
                    } else {
                      filteredMembers.assignAll(
                        allMembers.where((m) =>
                            m.name.toLowerCase().contains(query.toLowerCase()) ||
                            m.role.toLowerCase().contains(query.toLowerCase())),
                      );
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search members by name or role...',
                    hintStyle: TextStyle(fontSize: 13, color: AdminFlowTheme.textHint),
                    prefixIcon: Icon(Iconsax.search_normal, size: 18, color: AdminFlowTheme.textHint),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  return ListView.separated(
                    itemCount: filteredMembers.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: AdminFlowTheme.cardBorder),
                    itemBuilder: (context, idx) {
                      final member = filteredMembers[idx];
                      final isSelected = _selectedTeamMembers.any((m) => m.id == member.id);

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: AdminFlowTheme.infoBg,
                          child: Text(
                            member.name.substring(0, 1),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue),
                          ),
                        ),
                        title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        subtitle: Text('${member.role} • ${member.department}', style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted)),
                        trailing: Checkbox(
                          value: isSelected,
                          activeColor: AdminFlowTheme.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) {
                            setState(() {
                              if (isSelected) {
                                _selectedTeamMembers.removeWhere((m) => m.id == member.id);
                              } else {
                                _selectedTeamMembers.add(member);
                              }
                            });
                            setSheetState(() {});
                          },
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTeamMembers.removeWhere((m) => m.id == member.id);
                            } else {
                              _selectedTeamMembers.add(member);
                            }
                          });
                          setSheetState(() {});
                        },
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminFlowTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Done (${_selectedTeamMembers.length} selected)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave(AdminFlowController controller) {
    final title = _nameCtrl.text.trim();
    if (title.isEmpty) {
      Get.snackbar('Required', 'Please enter a project title');
      return;
    }

    final durationDays = _endDate.difference(_startDate).inDays;
    final durationStr = '${durationDays > 0 ? durationDays : 30} Days';
    final startStr = _formatDate(_startDate);
    final endStr = _formatDate(_endDate);

    if (widget.isEditMode && widget.project != null) {
      controller.selectedProject.value = widget.project!;
      controller.updateProjectDetails(
        title: title,
        category: _selectedCategory,
        status: _selectedStatus,
        description: _descCtrl.text.trim(),
        deadline: endStr,
        duration: durationStr,
      );
      Get.back();
      Get.snackbar(
        'Project Updated',
        'Project "$title" details have been successfully updated.',
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
      );
    } else {
      final code = _codeCtrl.text.trim().isNotEmpty ? _codeCtrl.text.trim() : 'PRJ-00${controller.projects.length + 1}';
      controller.createNewProject(
        title: title,
        code: code,
        category: _selectedCategory,
        status: _selectedStatus,
        description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : 'Project initialized with baseline modules and team setup.',
        startDate: startStr,
        endDate: endStr,
        duration: durationStr,
      );
      Get.back();
      Get.snackbar(
        'Project Created',
        'New project "$title" created successfully!',
        backgroundColor: AdminFlowTheme.primaryBlue,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AdminFlowController.to;

    return Scaffold(
      backgroundColor: AdminFlowTheme.surfaceSlate,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AdminFlowTheme.textDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditMode ? 'Edit Project' : 'Create Project',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AdminFlowTheme.textDark),
            ),
            Text(
              widget.isEditMode ? 'Modify project parameters & team' : 'Add new project details & assign team',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AdminFlowTheme.textMuted),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AdminFlowTheme.cardBorder, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Basic Info Card
                  AdminFlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Project Name', true),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameCtrl,
                          style: const TextStyle(fontSize: 13, color: AdminFlowTheme.textDark),
                          decoration: InputDecoration(
                            hintText: 'Enter project name (e.g. Website Redesign)',
                            hintStyle: const TextStyle(color: AdminFlowTheme.textHint, fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _buildLabel('Project Description', true),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descCtrl,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 13, color: AdminFlowTheme.textDark),
                          decoration: InputDecoration(
                            hintText: 'Enter project deliverables, scope, and objectives...',
                            hintStyle: const TextStyle(color: AdminFlowTheme.textHint, fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _buildLabel('Category', true),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                          ),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Date Pickers Card
                  AdminFlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Start Date', true),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _pickDate(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AdminFlowTheme.cardBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Iconsax.calendar, size: 16, color: AdminFlowTheme.primaryBlue),
                                      const SizedBox(width: 8),
                                      Text(_formatDate(_startDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminFlowTheme.textDark)),
                                    ],
                                  ),
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
                              _buildLabel('End Date', true),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _pickDate(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AdminFlowTheme.cardBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Iconsax.calendar, size: 16, color: AdminFlowTheme.primaryBlue),
                                      const SizedBox(width: 8),
                                      Text(_formatDate(_endDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminFlowTheme.textDark)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Status & Progress Card
                  AdminFlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Status', true),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedStatus,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                          ),
                          items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedStatus = val;
                                if (val == 'Completed') _progressValue = 100;
                                if (val == 'Not Started') _progressValue = 0;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('Progress (%)', false),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AdminFlowTheme.infoBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_progressValue.toInt()}%',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Slider(
                          value: _progressValue.clamp(0.0, 100.0),
                          min: 0,
                          max: 100,
                          divisions: 100,
                          activeColor: AdminFlowTheme.primaryBlue,
                          inactiveColor: AdminFlowTheme.cardBorder,
                          label: '${_progressValue.toInt()}%',
                          onChanged: (val) {
                            setState(() {
                              _progressValue = val;
                              if (val == 100) _selectedStatus = 'Completed';
                              if (val > 0 && _selectedStatus == 'Not Started') _selectedStatus = 'In Progress';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Attach Files Card
                  AdminFlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('Attach Files', false),
                            GestureDetector(
                              onTap: _pickFiles,
                              child: const Row(
                                children: [
                                  Icon(Iconsax.add, size: 14, color: AdminFlowTheme.primaryBlue),
                                  SizedBox(width: 4),
                                  Text('Add Files', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        InkWell(
                          onTap: _pickFiles,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AdminFlowTheme.cardBorder),
                            ),
                            child: const Column(
                              children: [
                                Icon(Iconsax.document_upload, size: 30, color: AdminFlowTheme.primaryBlue),
                                SizedBox(height: 8),
                                Text('Tap to browse and select files', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminFlowTheme.textDark)),
                                SizedBox(height: 4),
                                Text('Supports PDF, DOC, PNG, JPG, ZIP (Max 10MB)', style: TextStyle(fontSize: 10, color: AdminFlowTheme.textHint)),
                              ],
                            ),
                          ),
                        ),

                        if (_attachedFiles.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _attachedFiles.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final f = _attachedFiles[idx];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AdminFlowTheme.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      f.isPdf ? Iconsax.document_text : (f.isImage ? Iconsax.gallery : Iconsax.document),
                                      size: 20,
                                      color: f.isPdf ? Colors.redAccent : AdminFlowTheme.primaryBlue,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(f.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminFlowTheme.textDark)),
                                          Text('${f.sizeMb} MB • ${f.type}', style: const TextStyle(fontSize: 10, color: AdminFlowTheme.textHint)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.fullscreen_rounded, color: AdminFlowTheme.primaryBlue, size: 20),
                                      onPressed: () => ProjectFileViewer.open(context, f),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 18),
                                      onPressed: () => setState(() => _attachedFiles.removeAt(idx)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Assign Team Members Card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildLabel('Assign Team Members', false),
                          if (_selectedTeamMembers.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AdminFlowTheme.infoBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_selectedTeamMembers.length}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue),
                              ),
                            ),
                          ],
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _showTeamSelectorBottomSheet(controller),
                        child: const Row(
                          children: [
                            Icon(Iconsax.add, size: 14, color: AdminFlowTheme.primaryBlue),
                            SizedBox(width: 4),
                            Text('Add Members', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_selectedTeamMembers.isEmpty)
                    AdminFlowCard(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Iconsax.profile_2user, size: 30, color: AdminFlowTheme.textHint),
                            const SizedBox(height: 8),
                            const Text('No team members assigned yet', style: TextStyle(fontSize: 12, color: AdminFlowTheme.textHint)),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () => _showTeamSelectorBottomSheet(controller),
                              icon: const Icon(Iconsax.user_add, size: 14),
                              label: const Text('Assign from Employees'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AdminFlowTheme.primaryBlue,
                                side: const BorderSide(color: AdminFlowTheme.primaryBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    AdminFlowCard(
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedTeamMembers.length,
                        separatorBuilder: (_, _) => const Divider(height: 16, color: AdminFlowTheme.cardBorder),
                        itemBuilder: (context, idx) {
                          final member = _selectedTeamMembers[idx];
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AdminFlowTheme.infoBg,
                                child: Text(
                                  member.name.substring(0, 1),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(member.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AdminFlowTheme.textDark)),
                                    Text('${member.role} • ${member.department}', style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Iconsax.minus_cirlce, color: Color(0xFFEF4444), size: 20),
                                onPressed: () => setState(() => _selectedTeamMembers.removeAt(idx)),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Sticky Bottom Action Button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _onSave(controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminFlowTheme.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    widget.isEditMode ? 'Update Project' : 'Create Project',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isRequired) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AdminFlowTheme.textDark)),
        if (isRequired)
          const Text(' *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
      ],
    );
  }
}
