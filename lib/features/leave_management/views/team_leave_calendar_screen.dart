import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class TeamLeaveCalendarScreen extends StatefulWidget {
  const TeamLeaveCalendarScreen({super.key});

  @override
  State<TeamLeaveCalendarScreen> createState() => _TeamLeaveCalendarScreenState();
}

class _TeamLeaveCalendarScreenState extends State<TeamLeaveCalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  // Dummy data for calendar events
  final Map<int, List<Map<String, dynamic>>> _leaveData = {
    1: [{'name': 'Amit', 'status': 'Pending', 'color': Colors.orange}],
    6: [{'name': 'Neha', 'status': 'Approved', 'color': Colors.green}],
    7: [{'name': 'Rahul', 'status': 'Comp Off', 'color': Colors.purple}],
    12: [{'name': 'Vikram', 'status': 'Approved', 'color': Colors.blue}],
    15: [
      {'name': 'Sneha', 'status': 'Pending', 'color': Colors.orange},
      {'name': '+1', 'status': 'Holiday', 'color': Colors.pink},
    ],
    20: [
      {'name': 'Rahul', 'status': 'Comp Off', 'color': Colors.purple},
      {'name': 'Neha', 'status': 'Approved', 'color': Colors.green},
    ],
    23: [
      {'name': 'Amit', 'status': 'Pending', 'color': Colors.orange},
      {'name': 'Vikram', 'status': 'Approved', 'color': Colors.blue},
    ],
    26: [{'name': 'Holiday', 'status': 'Holiday', 'color': Colors.pink}],
    27: [{'name': 'Sneha', 'status': 'Pending', 'color': Colors.orange}],
  };

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _showMonthPickerBottomSheet() {
    final List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June', 
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText('Select Month (${_currentMonth.year})', fontSize: 16, fontWeight: FontWeight.bold),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textColorSecondary),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.slate200),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final monthNumber = index + 1;
                    final isSelected = monthNumber == _currentMonth.month;
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _currentMonth = DateTime(_currentMonth.year, monthNumber, 1);
                        });
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        color: isSelected ? AppColors.primaryLight : Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              months[index],
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                            ),
                            if (isSelected)
                              const Icon(Iconsax.tick_circle, color: AppColors.primaryColor, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedMonth = DateFormat('MMMM yyyy').format(_currentMonth);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Leave Calendar', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.calendar, color: AppColors.primaryColor),
            onPressed: _showMonthPickerBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_left, color: AppColors.textColorPrimary, size: 28),
                  onPressed: _previousMonth,
                ),
                GestureDetector(
                  onTap: _showMonthPickerBottomSheet,
                  child: AppText(formattedMonth, fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right, color: AppColors.textColorPrimary, size: 28),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          
          // Days Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDayHeader('Sun', Colors.red),
                _buildDayHeader('Mon', AppColors.textColorPrimary),
                _buildDayHeader('Tue', AppColors.textColorPrimary),
                _buildDayHeader('Wed', AppColors.textColorPrimary),
                _buildDayHeader('Thu', AppColors.textColorPrimary),
                _buildDayHeader('Fri', AppColors.textColorPrimary),
                _buildDayHeader('Sat', AppColors.textColorPrimary),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Calendar Grid
          Expanded(
            child: _buildCalendarGrid(),
          ),
          
          // Legend
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.slate200, width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem(Colors.green, 'Approved'),
                _buildLegendItem(Colors.orange, 'Pending'),
                _buildLegendItem(Colors.red, 'Rejected'),
                _buildLegendItem(Colors.purple, 'Comp Off'),
                _buildLegendItem(Colors.pink, 'Holiday'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String label, Color color) {
    return SizedBox(
      width: 44,
      child: AppText(
        label,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: color,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCalendarGrid() {
    int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    int firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
    int firstDayOffset = firstWeekday == 7 ? 0 : firstWeekday; 
    
    int totalCells = (daysInMonth + firstDayOffset) > 35 ? 42 : 35; // 5 or 6 rows needed

    return LayoutBuilder(
      builder: (context, constraints) {
        int rows = totalCells ~/ 7;
        double cellHeight = (constraints.maxHeight) / rows;
        
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: (MediaQuery.of(context).size.width - 16) / 7 / cellHeight,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            int dayNumber = index - firstDayOffset + 1;
            bool isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
            
            String displayDay = '';
            Color dayColor = AppColors.textColorPrimary;
            bool isSunday = index % 7 == 0;
            
            if (isCurrentMonth) {
              displayDay = dayNumber.toString();
              if (isSunday) {
                dayColor = Colors.red;
              }
            } else {
              if (dayNumber <= 0) {
                // Prev month
                int prevDays = DateTime(_currentMonth.year, _currentMonth.month, 0).day;
                displayDay = (prevDays + dayNumber).toString();
              } else {
                // Next month
                displayDay = (dayNumber - daysInMonth).toString();
              }
              dayColor = AppColors.slate300;
            }

            // Only show dummy data for the current active month (e.g. May 2025)
            // Just for demonstration, we show it if month is May (5).
            bool showDummyEvents = isCurrentMonth && _currentMonth.month == 5 && _leaveData.containsKey(dayNumber);

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.slate200, width: 0.5),
                color: isCurrentMonth ? Colors.white : AppColors.slate50,
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Highlight today if it's the current real-world day (optional, left transparent for now)
                    ),
                    child: AppText(
                      displayDay,
                      fontSize: 14,
                      fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
                      color: dayColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (showDummyEvents)
                    ..._leaveData[dayNumber]!.map((event) => _buildEventTag(event)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventTag(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: (event['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: event['color'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: AppText(
              event['name'] as String,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: (event['color'] as Color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        AppText(label, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textColorPrimary),
      ],
    );
  }
}

