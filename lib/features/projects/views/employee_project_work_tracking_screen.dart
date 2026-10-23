import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'employee_flow/controllers/employee_flow_controller.dart';
import 'employee_flow/screens/employee_project_dashboard_screen.dart';
import 'employee_flow/screens/employee_tasks_list_screen.dart';
import 'employee_flow/screens/employee_projects_list_screen.dart';
import 'employee_flow/screens/employee_time_log_screen.dart';

// Seamless Exports for all screens, models, controllers and widgets
export 'employee_flow/models/employee_flow_models.dart';
export 'employee_flow/controllers/employee_flow_controller.dart';
export 'employee_flow/widgets/employee_flow_widgets.dart';
export 'employee_flow/screens/employee_project_dashboard_screen.dart';
export 'employee_flow/screens/employee_projects_list_screen.dart';
export 'employee_flow/screens/employee_project_details_screen.dart';
export 'employee_flow/screens/employee_tasks_list_screen.dart';
export 'employee_flow/screens/employee_task_details_screen.dart';
export 'employee_flow/screens/employee_request_handover_screen.dart';
export 'employee_flow/screens/employee_handover_history_screen.dart';
export 'employee_flow/screens/employee_time_log_screen.dart';
export 'employee_flow/screens/employee_project_timeline_screen.dart';
export 'employee_flow/screens/employee_task_history_screen.dart';

/// Employee Project & Task Management Master Hub
/// Complete multi-screen flow mirroring the Admin Flow architecture and user design:
/// 1. Home Dashboard: Today's overview, Current Project, Quick Actions
/// 2. My Projects: Search, status tabs (Active, On Hold, Completed), progress & days left
/// 3. Project Details: Dates grid, Overall Progress, My Progress, Assigned Modules breakdown
/// 4. My Tasks: All, In Progress, Completed, Pending chips; Live Start/Pause/Stop timer; Handover
/// 5. Task Details: Live ticking timer, Overtime alert in RED, Break reasons logging, Session history
/// 6. Request Handover: Task module, Progress %, Handover reason, Notes, Assignee, Attachments
/// 7. Handover History: Total handovers badge, chronological transfers, View Details bottom sheet
/// 8. Time Log: This Week / This Month, Task-wise time breakdown (-1h badge, red overtime)
/// 9. Project Timeline: Milestone phases (Project Started -> Design -> Development -> Testing -> Release)
/// 10. Complete Task History: Start timestamp, breaks, remaining time, handover audit records
class EmployeeProjectWorkTrackingScreen extends StatefulWidget {
  final int initialTabIndex;

  const EmployeeProjectWorkTrackingScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<EmployeeProjectWorkTrackingScreen> createState() =>
      _EmployeeProjectWorkTrackingScreenState();
}

class _EmployeeProjectWorkTrackingScreenState
    extends State<EmployeeProjectWorkTrackingScreen> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<EmployeeFlowController>()) {
      Get.put(EmployeeFlowController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialTabIndex == 1) {
      return const EmployeeTasksListScreen(showBackButton: true);
    } else if (widget.initialTabIndex == 2) {
      return const EmployeeProjectsListScreen(showBackButton: true);
    } else if (widget.initialTabIndex == 3) {
      return const EmployeeTimeLogScreen(showBackButton: true);
    }

    return const EmployeeProjectDashboardScreen();
  }
}
