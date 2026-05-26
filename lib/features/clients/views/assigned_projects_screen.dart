import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/clients_controller.dart';
import '../models/client_model.dart';
import 'assign_project_screen.dart';

class AssignedProjectsScreen extends StatefulWidget {
  const AssignedProjectsScreen({super.key});

  @override
  State<AssignedProjectsScreen> createState() => _AssignedProjectsScreenState();
}

class _AssignedProjectsScreenState extends State<AssignedProjectsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientsController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Assigned Projects',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        final client = controller.selectedClient.value;
        if (client == null) {
          return const Center(child: AppText('No client selected'));
        }

        final allProjs = client.projects;
        final activeProjs = allProjs.where((p) => p.status == 'Active').toList();
        final completedProjs = allProjs.where((p) => p.status == 'Completed').toList();

        return Column(
          children: [
            // ── Screen 5 Mini Header Summary ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.slate100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                      child: Center(
                        child: AppText(
                          client.name.isNotEmpty ? client.name.substring(0, 2).toUpperCase() : 'CL',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            client.name,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            client.email,
                            fontSize: 12,
                            color: AppColors.textColorSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tabs Header
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.textColorHint,
                indicatorColor: AppColors.primaryColor,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: [
                  Tab(text: 'All Projects (${allProjs.length})'),
                  Tab(text: 'Active (${activeProjs.length})'),
                  Tab(text: 'Completed (${completedProjs.length})'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Tab Views Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProjectsList(context, allProjs),
                  _buildProjectsList(context, activeProjs),
                  _buildProjectsList(context, completedProjs),
                ],
              ),
            ),

            // Symmetrical trigger bottom action button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.slate200)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.clearProjectForm();
                    Get.to(() => AssignProjectScreen(clientId: client.id));
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const AppText(
                    'Assign New Project',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProjectsList(BuildContext context, List<ClientProject> projects) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.briefcase, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const AppText('No projects found under this category.', fontSize: 12, color: AppColors.textColorHint),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      physics: const BouncingScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final statusColor = project.status == 'Completed' 
            ? AppColors.successColor 
            : (project.status == 'Active' ? AppColors.warningColor : AppColors.errorColor);

        final startDateStr = DateFormat('dd MMM yyyy').format(project.startDate);
        final dueDateStr = DateFormat('dd MMM yyyy').format(project.dueDate);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    project.name,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      project.status,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.slate100),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDateCol('Start Date', startDateStr),
                  const Spacer(),
                  _buildDateCol('Due Date', dueDateStr),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textColorHint),
        const SizedBox(height: 4),
        AppText(value, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
      ],
    );
  }
}
