import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/admin_flow_controller.dart';
import '../models/admin_flow_models.dart';
import '../widgets/admin_flow_widgets.dart';
import 'admin_handover_history_screen.dart';

class AdminHandoverTaskScreen extends StatefulWidget {
  final AdminFlowTask task;

  const AdminHandoverTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<AdminHandoverTaskScreen> createState() => _AdminHandoverTaskScreenState();
}

class _AdminHandoverTaskScreenState extends State<AdminHandoverTaskScreen> {
  final AdminFlowController controller = AdminFlowController.to;

  late String selectedTargetMember;
  String selectedReason = 'Workload balance';
  final TextEditingController notesController = TextEditingController(
    text: 'Sprint 2 tasks pending. Please continue from here.',
  );
  final List<String> attachedFiles = [];

  final List<String> handoverReasons = [
    'Workload balance',
    'Leave',
    'Skill requirement',
    'Urgent reassignment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final members = controller.selectedProject.value.members;
    // Default to an employee who isn't the current assignee
    final other = members.firstWhereOrNull((m) => m.name != widget.task.assigneeName);
    selectedTargetMember = other?.name ?? (members.isNotEmpty ? members.first.name : 'Rohit Verma');
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  void _submitHandover() {
    if (selectedTargetMember.isEmpty) {
      Get.snackbar('Error', 'Please select a team member to handover to.',
          backgroundColor: AdminFlowTheme.dangerBg, colorText: AdminFlowTheme.dangerText);
      return;
    }

    final success = controller.performHandover(
      task: widget.task,
      newAssigneeName: selectedTargetMember,
      reason: selectedReason,
      notes: notesController.text.trim(),
    );

    if (success) {
      Get.snackbar(
        'Handover Successful',
        'Task "${widget.task.title}" has been assigned to $selectedTargetMember.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to Handover History
      Get.off(() => AdminHandoverHistoryScreen(task: widget.task));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminFlowTheme.surfaceSlate,
      appBar: const AdminFlowAppBar(
        title: 'Handover Task',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Task Card
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.task, color: AdminFlowTheme.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AdminFlowTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.task.moduleTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AdminFlowTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminFlowStatusBadge(status: widget.task.status),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Handover Details Card
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Handover Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AdminFlowTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Current Assignee
                  const Text(
                    'Current Assignee',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AdminFlowTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AdminFlowTheme.infoBg,
                        child: Text(
                          widget.task.assigneeName.isNotEmpty ? widget.task.assigneeName[0] : 'S',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.primaryBlue),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.task.assigneeName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AdminFlowTheme.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Handover To Dropdown
                  const Text(
                    'Handover To',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AdminFlowTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AdminFlowTheme.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedTargetMember,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AdminFlowTheme.textMuted),
                        items: controller.selectedProject.value.members.map((m) {
                          return DropdownMenuItem<String>(
                            value: m.name,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 11,
                                  backgroundColor: AdminFlowTheme.infoBg,
                                  child: Text(
                                    m.name.isNotEmpty ? m.name[0] : '?',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(m.name, style: const TextStyle(fontSize: 13, color: AdminFlowTheme.textDark, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 6),
                                Text('(${m.role})', style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedTargetMember = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Reason Dropdown
                  const Text(
                    'Reason',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AdminFlowTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AdminFlowTheme.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedReason,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AdminFlowTheme.textMuted),
                        items: handoverReasons.map((r) {
                          return DropdownMenuItem<String>(
                            value: r,
                            child: Text(r, style: const TextStyle(fontSize: 13, color: AdminFlowTheme.textDark, fontWeight: FontWeight.w500)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedReason = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Notes Text Area
                  const Text(
                    'Notes',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AdminFlowTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AdminFlowTheme.cardBorder),
                    ),
                    child: TextField(
                      controller: notesController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 13, color: AdminFlowTheme.textDark),
                      decoration: const InputDecoration(
                        hintText: 'Add handover notes or context...',
                        hintStyle: TextStyle(fontSize: 13, color: AdminFlowTheme.textHint),
                        contentPadding: EdgeInsets.all(12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Attachments Button
                  const Text(
                    'Attachments',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AdminFlowTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        attachedFiles.add('handover_doc_${attachedFiles.length + 1}.pdf');
                      });
                      Get.snackbar(
                        'File Attached',
                        'Added handover_doc_${attachedFiles.length}.pdf to handover audit.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.white,
                        colorText: AdminFlowTheme.textDark,
                      );
                    },
                    icon: const Icon(Icons.add, size: 16, color: AdminFlowTheme.primaryBlue),
                    label: const Text(
                      'Add Files',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminFlowTheme.primaryBlue),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      backgroundColor: const Color(0xFFEFF6FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),

                  if (attachedFiles.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: attachedFiles.map((f) => Chip(
                        label: Text(f, style: const TextStyle(fontSize: 11)),
                        backgroundColor: const Color(0xFFF1F5F9),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() {
                            attachedFiles.remove(f);
                          });
                        },
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Initiate Handover Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitHandover,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminFlowTheme.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Initiate Handover',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
