import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/followup_controller.dart';
import '../models/followup_model.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  final _selectedClient = RxnString();
  String? _clientError;

  final _selectedType = RxnString();
  String? _typeError;

  final _setReminder = false.obs;

  DateTime? _followupDate;
  TimeOfDay? _followupTime;

  final List<String> noteTypes = ['Call', 'Meeting', 'Task', 'Follow-up'];

  @override
  void initState() {
    super.initState();
    _followupDate = DateTime.now().add(const Duration(days: 2));
    _followupTime = const TimeOfDay(hour: 11, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _followupDate ?? DateTime.now(),
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
        _followupDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _followupTime ?? TimeOfDay.now(),
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
        _followupTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FollowupController>();

    String dateText = _followupDate != null 
        ? DateFormat('dd MMM yyyy').format(_followupDate!) 
        : 'Select Date';
    
    String timeText = _followupTime != null
        ? _followupTime!.format(context)
        : 'Select Time';

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Add Note & Activity',
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
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Select Client/Lead
                          const AppText(
                            'Select Client / Lead *',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorSecondary,
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            final client = _selectedClient.value;
                            return CustomBottomSheetDropdown(
                              label: 'Client/Lead',
                              selectedValue: client,
                              items: controller.clientNames,
                              onChanged: (val) {
                                _selectedClient.value = val;
                                setState(() {
                                  _clientError = null;
                                });
                              },
                              borderColor: _clientError != null ? AppColors.errorColor : null,
                            );
                          }),
                          if (_clientError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 16),
                              child: AppText(_clientError!, fontSize: 12, color: AppColors.errorColor),
                            ),
                          const SizedBox(height: 16),

                          // Note Title
                          AppInputField(
                            controller: _titleController,
                            label: 'Note Title *',
                            hint: 'e.g. Project Discussion Notes',
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter note title' : null,
                          ),
                          const SizedBox(height: 16),

                          // Note Description
                          AppInputField(
                            controller: _noteController,
                            label: 'Interaction Note *',
                            hint: 'Discussed about project wireframes and client requested Dynamic Ledgers export feature...',
                            maxLines: 5,
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please write note content' : null,
                          ),
                          const SizedBox(height: 16),

                          // Next Followup Date & Time (Optional)
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppText('Next Follow-up', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => _selectDate(context),
                                      child: _buildPickerField(dateText, Iconsax.calendar_1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppText('Time', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => _selectTime(context),
                                      child: _buildPickerField(timeText, Iconsax.clock),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Note Type Dropdown
                          const AppText(
                            'Note / Activity Type *',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorSecondary,
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            final type = _selectedType.value;
                            return CustomBottomSheetDropdown(
                              label: 'Activity Type',
                              selectedValue: type,
                              items: noteTypes,
                              onChanged: (val) {
                                _selectedType.value = val;
                                setState(() {
                                  _typeError = null;
                                });
                              },
                              borderColor: _typeError != null ? AppColors.errorColor : null,
                            );
                          }),
                          if (_typeError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 16),
                              child: AppText(_typeError!, fontSize: 12, color: AppColors.errorColor),
                            ),
                          const SizedBox(height: 16),

                          // Set Reminder Checkbox
                          Obx(() {
                            final val = _setReminder.value;
                            return Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: val,
                                    onChanged: (v) => _setReminder.value = v ?? false,
                                    activeColor: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const AppText('Set automated Follow-up Reminder', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const AppText(
                        'Cancel',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _submitForm(controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const AppText(
                        'Save Note',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerField(String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
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

  void _submitForm(FollowupController controller) {
    setState(() {
      _clientError = _selectedClient.value == null ? 'Please select client/lead' : null;
      _typeError = _selectedType.value == null ? 'Please select note/activity type' : null;
    });

    if (_formKey.currentState!.validate() &&
        _clientError == null &&
        _typeError == null) {

      DateTime pubDT = DateTime.now();
      if (_followupDate != null && _followupTime != null) {
        pubDT = DateTime(
          _followupDate!.year,
          _followupDate!.month,
          _followupDate!.day,
          _followupTime!.hour,
          _followupTime!.minute,
        );
      }

      final newNote = ActivityNote(
        id: 'note_${DateTime.now().millisecondsSinceEpoch}',
        clientName: _selectedClient.value!,
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        dateTime: pubDT,
        employeeName: 'Rahul Sharma', // Seed Default Employee
      );

      controller.addNote(newNote, setReminderFlag: _setReminder.value);
      Get.back();
    }
  }
}
