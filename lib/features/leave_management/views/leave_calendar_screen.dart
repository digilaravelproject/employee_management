import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/leave_calendar_controller.dart';
import '../models/holiday_calendar_model.dart';

class LeaveCalendarScreen extends StatelessWidget {
  const LeaveCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<LeaveCalendarController>()
        ? Get.find<LeaveCalendarController>()
        : Get.put(LeaveCalendarController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
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
        title: Obx(() => AppText(
              'Holidays ${controller.selectedYear.value}',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: false,
        actions: [
          // Year Selector Chip / Popup
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: controller.selectedYear.value,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.primaryColor),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                    items: controller.availableYears.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text('$year'),
                      );
                    }).toList(),
                    onChanged: (year) {
                      if (year != null) {
                        controller.changeYear(year);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchHolidays(isRefresh: true),
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Top Banner
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFE6EFFF),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/holiday_banner.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            'Plan ahead for\nimportant days',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.55,
                            child: Obx(
                              () => AppText(
                                'Check all company holidays, festivals and important observances for the year ${controller.selectedYear.value}.',
                                fontSize: 11,
                                color: AppColors.textColorPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Location Selector Bar (Optional Filter)
              Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText(
                      'Overview & Schedule',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedLocation.value,
                          isDense: true,
                          icon: const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textColorSecondary),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorSecondary,
                          ),
                          items: controller.availableLocations.map((loc) {
                            return DropdownMenuItem<String>(
                              value: loc,
                              child: Text(loc),
                            );
                          }).toList(),
                          onChanged: (loc) {
                            if (loc != null) {
                              controller.changeLocation(loc);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 12),

              // Stats Card
              Obx(() {
                final summary = controller.summary.value;
                final total = summary?.total ?? 0;
                final national = summary?.national ?? 0;
                final restricted = summary?.restricted ?? 0;
                final optional = summary?.optional ?? 0;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          Iconsax.calendar_1,
                          AppColors.primaryColor,
                          'Total Holidays',
                          '$total',
                        ),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _buildStatItem(
                          Iconsax.tree,
                          Colors.green,
                          'National Holidays',
                          '$national',
                        ),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _buildStatItem(
                          Iconsax.lamp,
                          Colors.orange,
                          'Restricted Holidays',
                          '$restricted',
                        ),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _buildStatItem(
                          Iconsax.building,
                          Colors.purple,
                          'Optional Holidays',
                          '$optional',
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Content: Loading / Error / Months List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty && controller.months.isEmpty) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      children: [
                        const Icon(Iconsax.info_circle, size: 40, color: Colors.orange),
                        const SizedBox(height: 12),
                        AppText(
                          controller.errorMessage.value,
                          fontSize: 13,
                          color: AppColors.textColorSecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchHolidays(),
                          icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                          label: const AppText('Try Again', fontSize: 13, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.months.isEmpty) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: const Column(
                      children: [
                        Icon(Iconsax.calendar_remove, size: 40, color: AppColors.slate400),
                        SizedBox(height: 12),
                        AppText(
                          'No holidays found for this year.',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  );
                }

                // Months list
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.months.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final monthItem = controller.months[index];
                    final colorTheme = _getMonthTheme(index);

                    return _buildMonthCard(
                      month: monthItem.month,
                      holidayCount:
                          '${monthItem.count} ${monthItem.count == 1 ? 'Holiday' : 'Holidays'}',
                      iconColor: colorTheme.color,
                      iconBgColor: colorTheme.bgColor,
                      holidays: monthItem.holidays,
                      controller: controller,
                    );
                  },
                );
              }),

              const SizedBox(height: 24),

              // Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Iconsax.info_circle, color: AppColors.primaryColor, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText('Note', fontSize: 13, fontWeight: FontWeight.bold),
                          SizedBox(height: 4),
                          AppText(
                            'Holiday dates are subject to change as per government declarations and company announcements.',
                            fontSize: 11,
                            color: AppColors.textColorSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 8),
        AppText(label, fontSize: 9, color: AppColors.textColorSecondary, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        AppText(value, fontSize: 18, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.slate200,
    );
  }

  Widget _buildMonthCard({
    required String month,
    required String holidayCount,
    required Color iconColor,
    required Color iconBgColor,
    required List<HolidayItemModel> holidays,
    required LeaveCalendarController controller,
  }) {
    final isExpanded = controller.expandedMonths[month] ?? true;

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderColor),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>('month_$month'),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (_) => controller.toggleMonth(month),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Iconsax.calendar_1, color: iconColor, size: 20),
          ),
          title: AppText(month, fontSize: 14, fontWeight: FontWeight.bold),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(holidayCount, fontSize: 12, fontWeight: FontWeight.bold, color: iconColor),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.textColorSecondary),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: holidays.map((holiday) {
                  final typeColor = _getTypeColor(holiday.type);
                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.slate200, width: 0.6),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 88,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                holiday.formattedDisplayDate,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColorPrimary,
                              ),
                              if (holiday.dayName != null && holiday.dayName!.isNotEmpty)
                                AppText(
                                  holiday.dayName!,
                                  fontSize: 10,
                                  color: AppColors.textColorSecondary,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                holiday.name,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorPrimary,
                              ),
                              if (holiday.description != null &&
                                  holiday.description!.isNotEmpty &&
                                  holiday.description != holiday.name)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: AppText(
                                    holiday.description!,
                                    fontSize: 10,
                                    color: AppColors.textColorSecondary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: AppText(
                            '${holiday.type} Holiday',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('national')) {
      return Colors.green;
    } else if (lower.contains('restricted')) {
      return Colors.orange;
    } else if (lower.contains('optional')) {
      return Colors.purple;
    }
    return AppColors.primaryColor;
  }

  _MonthTheme _getMonthTheme(int index) {
    const themes = [
      _MonthTheme(AppColors.primaryColor, AppColors.primaryLight),
      _MonthTheme(Colors.purple, Color(0x1A9C27B0)),
      _MonthTheme(Colors.green, Color(0x1A4CAF50)),
      _MonthTheme(Colors.orange, Color(0x1AFF9800)),
      _MonthTheme(Colors.pink, Color(0x1AE91E63)),
      _MonthTheme(AppColors.primaryColor, Color(0x1A3F51B5)),
      _MonthTheme(Colors.teal, Color(0x1A009688)),
      _MonthTheme(Colors.deepOrange, Color(0x1AFF5722)),
      _MonthTheme(Colors.cyan, Color(0x1A00BCD4)),
      _MonthTheme(Colors.amber, Color(0x1AFFC107)),
      _MonthTheme(Colors.deepPurple, Color(0x1A673AB7)),
      _MonthTheme(AppColors.primaryShade400, AppColors.primaryLight),
    ];
    return themes[index % themes.length];
  }
}

class _MonthTheme {
  final Color color;
  final Color bgColor;

  const _MonthTheme(this.color, this.bgColor);
}
