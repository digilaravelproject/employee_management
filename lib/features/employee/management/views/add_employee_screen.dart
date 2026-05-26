import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input_field.dart';
import '../controllers/employee_controller.dart';
import '../models/employee_model.dart';

class AddEmployeeScreen extends StatefulWidget {
  final EmployeeModel? employee; // If provided, we are in Edit mode
  const AddEmployeeScreen({super.key, this.employee});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final controller = Get.find<EmployeeController>();
  
  late TextEditingController nameController;
  late TextEditingController mobileController;
  late TextEditingController emailController;
  late TextEditingController salaryController;
  late TextEditingController addressController;
  late TextEditingController emergencyContactController;
  late TextEditingController empIdController;
  
  String selectedDesignation = '';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    nameController = TextEditingController(text: e?.name);
    mobileController = TextEditingController(text: e?.mobile);
    emailController = TextEditingController(text: e?.email);
    salaryController = TextEditingController(text: e?.salary.toString() ?? '');
    addressController = TextEditingController(text: e?.address);
    emergencyContactController = TextEditingController(text: e?.emergencyContact);
    empIdController = TextEditingController(text: e?.employeeId ?? 'EMP-${DateFormat('yyyy').format(DateTime.now())}-${(controller.employees.length + 1).toString().padLeft(3, '0')}');
    
    selectedDesignation = e?.designation ?? controller.designations[0];
    if (e != null) {
      controller.selectedSkills.assignAll(e.skills);
    } else {
      controller.selectedSkills.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
        ),
        title: AppText(widget.employee == null ? 'New Employee' : 'Edit Employee', fontSize: 18, fontWeight: FontWeight.w800),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildSectionCard(
              title: 'Identity Details',
              icon: Iconsax.personalcard,
              color: Colors.blue,
              children: [
                AppInputField(controller: empIdController, hint: 'Employee ID', icon: Iconsax.key, readOnly: true),
                const SizedBox(height: 16),
                AppInputField(controller: nameController, hint: 'Full Name', icon: Iconsax.user),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Contact Information',
              icon: Iconsax.call,
              color: Colors.green,
              children: [
                AppInputField(controller: mobileController, hint: 'Mobile Number', icon: Iconsax.call, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                AppInputField(controller: emailController, hint: 'Email Address', icon: Iconsax.sms, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                AppInputField(controller: emergencyContactController, hint: 'Emergency Contact', icon: Iconsax.call_calling, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                AppInputField(controller: addressController, hint: 'Residential Address', icon: Iconsax.location, maxLines: 2),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Professional Details',
              icon: Iconsax.briefcase,
              color: Colors.orange,
              children: [
                _buildDropdown('Designation', controller.designations, (v) => setState(() => selectedDesignation = v!)),
                const SizedBox(height: 16),
                AppInputField(controller: salaryController, hint: 'Monthly Salary', icon: Iconsax.wallet, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildDatePicker('Joining Date', selectedDate, (date) => setState(() => selectedDate = date)),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Expertise & Skills',
              icon: Iconsax.medal_star,
              color: Colors.purple,
              children: [
                Obx(() => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: controller.availableSkills.map((skill) {
                    final isSelected = controller.selectedSkills.contains(skill);
                    return FilterChip(
                      selected: isSelected,
                      label: AppText(skill, fontSize: 12, color: isSelected ? Colors.white : AppColors.textColorPrimary),
                      onSelected: (_) => controller.toggleSkill(skill),
                      selectedColor: AppColors.primaryColor,
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
                          //borderSide: BorderSide(color: isSelected ? AppColors.primaryColor : AppColors.slate200)
                        ),
                    );
                  }).toList(),
                )),
              ],
            ),
            const SizedBox(height: 40),
            AppButton(
              text: widget.employee == null ? 'Register Employee' : 'Update Details',
              onPressed: _handleSave,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Color color, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              AppText(title, fontSize: 15, fontWeight: FontWeight.w700),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 12, color: AppColors.textColorSecondary),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
         // padding: const EdgeInsets.symmetric(horizontal: 16),
       //   decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: selectedDesignation,
              decoration: const InputDecoration(border: InputBorder.none),
              items: items.map((e) => DropdownMenuItem(value: e, child: AppText(e, fontSize: 14))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 12, color: AppColors.textColorSecondary),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100));
            if (picked != null) onPick(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Iconsax.calendar, size: 20, color: AppColors.textColorSecondary),
                const SizedBox(width: 12),
                AppText(DateFormat('dd MMMM yyyy').format(date), fontSize: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    if (nameController.text.isEmpty || mobileController.text.isEmpty) {
      CustomSnackbar.showInfo('Name and Mobile are mandatory',);
      return;
    }

    final emp = EmployeeModel(
      id: widget.employee?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: empIdController.text,
      name: nameController.text,
      mobile: mobileController.text,
      email: emailController.text,
      designation: selectedDesignation,
      salary: double.tryParse(salaryController.text) ?? 0,
      skills: List.from(controller.selectedSkills),
      joiningDate: DateFormat('dd MMMM yyyy').format(selectedDate),
      address: addressController.text,
      emergencyContact: emergencyContactController.text,
    );

    if (widget.employee == null) {
      controller.addEmployee(emp);
    } else {
      controller.updateEmployee(emp);
    }
    Get.back();
    CustomSnackbar.showSuccess('Employee records updated');
  }
}
