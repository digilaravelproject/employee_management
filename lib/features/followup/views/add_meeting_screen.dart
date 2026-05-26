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

class AddMeetingScreen extends StatefulWidget {
  const AddMeetingScreen({super.key});

  @override
  State<AddMeetingScreen> createState() => _AddMeetingScreenState();
}

class _AddMeetingScreenState extends State<AddMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  
  final _selectedClient = RxnString();
  String? _clientError;

  final _selectedDuration = RxnString();
  String? _durationError;

  final _selectedMode = RxnString();
  String? _modeError;

  final _selectedEmployee = RxnString();
  String? _employeeError;

  DateTime? _meetingDate;
  TimeOfDay? _meetingTime;

  final List<String> durations = ['30 Mins', '45 Mins', '1 Hour', '2 Hours'];
  final List<String> modes = ['Office', 'Online'];

  @override
  void initState() {
    super.initState();
    _meetingDate = DateTime.now();
    _meetingTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _meetingDate ?? DateTime.now(),
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
        _meetingDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _meetingTime ?? TimeOfDay.now(),
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
        _meetingTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FollowupController>();

    String dateText = _meetingDate != null 
        ? DateFormat('dd MMM yyyy').format(_meetingDate!) 
        : 'Select Date';
    
    String timeText = _meetingTime != null
        ? _meetingTime!.format(context)
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
          'Schedule Meeting',
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
                          // Meeting Title
                          AppInputField(
                            controller: _titleController,
                            label: 'Meeting Title *',
                            hint: 'e.g. Project Discussion',
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter meeting title' : null,
                          ),
                          const SizedBox(height: 16),

                          // With Client/Lead Dropdown
                          const AppText(
                            'With Client/Lead *',
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

                          // Assign Employee (Only visible to Admin)
                          if (controller.selectedRole.value == 'Admin') ...[
                            const AppText(
                              'Assign Employee / Representative *',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorSecondary,
                            ),
                            const SizedBox(height: 8),
                            Obx(() {
                              final emp = _selectedEmployee.value;
                              final repsList = controller.employees.where((e) => e != 'All Employees').toList();
                              return CustomBottomSheetDropdown(
                                label: 'Employee / Representative',
                                selectedValue: emp,
                                items: repsList,
                                onChanged: (val) {
                                  _selectedEmployee.value = val;
                                  setState(() {
                                    _employeeError = null;
                                  });
                                },
                                borderColor: _employeeError != null ? AppColors.errorColor : null,
                              );
                            }),
                            if (_employeeError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 16),
                                child: AppText(_employeeError!, fontSize: 12, color: AppColors.errorColor),
                              ),
                            const SizedBox(height: 16),
                          ],

                          // Date & Time pickers
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppText('Date *', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
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
                                    const AppText('Time *', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
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

                          // Duration Dropdown
                          const AppText(
                            'Duration *',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorSecondary,
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            final dur = _selectedDuration.value;
                            return CustomBottomSheetDropdown(
                              label: 'Duration',
                              selectedValue: dur,
                              items: durations,
                              onChanged: (val) {
                                _selectedDuration.value = val;
                                setState(() {
                                  _durationError = null;
                                });
                              },
                              borderColor: _durationError != null ? AppColors.errorColor : null,
                            );
                          }),
                          if (_durationError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 16),
                              child: AppText(_durationError!, fontSize: 12, color: AppColors.errorColor),
                            ),
                          const SizedBox(height: 16),

                          // Location / Mode Dropdown
                          const AppText(
                            'Location / Mode *',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorSecondary,
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            final mode = _selectedMode.value;
                            return CustomBottomSheetDropdown(
                              label: 'Location / Mode',
                              selectedValue: mode,
                              items: modes,
                              onChanged: (val) {
                                _selectedMode.value = val;
                                setState(() {
                                  _modeError = null;
                                });
                              },
                              borderColor: _modeError != null ? AppColors.errorColor : null,
                            );
                          }),
                          if (_modeError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 16),
                              child: AppText(_modeError!, fontSize: 12, color: AppColors.errorColor),
                            ),
                          const SizedBox(height: 16),

                          // Notes
                          AppInputField(
                            controller: _notesController,
                            label: 'Meeting Agenda / Notes',
                            hint: 'Type notes here...',
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Symmetrical footer buttons
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
                        'Save Meeting',
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
    final isAdmin = controller.selectedRole.value == 'Admin';

    setState(() {
      _clientError = _selectedClient.value == null ? 'Please select client' : null;
      _durationError = _selectedDuration.value == null ? 'Please select duration' : null;
      _modeError = _selectedMode.value == null ? 'Please select location/mode' : null;
      if (isAdmin) {
        _employeeError = _selectedEmployee.value == null ? 'Please select an employee' : null;
      } else {
        _employeeError = null;
      }
    });

    if (_formKey.currentState!.validate() &&
        _clientError == null &&
        _durationError == null &&
        _modeError == null &&
        _employeeError == null) {
      
      DateTime pubDT = DateTime.now();
      if (_meetingDate != null && _meetingTime != null) {
        pubDT = DateTime(
          _meetingDate!.year,
          _meetingDate!.month,
          _meetingDate!.day,
          _meetingTime!.hour,
          _meetingTime!.minute,
        );
      }

      final newMeet = FollowupMeeting(
        id: 'meet_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        clientName: _selectedClient.value!,
        employeeName: isAdmin ? _selectedEmployee.value! : 'Rahul Sharma',
        dateTime: pubDT,
        duration: _selectedDuration.value!,
        mode: _selectedMode.value!,
        notes: _notesController.text.trim(),
      );

      controller.addMeeting(newMeet);
      Get.back();
    }
  }
}
