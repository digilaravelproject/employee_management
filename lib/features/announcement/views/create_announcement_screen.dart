import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  String _selectedType = 'General';
  String _selectedAudience = 'All Employees';
  String _selectedPriority = 'Normal';

  bool _notifyInApp = true;
  bool _notifyEmail = true;
  bool _notifySMS = false;

  DateTime? _publishDate;
  TimeOfDay? _publishTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _publishDate ?? DateTime.now(),
      firstDate: DateTime.now(),
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
    if (picked != null && picked != _publishDate) {
      setState(() {
        _publishDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _publishTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _publishTime) {
      setState(() {
        _publishTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateText = _publishDate != null 
        ? DateFormat('dd MMM yyyy').format(_publishDate!) 
        : '20 May 2025';
    
    String timeText = _publishTime != null
        ? _publishTime!.format(context)
        : '10:30 AM';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Create Announcement', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,

      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRequiredLabel('Announcement Title'),
                  const SizedBox(height: 8),
                  _buildTextField('e.g. Holiday on 25 May'),
                  
                  const SizedBox(height: 24),
                  
                  _buildRequiredLabel('Announcement Type'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTypeCard('General', Iconsax.speaker, AppColors.primaryColor)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTypeCard('Holiday', Iconsax.calendar_1, Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTypeCard('Reminder', Iconsax.notification, Colors.orange)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTypeCard('Urgent', Iconsax.danger, Colors.red)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRequiredLabel('Publish Date'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: _buildDropdownField(dateText, Iconsax.calendar_1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRequiredLabel('Publish Time'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectTime(context),
                              child: _buildDropdownField(timeText, Iconsax.clock),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildRequiredLabel('Audience'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildRadioOption('All Employees'),
                      _buildRadioOption('Specific Department'),
                      _buildRadioOption('Specific Designation'),
                      _buildRadioOption('Custom Employees'),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.people, color: AppColors.primaryColor, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: AppText('This announcement will be visible to all employees.', fontSize: 12, color: AppColors.primaryColor),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const AppText('Priority', fontSize: 13, fontWeight: FontWeight.bold),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildPriorityCard('Low', Icons.arrow_downward, Colors.blue)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildPriorityCard('Normal', Icons.remove_circle_outline, Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildPriorityCard('High', Icons.arrow_upward, Colors.orange)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildPriorityCard('Urgent', Icons.error_outline, Colors.red)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildRequiredLabel('Message / Description'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.slate200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Toolbar
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        //   decoration: const BoxDecoration(
                        //     color: AppColors.slate50,
                        //     borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        //     border: Border(bottom: BorderSide(color: AppColors.slate200)),
                        //   ),
                        //   child: Row(
                        //     children: [
                        //       _buildToolbarIcon(Icons.format_bold),
                        //       _buildToolbarIcon(Icons.format_italic),
                        //       _buildToolbarIcon(Icons.format_underlined),
                        //       const SizedBox(width: 8),
                        //       Container(width: 1, height: 20, color: AppColors.slate300),
                        //       const SizedBox(width: 8),
                        //       _buildToolbarIcon(Icons.format_list_bulleted),
                        //       _buildToolbarIcon(Icons.format_list_numbered),
                        //       _buildToolbarIcon(Icons.format_align_left),
                        //       const SizedBox(width: 8),
                        //       Container(width: 1, height: 20, color: AppColors.slate300),
                        //       const SizedBox(width: 8),
                        //       _buildToolbarIcon(Icons.link),
                        //     ],
                        //   ),
                        // ),
                        // Text Area
                        TextFormField(
                          maxLines: 6,
                          decoration: const InputDecoration(
                            hintText: 'Type your announcement message here...',
                            hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: AppText('0/1000', fontSize: 11, color: AppColors.textColorSecondary),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      const AppText('Attachment', fontSize: 13, fontWeight: FontWeight.bold),
                      const AppText(' (Optional)', fontSize: 13, color: AppColors.textColorSecondary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildFileUploadArea(),
                  
                  const SizedBox(height: 24),
                  
                  const AppText('Send Notification Via', fontSize: 13, fontWeight: FontWeight.bold),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildCheckbox('In-App Notification', _notifyInApp, (val) => setState(() => _notifyInApp = val ?? false)),
                      const SizedBox(width: 16),
                      _buildCheckbox('Email', _notifyEmail, (val) => setState(() => _notifyEmail = val ?? false)),
                      const SizedBox(width: 16),
                      _buildCheckbox('SMS', _notifySMS, (val) => setState(() => _notifySMS = val ?? false)),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const AppText('Save as Draft', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Announcement published successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const AppText('Publish Announcement', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredLabel(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(text, fontSize: 13, fontWeight: FontWeight.bold),
        const AppText(' *', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
      ],
    );
  }

  Widget _buildTextField(String hint) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget _buildDropdownField(String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textColorSecondary, size: 18),
          const SizedBox(width: 8),
          Expanded(child: AppText(value, fontSize: 13, fontWeight: FontWeight.w500)),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.textColorSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildTypeCard(String title, IconData icon, Color color) {
    final isSelected = _selectedType == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = title),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.slate200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: isSelected ? color : AppColors.textColorSecondary, size: 28),
                  const SizedBox(height: 8),
                  AppText(
                    title,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.textColorPrimary : AppColors.textColorSecondary,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String label) {
    final isSelected = _selectedAudience == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedAudience = label),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : AppColors.slate300,
                width: isSelected ? 6 : 1.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AppText(label, fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
        ],
      ),
    );
  }

  Widget _buildPriorityCard(String title, IconData icon, Color color) {
    final isSelected = _selectedPriority == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.slate200,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            AppText(
              title,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(icon, color: AppColors.textColorPrimary, size: 18),
    );
  }

  Widget _buildFileUploadArea() {
    return CustomPaint(
      painter: _DashedRectPainter(color: AppColors.primaryColor.withValues(alpha: 0.5)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                const AppText('Upload Files', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ],
            ),
            const SizedBox(height: 4),
            const AppText('PDF, JPG, PNG or DOC (Max. 10MB)', fontSize: 11, color: AppColors.textColorSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 4),
        AppText(label, fontSize: 12, fontWeight: FontWeight.w500),
      ],
    );
  }
}

// Dashed Border Painter
class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 5;
    const double radius = 12;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    Path path = Path()..addRRect(rrect);
    PathMetrics pathMetrics = path.computeMetrics();

    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double len = distance + dashWidth;
        canvas.drawPath(
          pathMetric.extractPath(distance, len),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
