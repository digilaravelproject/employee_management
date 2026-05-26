import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../controllers/leads_controller.dart';
import '../models/lead_model.dart';
import '../../role_permissions/models/role_permission_models.dart';

class AssignSalesTeamScreen extends StatefulWidget {
  final Lead lead;
  const AssignSalesTeamScreen({super.key, required this.lead});

  @override
  State<AssignSalesTeamScreen> createState() => _AssignSalesTeamScreenState();
}

class _AssignSalesTeamScreenState extends State<AssignSalesTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  late LeadsController controller;
  
  final selectedRep = Rxn<AppUser>();
  late TextEditingController notesController;
  
  String? _selectionError;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LeadsController>();
    selectedRep.value = widget.lead.assignedTo;
    notesController = TextEditingController(text: 'Lead assigned for further communication and closing.');
  }

  @override
  void dispose() {
    notesController.dispose();
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Assign to Sales Team',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Search Sales Person ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.slate100),
                      ),
                      child: TextField(
                        onChanged: (value) => controller.salespersonSearchQuery.value = value,
                        decoration: const InputDecoration(
                          hintText: 'Search sales person...',
                          hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 14),
                          prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Salespersons list ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'Select Sales Person *',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorHint,
                      letterSpacing: 0.8,
                    ),
                    const SizedBox(height: 8),
                    
                    // Selected salespersons card
                    Obx(() {
                      final reps = controller.filteredSalesReps;
                      if (reps.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: AppText('No sales representatives found.', fontSize: 13, color: AppColors.textColorHint),
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _selectionError != null ? AppColors.errorColor : AppColors.slate200),
                        ),
                        child: Column(
                          children: reps.map((rep) {
                            return Obx(() {
                              final isSelected = selectedRep.value?.email == rep.email;
                              return InkWell(
                                onTap: () {
                                  selectedRep.value = rep;
                                  setState(() {
                                    _selectionError = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: reps.last == rep 
                                        ? null 
                                        : const Border(bottom: BorderSide(color: AppColors.slate100)),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundImage: NetworkImage(rep.avatarUrl),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            AppText(
                                              rep.name,
                                              fontSize: 14,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                              color: AppColors.textColorPrimary,
                                            ),
                                            const SizedBox(height: 2),
                                            const AppText(
                                              'Sales Executive',
                                              fontSize: 11,
                                              color: AppColors.textColorSecondary,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check_circle_rounded, color: AppColors.primaryColor, size: 22)
                                      else
                                        const Icon(Icons.circle_outlined, color: AppColors.textColorHint, size: 22),
                                    ],
                                  ),
                                ),
                              );
                            });
                          }).toList(),
                        ),
                      );
                    }),
                    
                    if (_selectionError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 16),
                        child: AppText(_selectionError!, color: AppColors.errorColor, fontSize: 12),
                      ),
                    
                    const SizedBox(height: 20),

                    // Symmetrical Note Field
                    const AppText(
                      'Note',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorHint,
                      letterSpacing: 0.8,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: AppInputField(
                        controller: notesController,
                        label: 'Assignment Comment',
                        hint: 'Comment...',
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Symmetrical Footer Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.slate200)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const AppText(
                    'Assign Lead',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitAssignment() {
    if (selectedRep.value == null) {
      setState(() {
        _selectionError = 'Please select a sales representative to assign';
      });
      return;
    }

    controller.assignSalesperson(
      widget.lead.id,
      selectedRep.value!,
      notesController.text,
    );
    Get.back(); // Pop Assign to team screen and return
  }
}
