import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/followup_controller.dart';
import '../models/followup_model.dart';
import 'add_meeting_screen.dart';

class AdminMeetingsScreen extends StatefulWidget {
  const AdminMeetingsScreen({super.key});

  @override
  State<AdminMeetingsScreen> createState() => _AdminMeetingsScreenState();
}

class _AdminMeetingsScreenState extends State<AdminMeetingsScreen> {
  final FollowupController controller = Get.find<FollowupController>();
  late DateTime _selectedDate;
  final List<DateTime> _dateStrip = [];

  // Local Rx for representative dropdown filter
  final _selectedEmployee = 'All Employees'.obs;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    final today = DateTime.now();
    for (int i = -3; i <= 3; i++) {
      _dateStrip.add(today.add(Duration(days: i)));
    }
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Team Meetings',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Filter Deck Header ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Representative Selection Dropdown
                Obx(() {
                  final emp = _selectedEmployee.value;
                  return CustomBottomSheetDropdown(
                    label: 'Representative',
                    selectedValue: emp,
                    items: controller.employees,
                    onChanged: (val) {
                      _selectedEmployee.value = val;
                    },
                  );
                }),
                const SizedBox(height: 12),

                // Calendar date title and select button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      DateFormat('MMMM yyyy').format(_selectedDate),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
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
                          setState(() {
                            _selectedDate = picked;
                            _dateStrip.clear();
                            for (int i = -3; i <= 3; i++) {
                              _dateStrip.add(picked.add(Duration(days: i)));
                            }
                          });
                        }
                      },
                      child: const Icon(Iconsax.calendar_1, color: AppColors.primaryColor, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Horizontal date strip
                SizedBox(
                  height: 64,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _dateStrip.length,
                    itemBuilder: (context, index) {
                      final date = _dateStrip[index];
                      final isSelected = DateUtils.isSameDay(date, _selectedDate);
                      final isToday = DateUtils.isSameDay(date, DateTime.now());

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primaryColor 
                                : (isToday ? AppColors.primaryLight.withValues(alpha: 0.4) : Colors.transparent),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.primaryColor 
                                  : (isToday ? AppColors.primaryColor.withValues(alpha: 0.3) : AppColors.slate200),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(
                                DateFormat('E').format(date).substring(0, 1),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.textColorSecondary,
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                DateFormat('d').format(date),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.white : AppColors.textColorPrimary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Meetings List ──
          Expanded(
            child: Obx(() {
              final allMeets = controller.meetings;
              final selectedEmp = _selectedEmployee.value;

              // Filter by employee representative (if selected) and matching selected date
              final teamMeets = allMeets.where((m) {
                final matchEmp = selectedEmp == 'All Employees' || m.employeeName == selectedEmp;
                final matchDate = DateUtils.isSameDay(m.dateTime, _selectedDate);
                return matchEmp && matchDate;
              }).toList();

              if (teamMeets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.people, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: AppText(
                          'No scheduled meetings found on ${DateFormat('dd MMM yyyy').format(_selectedDate)}${selectedEmp != 'All Employees' ? ' for $selectedEmp' : ''}.',
                          fontSize: 12,
                          color: AppColors.textColorHint,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: teamMeets.length,
                itemBuilder: (context, index) {
                  final meet = teamMeets[index];
                  return _buildTeamMeetingCard(meet);
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.slate200)),
        ),
        child: ElevatedButton.icon(
          onPressed: () => Get.to(() => const AddMeetingScreen()),
          icon: const Icon(Iconsax.add, color: Colors.white, size: 20),
          label: const AppText(
            'Schedule Team Meeting',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMeetingCard(FollowupMeeting meet) {
    final timeStr = DateFormat('hh:mm a').format(meet.dateTime);
    final isOnline = meet.mode == 'Online';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  meet.title,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline 
                      ? AppColors.primaryLight.withValues(alpha: 0.6) 
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  meet.mode,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isOnline ? AppColors.primaryColor : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Iconsax.profile_2user, size: 16, color: AppColors.textColorSecondary),
              const SizedBox(width: 8),
              AppText(
                'Client: ',
                fontSize: 11,
                color: AppColors.textColorSecondary,
              ),
              AppText(
                meet.clientName,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.user, size: 16, color: AppColors.textColorSecondary),
              const SizedBox(width: 8),
              AppText(
                'Assigned to: ',
                fontSize: 11,
                color: AppColors.textColorSecondary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText(
                  meet.employeeName,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.clock, size: 16, color: AppColors.textColorSecondary),
              const SizedBox(width: 8),
              AppText(
                '$timeStr (${meet.duration})',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorPrimary,
              ),
            ],
          ),
          if (meet.notes.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: AppColors.slate100, height: 1),
            ),
            AppText(
              meet.notes,
              fontSize: 11,
              color: AppColors.textColorSecondary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
