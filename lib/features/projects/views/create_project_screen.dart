import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../employee/management/models/employee_model.dart';
import '../controllers/projects_controller.dart';
import 'project_file_viewer_screen.dart';

class CreateProjectScreen extends StatelessWidget {
  final bool isEditMode;
  const CreateProjectScreen({super.key, required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProjectsController>()
        ? Get.find<ProjectsController>()
        : Get.put(ProjectsController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              isEditMode ? 'Edit Project' : 'Create Project',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
            AppText(
              isEditMode ? 'Modify project parameters' : 'Add new project details & assign team',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorHint,
            ),
          ],
        ),
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
                  // ── Form Input Fields Card ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Project Name', true),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.nameController,
                          style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                          decoration: InputDecoration(
                            hintText: 'Enter project name (e.g. Website Redesign)',
                            hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                            filled: true,
                            fillColor: AppColors.slate50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildLabel('Project Description', true),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.descriptionController,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 13, color: AppColors.textColorPrimary),
                          decoration: InputDecoration(
                            hintText: 'Enter project description and deliverables',
                            hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                            filled: true,
                            fillColor: AppColors.slate50,
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Category selection dropdown
                        _buildLabel('Category', true),
                        const SizedBox(height: 8),
                        Obx(() {
                          final categories = [
                            'Web Development',
                            'Mobile Development',
                            'Software Integration',
                            'Digital Marketing',
                            'Design & Branding',
                            'QA & Testing',
                          ];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: categories.contains(controller.selectedCategory.value)
                                    ? controller.selectedCategory.value
                                    : categories.first,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorHint),
                                dropdownColor: Colors.white,
                                items: categories.map((cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat,
                                    child: AppText(cat, fontSize: 13, color: AppColors.textColorPrimary),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) controller.selectedCategory.value = val;
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Date Pickers Card ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Start Date', true),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context, controller, true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Iconsax.calendar, size: 16, color: AppColors.primaryColor),
                                      const SizedBox(width: 8),
                                      Obx(() => AppText(
                                            _formatDate(controller.startDate.value),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textColorPrimary,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('End Date', true),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context, controller, false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Iconsax.calendar, size: 16, color: AppColors.primaryColor),
                                      const SizedBox(width: 8),
                                      Obx(() => AppText(
                                            _formatDate(controller.endDate.value),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textColorPrimary,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Status Selector Card ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Status', true),
                        const SizedBox(height: 8),
                        Obx(() {
                          final statuses = ['Not Started', 'In Progress', 'On Hold', 'Completed'];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: statuses.contains(controller.selectedStatus.value)
                                    ? controller.selectedStatus.value
                                    : statuses.first,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorHint),
                                dropdownColor: Colors.white,
                                items: statuses.map((stat) {
                                  return DropdownMenuItem<String>(
                                    value: stat,
                                    child: AppText(stat, fontSize: 13, color: AppColors.textColorPrimary),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.selectedStatus.value = val;
                                    if (val == 'Completed') {
                                      controller.progressValue.value = 100.0;
                                    } else if (val == 'Not Started') {
                                      controller.progressValue.value = 0.0;
                                    } else if (val == 'In Progress' && controller.progressValue.value == 0) {
                                      controller.progressValue.value = 25.0;
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('Progress (%)', false),
                            Obx(() => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: AppText(
                                    '${controller.progressValue.value.toInt()}%',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Obx(() => Slider(
                              value: controller.progressValue.value.clamp(0.0, 100.0),
                              min: 0,
                              max: 100,
                              divisions: 100,
                              activeColor: AppColors.primaryColor,
                              inactiveColor: AppColors.slate200,
                              label: '${controller.progressValue.value.toInt()}%',
                              onChanged: (val) {
                                controller.progressValue.value = val;
                                if (val == 100) {
                                  controller.selectedStatus.value = 'Completed';
                                } else if (val > 0 && controller.selectedStatus.value == 'Not Started') {
                                  controller.selectedStatus.value = 'In Progress';
                                }
                              },
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Attach Files block ──
                  Container(
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
                            _buildLabel('Attach Files', false),
                            GestureDetector(
                              onTap: () => controller.pickRealFiles(),
                              child: const Row(
                                children: [
                                  Icon(Iconsax.add, size: 14, color: AppColors.primaryColor),
                                  SizedBox(width: 4),
                                  AppText('Add Files', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // File picker click area
                        InkWell(
                          onTap: () => controller.pickRealFiles(),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.slate300,
                                width: 1.5,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(Iconsax.document_upload, size: 32, color: AppColors.primaryColor),
                                SizedBox(height: 8),
                                AppText('Tap to browse and select files', fontSize: 12, fontWeight: FontWeight.bold),
                                SizedBox(height: 4),
                                AppText('Supports PDF, DOC, PNG, JPG, ZIP (Max 10MB)', fontSize: 10, color: AppColors.textColorHint),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Attached files list
                        Obx(() {
                          final files = controller.selectedFiles;
                          if (files.isEmpty) return const SizedBox();
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              final f = files[index];
                              final isPdf = f.isPdf;
                              final isImage = f.isImage;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => ProjectFileViewer.open(context, f),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.slate200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isPdf
                                              ? Iconsax.document_text
                                              : (isImage ? Iconsax.gallery : Iconsax.document),
                                          size: 20,
                                          color: isPdf
                                              ? Colors.redAccent
                                              : (isImage ? AppColors.indigo500 : AppColors.primaryColor),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              AppText(f.name, fontSize: 12, fontWeight: FontWeight.bold),
                                              AppText('${f.sizeMb} MB • ${f.type} • Tap to preview',
                                                  fontSize: 9, color: AppColors.textColorHint),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.fullscreen_rounded, color: AppColors.primaryColor, size: 20),
                                          tooltip: 'Preview',
                                          onPressed: () => ProjectFileViewer.open(context, f),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close_rounded, color: AppColors.errorColor, size: 18),
                                          onPressed: () => controller.removeAttachedFile(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Assign Team Members Section (Live Employee List API) ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Row(
                            children: [
                              _buildLabel('Assign Team Members', false),
                              if (controller.selectedTeamEmployees.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: AppText(
                                    '${controller.selectedTeamEmployees.length}',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ],
                          )),
                      GestureDetector(
                        onTap: () {
                          if (controller.employeesList.isEmpty) {
                            controller.fetchEmployees();
                          }
                          _showAssignTeamBottomSheet(context, controller);
                        },
                        child: const Row(
                          children: [
                            Icon(Iconsax.add, size: 14, color: AppColors.primaryColor),
                            SizedBox(width: 4),
                            AppText('Add Members', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Selected Team Members Display List
                  Obx(() {
                    final members = controller.selectedTeamEmployees;
                    if (members.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Iconsax.profile_2user, size: 30, color: AppColors.textColorHint),
                              const SizedBox(height: 8),
                              const AppText(
                                'No team members assigned yet',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColorHint,
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  if (controller.employeesList.isEmpty) {
                                    controller.fetchEmployees();
                                  }
                                  _showAssignTeamBottomSheet(context, controller);
                                },
                                icon: const Icon(Iconsax.user_add, size: 14),
                                label: const Text('Assign from Employees'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryColor,
                                  side: const BorderSide(color: AppColors.primaryColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: members.length,
                            separatorBuilder: (context, index) => const Divider(height: 16, color: AppColors.slate100),
                            itemBuilder: (context, index) {
                              final emp = members[index];
                              return Row(
                                children: [
                                  _buildEmployeeAvatar(emp),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: AppText(
                                                emp.name,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textColorPrimary,
                                                maxLines: 1,
                                              ),
                                            ),
                                            if (emp.employeeId.isNotEmpty)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.slate100,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: AppText(
                                                  emp.employeeId,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textColorSecondary,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        AppText(
                                          emp.designation.isNotEmpty ? emp.designation : emp.email,
                                          fontSize: 11,
                                          color: AppColors.textColorHint,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Iconsax.minus_cirlce, color: AppColors.errorColor, size: 20),
                                    onPressed: () => controller.toggleTeamEmployee(emp),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // ── Bottom Action Button ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() {
                  final isLoading = isEditMode
                      ? controller.isUpdatingProject.value
                      : controller.isCreatingProject.value;
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (isEditMode) {
                              controller.updateProject();
                            } else {
                              controller.createProjectApi();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : AppText(
                            isEditMode ? 'Update Project' : 'Create Project',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeAvatar(EmployeeModel emp) {
    final pic = emp.profilePic;
    String? url;
    if (pic != null && pic.isNotEmpty) {
      url = pic.startsWith('http') ? pic : AppConstants.getFileUrl(pic);
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primaryLight,
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null
          ? AppText(
              emp.name.isNotEmpty ? emp.name[0].toUpperCase() : 'E',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            )
          : null,
    );
  }

  Widget _buildLabel(String text, bool isRequired) {
    return Row(
      children: [
        AppText(text, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
        if (isRequired)
          const AppText(' *', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.errorColor),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate(BuildContext context, ProjectsController controller, bool isStart) async {
    final initial = isStart ? controller.startDate.value : controller.endDate.value;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isStart) {
        controller.startDate.value = picked;
      } else {
        controller.endDate.value = picked;
      }
    }
  }

  void _showAssignTeamBottomSheet(BuildContext context, ProjectsController controller) {
    final searchCtrl = TextEditingController(text: controller.employeeSearchQuery.value);

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(color: AppColors.slate300, borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Select Team Members', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                    const SizedBox(height: 2),
                    Obx(() => AppText(
                          '${controller.selectedTeamEmployees.length} of ${controller.employeesList.length} selected',
                          fontSize: 11,
                          color: AppColors.textColorHint,
                        )),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const AppText('Done', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar
            TextField(
              controller: searchCtrl,
              onChanged: (val) => controller.employeeSearchQuery.value = val,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by employee name, role or ID...',
                hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 12),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textColorHint),
                suffixIcon: searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          searchCtrl.clear();
                          controller.employeeSearchQuery.value = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.slate50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.slate100),

            // Live Employee List from API
            Expanded(
              child: Obx(() {
                if (controller.isLoadingEmployees.value && controller.employeesList.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryColor),
                        SizedBox(height: 12),
                        AppText('Loading employees from server...', fontSize: 12, color: AppColors.textColorSecondary),
                      ],
                    ),
                  );
                }

                final list = controller.filteredEmployeesList;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.user_search, size: 36, color: AppColors.textColorHint),
                        const SizedBox(height: 10),
                        const AppText('No employees match your search', fontSize: 13, fontWeight: FontWeight.bold),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () => controller.fetchEmployees(),
                          child: const Text('Refresh Employee List'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: list.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) => const Divider(height: 16, color: AppColors.slate100),
                  itemBuilder: (context, index) {
                    final emp = list[index];
                    return Obx(() {
                      final isSelected = controller.selectedTeamEmployees.any((e) =>
                          e.id.toString() == emp.id.toString() ||
                          (emp.employeeId.isNotEmpty && e.employeeId == emp.employeeId));
                      return InkWell(
                        onTap: () => controller.toggleTeamEmployee(emp),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              _buildEmployeeAvatar(emp),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppText(
                                            emp.name,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textColorPrimary,
                                            maxLines: 1,
                                          ),
                                        ),
                                        if (emp.employeeId.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.slate100,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: AppText(
                                              emp.employeeId,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textColorSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    AppText(
                                      emp.designation.isNotEmpty
                                          ? '${emp.designation} • ${emp.department}'
                                          : emp.email,
                                      fontSize: 11,
                                      color: AppColors.textColorHint,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isSelected)
                                const Icon(Icons.check_box_rounded, color: AppColors.primaryColor, size: 22)
                              else
                                const Icon(Icons.check_box_outline_blank_rounded, color: AppColors.slate300, size: 22),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
