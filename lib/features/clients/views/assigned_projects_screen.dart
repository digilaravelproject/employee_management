import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/clients_controller.dart';
import '../models/client_detail_model.dart';
import 'assign_project_screen.dart';

class AssignedProjectsScreen extends StatefulWidget {
  final String? clientId;
  const AssignedProjectsScreen({super.key, this.clientId});

  @override
  State<AssignedProjectsScreen> createState() => _AssignedProjectsScreenState();
}

class _AssignedProjectsScreenState extends State<AssignedProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ClientsController controller;

  String get effectiveClientId =>
      widget.clientId ?? controller.selectedClient.value?.id.toString() ?? '';

  @override
  void initState() {
    super.initState();
    controller = Get.find<ClientsController>();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    if (effectiveClientId.isNotEmpty) {
      controller.fetchClientProjects(effectiveClientId, status: 'all');
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (effectiveClientId.isEmpty) return;

    String status = 'all';
    if (_tabController.index == 1) status = 'active';
    if (_tabController.index == 2) status = 'completed';

    controller.fetchClientProjects(effectiveClientId, status: status);
  }

  String get _currentTabStatus {
    if (_tabController.index == 1) return 'active';
    if (_tabController.index == 2) return 'completed';
    return 'all';
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textColorPrimary,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Client Projects',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textColorPrimary),
            tooltip: 'Refresh',
            onPressed: () {
              if (effectiveClientId.isNotEmpty) {
                controller.fetchClientProjects(
                  effectiveClientId,
                  status: _currentTabStatus,
                );
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final clientInfo = controller.clientProjectsClientInfo.value;
        final selectedClient = controller.selectedClient.value;
        final clientName = clientInfo?.name.isNotEmpty == true
            ? clientInfo!.name
            : (selectedClient?.name ?? 'Client');
        final clientEmail = clientInfo?.email.isNotEmpty == true
            ? clientInfo!.email
            : (selectedClient?.email ?? '');
        final clientMobile = clientInfo?.mobileNumber.isNotEmpty == true
            ? clientInfo!.mobileNumber
            : (selectedClient?.mobile ?? '');
        final clientStatus = clientInfo?.status.isNotEmpty == true
            ? clientInfo!.status
            : (selectedClient?.status ?? 'Active');

        final counts = controller.clientProjectsCounts.value;
        final allCount = counts?.all ?? controller.clientProjects.length;
        final activeCount = counts?.active ?? 0;
        final completedCount = counts?.completed ?? 0;

        final projects = controller.clientProjects;
        final isLoading = controller.isLoadingClientProjects.value;

        return Column(
          children: [
            // ── Mini Header Summary (Real Client Info from API) ──
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
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                      child: Center(
                        child: AppText(
                          clientName.isNotEmpty
                              ? clientName.substring(0, clientName.length >= 2 ? 2 : 1).toUpperCase()
                              : 'CL',
                          fontSize: 14,
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
                          Row(
                            children: [
                              Expanded(
                                child: AppText(
                                  clientName,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (clientStatus.toLowerCase() == 'active'
                                          ? AppColors.successColor
                                          : AppColors.slate400)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: AppText(
                                  clientStatus,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: clientStatus.toLowerCase() == 'active'
                                      ? AppColors.successColor
                                      : AppColors.slate400,
                                ),
                              ),
                            ],
                          ),
                          if (clientEmail.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            AppText(
                              clientEmail,
                              fontSize: 12,
                              color: AppColors.textColorSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (clientMobile.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            AppText(
                              clientMobile,
                              fontSize: 11,
                              color: AppColors.textColorHint,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tabs Header with Real API Counts
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
                  Tab(text: 'All Projects ($allCount)'),
                  Tab(text: 'Active ($activeCount)'),
                  Tab(text: 'Completed ($completedCount)'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Projects List Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        if (effectiveClientId.isNotEmpty) {
                          await controller.fetchClientProjects(
                            effectiveClientId,
                            status: _currentTabStatus,
                          );
                        }
                      },
                      child: _buildProjectsList(context, projects),
                    ),
            ),

            // Bottom Action Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.slate200)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    controller.clearProjectForm();
                    final added = await Get.to(() => AssignProjectScreen(clientId: effectiveClientId));
                    if (added == true) {
                      controller.fetchClientProjects(effectiveClientId, status: _currentTabStatus);
                      controller.fetchClientDetail(effectiveClientId);
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const AppText(
                    'Add New Project',
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

  Widget _buildProjectsList(BuildContext context, List<ClientDetailProject> projects) {
    if (projects.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.briefcase, size: 52, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                const AppText(
                  'No projects found under this status.',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColorHint,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final statusColor = _getStatusColor(project.status);
        final currencyFormat = NumberFormat.currency(locale: 'HI', symbol: '₹', decimalDigits: 0);
        final valStr = currencyFormat.format(project.estimatedValue);

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
              // Header: Project Name & Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppText(
                      project.name,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      project.status,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Category & Priority Chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (project.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        project.category,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorSecondary,
                      ),
                    ),
                  if (project.priority.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        'Priority: ${project.priority}',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  if (project.workingDays > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.indigo500.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        '${project.workingDays} Working Days',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.indigo500,
                      ),
                    ),
                ],
              ),

              if (project.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                AppText(
                  project.description,
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.slate100),
              const SizedBox(height: 12),

              // Financial & Timeline Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDataCol('Estimated Value', valStr, isPrimary: true),
                  _buildDataCol('Start Date', _formatDate(project.startDate)),
                  _buildDataCol('End Date', _formatDate(project.endDate)),
                ],
              ),

              // Optional Project Manager info
              if (project.projectManager != null && project.projectManager!.name.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.user, size: 14, color: AppColors.textColorSecondary),
                      const SizedBox(width: 6),
                      AppText(
                        'Manager: ${project.projectManager!.name}',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataCol(String label, String value, {bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorHint,
        ),
        const SizedBox(height: 4),
        AppText(
          value,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isPrimary ? AppColors.primaryColor : AppColors.textColorPrimary,
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '—';
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(d);
    } catch (_) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('progress') || s == 'active') {
      return AppColors.warningColor;
    } else if (s.contains('complete') || s == 'done') {
      return AppColors.successColor;
    } else if (s.contains('hold') || s.contains('pause')) {
      return AppColors.indigo500;
    }
    return AppColors.textColorSecondary;
  }
}
