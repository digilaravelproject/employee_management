import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/projects_controller.dart';

class CreateProjectScreen extends StatelessWidget {
  final bool isEditMode;
  const CreateProjectScreen({super.key, required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectsController>();

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
              isEditMode ? 'Modify project parameters' : 'Add new project details',
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
                            hintText: 'Enter project name',
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
                            hintText: 'Enter project description',
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
                          final categories = ['Web Development', 'Mobile Development', 'Software Integration', 'Digital Marketing'];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.selectedCategory.value,
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
                                      const Icon(Iconsax.calendar, size: 16, color: AppColors.textColorHint),
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
                                      const Icon(Iconsax.calendar, size: 16, color: AppColors.textColorHint),
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
                                value: controller.selectedStatus.value,
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
                                  if (val != null) controller.selectedStatus.value = val;
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Attach Files dashed UI block ──
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
                              onTap: () {
                                // Add mock files on click
                                controller.addMockFile('Proposal_v3.pdf', 3.2, 'pdf');
                              },
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

                        // Dashed drag & drop style mockup box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.slate300,
                              width: 1.5,
                              style: BorderStyle.solid, // Simple border in replacement of complex dashed borders
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(Iconsax.document_upload, size: 32, color: AppColors.textColorHint),
                              SizedBox(height: 8),
                              AppText('Drag & drop files here', fontSize: 12, fontWeight: FontWeight.bold),
                              SizedBox(height: 4),
                              AppText('or browse files (Max size: 10MB)', fontSize: 10, color: AppColors.textColorHint),
                            ],
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
                              return Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.slate200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Iconsax.document_text, size: 20, color: AppColors.primaryColor),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AppText(f.name, fontSize: 12, fontWeight: FontWeight.bold),
                                          AppText('${f.sizeMb} MB • ${f.type}', fontSize: 9, color: AppColors.textColorHint),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: AppColors.errorColor, size: 18),
                                      onPressed: () => controller.selectedFiles.remove(f),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Assign Team Members Section ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Assign Team Members', false),
                      GestureDetector(
                        onTap: () => _showAssignTeamBottomSheet(context, controller),
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

                  Obx(() {
                    final members = controller.selectedEmployees;
                    if (members.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: const Center(
                          child: AppText(
                            'No team members assigned yet',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColorHint,
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
                            separatorBuilder: (context, index) => const Divider(height: 20, color: AppColors.slate200),
                            itemBuilder: (context, index) {
                              final emp = members[index];
                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage: NetworkImage(emp.avatarUrl),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(emp.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                        const SizedBox(height: 2),
                                        AppText(emp.email, fontSize: 10, color: AppColors.textColorHint),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Iconsax.minus_cirlce, color: AppColors.errorColor, size: 20),
                                    onPressed: () => controller.selectedEmployees.remove(emp),
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
                child: ElevatedButton(
                  onPressed: () {
                    if (isEditMode) {
                      controller.updateProject();
                    } else {
                      controller.saveProject();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor, // Indigo replaced
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: AppText(
                    isEditMode ? 'Update Project' : 'Create Project',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
      lastDate: DateTime(2030),
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
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Select Team Members', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                    SizedBox(height: 2),
                    AppText('Assign multiple employees to this project', fontSize: 11, color: AppColors.textColorHint),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const AppText('Done', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: controller.allEmployees.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(height: 20, color: AppColors.slate200),
                itemBuilder: (context, index) {
                  final user = controller.allEmployees[index];
                  return Obx(() {
                    final isSelected = controller.selectedEmployees.contains(user);
                    return InkWell(
                      onTap: () => controller.toggleEmployeeSelection(user),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(user.avatarUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(user.name, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                                const SizedBox(height: 2),
                                AppText(user.email, fontSize: 10, color: AppColors.textColorHint),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_box_rounded, color: AppColors.primaryColor, size: 22)
                          else
                            const Icon(Icons.check_box_outline_blank_rounded, color: AppColors.slate300, size: 22),
                        ],
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
