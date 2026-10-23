import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/admin_flow_controller.dart';
import '../models/admin_flow_models.dart';
import 'admin_flow_widgets.dart';

class AdminFlowBottomSheets {
  /// Show Add Task Modal Bottom Sheet (User Req: module task add sbke lia bottomsheet bnao)
  static void showAddTaskBottomSheet(
    BuildContext context,
    AdminFlowController controller, {
    String? defaultModule,
    String? defaultAssignee,
  }) {
    final project = controller.selectedProject.value;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final hoursCtrl = TextEditingController(text: '8');
    final startDateCtrl = TextEditingController(text: 'Oct 24, 2026');
    final dueDateCtrl = TextEditingController(text: 'Nov 02, 2026');

    String selectedModule = defaultModule ?? (project.modules.isNotEmpty ? project.modules.first.title : 'General');
    String selectedEmployee = defaultAssignee ?? (project.members.isNotEmpty ? project.members.first.name : 'Unassigned');
    String selectedPriority = 'Medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add New Task',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AdminFlowTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Project: ${project.title}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AdminFlowTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AdminFlowTheme.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 20, color: AdminFlowTheme.cardBorder),

                // Task Title
                const Text('Task Title *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                const SizedBox(height: 6),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Payment Gateway Webhook Integration',
                    hintStyle: const TextStyle(fontSize: 13, color: AdminFlowTheme.textHint),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                  ),
                ),
                const SizedBox(height: 14),

                // Target Module Dropdown
                const Text('Target Module *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedModule,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                  ),
                  items: project.modules.map((m) => DropdownMenuItem(value: m.title, child: Text(m.title, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) setSheetState(() => selectedModule = val);
                  },
                ),
                const SizedBox(height: 14),

                // Assign to Employee (Instant assignment)
                const Text('Assign To Employee *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedEmployee,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                  ),
                  items: project.members.map((m) => DropdownMenuItem(
                    value: m.name,
                    child: Text('${m.name} (${m.role})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setSheetState(() => selectedEmployee = val);
                  },
                ),
                const SizedBox(height: 14),

                // Allocated Hours & Priority
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Allocated Time (Hours) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: hoursCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'e.g. 8',
                              suffixText: 'hrs',
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Priority', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: selectedPriority,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                            ),
                            items: ['High', 'Medium', 'Low'].map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (val) {
                              if (val != null) setSheetState(() => selectedPriority = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Dates Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: startDateCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              prefixIcon: const Icon(Iconsax.calendar_1, size: 16, color: AdminFlowTheme.textHint),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Due Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: dueDateCtrl,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              prefixIcon: const Icon(Iconsax.calendar_2, size: 16, color: AdminFlowTheme.textHint),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description
                const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                const SizedBox(height: 6),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Enter task scope and deliverables...',
                    hintStyle: const TextStyle(fontSize: 13, color: AdminFlowTheme.textHint),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) {
                        Get.snackbar('Required', 'Please enter task title');
                        return;
                      }
                      final allocatedHrs = double.tryParse(hoursCtrl.text.trim()) ?? 8.0;

                      controller.addTaskToModule(
                        moduleTitle: selectedModule,
                        title: titleCtrl.text.trim(),
                        assigneeName: selectedEmployee,
                        allocatedHours: allocatedHrs,
                        priority: selectedPriority,
                        dueDate: dueDateCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                      );
                      Navigator.pop(ctx);
                      Get.snackbar(
                        'Task Created & Assigned',
                        'Task "${titleCtrl.text}" assigned to $selectedEmployee ($allocatedHrs hrs).',
                        backgroundColor: const Color(0xFF10B981),
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminFlowTheme.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Create & Assign Task', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show Add Module Modal Bottom Sheet (User Req: module task add sbke lia bottomsheet bnao)
  static void showAddModuleBottomSheet(BuildContext context, AdminFlowController controller) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedStatus = 'In Progress';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Module',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AdminFlowTheme.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AdminFlowTheme.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 20, color: AdminFlowTheme.cardBorder),

                // Module Title
                const Text('Module Title *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                const SizedBox(height: 6),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Authentication & Authorization',
                    hintStyle: const TextStyle(fontSize: 13, color: AdminFlowTheme.textHint),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                  ),
                ),
                const SizedBox(height: 14),

                // Status
                const Text('Initial Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                  ),
                  items: ['In Progress', 'Pending', 'Completed'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) setSheetState(() => selectedStatus = val);
                  },
                ),
                const SizedBox(height: 14),

                // Description
                const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                const SizedBox(height: 6),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Describe module requirements and scope...',
                    hintStyle: const TextStyle(fontSize: 13, color: AdminFlowTheme.textHint),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminFlowTheme.cardBorder)),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) {
                        Get.snackbar('Required', 'Please enter module title');
                        return;
                      }
                      controller.addModuleToCurrentProject(
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        status: selectedStatus,
                      );
                      Navigator.pop(ctx);
                      Get.snackbar(
                        'Module Added',
                        'Module "${titleCtrl.text}" created successfully.',
                        backgroundColor: AdminFlowTheme.primaryBlue,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminFlowTheme.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Create Module', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show Delete Project Confirmation Bottom Sheet
  static void showDeleteProjectBottomSheet(
    BuildContext context,
    AdminFlowController controller,
    AdminFlowProject project, {
    VoidCallback? onDeleted,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Warning Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 30),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Delete Project',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AdminFlowTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Are you sure you want to delete "${project.title}" (${project.code})?\nAll modules, tasks, and audit logs will be permanently removed.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AdminFlowTheme.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AdminFlowTheme.cardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: AdminFlowTheme.textDark, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        final ok = controller.deleteProject(project.id);
                        Navigator.pop(ctx);
                        if (ok) {
                          onDeleted?.call();
                          Get.snackbar(
                            'Project Deleted',
                            'Project "${project.title}" was removed.',
                            backgroundColor: const Color(0xFFDC2626),
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Confirm Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show Add/Upload File Bottom Sheet for Admin
  static void showAddFileBottomSheet(
    BuildContext context,
    AdminFlowController controller,
    String projectId,
  ) {
    final fileNameCtrl = TextEditingController();
    String selectedExt = 'pdf';
    String selectedSize = '3.5 MB';

    final extensions = [
      {'ext': 'pdf', 'label': 'PDF Doc', 'icon': Iconsax.document_text, 'color': const Color(0xFFDC2626)},
      {'ext': 'fig', 'label': 'Figma Design', 'icon': Iconsax.brush_1, 'color': const Color(0xFF8B5CF6)},
      {'ext': 'docx', 'label': 'Word Spec', 'icon': Iconsax.document, 'color': const Color(0xFF2563EB)},
      {'ext': 'xlsx', 'label': 'Excel Sheet', 'icon': Iconsax.document_filter, 'color': const Color(0xFF059669)},
      {'ext': 'png', 'label': 'Image Asset', 'icon': Iconsax.gallery, 'color': const Color(0xFFEC4899)},
      {'ext': 'zip', 'label': 'ZIP Archive', 'icon': Iconsax.archive_book, 'color': const Color(0xFFD97706)},
    ];

    final sizes = ['1.2 MB', '2.5 MB', '4.8 MB', '10.5 MB', '24.0 MB'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Project File',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AdminFlowTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Add documentation, design assets or specs',
                          style: TextStyle(fontSize: 12, color: AdminFlowTheme.textMuted),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AdminFlowTheme.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AdminFlowTheme.cardBorder),

                // File Name
                const Text('File Name *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                const SizedBox(height: 8),
                TextField(
                  controller: fileNameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Architecture_SRS_Specification_v3',
                    hintStyle: const TextStyle(fontSize: 13, color: AdminFlowTheme.textHint),
                    prefixIcon: const Icon(Iconsax.document_upload, size: 20, color: AdminFlowTheme.primaryBlue),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AdminFlowTheme.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AdminFlowTheme.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AdminFlowTheme.primaryBlue, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // File Type / Extension Chips
                const Text('File Type *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: extensions.map((item) {
                    final isSel = selectedExt == item['ext'];
                    final color = item['color'] as Color;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedExt = item['ext'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? color.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? color : AdminFlowTheme.cardBorder,
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item['icon'] as IconData, size: 16, color: isSel ? color : AdminFlowTheme.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? color : AdminFlowTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // File Size Preset
                const Text('Estimated File Size', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                const SizedBox(height: 8),
                Row(
                  children: sizes.map((size) {
                    final isSel = selectedSize == size;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setSheetState(() => selectedSize = size),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? AdminFlowTheme.primaryBlue : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              color: isSel ? Colors.white : AdminFlowTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Uploaded By Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminFlowTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminFlowTheme.primaryBlue.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.shield_tick, size: 20, color: AdminFlowTheme.primaryBlue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uploading as Admin',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.primaryBlue),
                            ),
                            Text(
                              'Visible immediately to assigned team members and employees',
                              style: TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AdminFlowTheme.cardBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: AdminFlowTheme.textDark, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            var name = fileNameCtrl.text.trim();
                            if (name.isEmpty) {
                              name = 'Project_Document_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
                            }
                            if (!name.toLowerCase().endsWith('.$selectedExt')) {
                              name = '$name.$selectedExt';
                            }

                            controller.addFileToProject(
                              projectId: projectId,
                              fileName: name,
                              fileSize: selectedSize,
                              fileExtension: selectedExt,
                              uploadedBy: 'Admin (System)',
                            );

                            Navigator.pop(ctx);
                            Get.snackbar(
                              'File Uploaded',
                              '$name has been attached to the project.',
                              backgroundColor: AdminFlowTheme.primaryBlue,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 3),
                              icon: const Icon(Iconsax.document_upload, color: Colors.white),
                            );
                          },
                          icon: const Icon(Iconsax.document_upload, size: 18, color: Colors.white),
                          label: const Text('Upload File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminFlowTheme.primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
