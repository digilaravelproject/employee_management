import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/employee_flow_controller.dart';
import '../models/employee_flow_models.dart';
import '../widgets/employee_flow_widgets.dart';

/// Screen 5: Request Handover
/// Matches Mockup 5 from the user reference:
/// - Header: "Request Handover"
/// - Task Card: Task name & Module
/// - Current Progress Slider / Bar (60%)
/// - Reason for Handover dropdown (Workload balance, etc.)
/// - Notes multiline textfield
/// - Select New Assignee dropdown (with avatar & role)
/// - Attachments (Optional)
/// - "Submit Request" button
class EmployeeRequestHandoverScreen extends StatefulWidget {
  final EmployeeFlowTask task;

  const EmployeeRequestHandoverScreen({
    super.key,
    required this.task,
  });

  @override
  State<EmployeeRequestHandoverScreen> createState() => _EmployeeRequestHandoverScreenState();
}

class _EmployeeRequestHandoverScreenState extends State<EmployeeRequestHandoverScreen> {
  late double _progress;
  String _selectedReason = 'Workload balance';
  late final TextEditingController _notesController;
  String _selectedAssignee = 'Neha Singh';
  String _selectedAssigneeRole = 'UI/UX Designer';
  String? _attachedFileName;

  final List<String> _reasons = [
    'Workload balance',
    'Leave',
    'Skill dependency',
    'Shift handover',
    'Priority reassignment',
    'Emergency',
  ];

  final List<Map<String, String>> _assignees = [
    {
      'name': 'Neha Singh',
      'role': 'UI/UX Designer',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    },
    {
      'name': 'Sneha Patel',
      'role': 'Frontend Developer',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    },
    {
      'name': 'Rohit Verma',
      'role': 'Senior Backend Engineer',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    },
    {
      'name': 'Vikram Seth',
      'role': 'QA Lead',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    },
  ];

  @override
  void initState() {
    super.initState();
    _progress = (widget.task.progress * 100).clamp(10.0, 100.0);
    _notesController = TextEditingController(
      text: 'I am handling another high priority task. Please assign this task to $_selectedAssignee.',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = EmployeeFlowController.to;

    return Scaffold(
      backgroundColor: EmployeeFlowTheme.surfaceSlate,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: EmployeeFlowTheme.textDark),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Request Handover',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: EmployeeFlowTheme.textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Task Card
            EmployeeFlowCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: EmployeeFlowTheme.infoBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.shield_tick, color: EmployeeFlowTheme.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: EmployeeFlowTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Module: ${widget.task.moduleTitle}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: EmployeeFlowTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. Current Progress Slider
            const Text(
              'Current Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: EmployeeFlowTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            EmployeeFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Completion percentage',
                        style: TextStyle(fontSize: 12, color: EmployeeFlowTheme.textMuted),
                      ),
                      Text(
                        '${_progress.toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: EmployeeFlowTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: EmployeeFlowTheme.successGreen,
                      inactiveTrackColor: EmployeeFlowTheme.cardBorder,
                      thumbColor: EmployeeFlowTheme.successGreen,
                      overlayColor: EmployeeFlowTheme.successGreen.withValues(alpha: 0.2),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _progress,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      onChanged: (val) {
                        setState(() => _progress = val);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. Reason for Handover Dropdown
            const Text(
              'Reason for Handover',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: EmployeeFlowTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EmployeeFlowTheme.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReason,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: EmployeeFlowTheme.textMuted),
                  items: _reasons.map((r) {
                    return DropdownMenuItem<String>(
                      value: r,
                      child: Text(
                        r,
                        style: const TextStyle(fontSize: 14, color: EmployeeFlowTheme.textDark),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedReason = val);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 4. Notes Textfield
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: EmployeeFlowTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EmployeeFlowTheme.cardBorder),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                style: const TextStyle(fontSize: 13, color: EmployeeFlowTheme.textDark),
                decoration: const InputDecoration(
                  hintText: 'Explain the context, pending modules and handover requirements...',
                  hintStyle: TextStyle(fontSize: 13, color: EmployeeFlowTheme.textHint),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 5. Select New Assignee
            const Text(
              'Select New Assignee',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: EmployeeFlowTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EmployeeFlowTheme.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAssignee,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: EmployeeFlowTheme.textMuted),
                  items: _assignees.map((a) {
                    return DropdownMenuItem<String>(
                      value: a['name']!,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(a['avatar']!),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                a['name']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: EmployeeFlowTheme.textDark,
                                ),
                              ),
                              Text(
                                a['role']!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: EmployeeFlowTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final found = _assignees.firstWhere((a) => a['name'] == val);
                      setState(() {
                        _selectedAssignee = val;
                        _selectedAssigneeRole = found['role']!;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 6. Attachments (Optional)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attachments (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: EmployeeFlowTheme.textDark,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.attach_file, size: 16),
                  label: const Text('+ Add File', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    setState(() {
                      _attachedFileName = 'handover_specs_notes.pdf';
                    });
                    Get.snackbar(
                      'File Attached',
                      'handover_specs_notes.pdf has been attached.',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
              ],
            ),
            if (_attachedFileName != null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: EmployeeFlowTheme.infoBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 16, color: EmployeeFlowTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _attachedFileName!,
                        style: const TextStyle(fontSize: 12, color: EmployeeFlowTheme.primaryBlue),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: EmployeeFlowTheme.primaryBlue),
                      onPressed: () => setState(() => _attachedFileName = null),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // 7. Submit Request Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: EmployeeFlowTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  controller.requestHandover(
                    task: widget.task,
                    toUser: _selectedAssignee,
                    toUserRole: _selectedAssigneeRole,
                    reason: _selectedReason,
                    notes: _notesController.text.trim(),
                    progressAtHandover: _progress,
                    attachmentName: _attachedFileName,
                  );
                },
                child: const Text(
                  'Submit Request',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
