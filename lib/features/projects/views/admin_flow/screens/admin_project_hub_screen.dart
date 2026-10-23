import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/admin_flow_controller.dart';
import '../models/admin_flow_models.dart';
import '../widgets/admin_flow_widgets.dart';
import 'admin_employee_details_screen.dart';
import 'admin_module_details_screen.dart';
import 'admin_project_report_screen.dart';
import 'admin_project_actions_sheet.dart';
import 'admin_handover_history_screen.dart';
import 'admin_project_form_screen.dart';
import '../widgets/admin_flow_bottom_sheets.dart';
import '../../common/project_file_viewer_screen.dart';
import 'package:share_plus/share_plus.dart';

class AdminProjectHubScreen extends StatelessWidget {
  const AdminProjectHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AdminFlowController.to;

    return Obx(() {
      final project = controller.selectedProject.value;
      final selectedTab = controller.selectedHubTab.value;

      String appBarTitle = 'Project Dashboard';
      if (selectedTab == 1) appBarTitle = 'Team & Assignments';
      if (selectedTab == 2) appBarTitle = 'Modules & Tasks';
      if (selectedTab == 3) appBarTitle = 'Project Timeline';
      if (selectedTab == 4) appBarTitle = 'Project Settings';

      return Scaffold(
        backgroundColor: AdminFlowTheme.surfaceSlate,
        appBar: AdminFlowAppBar(
          title: appBarTitle,
          actions: [
            // Quick Add Shortcut Button
            IconButton(
              tooltip: 'Add Task or Module',
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: AdminFlowTheme.primaryBlue, size: 20),
              ),
              onPressed: () {
                _showQuickAddChooser(context, controller);
              },
            ),
            // Edit Project Button
            IconButton(
              tooltip: 'Edit Project',
              icon: const Icon(Iconsax.edit, color: AdminFlowTheme.textDark, size: 18),
              onPressed: () {
                Get.to(() => AdminProjectFormScreen(isEditMode: true, project: project));
              },
            ),
            // More Actions Menu
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, color: AdminFlowTheme.textDark),
              onPressed: () {
                AdminProjectActionsSheet.show(context);
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: selectedTab,
          children: [
            _buildOverviewTab(context, controller, project),
            _buildTeamTab(context, controller),
            _buildModulesTab(context, controller),
            _buildTimelineTab(context, controller, project),
            _buildSettingsTab(context, controller, project),
          ],
        ),
        bottomNavigationBar: _buildHubBottomNav(controller),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 0: OVERVIEW (DASHBOARD WITH EMBEDDED PROJECT REPORT)
  // ─────────────────────────────────────────────────────────────
  Widget _buildOverviewTab(BuildContext context, AdminFlowController controller, AdminFlowProject project) {
    final percent = (project.progress * 100).toInt();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Header Card
          AdminFlowCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: project.iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(project.icon, color: project.themeColor, size: 22),
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
                              color: AdminFlowTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                project.code,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminFlowTheme.textMuted),
                              ),
                              const SizedBox(width: 8),
                              Text('•  ${project.category}', style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AdminFlowStatusBadge(status: project.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  project.description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AdminFlowTheme.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2x2 Dates & Duration Grid Card
          AdminFlowCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildGridItem(
                        icon: Iconsax.calendar_1,
                        label: 'Start Date',
                        value: project.startDate,
                      ),
                    ),
                    Expanded(
                      child: _buildGridItem(
                        icon: Iconsax.calendar_2,
                        label: 'End Date',
                        value: project.endDate,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AdminFlowTheme.cardBorder),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridItem(
                        icon: Iconsax.clock,
                        label: 'Deadline',
                        value: project.deadline,
                      ),
                    ),
                    Expanded(
                      child: _buildGridItem(
                        icon: Iconsax.timer_1,
                        label: 'Duration',
                        value: project.duration,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Overall Progress Card
          AdminFlowCard(
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AdminFlowTheme.textDark,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AdminFlowTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AdminFlowProgressBar(
                  progress: project.progress,
                  color: const Color(0xFF10B981),
                  height: 7,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Total Members & Total Modules Summary Card
          AdminFlowCard(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Iconsax.profile_2user, size: 20, color: AdminFlowTheme.textMuted),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Members',
                            style: TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted),
                          ),
                          Text(
                            '${project.totalMembers}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AdminFlowTheme.textDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: AdminFlowTheme.cardBorder),
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(Iconsax.folder, size: 20, color: AdminFlowTheme.textMuted),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Modules',
                            style: TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted),
                          ),
                          Text(
                            '${project.totalModules}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AdminFlowTheme.textDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Completed Modules & Pending Modules Cards Row
          Row(
            children: [
              Expanded(
                child: AdminFlowCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: AdminFlowTheme.successText, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Completed Modules',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AdminFlowTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${project.completedModules} ',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AdminFlowTheme.textDark),
                            ),
                            const TextSpan(
                              text: '(37.5%)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AdminFlowTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminFlowCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.access_time_filled_rounded, color: Color(0xFFF59E0B), size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Pending Modules',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AdminFlowTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${project.pendingModules} ',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AdminFlowTheme.textDark),
                            ),
                            const TextSpan(
                              text: '(62.5%)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AdminFlowTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Quick Operations Bar ──
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => AdminFlowBottomSheets.showAddTaskBottomSheet(context, controller),
                  icon: const Icon(Icons.add_task_rounded, size: 16, color: Colors.white),
                  label: const Text('Add Task', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminFlowTheme.primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AdminFlowBottomSheets.showAddModuleBottomSheet(context, controller),
                  icon: const Icon(Icons.folder_open_rounded, size: 16, color: AdminFlowTheme.primaryBlue),
                  label: const Text('Add Module', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    backgroundColor: const Color(0xFFEFF6FF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // ── EMBEDDED PROJECT REPORT ON DASHBOARD (User Req: project ka report project ke andar dikhna chahia dashboard pe hi) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Project Analytics & Report',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AdminFlowTheme.textDark),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const AdminProjectReportScreen()),
                child: const Text(
                  'Full View >',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Embedded Time Summary Card
          AdminFlowCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Time Allocation Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeBox('Estimated', '${project.estimatedHours}', 'hrs', const Color(0xFF3B206A), const Color(0xFFF5F0FB)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTimeBox('Actual', '${project.actualHours}', 'hrs', const Color(0xFF0F172A), const Color(0xFFF1F5F9)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTimeBox('Remaining', '${project.remainingHours}', 'hrs', const Color(0xFF10B981), const Color(0xFFECFDF5)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Embedded Module Wise Progress Donut Card
          AdminFlowCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Module Wise Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: CustomPaint(
                        painter: DonutChartPainter(
                          completed: project.completedModules,
                          inProgress: 3,
                          pending: project.pendingModules,
                          percentage: (project.progress * 100).toInt(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendRow(const Color(0xFF10B981), 'Completed', '${project.completedModules}'),
                          const SizedBox(height: 8),
                          _buildLegendRow(const Color(0xFF3B82F6), 'In Progress', '3'),
                          const SizedBox(height: 8),
                          _buildLegendRow(const Color(0xFFF59E0B), 'Pending', '${project.pendingModules}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Embedded Task Status Distribution Bars
          AdminFlowCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Task Status Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _buildStatusBar('Completed', '${project.completedTasksCount} (37.5%)', 0.375, const Color(0xFF10B981)),
                const SizedBox(height: 10),
                _buildStatusBar('In Progress', '${project.inProgressTasksCount} (43.7%)', 0.437, const Color(0xFF3B82F6)),
                const SizedBox(height: 10),
                _buildStatusBar('Pending', '${project.pendingTasksCount} (18.8%)', 0.188, const Color(0xFFF59E0B)),
                const SizedBox(height: 10),
                _buildStatusBar('Overdue (Time Exceeded)', '${project.overdueTasksCount} (6.2%)', 0.062, const Color(0xFFEF4444)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── PROJECT FILES & DOCUMENTS (Admin & Employee can both view & upload files) ──
          _buildProjectFilesSection(context, controller, project),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PROJECT FILES & DOCUMENTS SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildProjectFilesSection(BuildContext context, AdminFlowController controller, AdminFlowProject project) {
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
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AdminFlowTheme.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final files = controller.getFilesForProject(project.id);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AdminFlowTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${files.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AdminFlowTheme.primaryBlue,
                      ),
                    ),
                  );
                }),
              ],
            ),
            InkWell(
              onTap: () => AdminFlowBottomSheets.showAddFileBottomSheet(context, controller, project.id),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AdminFlowTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.add, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Upload File',
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
            return AdminFlowCard(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AdminFlowTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.folder_open, color: AdminFlowTheme.primaryBlue, size: 24),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No files attached yet',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Upload SRS, designs, sheets, or code bundles for this project.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: AdminFlowTheme.textMuted),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: files.map((file) => _buildAdminFileCard(context, controller, file)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildAdminFileCard(BuildContext context, AdminFlowController controller, AdminProjectFileItem file) {
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
        iconColor = AdminFlowTheme.primaryBlue;
        iconBg = AdminFlowTheme.primaryLight;
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
        border: Border.all(color: AdminFlowTheme.cardBorder),
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
                          color: AdminFlowTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            file.fileSize,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AdminFlowTheme.textMuted),
                          ),
                          const SizedBox(width: 6),
                          const Text('•', style: TextStyle(fontSize: 10, color: AdminFlowTheme.textMuted)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              file.uploadedBy,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            file.uploadDate,
                            style: const TextStyle(fontSize: 10.5, color: AdminFlowTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: AdminFlowTheme.textMuted),
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
                          Icon(Iconsax.eye, size: 16, color: AdminFlowTheme.textDark),
                          SizedBox(width: 10),
                          Text('Open & View', style: TextStyle(fontSize: 12.5)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Iconsax.share, size: 16, color: AdminFlowTheme.primaryBlue),
                          SizedBox(width: 10),
                          Text('Share File', style: TextStyle(fontSize: 12.5, color: AdminFlowTheme.primaryBlue)),
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

  Widget _buildTimeBox(String label, String value, String unit, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, color: AdminFlowTheme.textMuted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
                TextSpan(text: ' $unit', style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label, String count) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AdminFlowTheme.textMuted))),
        Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
      ],
    );
  }

  Widget _buildStatusBar(String label, String count, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
            Text(count, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AdminFlowTheme.textMuted)),
          ],
        ),
        const SizedBox(height: 5),
        AdminFlowProgressBar(progress: percent, color: color, height: 6),
      ],
    );
  }

  Widget _buildGridItem({required IconData icon, required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AdminFlowTheme.textHint),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AdminFlowTheme.textMuted)),
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 1: TEAM & ASSIGNMENTS
  // ─────────────────────────────────────────────────────────────
  Widget _buildTeamTab(BuildContext context, AdminFlowController controller) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminFlowTheme.cardBorder),
            ),
            child: TextField(
              controller: controller.teamSearchController,
              onChanged: (val) => controller.teamSearchQuery.value = val,
              style: const TextStyle(fontSize: 13, color: AdminFlowTheme.textDark),
              decoration: const InputDecoration(
                hintText: 'Search employee by name, city or role...',
                hintStyle: TextStyle(color: AdminFlowTheme.textHint, fontSize: 13),
                prefixIcon: Icon(Iconsax.search_normal, color: AdminFlowTheme.textHint, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            final members = controller.filteredMembers;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final member = members[idx];
                final percent = (member.progress * 100).toInt();

                return AdminFlowCard(
                  padding: const EdgeInsets.all(14),
                  onTap: () {
                    controller.selectedMember.value = member;
                    Get.to(() => AdminEmployeeDetailsScreen(member: member));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AdminFlowTheme.infoBg,
                            child: Text(
                              member.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${member.role} • ${member.department}',
                                  style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 11, color: Color(0xFF3B206A)),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        '${member.city}, ${member.state} (${member.pincode})',
                                        style: const TextStyle(fontSize: 10.5, color: AdminFlowTheme.textMuted, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          AdminFlowStatusBadge(status: member.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AdminFlowProgressBar(
                              progress: member.progress,
                              color: AdminFlowTheme.primaryBlue,
                              height: 6,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$percent%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '${member.assignedModules.length} modules >',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AdminFlowTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 2: MODULES (WITH ADD MODULE & ADD TASK BUTTONS)
  // ─────────────────────────────────────────────────────────────
  Widget _buildModulesTab(BuildContext context, AdminFlowController controller) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              // Top Action Row: Add Module & Add Task
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => AdminFlowBottomSheets.showAddModuleBottomSheet(context, controller),
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text('Add Module', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminFlowTheme.primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => AdminFlowBottomSheets.showAddTaskBottomSheet(context, controller),
                      icon: const Icon(Icons.add_task_rounded, size: 16, color: AdminFlowTheme.primaryBlue),
                      label: const Text('Add & Assign Task', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        backgroundColor: const Color(0xFFEFF6FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Search input
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminFlowTheme.cardBorder),
                ),
                child: TextField(
                  controller: controller.moduleSearchController,
                  onChanged: (val) => controller.moduleSearchQuery.value = val,
                  style: const TextStyle(fontSize: 13, color: AdminFlowTheme.textDark),
                  decoration: const InputDecoration(
                    hintText: 'Search Modules...',
                    hintStyle: TextStyle(color: AdminFlowTheme.textHint, fontSize: 13),
                    prefixIcon: Icon(Iconsax.search_normal, color: AdminFlowTheme.textHint, size: 18),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Filter Tabs
              Obx(() => Row(
                children: [
                  _buildModuleFilterChip(controller, 'All', 'All (${controller.selectedProject.value.modules.length})'),
                  const SizedBox(width: 8),
                  _buildModuleFilterChip(controller, 'Completed', 'Completed (${controller.selectedProject.value.completedModules})'),
                  const SizedBox(width: 8),
                  _buildModuleFilterChip(controller, 'Pending', 'Pending (${controller.selectedProject.value.pendingModules})'),
                ],
              )),
            ],
          ),
        ),

        // Modules List
        Expanded(
          child: Obx(() {
            final modules = controller.filteredModules;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: modules.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final module = modules[idx];
                final percent = (module.progress * 100).toInt();

                return AdminFlowCard(
                  padding: const EdgeInsets.all(14),
                  onTap: () {
                    controller.selectedModule.value = module;
                    Get.to(() => AdminModuleDetailsScreen(module: module));
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Iconsax.folder_2, color: AdminFlowTheme.primaryBlue, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              module.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${module.tasks.length} tasks  •  $percent%',
                              style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      AdminFlowStatusBadge(status: module.status),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AdminFlowTheme.textHint),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildModuleFilterChip(AdminFlowController controller, String key, String label) {
    final isSelected = controller.moduleFilter.value == key;
    return GestureDetector(
      onTap: () => controller.moduleFilter.value = key,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AdminFlowTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AdminFlowTheme.primaryBlue : AdminFlowTheme.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AdminFlowTheme.textMuted,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 3: TIMELINE
  // ─────────────────────────────────────────────────────────────
  Widget _buildTimelineTab(BuildContext context, AdminFlowController controller, AdminFlowProject project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminFlowCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(project.startDate, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AdminFlowTheme.textDark)),
                    Text(project.endDate, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AdminFlowTheme.textDark)),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Start Date', style: TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted)),
                    Text('End Date', style: TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted)),
                  ],
                ),
                const SizedBox(height: 10),
                AdminFlowProgressBar(
                  progress: 0.27,
                  color: AdminFlowTheme.primaryBlue,
                  height: 6,
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('27%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AdminFlowTheme.textMuted)),
                    Text('112 days left', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Subtabs: Milestones | Activity Log
          Obx(() {
            final subTab = controller.timelineSubTab.value;
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTimelineSubTab(
                      title: 'Milestones',
                      isSelected: subTab == 0,
                      onTap: () => controller.timelineSubTab.value = 0,
                    ),
                  ),
                  Expanded(
                    child: _buildTimelineSubTab(
                      title: 'Activity Log',
                      isSelected: subTab == 1,
                      onTap: () => controller.timelineSubTab.value = 1,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          Obx(() {
            if (controller.timelineSubTab.value == 0) {
              return _buildMilestonesList(project);
            } else {
              return _buildActivityLogList(project);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineSubTab({required String title, required bool isSelected, required VoidCallback onTap}) {
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

  Widget _buildMilestonesList(AdminFlowProject project) {
    return AdminFlowCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(project.milestones.length, (index) {
          final m = project.milestones[index];
          final isLast = index == project.milestones.length - 1;
          Color dotColor = const Color(0xFFCBD5E1);
          if (m.status == 'Completed') dotColor = const Color(0xFF10B981);
          if (m.status == 'In Progress') dotColor = const Color(0xFF3B206A);
          if (m.status == 'Pending') dotColor = const Color(0xFFF59E0B);

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.date,
                              style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              m.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                            ),
                          ],
                        ),
                        AdminFlowStatusBadge(status: m.status),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActivityLogList(AdminFlowProject project) {
    return AdminFlowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: project.activityLog.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: item.iconColor.withValues(alpha: 0.12),
                  child: Icon(item.icon, size: 14, color: item.iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                      const SizedBox(height: 2),
                      Text('${item.user}  •  ${item.timestamp}', style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 4: SETTINGS (PROJECT SETTINGS & ADMINISTRATION)
  // (User Req: settings bhi project ke andar rhega and vha add task module and aur es tarah ki chije rkh skte hai)
  // ─────────────────────────────────────────────────────────────
  Widget _buildSettingsTab(BuildContext context, AdminFlowController controller, AdminFlowProject project) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Project Quick Administration Card
        AdminFlowCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Iconsax.setting_2, color: AdminFlowTheme.primaryBlue, size: 20),
                  SizedBox(width: 8),
                  Text('Project Administration', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Manage tasks, modules, deadlines and handover configurations.', style: TextStyle(fontSize: 12, color: AdminFlowTheme.textMuted)),
              const SizedBox(height: 16),

              _buildSettingsActionTile(
                icon: Icons.add_task_rounded,
                iconColor: const Color(0xFF3B206A),
                title: 'Add & Assign Task',
                subtitle: 'Assign task directly to employee with time budget',
                onTap: () => AdminFlowBottomSheets.showAddTaskBottomSheet(context, controller),
              ),
              const Divider(height: 20, color: AdminFlowTheme.cardBorder),

              _buildSettingsActionTile(
                icon: Icons.create_new_folder_outlined,
                iconColor: const Color(0xFF16A34A),
                title: 'Add New Module',
                subtitle: 'Create a new feature module for this project',
                onTap: () => AdminFlowBottomSheets.showAddModuleBottomSheet(context, controller),
              ),
              const Divider(height: 20, color: AdminFlowTheme.cardBorder),

              _buildSettingsActionTile(
                icon: Iconsax.edit,
                iconColor: const Color(0xFFD97706),
                title: 'Edit Project Details',
                subtitle: 'Modify project title, status, category and deadline',
                onTap: () => Get.to(() => AdminProjectFormScreen(isEditMode: true, project: project)),
              ),
              const Divider(height: 20, color: AdminFlowTheme.cardBorder),

              _buildSettingsActionTile(
                icon: Iconsax.refresh_2,
                iconColor: const Color(0xFF9333EA),
                title: 'Handover Audit Log',
                subtitle: 'Review full history of task transfers between team',
                onTap: () => Get.to(() => const AdminHandoverHistoryScreen()),
              ),
              const Divider(height: 20, color: AdminFlowTheme.cardBorder),

              _buildSettingsActionTile(
                icon: Iconsax.document_download,
                iconColor: const Color(0xFF0F172A),
                title: 'Export Project Report',
                subtitle: 'Download analytics report as PDF/Excel',
                onTap: () => Get.to(() => const AdminProjectReportScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Danger Zone: Delete Project (User Req: project delete ka option hona chahia)
        AdminFlowCard(
          color: const Color(0xFFFFF1F2),
          border: Border.all(color: const Color(0xFFFECDD3)),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626), size: 20),
                  SizedBox(width: 8),
                  Text('Danger Zone: Delete Project', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF991B1B))),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Deleting this project will permanently remove all associated modules, tasks, and audit logs.',
                style: TextStyle(fontSize: 11.5, color: Color(0xFFB91C1C)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => AdminFlowBottomSheets.showDeleteProjectBottomSheet(
                    context,
                    controller,
                    project,
                    onDeleted: () => Get.back(),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white),
                  label: const Text('Delete Project', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSettingsActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AdminFlowTheme.textHint),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BOTTOM NAV BAR FOR PROJECT HUB (Overview, Team, Modules, Timeline, Settings)
  // ─────────────────────────────────────────────────────────────
  Widget _buildHubBottomNav(AdminFlowController controller) {
    final selectedTab = controller.selectedHubTab.value;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AdminFlowTheme.cardBorder)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildHubNavItem(controller, 0, Iconsax.category, 'Overview', selectedTab == 0),
            _buildHubNavItem(controller, 1, Iconsax.profile_2user, 'Team', selectedTab == 1),
            _buildHubNavItem(controller, 2, Iconsax.folder, 'Modules', selectedTab == 2),
            _buildHubNavItem(controller, 3, Iconsax.calendar_1, 'Timeline', selectedTab == 3),
            _buildHubNavItem(controller, 4, Iconsax.setting_2, 'Settings', selectedTab == 4),
          ],
        ),
      ),
    );
  }

  Widget _buildHubNavItem(AdminFlowController controller, int index, IconData icon, String label, bool isSelected) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller.selectedHubTab.value = index;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? AdminFlowTheme.primaryBlue : AdminFlowTheme.textHint,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AdminFlowTheme.primaryBlue : AdminFlowTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🚀 INTERACTIVE DIALOGS (Add Task with Assignee, Add Module, Edit, Delete)
  // ─────────────────────────────────────────────────────────────

  void _showQuickAddChooser(BuildContext context, AdminFlowController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What would you like to create?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add_task_rounded, color: AdminFlowTheme.primaryBlue),
              ),
              title: const Text('Add & Assign New Task', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Assign task to team member with allocated time', style: TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(ctx);
                AdminFlowBottomSheets.showAddTaskBottomSheet(context, controller);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.create_new_folder_outlined, color: Color(0xFF16A34A)),
              ),
              title: const Text('Add New Module', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Create a feature module for this project', style: TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(ctx);
                AdminFlowBottomSheets.showAddModuleBottomSheet(context, controller);
              },
            ),
          ],
        ),
      ),
    );
  }


}

