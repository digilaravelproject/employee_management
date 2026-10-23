import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/admin_flow_controller.dart';
import '../models/admin_flow_models.dart';
import '../widgets/admin_flow_widgets.dart';
import 'admin_task_details_screen.dart';

class AdminModuleDetailsScreen extends StatefulWidget {
  final AdminFlowModule module;

  const AdminModuleDetailsScreen({
    super.key,
    required this.module,
  });

  @override
  State<AdminModuleDetailsScreen> createState() => _AdminModuleDetailsScreenState();
}

class _AdminModuleDetailsScreenState extends State<AdminModuleDetailsScreen> {
  final AdminFlowController controller = AdminFlowController.to;
  int selectedSubTab = 0; // 0: Tasks, 1: Overview

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final percent = (module.progress * 100).toInt();

    return Scaffold(
      backgroundColor: AdminFlowTheme.surfaceSlate,
      appBar: const AdminFlowAppBar(
        title: 'Module Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.folder_2, color: AdminFlowTheme.primaryBlue, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              module.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AdminFlowTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${module.tasksCount} Tasks  •  $percent% Complete',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AdminFlowTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AdminFlowStatusBadge(status: module.status),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AdminFlowProgressBar(
                    progress: module.progress,
                    color: AdminFlowTheme.primaryBlue,
                    height: 7,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subtabs: Tasks | Overview
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSubTabButton(
                      title: 'Tasks',
                      isSelected: selectedSubTab == 0,
                      onTap: () => setState(() => selectedSubTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildSubTabButton(
                      title: 'Overview',
                      isSelected: selectedSubTab == 1,
                      onTap: () => setState(() => selectedSubTab = 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Content
            if (selectedSubTab == 0)
              _buildTasksList(module)
            else
              _buildModuleOverview(module),

            const SizedBox(height: 24),

            // Bottom Action: View Module Timeline
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Switch to Timeline tab in Hub
                  controller.selectedHubTab.value = 3;
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminFlowTheme.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'View Module Timeline',
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

  Widget _buildSubTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AdminFlowTheme.textDark : AdminFlowTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksList(AdminFlowModule module) {
    final tasks = module.tasks.isNotEmpty ? module.tasks : controller.selectedModule.value?.tasks ?? [];

    if (tasks.isEmpty) {
      return AdminFlowCard(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text('No tasks created for this module.', style: TextStyle(color: AdminFlowTheme.textMuted)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isCompleted = task.status == 'Completed';

        return AdminFlowCard(
          padding: const EdgeInsets.all(14),
          onTap: () {
            controller.selectedTask.value = task;
            Get.to(() => AdminTaskDetailsScreen(task: task));
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isCompleted ? AdminFlowTheme.successBg : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? AdminFlowTheme.successText : const Color(0xFFCBD5E1),
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 13, color: AdminFlowTheme.successText)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AdminFlowTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assigned to: ${task.assigneeName}',
                      style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Due: ${task.dueDate}',
                      style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AdminFlowStatusBadge(status: task.status),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModuleOverview(AdminFlowModule module) {
    return AdminFlowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Module Description', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            module.description.isNotEmpty
                ? module.description
                : 'Contains core business logic, API validation, and UI client integration for this feature.',
            style: const TextStyle(color: AdminFlowTheme.textMuted, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Divider(color: AdminFlowTheme.cardBorder),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Security Review', style: TextStyle(color: AdminFlowTheme.textMuted, fontSize: 13)),
              Text('Passed (OWASP Top 10)', style: TextStyle(color: AdminFlowTheme.successText, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Target Release Sprint', style: TextStyle(color: AdminFlowTheme.textMuted, fontSize: 13)),
              Text('Sprint 2.4 (Q4)', style: TextStyle(color: AdminFlowTheme.textDark, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
