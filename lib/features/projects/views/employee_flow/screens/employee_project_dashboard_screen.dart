import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/employee_flow_controller.dart';
import '../models/employee_flow_models.dart';
import '../widgets/employee_flow_widgets.dart';
import 'employee_project_details_screen.dart';
import 'employee_task_details_screen.dart';

/// Screen 1: Employee Project Dashboard (Only Projects)
/// Fulfills user requirement:
/// "bahar dashboard pe only projects hi dikhao"
/// 1. Top Bar: Avatar, Greeting, Role, Notification Icon, Back button
/// 2. Today's Overview: Total Tasks, In Progress, Completed
/// 3. Search & Filter Bar: Active, On Hold, Completed
/// 4. Projects List: All assigned projects with progress, deadline & details
/// 5. Sticky Live Timer Tracker banner if active
class EmployeeProjectDashboardScreen extends StatelessWidget {
  const EmployeeProjectDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EmployeeFlowController.to;

    return Scaffold(
      backgroundColor: EmployeeFlowTheme.surfaceSlate,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Profile Header
                    _buildProfileHeader(context, controller),

                    const SizedBox(height: 18),

                    // 2. Today's Overview Card
                    _buildTodayOverview(controller),

                    const SizedBox(height: 20),

                    // 3. Search Bar & Filter Chips for Projects
                    _buildProjectSearchAndFilter(controller),

                    const SizedBox(height: 16),

                    // 4. Projects Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Projects',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: EmployeeFlowTheme.textDark,
                          ),
                        ),
                        Obx(() => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: EmployeeFlowTheme.infoBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${controller.filteredProjects.length} Projects',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: EmployeeFlowTheme.primaryBlue,
                                ),
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 5. Projects List
                    _buildProjectsList(controller),

                    const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, EmployeeFlowController controller) {
    final canGoBack = Navigator.of(context).canPop();

    return Row(
      children: [
        if (canGoBack) ...[
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: EmployeeFlowTheme.cardBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: EmployeeFlowTheme.textDark,
                size: 16,
              ),
            ),
          ),
        ],
        // Avatar with border
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: EmployeeFlowTheme.infoBg,
            shape: BoxShape.circle,
            border: Border.all(color: EmployeeFlowTheme.primaryBlue.withValues(alpha: 0.3), width: 1.5),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(
            child: Icon(Icons.person, color: EmployeeFlowTheme.primaryBlue, size: 22),
          ),
        ),
        const SizedBox(width: 12),
        // Name and Designation
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                    'Hello, ${controller.currentUser.value.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: EmployeeFlowTheme.textDark,
                    ),
                  )),
              const SizedBox(height: 2),
              Obx(() => Text(
                    controller.currentUser.value.role,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: EmployeeFlowTheme.textMuted,
                    ),
                  )),
            ],
          ),
        ),
        // Notification bell with red badge
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: EmployeeFlowTheme.cardBorder),
              ),
              child: const Icon(
                Iconsax.notification,
                color: EmployeeFlowTheme.textDark,
                size: 20,
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: EmployeeFlowTheme.dangerRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayOverview(EmployeeFlowController controller) {
    return EmployeeFlowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Overview",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: EmployeeFlowTheme.textDark,
                ),
              ),
              Text(
                'Tue, 16 Sep 2025',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: EmployeeFlowTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  count: '3',
                  label: 'Total Tasks',
                  numberColor: EmployeeFlowTheme.textDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  count: '2',
                  label: 'In Progress',
                  numberColor: EmployeeFlowTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  count: '1',
                  label: 'Completed',
                  numberColor: EmployeeFlowTheme.successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String count,
    required String label,
    required Color numberColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: EmployeeFlowTheme.surfaceSlate,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EmployeeFlowTheme.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: numberColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: EmployeeFlowTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSearchAndFilter(EmployeeFlowController controller) {
    return Column(
      children: [
        // Search Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: EmployeeFlowTheme.cardBorder),
          ),
          child: TextField(
            controller: controller.projectSearchController,
            onChanged: (val) => controller.projectSearchQuery.value = val,
            style: const TextStyle(fontSize: 14, color: EmployeeFlowTheme.textDark),
            decoration: InputDecoration(
              hintText: 'Search projects...',
              hintStyle: const TextStyle(fontSize: 13, color: EmployeeFlowTheme.textHint),
              prefixIcon: const Icon(Iconsax.search_normal, color: EmployeeFlowTheme.textHint, size: 18),
              suffixIcon: Obx(() => controller.projectSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: EmployeeFlowTheme.textHint),
                      onPressed: () {
                        controller.projectSearchController.clear();
                        controller.projectSearchQuery.value = '';
                      },
                    )
                  : const SizedBox.shrink()),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Filter Chips (Active, On Hold, Completed)
        Obx(() {
          final activeCount = controller.projects.where((p) => p.status == 'Active').length;
          final onHoldCount = controller.projects.where((p) => p.status == 'On Hold').length;
          final completedCount = controller.projects.where((p) => p.status == 'Completed').length;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Active ($activeCount)',
                  value: 'Active',
                  current: controller.projectFilter.value,
                  onTap: () => controller.projectFilter.value = 'Active',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'On Hold ($onHoldCount)',
                  value: 'On Hold',
                  current: controller.projectFilter.value,
                  onTap: () => controller.projectFilter.value = 'On Hold',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Completed ($completedCount)',
                  value: 'Completed',
                  current: controller.projectFilter.value,
                  onTap: () => controller.projectFilter.value = 'Completed',
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required String current,
    required VoidCallback onTap,
  }) {
    final isSelected = current == value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? EmployeeFlowTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? EmployeeFlowTheme.primaryBlue : EmployeeFlowTheme.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : EmployeeFlowTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsList(EmployeeFlowController controller) {
    return Obx(() {
      final projects = controller.filteredProjects;

      if (projects.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(Iconsax.folder_cross, size: 48, color: EmployeeFlowTheme.textHint),
              const SizedBox(height: 12),
              const Text(
                'No projects found',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: EmployeeFlowTheme.textDark),
              ),
              const SizedBox(height: 4),
              const Text(
                'Try adjusting your search or filter tab.',
                style: TextStyle(fontSize: 12, color: EmployeeFlowTheme.textMuted),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: projects.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final project = projects[index];
          return _buildProjectCard(project);
        },
      );
    });
  }

  Widget _buildProjectCard(EmployeeFlowProject project) {
    final percent = (project.progress * 100).toInt();

    return EmployeeFlowCard(
      onTap: () => Get.to(() => EmployeeProjectDetailsScreen(project: project)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: EmployeeFlowTheme.infoBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  project.icon,
                  color: EmployeeFlowTheme.primaryBlue,
                  size: 22,
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
                        fontSize: 15,
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
          if (project.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: EmployeeFlowTheme.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 14),
          // Progress Bar with Percent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: EmployeeFlowTheme.textMuted,
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: EmployeeFlowTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          EmployeeFlowProgressBar(
            progress: project.progress,
            activeColor: EmployeeFlowTheme.primaryBlue,
            height: 6,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: EmployeeFlowTheme.cardBorder),
          const SizedBox(height: 10),
          // Footer: Modules count, Tasks count, Due date, and Arrow
          Row(
            children: [
              Row(
                children: [
                  const Icon(Iconsax.element_3, size: 14, color: EmployeeFlowTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${project.totalModules} Modules',
                    style: const TextStyle(fontSize: 11, color: EmployeeFlowTheme.textMuted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(Iconsax.task, size: 14, color: EmployeeFlowTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${project.totalTasks} Tasks',
                    style: const TextStyle(fontSize: 11, color: EmployeeFlowTheme.textMuted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    'Due: ${project.deadline}',
                    style: const TextStyle(fontSize: 11, color: EmployeeFlowTheme.textMuted, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: EmployeeFlowTheme.textHint,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
