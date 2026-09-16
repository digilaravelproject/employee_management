import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/holidays_controller.dart';
import '../models/holiday_model.dart';
import 'add_holiday_screen.dart';
import 'holiday_details_screen.dart';

class HolidayCalendarScreen extends StatelessWidget {
  const HolidayCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller
    final controller = Get.put(HolidaysController());

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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textColorPrimary,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Holiday Calendar',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Filters Section ──
            _buildFilters(context, controller),

            // ── Scrollable Collapsible Months List ──
            Expanded(
              child: Obx(() {
                final grouped = controller.holidaysByMonth;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final monthIndex = index + 1;
                    return Obx(() {
                      final list = grouped[monthIndex] ?? [];
                      final isExpanded = controller.expandedMonths[monthIndex] ?? false;

                      return _MonthAccordionItem(
                        monthIndex: monthIndex,
                        holidays: list,
                        isExpanded: isExpanded,
                        onToggle: () => controller.toggleMonth(monthIndex),
                        controller: controller,
                      );
                    });
                  },
                );
              }),
            ),

            // ── Bottom Legend Area ──
            _buildLegend(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.clearForm();
          Get.to(() => const AddHolidayScreen());
        },
        backgroundColor: AppColors.primaryColor, // Premium Theme Primary Color
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  // Build Year and Location Filter Row
  Widget _buildFilters(BuildContext context, HolidaysController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Year Selection Filter
          Expanded(
            child: Obx(() {
              final activeYear = controller.filterYear.value;
              return GestureDetector(
                onTap: () => _showYearBottomSheet(context, controller),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.15), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Iconsax.calendar, size: 12, color: AppColors.primaryColor),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'YEAR',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorHint,
                            ),
                            const SizedBox(height: 1),
                            AppText(
                              '$activeYear',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColorPrimary,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Iconsax.arrow_down_1, size: 12, color: AppColors.textColorSecondary),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 12),

          // Location Filter Selection
          Expanded(
            child: Obx(() {
              final activeLoc = controller.filterLocation.value;
              return GestureDetector(
                onTap: () => _showLocationBottomSheet(context, controller),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.15), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Iconsax.location, size: 12, color: AppColors.primaryColor),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'LOCATION',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorHint,
                            ),
                            const SizedBox(height: 1),
                            AppText(
                              activeLoc,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColorPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Iconsax.arrow_down_1, size: 12, color: AppColors.textColorSecondary),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Beautiful Custom Year Selector Bottom Sheet
  void _showYearBottomSheet(BuildContext context, HolidaysController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull bar and header
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'Select Calendar Year',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textColorPrimary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textColorSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.borderColor),
              const SizedBox(height: 16),

              // Year list options
              Obx(() {
                final currentYear = controller.filterYear.value;
                final years = [DateTime.now().year - 2, DateTime.now().year - 1, DateTime.now().year];
                return Column(
                  children: years.map((year) {
                    final isSelected = currentYear == year;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () {
                          controller.filterYear.value = year;
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryLight : AppColors.slate50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor : AppColors.slate100,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.calendar,
                                    size: 18,
                                    color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
                                  ),
                                  const SizedBox(width: 14),
                                  AppText(
                                    '$year',
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                                  ),
                                ],
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 20,
                                  color: AppColors.primaryColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // Beautiful Custom Location Selector Bottom Sheet
  void _showLocationBottomSheet(BuildContext context, HolidaysController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull bar and header
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'Select Location',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textColorPrimary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textColorSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.borderColor),
              const SizedBox(height: 16),

              // Location list options
              Obx(() {
                final currentLoc = controller.filterLocation.value;
                return Column(
                  children: controller.locations.map((loc) {
                    final isSelected = currentLoc == loc;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () {
                          controller.filterLocation.value = loc;
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryLight : AppColors.slate50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor : AppColors.slate100,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.location,
                                    size: 18,
                                    color: isSelected ? AppColors.primaryColor : AppColors.textColorSecondary,
                                  ),
                                  const SizedBox(width: 14),
                                  AppText(
                                    loc,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? AppColors.primaryColor : AppColors.textColorPrimary,
                                  ),
                                ],
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 20,
                                  color: AppColors.primaryColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // Build the Legend indicators at the bottom
  Widget _buildLegend() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _LegendItem(color: AppColors.successColor, label: 'National Holiday'),
          _LegendItem(color: AppColors.warningColor, label: 'Optional Holiday'),
          _LegendItem(color: AppColors.primaryColor, label: 'Restricted Holiday'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        AppText(
          label,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textColorSecondary,
        ),
      ],
    );
  }
}

// ── INDIVIDUAL ACCORDION / COLLAPSIBLE ITEM ──
class _MonthAccordionItem extends StatelessWidget {
  final int monthIndex;
  final List<Holiday> holidays;
  final bool isExpanded;
  final VoidCallback onToggle;
  final HolidaysController controller;

  const _MonthAccordionItem({
    required this.monthIndex,
    required this.holidays,
    required this.isExpanded,
    required this.onToggle,
    required this.controller,
  });

  String getMonthName(int index) {
    const list = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return list[index - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Calendar month icon with soft blue background
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Iconsax.calendar_1,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Month Name and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          getMonthName(monthIndex),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isExpanded ? AppColors.primaryColor : AppColors.textColorPrimary,
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          holidays.isEmpty
                              ? 'No holidays'
                              : '${holidays.length} ${holidays.length == 1 ? 'day' : 'days'} off',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ),

                  // Holiday count indicator badge
                  if (holidays.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppText(
                        '${holidays.length}',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                      ),
                    ),

                  const SizedBox(width: 12),

                  // Chevron indicator rotating dynamically
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Iconsax.arrow_down_1,
                      size: 16,
                      color: AppColors.textColorHint,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Expanded Content with smooth height transition
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              heightFactor: isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14, top: 12),
                child: Column(
                  children: [
                    const Divider(height: 1, color: AppColors.borderColor),
                    const SizedBox(height: 12),
                    if (holidays.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              Iconsax.calendar_tick,
                              size: 36,
                              color: AppColors.textColorHint.withOpacity(0.3),
                            ),
                            const SizedBox(height: 8),
                            const AppText(
                              'No holidays this month',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColorHint,
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: holidays.length,
                        itemBuilder: (context, idx) {
                          final holiday = holidays[idx];
                          return _HolidayItemCard(holiday: holiday, controller: controller);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── HOLIDAY ITEM ROW CARD ──
class _HolidayItemCard extends StatelessWidget {
  final Holiday holiday;
  final HolidaysController controller;

  const _HolidayItemCard({required this.holiday, required this.controller});

  String getWeekdayName(DateTime date) {
    const list = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return list[date.weekday - 1];
  }

  String getMonthAbbreviation(DateTime date) {
    const list = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return list[date.month - 1];
  }

  Color getBadgeColor(String type) {
    if (type.contains('National')) return AppColors.successColor.withOpacity(0.1);
    if (type.contains('Optional')) return AppColors.warningColor.withOpacity(0.1);
    return AppColors.primaryColor.withOpacity(0.1);
  }

  Color getBadgeTextColor(String type) {
    if (type.contains('National')) return AppColors.successColor;
    if (type.contains('Optional')) return AppColors.warningColor;
    return AppColors.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = getBadgeTextColor(holiday.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              controller.selectedHoliday.value = holiday;
              Get.to(() => const HolidayDetailsScreen());
            },
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Accent Indicator Bar
                  Container(
                    width: 4,
                    color: accentColor,
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Date Container Box (Left)
                          Container(
                            width: 50,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppText(
                                  holiday.date.day.toString().padLeft(2, '0'),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryColor,
                                ),
                                AppText(
                                  getMonthAbbreviation(holiday.date),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textColorHint,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Name, Weekday & Type Tag (Middle)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  holiday.name,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorPrimary,
                                ),
                                const SizedBox(height: 2),
                                AppText(
                                  getWeekdayName(holiday.date),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColorHint,
                                ),
                                const SizedBox(height: 6),

                                // Holiday Type Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: getBadgeColor(holiday.type),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: AppText(
                                    holiday.type,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Dot Actions Menu Icon (Right)
                          IconButton(
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: AppColors.textColorSecondary,
                              size: 20,
                            ),
                            onPressed: () => _showHolidayActionsBottomSheet(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Interactive Bottom Sheet Options for Quick Actions
  void _showHolidayActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Bar Indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              AppText(
                holiday.name,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              AppText(
                holiday.type,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: getBadgeTextColor(holiday.type),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.borderColor),
              const SizedBox(height: 8),

              // View Details Item
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.eye, color: AppColors.primaryColor, size: 18),
                ),
                title: const AppText('View Details', fontSize: 13, fontWeight: FontWeight.bold),
                onTap: () {
                  Navigator.pop(context);
                  controller.selectedHoliday.value = holiday;
                  Get.to(() => const HolidayDetailsScreen());
                },
              ),

              // Edit Item
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.edit, color: AppColors.warningColor, size: 18),
                ),
                title: const AppText('Edit Holiday', fontSize: 13, fontWeight: FontWeight.bold),
                onTap: () {
                  Navigator.pop(context);
                  controller.selectedHoliday.value = holiday;
                  controller.populateForm(holiday);
                  Get.to(() => const AddHolidayScreen());
                },
              ),

              // Delete Item
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.trash, color: AppColors.errorColor, size: 18),
                ),
                title: const AppText('Delete Holiday', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.errorColor),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Confirmation Alert Dialog before deleting
  void _showDeleteConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Iconsax.warning_2, color: AppColors.errorColor, size: 26),
            const SizedBox(width: 10),
            const AppText('Delete Holiday?', fontSize: 16, fontWeight: FontWeight.bold),
          ],
        ),
        content: AppText(
          'Are you sure you want to delete "${holiday.name}"? This action cannot be undone.',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textColorSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteHoliday(holiday.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const AppText('Delete', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
