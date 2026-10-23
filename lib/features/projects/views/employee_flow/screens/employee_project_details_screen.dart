import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/employee_flow_controller.dart';
import '../models/employee_flow_models.dart';
import '../widgets/employee_flow_widgets.dart';
import 'employee_task_details_screen.dart';
import 'employee_tasks_list_screen.dart';
import 'employee_handover_history_screen.dart';
import 'employee_project_timeline_screen.dart';
import '../../common/project_file_viewer_screen.dart';
import 'package:share_plus/share_plus.dart';

/// Screen 3: Project Workspace (Single-scroll layout with Quick Actions, NO tabs)
/// Contains:
/// 1. Project Title & Description Card
/// 2. Quick Actions inside project: Tasks, Time Log, Handover, Task History, Timeline
/// 3. Dates Info Grid (Start, End, Deadline, Duration)
/// 4. Overall Progress & My Progress
/// 5. Assigned Modules list
/// 6. Sticky active work timer banner at the bottom
class EmployeeProjectDetailsScreen extends StatelessWidget {
  final EmployeeFlowProject project;

  const EmployeeProjectDetailsScreen({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final controller = EmployeeFlowController.to;
    final percent = (project.progress * 100).toInt();

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: EmployeeFlowTheme.textDark,
              ),
            ),
            Text(
              project.code,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: EmployeeFlowTheme.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: EmployeeFlowStatusBadge(status: project.status),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Project Title Card
                  _buildProjectHeaderCard(),

                  const SizedBox(height: 18),

                  // 2. Quick Access inside Project (Dark Themed: Timeline & Handover)
                  _buildQuickAccess(context, controller),

                  const SizedBox(height: 18),

                  // 3. Info Grid: Start Date, End Date, Deadline, Duration
                  _buildInfoGrid(),

                  const SizedBox(height: 16),

                  // 4. Overall Progress
                  _buildOverallProgress(percent),

                  const SizedBox(height: 16),

                  // 5. My Progress
                  _buildMyProgress(),

                  const SizedBox(height: 16),

                  // 6. Assigned Modules
                  _buildAssignedModules(context),

                  const SizedBox(height: 18),

                  // 7. Project Files & Documents (Admin & Employee shared files)
                  _buildProjectFilesSection(context, controller),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Sticky Active Timer Tracker (if any task is currently running/paused)
          Obx(() {
            final task = controller.activeRunningTask.value;
            if (task == null) return const SizedBox.shrink();
            return EmployeeActiveTimerBanner(
              task: task,
              onPause: () => controller.pauseTaskTimer(reason: 'Quick Break'),
              onResume: () => controller.resumeTaskTimer(),
              onStop: () => controller.stopTaskTimer(markCompleted: false),
              onTap: () => Get.to(() => EmployeeTaskDetailsScreen(task: task)),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. PROJECT HEADER CARD
  // ===========================================================================
  Widget _buildProjectHeaderCard() {
    return EmployeeFlowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: EmployeeFlowTheme.infoBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  project.icon,
                  color: EmployeeFlowTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: EmployeeFlowTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.code,
                      style: const TextStyle(
                        fontSize: 12,
                        color: EmployeeFlowTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              EmployeeFlowStatusBadge(status: project.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            project.description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: EmployeeFlowTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. QUICK ACCESS INSIDE PROJECT (Primary Color Border, Horizontal Layout)
  // ===========================================================================
  Widget _buildQuickAccess(BuildContext context, EmployeeFlowController controller) {
    final handoversCount = controller.getHandoversForProject(project.id).length;
    final milestonesCount = project.milestones.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: EmployeeFlowTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 1. Timeline Card (Primary Border, Horizontal Layout)
            Expanded(
              child: _buildQuickAccessCard(
                icon: Iconsax.diagram,
                title: 'Timeline',
                count: '$milestonesCount',
                subtitle: 'Roadmap',
                onTap: () => Get.to(() => EmployeeProjectTimelineScreen(project: project)),
              ),
            ),
            const SizedBox(width: 12),
            // 2. Handover Card (Primary Border, Horizontal Layout)
            Expanded(
              child: _buildQuickAccessCard(
                icon: Iconsax.repeat,
                title: 'Handover',
                count: '$handoversCount',
                subtitle: 'Transfers',
                onTap: () => Get.to(() => EmployeeHandoverHistoryScreen(project: project)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String count,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: EmployeeFlowTheme.primaryBlue,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: EmployeeFlowTheme.primaryBlue.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: EmployeeFlowTheme.infoBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: EmployeeFlowTheme.primaryBlue.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(icon, color: EmployeeFlowTheme.primaryBlue, size: 19),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: EmployeeFlowTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: EmployeeFlowTheme.infoBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          count,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: EmployeeFlowTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: EmployeeFlowTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: EmployeeFlowTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. INFO GRID
  // ===========================================================================
  Widget _buildInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Iconsax.calendar_2,
                label: 'Start Date',
                value: project.startDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                icon: Iconsax.calendar_tick,
                label: 'End Date',
                value: project.endDate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Iconsax.clock,
                label: 'Deadline',
                value: project.deadline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                icon: Iconsax.timer_1,
                label: 'Duration',
                value: project.duration,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EmployeeFlowTheme.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: EmployeeFlowTheme.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: EmployeeFlowTheme.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: EmployeeFlowTheme.textDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. OVERALL PROGRESS
  // ===========================================================================
  Widget _buildOverallProgress(int percent) {
    return EmployeeFlowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: EmployeeFlowTheme.textDark,
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: EmployeeFlowTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          EmployeeFlowProgressBar(
            progress: project.progress,
            activeColor: EmployeeFlowTheme.successGreen,
            height: 8,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  icon: Iconsax.element_3,
                  count: '${project.totalModules}',
                  label: 'Total Modules',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  icon: Iconsax.task_square,
                  count: '${project.totalTasks}',
                  label: 'Total Tasks',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: EmployeeFlowTheme.surfaceSlate,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: EmployeeFlowTheme.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: EmployeeFlowTheme.primaryBlue),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: EmployeeFlowTheme.textDark),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: EmployeeFlowTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. MY PROGRESS
  // ===========================================================================
  Widget _buildMyProgress() {
    return EmployeeFlowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: EmployeeFlowTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: EmployeeFlowTheme.surfaceSlate,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: EmployeeFlowTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: EmployeeFlowTheme.successBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 14, color: EmployeeFlowTheme.successText),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${project.myCompletedTasks}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: EmployeeFlowTheme.textDark,
                            ),
                          ),
                          const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 11,
                              color: EmployeeFlowTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: EmployeeFlowTheme.surfaceSlate,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: EmployeeFlowTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: EmployeeFlowTheme.warningBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.priority_high, size: 14, color: EmployeeFlowTheme.warningText),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${project.myPendingTasks}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: EmployeeFlowTheme.textDark,
                            ),
                          ),
                          const Text(
                            'Pending',
                            style: TextStyle(
                              fontSize: 11,
                              color: EmployeeFlowTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. ASSIGNED MODULES
  // ===========================================================================
  Widget _buildAssignedModules(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assigned Modules',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: EmployeeFlowTheme.textDark,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => EmployeeTasksListScreen(showBackButton: true, project: project)),
              child: const Text(
                'View Tasks',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: EmployeeFlowTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (project.modules.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No assigned modules yet.',
                style: TextStyle(color: EmployeeFlowTheme.textMuted),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: project.modules.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final module = project.modules[index];
              final modPercent = (module.progress * 100).toInt();

              return EmployeeFlowCard(
                onTap: () => Get.to(() => EmployeeTasksListScreen(showBackButton: true, project: project)),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            module.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: EmployeeFlowTheme.textDark,
                            ),
                          ),
                        ),
                        EmployeeFlowStatusBadge(status: module.status),
                      ],
                    ),
                    if (module.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        module.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: EmployeeFlowTheme.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${module.totalTasks} Tasks assigned',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: EmployeeFlowTheme.textMuted,
                          ),
                        ),
                        Text(
                          '$modPercent%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: EmployeeFlowTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    EmployeeFlowProgressBar(
                      progress: module.progress,
                      activeColor: EmployeeFlowTheme.primaryBlue,
                      height: 5,
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // ===========================================================================
  // 7. PROJECT FILES & DOCUMENTS SECTION (Admin & Employee can both view & add)
  // ===========================================================================
  Widget _buildProjectFilesSection(BuildContext context, EmployeeFlowController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Project Files & Documents',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: EmployeeFlowTheme.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final files = controller.getFilesForProject(project.id);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: EmployeeFlowTheme.infoBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${files.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: EmployeeFlowTheme.primaryBlue,
                      ),
                    ),
                  );
                }),
              ],
            ),
            InkWell(
              onTap: () => _showAddFileModal(context, controller),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: EmployeeFlowTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.add, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Add File',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final files = controller.getFilesForProject(project.id);
          if (files.isEmpty) {
            return EmployeeFlowCard(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: EmployeeFlowTheme.infoBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.folder_open, color: EmployeeFlowTheme.primaryBlue, size: 24),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No files attached yet',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: EmployeeFlowTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap "Add File" to upload wireframes, specs, or documents.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: EmployeeFlowTheme.textMuted),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: files.map((file) => _buildEmployeeFileCard(context, controller, file)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEmployeeFileCard(BuildContext context, EmployeeFlowController controller, ProjectFileItem file) {
    Color iconColor;
    Color iconBg;
    IconData fileIcon;

    switch (file.fileExtension.toLowerCase()) {
      case 'pdf':
        iconColor = const Color(0xFFDC2626);
        iconBg = const Color(0xFFFEE2E2);
        fileIcon = Iconsax.document_text;
        break;
      case 'fig':
        iconColor = const Color(0xFF8B5CF6);
        iconBg = const Color(0xFFF3E8FF);
        fileIcon = Iconsax.brush_1;
        break;
      case 'docx':
      case 'doc':
        iconColor = const Color(0xFF2563EB);
        iconBg = const Color(0xFFDBEAFE);
        fileIcon = Iconsax.document;
        break;
      case 'xlsx':
      case 'csv':
        iconColor = const Color(0xFF059669);
        iconBg = const Color(0xFFD1FAE5);
        fileIcon = Iconsax.document_filter;
        break;
      case 'png':
      case 'jpg':
      case 'jpeg':
        iconColor = const Color(0xFFEC4899);
        iconBg = const Color(0xFFFCE7F3);
        fileIcon = Iconsax.gallery;
        break;
      case 'zip':
      case 'rar':
        iconColor = const Color(0xFFD97706);
        iconBg = const Color(0xFFFEF3C7);
        fileIcon = Iconsax.archive_book;
        break;
      default:
        iconColor = EmployeeFlowTheme.primaryBlue;
        iconBg = EmployeeFlowTheme.infoBg;
        fileIcon = Iconsax.document;
    }

    void openViewer() {
      Get.to(() => ProjectFileViewerScreen(
        fileName: file.fileName,
        fileExtension: file.fileExtension,
        fileSize: file.fileSize,
        uploadedBy: file.uploadedBy,
        uploadDate: file.uploadDate,
        projectId: file.projectId,
      ));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EmployeeFlowTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: openViewer,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(fileIcon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: EmployeeFlowTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            file.fileSize,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: EmployeeFlowTheme.textMuted),
                          ),
                          const SizedBox(width: 6),
                          const Text('•', style: TextStyle(fontSize: 10, color: EmployeeFlowTheme.textMuted)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              file.uploadedBy,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: EmployeeFlowTheme.textMuted),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            file.uploadDate,
                            style: const TextStyle(fontSize: 10.5, color: EmployeeFlowTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: EmployeeFlowTheme.textMuted),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (val) {
                    if (val == 'view') {
                      openViewer();
                    } else if (val == 'share') {
                      SharePlus.instance.share(
                        ShareParams(
                          text: 'Project File: ${file.fileName} (${file.fileSize})\nUploaded by: ${file.uploadedBy} on ${file.uploadDate}\nProject: ${file.projectId}',
                          subject: file.fileName,
                        ),
                      );
                    } else if (val == 'delete') {
                      controller.deleteProjectFile(file.id);
                      Get.snackbar(
                        'File Removed',
                        '${file.fileName} has been deleted.',
                        backgroundColor: const Color(0xFFDC2626),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Iconsax.eye, size: 16, color: EmployeeFlowTheme.textDark),
                          SizedBox(width: 10),
                          Text('Open & View', style: TextStyle(fontSize: 12.5)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Iconsax.share, size: 16, color: EmployeeFlowTheme.primaryBlue),
                          SizedBox(width: 10),
                          Text('Share File', style: TextStyle(fontSize: 12.5, color: EmployeeFlowTheme.primaryBlue)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Iconsax.trash, size: 16, color: Color(0xFFDC2626)),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(fontSize: 12.5, color: Color(0xFFDC2626))),
                        ],
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

  /// Show Add/Upload File Bottom Sheet for Employee
  void _showAddFileModal(BuildContext context, EmployeeFlowController controller) {
    final fileNameCtrl = TextEditingController();
    String selectedExt = 'pdf';
    String selectedSize = '2.4 MB';

    final extensions = [
      {'ext': 'pdf', 'label': 'PDF Doc', 'icon': Iconsax.document_text, 'color': const Color(0xFFDC2626)},
      {'ext': 'fig', 'label': 'Figma Design', 'icon': Iconsax.brush_1, 'color': const Color(0xFF8B5CF6)},
      {'ext': 'docx', 'label': 'Word Spec', 'icon': Iconsax.document, 'color': const Color(0xFF2563EB)},
      {'ext': 'xlsx', 'label': 'Excel Sheet', 'icon': Iconsax.document_filter, 'color': const Color(0xFF059669)},
      {'ext': 'png', 'label': 'Image Asset', 'icon': Iconsax.gallery, 'color': const Color(0xFFEC4899)},
      {'ext': 'zip', 'label': 'ZIP Archive', 'icon': Iconsax.archive_book, 'color': const Color(0xFFD97706)},
    ];

    final sizes = ['1.2 MB', '2.4 MB', '4.5 MB', '9.8 MB', '18.0 MB'];

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
                            color: EmployeeFlowTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Attach designs, schemas, reports, or documentation',
                          style: TextStyle(fontSize: 12, color: EmployeeFlowTheme.textMuted),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: EmployeeFlowTheme.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 24, color: EmployeeFlowTheme.cardBorder),

                // File Name
                const Text('File Name *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: EmployeeFlowTheme.textDark)),
                const SizedBox(height: 8),
                TextField(
                  controller: fileNameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Auth_Screen_Wireframes_v2',
                    hintStyle: const TextStyle(fontSize: 13, color: EmployeeFlowTheme.textMuted),
                    prefixIcon: const Icon(Iconsax.document_upload, size: 20, color: EmployeeFlowTheme.primaryBlue),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: EmployeeFlowTheme.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: EmployeeFlowTheme.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: EmployeeFlowTheme.primaryBlue, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // File Type / Extension Chips
                const Text('File Type *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: EmployeeFlowTheme.textDark)),
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
                            color: isSel ? color : EmployeeFlowTheme.cardBorder,
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item['icon'] as IconData, size: 16, color: isSel ? color : EmployeeFlowTheme.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? color : EmployeeFlowTheme.textDark,
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
                const Text('Estimated File Size', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: EmployeeFlowTheme.textDark)),
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
                            color: isSel ? EmployeeFlowTheme.primaryBlue : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              color: isSel ? Colors.white : EmployeeFlowTheme.textDark,
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
                    color: EmployeeFlowTheme.infoBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: EmployeeFlowTheme.primaryBlue.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.user_tick, size: 20, color: EmployeeFlowTheme.primaryBlue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uploading as Aarav Sharma (You)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: EmployeeFlowTheme.primaryBlue),
                            ),
                            Text(
                              'Admin and project team members can view and access this file',
                              style: TextStyle(fontSize: 11, color: EmployeeFlowTheme.textMuted),
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
                            side: const BorderSide(color: EmployeeFlowTheme.cardBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: EmployeeFlowTheme.textDark, fontWeight: FontWeight.w600)),
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
                              name = 'Employee_File_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
                            }
                            if (!name.toLowerCase().endsWith('.$selectedExt')) {
                              name = '$name.$selectedExt';
                            }

                            controller.addFileToProject(
                              projectId: project.id,
                              fileName: name,
                              fileSize: selectedSize,
                              fileExtension: selectedExt,
                              uploadedBy: 'Aarav Sharma (Employee)',
                            );

                            Navigator.pop(ctx);
                            Get.snackbar(
                              'File Uploaded',
                              '$name has been added to project files.',
                              backgroundColor: EmployeeFlowTheme.primaryBlue,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 3),
                              icon: const Icon(Iconsax.document_upload, color: Colors.white),
                            );
                          },
                          icon: const Icon(Iconsax.document_upload, size: 18, color: Colors.white),
                          label: const Text('Upload File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: EmployeeFlowTheme.primaryBlue,
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
