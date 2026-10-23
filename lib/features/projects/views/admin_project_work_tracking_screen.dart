import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/project_model.dart';
import 'admin_flow/controllers/admin_flow_controller.dart';
import 'admin_flow/screens/admin_projects_list_view.dart';
import 'admin_flow/screens/admin_project_hub_screen.dart';

// Exports for seamless access
export 'admin_flow/models/admin_flow_models.dart';
export 'admin_flow/controllers/admin_flow_controller.dart';
export 'admin_flow/screens/admin_projects_list_view.dart';
export 'admin_flow/screens/admin_project_hub_screen.dart';
export 'admin_flow/screens/admin_employee_details_screen.dart';
export 'admin_flow/screens/admin_module_details_screen.dart';
export 'admin_flow/screens/admin_task_details_screen.dart';
export 'admin_flow/screens/admin_handover_task_screen.dart';
export 'admin_flow/screens/admin_handover_history_screen.dart';
export 'admin_flow/screens/admin_project_report_screen.dart';
export 'admin_flow/screens/admin_project_actions_sheet.dart';

/// Admin Project Work Tracking Entry Screen
/// Replaces the old 'Project Operations Hub' with the modern multi-screen agency flow:
/// 1. Projects List (with Office Management header, search, status filters, bottom nav)
/// 2. Project Details Hub (Overview tab with metrics, dates, summary stats)
/// 3. Team & Assignments (search, member cards with working status & progress)
/// 4. Employee Details (profile, joined on, assigned modules progress bars)
/// 5. Modules (filters: All, Completed, Pending; task count & progress)
/// 6. Module Details (Tasks & Overview tabs, tasks list with status badges)
/// 7. Task Details (info grid, priority, description, handover snippet)
/// 8. Project Timeline (Milestones & Activity Log vertical timelines)
/// 9. Handover Task (assignee, handover-to dropdown, reason, notes, attachments)
/// 10. Handover History (chronological audit trail of task transfers)
/// 11. Project Report (Time Summary, module donut progress chart, task distribution)
/// 12. Project Actions (Assign Task, Add Module, Project Settings, Export Report, Quick Actions)
class AdminProjectWorkTrackingScreen extends StatefulWidget {
  final String? initialProjectId;
  final String? initialProjectName;
  final Project? initialProject;

  const AdminProjectWorkTrackingScreen({
    super.key,
    this.initialProjectId,
    this.initialProjectName,
    this.initialProject,
  });

  @override
  State<AdminProjectWorkTrackingScreen> createState() => _AdminProjectWorkTrackingScreenState();
}

class _AdminProjectWorkTrackingScreenState extends State<AdminProjectWorkTrackingScreen> {
  late final AdminFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AdminFlowController>()
        ? Get.find<AdminFlowController>()
        : Get.put(AdminFlowController(), permanent: true);

    _controller.selectProjectByIdOrModel(
      projectId: widget.initialProjectId,
      projectName: widget.initialProjectName,
      existingProject: widget.initialProject,
    );
  }

  @override
  Widget build(BuildContext context) {
    // If a specific project was selected upon entry, open directly into the Project Hub (Overview)
    if (widget.initialProject != null || (widget.initialProjectId != null && widget.initialProjectId!.isNotEmpty)) {
      return const AdminProjectHubScreen();
    }

    // Default entry: Full Projects List Flow
    return const AdminProjectsListView();
  }
}
