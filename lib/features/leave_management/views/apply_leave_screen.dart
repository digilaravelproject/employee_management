import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../bindings/apply_leave_binding.dart';
import '../controllers/apply_leave_controller.dart';
import '../models/leave_type_model.dart';

class ApplyLeaveScreen extends StatelessWidget {
  const ApplyLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure binding dependencies are initialized
    if (!Get.isRegistered<ApplyLeaveController>()) {
      ApplyLeaveBinding().dependencies();
    }
    final controller = Get.find<ApplyLeaveController>();

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
        title: const AppText('Apply Leave', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Fill the details below to request a new leave. Fields marked with an asterisk (*) are required.',
                    fontSize: 12,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 24),
                  
                  // Leave Type Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Leave Type', true),
                        const SizedBox(height: 12),
                        Obx(() => CustomBottomSheetDropdown(
                          label: 'Leave Type',
                          selectedValue: controller.selectedLeaveType.value.isNotEmpty ? controller.selectedLeaveType.value : null,
                          items: controller.leaveTypeNames,
                          prefixIcon: Iconsax.tree,
                          prefixIconColor: Colors.green,
                          prefixIconBgColor: Colors.green.withValues(alpha: 0.1),
                          onChanged: (val) => controller.setLeaveType(val),
                        )),
                        
                        // Enriched Leave Type Meta Information
                        Obx(() {
                          final selected = controller.selectedLeaveTypeModel.value;
                          if (selected == null) return const SizedBox.shrink();
                          return _buildLeaveTypeDetailsCard(selected);
                        }),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Date Selection Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('From Date', true),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => controller.selectFromDate(context),
                                    child: Obx(() => _buildDatePicker(controller.getFormattedFromDate())),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('To Date', true),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => controller.selectToDate(context),
                                    child: Obx(() => _buildDatePicker(controller.getFormattedToDate())),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AppText('Total Days', fontSize: 13, color: AppColors.textColorSecondary, fontWeight: FontWeight.w600),
                              Obx(() => AppText(
                                '${controller.totalDays.value % 1 == 0 ? controller.totalDays.value.toInt() : controller.totalDays.value} Days',
                                fontSize: 14, 
                                fontWeight: FontWeight.w800, 
                                color: AppColors.primaryColor,
                              )),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildLabel('Session', true),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Obx(
                            () => Row(
                              children: [
                                Expanded(child: _buildSessionButton('Full Day', controller.sessionType.value == 'Full Day', () => controller.setSessionType('Full Day'))),
                                Expanded(child: _buildSessionButton('1st Half', controller.sessionType.value == '1st Half', () => controller.setSessionType('1st Half'))),
                                Expanded(child: _buildSessionButton('2nd Half', controller.sessionType.value == '2nd Half', () => controller.setSessionType('2nd Half'))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Assign Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Assign', false, isOptional: true),
                        const SizedBox(height: 12),
                        Obx(() => CustomBottomSheetDropdown(
                          label: 'Assign',
                          selectedValue: controller.selectedAssignee.value,
                          items: controller.assigneeList,
                          prefixIcon: Iconsax.user_tag,
                          prefixIconColor: AppColors.primaryColor,
                          prefixIconBgColor: AppColors.primaryLight,
                          onChanged: (val) => controller.setAssignee(val),
                        )),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Reason for Leave', true),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: controller.reasonController,
                          maxLines: 4,
                          maxLength: 250,
                          decoration: InputDecoration(
                            hintText: 'Please provide reason for leave...',
                            hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                            filled: true,
                            fillColor: AppColors.slate50,
                            counterStyle: const TextStyle(fontSize: 11, color: AppColors.textColorHint),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.slate200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.slate200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primaryColor),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildLabel('Contact During Leave', false, isOptional: true),
                        const SizedBox(height: 12),
                        _buildTextField(
                          Iconsax.call,
                          'Enter contact number',
                          controller: controller.contactController,
                          keyboardType: TextInputType.phone,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildLabel('Address During Leave', false, isOptional: true),
                        const SizedBox(height: 12),
                        _buildTextField(
                          Iconsax.location,
                          'Enter address',
                          controller: controller.addressController,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Obx(() {
                          final selected = controller.selectedLeaveTypeModel.value;
                          final isRequired = selected?.requiresAttachment == true;
                          return _buildLabel('Upload Document', isRequired, isOptional: !isRequired);
                        }),
                        const SizedBox(height: 12),
                        
                        // Attachment picker widget
                        Obx(() {
                          final file = controller.selectedAttachment.value;
                          if (file != null) {
                            final fileName = file.path.split('/').last;
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Iconsax.document_text, color: AppColors.primaryColor, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          fileName,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        const AppText(
                                          'Attached successfully',
                                          fontSize: 11,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                    onPressed: () => controller.removeAttachment(),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return GestureDetector(
                            onTap: () => controller.pickAttachment(),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.slate50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: CustomPaint(
                                painter: DashedBorderPainter(color: AppColors.slate300, radius: 16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Iconsax.document_upload, color: AppColors.primaryColor, size: 28),
                                      ),
                                      const SizedBox(height: 16),
                                      const AppText(
                                        'Click to upload supporting document',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textColorPrimary,
                                      ),
                                      const SizedBox(height: 4),
                                      const AppText(
                                        'JPG, PNG (Max 5MB)',
                                        fontSize: 11,
                                        color: AppColors.textColorSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40), // Space for button
                ],
              ),
            ),
          ),
          
          // Bottom button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isSubmitting.value 
                      ? null 
                      : () => controller.submitLeaveApplication(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.6),
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            AppText('Submit Application', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ],
                        ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveTypeDetailsCard(LeaveTypeModel leaveType) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leaveType.code.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(
                    leaveType.code,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: leaveType.isPaid ? Colors.green.withValues(alpha: 0.12) : Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText(
                  leaveType.isPaid ? 'Paid Leave' : 'Unpaid',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: leaveType.isPaid ? Colors.green[800] : Colors.orange[800],
                ),
              ),
              const Spacer(),
              AppText(
                'Allowance: ${leaveType.annualAllowance} Days/Yr',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorSecondary,
              ),
            ],
          ),
          if (leaveType.description != null && leaveType.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            AppText(
              leaveType.description!,
              fontSize: 12,
              color: AppColors.textColorSecondary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (leaveType.requiresAttachment) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Iconsax.info_circle, size: 13, color: Colors.orange),
                const SizedBox(width: 4),
                AppText(
                  'Supporting document is mandatory for this leave.',
                  fontSize: 11,
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isRequired, {bool isOptional = false}) {
    return Row(
      children: [
        AppText(text, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
        if (isRequired)
          const AppText(' *', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
        if (isOptional)
          const AppText(' (Optional)', fontSize: 11, color: AppColors.textColorHint),
      ],
    );
  }

  Widget _buildDatePicker(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: AppText(value, fontSize: 13, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis)),
          const Icon(Iconsax.calendar_1, color: AppColors.primaryColor, size: 18),
        ],
      ),
    );
  }

  Widget _buildSessionButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: AppText(
            label,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textColorSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon, 
    String hint, {
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.textColorSecondary, size: 18),
        filled: true,
        fillColor: AppColors.slate50,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    var path = Path();
    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
    path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    Path dashPath = Path();
    double dashWidth = 6.0;
    double dashSpace = 6.0;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
