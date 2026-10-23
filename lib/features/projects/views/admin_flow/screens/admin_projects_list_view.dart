import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/admin_flow_controller.dart';
import '../models/admin_flow_models.dart';
import '../widgets/admin_flow_widgets.dart';
import 'admin_project_hub_screen.dart';
import 'admin_project_report_screen.dart';
import 'admin_project_actions_sheet.dart';
import 'admin_employee_details_screen.dart';
import 'admin_project_form_screen.dart';
import '../widgets/admin_flow_bottom_sheets.dart';

class AdminProjectsListView extends StatelessWidget {
  const AdminProjectsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminFlowController(), permanent: true);

    return Scaffold(
      backgroundColor: AdminFlowTheme.surfaceSlate,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AdminFlowTheme.textDark, size: 24),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          'Office Management',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AdminFlowTheme.textDark,
          ),
        ),
        centerTitle: false,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Iconsax.notification, color: AdminFlowTheme.textDark, size: 22),
                onPressed: () {
                  Get.snackbar(
                    'Notifications',
                    'You have 3 active project updates and 1 pending handover.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.white,
                    colorText: AdminFlowTheme.textDark,
                  );
                },
              ),
              Positioned(
                top: 13,
                right: 13,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AdminFlowTheme.cardBorder, height: 1),
        ),
      ),
      drawer: _buildDrawer(context, controller),
      body: _buildProjectsMainContent(context, controller),
    );
  }

  Widget _buildProjectsMainContent(BuildContext context, AdminFlowController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title "Projects" and New Project Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Projects',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AdminFlowTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const AdminProjectFormScreen(isEditMode: false)),
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text('New Project', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminFlowTheme.primaryBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search input
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminFlowTheme.cardBorder),
                ),
                child: TextField(
                  controller: controller.projectSearchController,
                  onChanged: (val) => controller.projectSearchQuery.value = val,
                  style: const TextStyle(fontSize: 14, color: AdminFlowTheme.textDark),
                  decoration: InputDecoration(
                    hintText: 'Search projects...',
                    hintStyle: const TextStyle(color: AdminFlowTheme.textHint, fontSize: 13),
                    prefixIcon: const Icon(Iconsax.search_normal, color: AdminFlowTheme.textHint, size: 18),
                    suffixIcon: controller.projectSearchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16, color: AdminFlowTheme.textMuted),
                            onPressed: () {
                              controller.projectSearchController.clear();
                              controller.projectSearchQuery.value = '';
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Filter Tabs (All, Active, Completed, On Hold)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(controller, 'All', 'All (5)'),
                    const SizedBox(width: 8),
                    _buildFilterChip(controller, 'Active', 'Active (3)'),
                    const SizedBox(width: 8),
                    _buildFilterChip(controller, 'Completed', 'Completed (1)'),
                    const SizedBox(width: 8),
                    _buildFilterChip(controller, 'On Hold', 'On Hold (1)'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Projects List
        Expanded(
          child: Obx(() {
            final list = controller.filteredProjects;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.folder_open, size: 48, color: AdminFlowTheme.textHint.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text('No projects match your filter', style: TextStyle(color: AdminFlowTheme.textMuted, fontSize: 14)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final project = list[index];
                return _buildProjectCard(context, controller, project);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(AdminFlowController controller, String key, String label) {
    final isSelected = controller.projectFilter.value == key;
    return GestureDetector(
      onTap: () => controller.projectFilter.value = key,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AdminFlowTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AdminFlowTheme.primaryBlue : AdminFlowTheme.cardBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AdminFlowTheme.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
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

  Widget _buildProjectCard(BuildContext context, AdminFlowController controller, AdminFlowProject project) {
    return AdminFlowCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        controller.selectedProject.value = project;
        controller.selectedHubTab.value = 0; // Overview tab
        Get.to(() => const AdminProjectHubScreen());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
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
              // Name & Code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AdminFlowTheme.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.code,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AdminFlowTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge & Project Actions Menu
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminFlowStatusBadge(status: project.status),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: AdminFlowTheme.textMuted),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (val) {
                      if (val == 'edit') {
                        Get.to(() => AdminProjectFormScreen(isEditMode: true, project: project));
                      } else if (val == 'delete') {
                        AdminFlowBottomSheets.showDeleteProjectBottomSheet(context, controller, project);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Iconsax.edit_2, size: 16, color: AdminFlowTheme.primaryBlue),
                            SizedBox(width: 8),
                            Text('Edit Project', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Iconsax.trash, size: 16, color: Color(0xFFDC2626)),
                            SizedBox(width: 8),
                            Text('Delete Project', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Row
          Row(
            children: [
              Expanded(
                child: AdminFlowProgressBar(
                  progress: project.progress,
                  color: project.themeColor,
                  height: 6,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(project.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AdminFlowTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date Range with calendar icon
          Row(
            children: [
              const Icon(Iconsax.calendar_1, size: 14, color: AdminFlowTheme.textHint),
              const SizedBox(width: 6),
              Text(
                '${project.startDate} - ${project.endDate}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AdminFlowTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AdminFlowController controller) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AdminFlowTheme.primaryBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.building, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Office Management',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Admin Workspace Hub',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Iconsax.folder, color: AdminFlowTheme.primaryBlue),
            title: const Text('All Projects', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Iconsax.profile_2user, color: AdminFlowTheme.textDark),
            title: const Text('Team Directory', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => Scaffold(
                backgroundColor: AdminFlowTheme.surfaceSlate,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  title: const Text('Organization Team', style: TextStyle(color: AdminFlowTheme.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AdminFlowTheme.textDark),
                    onPressed: () => Get.back(),
                  ),
                ),
                body: _buildAllEmployeesTab(controller),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.refresh_2, color: AdminFlowTheme.textDark),
            title: const Text('Task Handovers', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              AdminProjectActionsSheet.showHandoverHistoryDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.chart_2, color: AdminFlowTheme.textDark),
            title: const Text('Global Reports', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const AdminProjectReportScreen());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllEmployeesTab(AdminFlowController controller) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Organization Team',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AdminFlowTheme.textDark),
              ),
              const SizedBox(height: 8),
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AdminFlowTheme.cardBorder),
                ),
                child: TextField(
                  controller: controller.teamSearchController,
                  onChanged: (val) => controller.teamSearchQuery.value = val,
                  decoration: const InputDecoration(
                    hintText: 'Search employee by name or role...',
                    hintStyle: TextStyle(fontSize: 13, color: AdminFlowTheme.textHint),
                    prefixIcon: Icon(Iconsax.search_normal, size: 18, color: AdminFlowTheme.textHint),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.filteredMembers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final member = controller.filteredMembers[idx];
              return AdminFlowCard(
                padding: const EdgeInsets.all(14),
                onTap: () {
                  controller.selectedMember.value = member;
                  Get.to(() => AdminEmployeeDetailsScreen(member: member));
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AdminFlowTheme.infoBg,
                      child: Text(
                        member.name.substring(0, 1),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          Text('${member.role} • ${member.department}', style: const TextStyle(color: AdminFlowTheme.textMuted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 11, color: AdminFlowTheme.primaryBlue),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  '${member.city}, ${member.state} (${member.pincode})',
                                  style: const TextStyle(fontSize: 10.5, color: AdminFlowTheme.textMuted),
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
              );
            },
          ),
        ),
      ],
    );
  }
}
