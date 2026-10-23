import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/admin_flow_controller.dart';
import '../widgets/admin_flow_widgets.dart';
import '../widgets/admin_flow_bottom_sheets.dart';
import 'admin_project_report_screen.dart';
import 'admin_handover_history_screen.dart';

class AdminProjectActionsSheet extends StatelessWidget {
  const AdminProjectActionsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AdminProjectActionsSheet(),
    );
  }

  static void showHandoverHistoryDialog(BuildContext context) {
    Get.to(() => const AdminHandoverHistoryScreen());
  }

  @override
  Widget build(BuildContext context) {
    final controller = AdminFlowController.to;
    final project = controller.selectedProject.value;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AdminFlowTheme.textDark,
                    ),
                  ),
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminFlowTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AdminFlowTheme.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Action Items
          _buildActionItem(
            icon: Iconsax.user_add,
            iconBg: const Color(0xFFF5F0FB),
            iconColor: const Color(0xFF3B206A),
            title: 'Assign Task',
            subtitle: 'Assign new task to team member',
            onTap: () {
              Navigator.pop(context);
              AdminFlowBottomSheets.showAddTaskBottomSheet(context, controller);
            },
          ),
          const SizedBox(height: 10),
          _buildActionItem(
            icon: Iconsax.folder_add,
            iconBg: const Color(0xFFF0FDF4),
            iconColor: const Color(0xFF16A34A),
            title: 'Add Module',
            subtitle: 'Create new module for this project',
            onTap: () {
              Navigator.pop(context);
              AdminFlowBottomSheets.showAddModuleBottomSheet(context, controller);
            },
          ),
          const SizedBox(height: 10),
          _buildActionItem(
            icon: Iconsax.setting_2,
            iconBg: const Color(0xFFF8FAFC),
            iconColor: const Color(0xFF475569),
            title: 'Project Settings',
            subtitle: 'Edit project details, deadline, etc.',
            onTap: () {
              Navigator.pop(context);
              Get.snackbar(
                'Project Settings',
                'Opening settings for ${project.title}.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AdminFlowTheme.textDark,
                colorText: Colors.white,
              );
            },
          ),
          const SizedBox(height: 10),
          _buildActionItem(
            icon: Iconsax.document_download,
            iconBg: const Color(0xFFFFFBEB),
            iconColor: const Color(0xFFD97706),
            title: 'Export Report',
            subtitle: 'Download project report (PDF/Excel)',
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const AdminProjectReportScreen());
            },
          ),

          const SizedBox(height: 20),
          const Divider(color: AdminFlowTheme.cardBorder),
          const SizedBox(height: 12),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AdminFlowTheme.textMuted,
            ),
          ),
          const SizedBox(height: 12),

          _buildQuickActionLink(
            icon: Iconsax.diagram,
            title: 'View Gantt Chart',
            onTap: () {
              Navigator.pop(context);
              controller.selectedHubTab.value = 3; // Timeline tab
            },
          ),
          _buildQuickActionLink(
            icon: Iconsax.activity,
            title: 'View Activity Log',
            onTap: () {
              Navigator.pop(context);
              controller.selectedHubTab.value = 3;
              controller.timelineSubTab.value = 1;
            },
          ),
          _buildQuickActionLink(
            icon: Iconsax.messages_2,
            title: 'Project Chat',
            onTap: () {
              Navigator.pop(context);
              Get.snackbar(
                'Project Chat',
                'Connecting to project collaboration channel...',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AdminFlowTheme.primaryBlue,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AdminFlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AdminFlowTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AdminFlowTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AdminFlowTheme.textHint),
        ],
      ),
    );
  }

  Widget _buildQuickActionLink({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: AdminFlowTheme.primaryBlue),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AdminFlowTheme.textDark)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AdminFlowTheme.textHint),
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: onTap,
    );
  }
}
