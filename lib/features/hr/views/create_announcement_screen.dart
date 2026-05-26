import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/hr_controller.dart';
import '../models/hr_models.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _selectedType = 'General';
  String _selectedAudience = 'All Employees';
  String _selectedPriority = 'Normal';

  bool _notifyInApp = true;
  bool _notifyEmail = true;
  bool _notifySMS = false;

  DateTime? _publishDate;
  TimeOfDay? _publishTime;

  @override
  void initState() {
    super.initState();
    _publishDate = DateTime.now();
    _publishTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

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
    if (picked != null) {
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
    if (picked != null) {
      setState(() {
        _publishTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HrController>();

    String dateText = _publishDate != null 
        ? DateFormat('dd MMM yyyy').format(_publishDate!) 
        : 'Select Date';
    
    String timeText = _publishTime != null
        ? _publishTime!.format(context)
        : 'Select Time';

    return Scaffold(
      backgroundColor: Colors.white,
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText('Create Announcement', fontSize: 20, fontWeight: FontWeight.bold),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequiredLabel('Announcement Title'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter announcement title' : null,
                      decoration: InputDecoration(
                        hintText: 'e.g. Holiday on 25 May',
                        hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.slate50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildRequiredLabel('Announcement Type'),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 20),
                    
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
                        const SizedBox(width: 12),
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
                    const SizedBox(height: 20),
                    
                    _buildRequiredLabel('Audience'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        _buildRadioOption('All Employees'),
                        _buildRadioOption('Specific Department'),
                        _buildRadioOption('Specific Designation'),
                        _buildRadioOption('Custom Employees'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.people, color: AppColors.primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppText(
                              'This announcement will be visible to $_selectedAudience.', 
                              fontSize: 11, 
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const AppText('Priority', fontSize: 13, fontWeight: FontWeight.bold),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildPriorityCard('Low', Icons.arrow_downward, Colors.blue)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildPriorityCard('Normal', Icons.remove_circle_outline, Colors.green)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildPriorityCard('High', Icons.arrow_upward, Colors.orange)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildPriorityCard('Urgent', Icons.error_outline, Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    _buildRequiredLabel('Message / Description'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.slate200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextFormField(
                        controller: _contentController,
                        maxLines: 5,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter announcement description' : null,
                        decoration: const InputDecoration(
                          hintText: 'Type your announcement message here...',
                          hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        const AppText('Attachment', fontSize: 13, fontWeight: FontWeight.bold),
                        const AppText(' (Optional)', fontSize: 13, color: AppColors.textColorSecondary),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildFileUploadArea(),
                    const SizedBox(height: 20),
                    
                    const AppText('Send Notification Via', fontSize: 13, fontWeight: FontWeight.bold),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildCheckbox('In-App', _notifyInApp, (val) => setState(() => _notifyInApp = val ?? false)),
                        const SizedBox(width: 14),
                        _buildCheckbox('Email', _notifyEmail, (val) => setState(() => _notifyEmail = val ?? false)),
                        const SizedBox(width: 14),
                        _buildCheckbox('SMS', _notifySMS, (val) => setState(() => _notifySMS = val ?? false)),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Bottom Action buttons
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
                          side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const AppText('Save Draft', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _publishAnnouncement(controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const AppText('Publish', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredLabel(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(text, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
        const AppText(' *', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
      ],
    );
  }

  Widget _buildDropdownField(String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textColorSecondary, size: 18),
          const SizedBox(width: 8),
          Expanded(child: AppText(value, fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary)),
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
        height: 75,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.slate200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textColorSecondary, size: 22),
            const SizedBox(height: 6),
            AppText(
              title,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.textColorPrimary : AppColors.textColorSecondary,
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
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : AppColors.slate400,
                width: isSelected ? 5.5 : 1.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AppText(label, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: AppColors.textColorPrimary),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.slate200,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
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

  Widget _buildFileUploadArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryColor, size: 28),
          const SizedBox(height: 6),
          const AppText('Tap to mock upload files', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          const SizedBox(height: 2),
          const AppText('Supports PDF, JPG, PNG (Max 10MB)', fontSize: 10, color: AppColors.textColorHint),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 6),
        AppText(label, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textColorSecondary),
      ],
    );
  }

  void _publishAnnouncement(HrController controller) {
    if (_formKey.currentState!.validate()) {
      DateTime pubDT = DateTime.now();
      if (_publishDate != null && _publishTime != null) {
        pubDT = DateTime(
          _publishDate!.year,
          _publishDate!.month,
          _publishDate!.day,
          _publishTime!.hour,
          _publishTime!.minute,
        );
      }

      final newAnn = HrAnnouncement(
        id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        type: _selectedType,
        publishDate: pubDT,
        priority: _selectedPriority,
        isPinned: _selectedPriority == 'High' || _selectedPriority == 'Urgent',
        content: _contentController.text.trim(),
      );

      controller.addAnnouncement(newAnn);
      Get.back();
    }
  }
}
