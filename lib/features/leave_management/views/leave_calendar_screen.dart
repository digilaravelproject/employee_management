import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class LeaveCalendarScreen extends StatelessWidget {
  const LeaveCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText('Holidays 2025', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         color: AppColors.slate100,
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: IconButton(
        //         icon: const Icon(Iconsax.document_download, color: AppColors.textColorPrimary, size: 20),
        //         onPressed: () {},
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFE6EFFF), // Light blue fallback
                image: const DecorationImage(
                  image: AssetImage('assets/images/holiday_banner.png'), // Update this to match user's asset name if different
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
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: const AppText(
                            'Check all company holidays, festivals and important observances for the year 2025.',
                            fontSize: 11,
                            color: AppColors.textColorPrimary,
                           // height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40), // Space for image elements on the right
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats Card
            Container(
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
                    child: _buildStatItem(Iconsax.calendar_1, Colors.blue, 'Total Holidays', '23'),
                  ),
                  _buildDivider(),
                  Expanded(
                    child: _buildStatItem(Iconsax.tree, Colors.green, 'National Holidays', '13'),
                  ),
                  _buildDivider(),
                  Expanded(
                    child: _buildStatItem(Iconsax.lamp, Colors.orange, 'Restricted Holidays', '7'),
                  ),
                  _buildDivider(),
                  Expanded(
                    child: _buildStatItem(Iconsax.building, Colors.purple, 'Optional Holidays', '3'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Months List
            _buildMonthCard(
              month: 'January',
              holidayCount: '2 Holidays',
              iconColor: Colors.blue,
              iconBgColor: Colors.blue.withValues(alpha: 0.1),
              holidays: [
                _HolidayItem('01 Jan, Wed', 'New Year\'s Day', 'National Holiday', Colors.green),
                _HolidayItem('26 Jan, Sun', 'Republic Day', 'National Holiday', Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMonthCard(
              month: 'February',
              holidayCount: '1 Holiday',
              iconColor: Colors.purple,
              iconBgColor: Colors.purple.withValues(alpha: 0.1),
              holidays: [
                _HolidayItem('26 Feb, Wed', 'Maha Shivratri', 'Restricted Holiday', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMonthCard(
              month: 'March',
              holidayCount: '2 Holidays',
              iconColor: Colors.green,
              iconBgColor: Colors.green.withValues(alpha: 0.1),
              holidays: [
                _HolidayItem('14 Mar, Fri', 'Holi', 'National Holiday', Colors.green),
                _HolidayItem('31 Mar, Mon', 'Eid-ul-Fitr', 'National Holiday', Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMonthCard(
              month: 'April',
              holidayCount: '2 Holidays',
              iconColor: Colors.orange,
              iconBgColor: Colors.orange.withValues(alpha: 0.1),
              holidays: [
                _HolidayItem('10 Apr, Thu', 'Mahavir Jayanti', 'Restricted Holiday', Colors.orange),
                _HolidayItem('18 Apr, Fri', 'Good Friday', 'Restricted Holiday', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMonthCard(
              month: 'May',
              holidayCount: '2 Holidays',
              iconColor: Colors.pink,
              iconBgColor: Colors.pink.withValues(alpha: 0.1),
              holidays: [
                _HolidayItem('01 May, Thu', 'Labour Day', 'National Holiday', Colors.green),
                _HolidayItem('12 May, Mon', 'Buddha Purnima', 'Restricted Holiday', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMonthCard(
              month: 'June',
              holidayCount: '1 Holiday',
              iconColor: Colors.blue,
              iconBgColor: Colors.blue.withValues(alpha: 0.1),
              holidays: [
                _HolidayItem('07 Jun, Sat', 'Bakrid (Eid al-Adha)', 'Restricted Holiday', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMonthCard(
              month: 'July',
              holidayCount: '1 Holiday',
              iconColor: Colors.indigo,
              iconBgColor: Colors.indigo.withValues(alpha: 0.1),
              holidays: [
                _HolidayItem('06 Jul, Sun', 'Muharram', 'Restricted Holiday', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMonthCard(
              month: 'August',
              holidayCount: '3 Holidays',
              iconColor: Colors.teal,
              iconBgColor: Colors.teal.withValues(alpha: 0.1),
              holidays: [
                _HolidayItem('09 Aug, Sat', 'Raksha Bandhan', 'Restricted Holiday', Colors.orange),
                _HolidayItem('15 Aug, Fri', 'Independence Day', 'National Holiday', Colors.green),
                _HolidayItem('16 Aug, Sat', 'Janmashtami', 'Restricted Holiday', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMonthCard(
              month: 'September',
              holidayCount: '1 Holiday',
              iconColor: Colors.orange,
              iconBgColor: Colors.orange.withValues(alpha: 0.1),
              holidays: [
                _HolidayItem('06 Sep, Sat', 'Ganesh Chaturthi', 'Restricted Holiday', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMonthCard(
              month: 'October',
              holidayCount: '3 Holidays',
              iconColor: Colors.purple,
              iconBgColor: Colors.purple.withValues(alpha: 0.1),
              holidays: [
                _HolidayItem('02 Oct, Thu', 'Gandhi Jayanti', 'National Holiday', Colors.green),
                _HolidayItem('02 Oct, Thu', 'Dussehra', 'National Holiday', Colors.green),
                _HolidayItem('20 Oct, Mon', 'Diwali', 'National Holiday', Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMonthCard(
              month: 'November',
              holidayCount: '1 Holiday',
              iconColor: Colors.pink,
              iconBgColor: Colors.pink.withValues(alpha: 0.1),
              holidays: [
                _HolidayItem('05 Nov, Wed', 'Guru Nanak Jayanti', 'Restricted Holiday', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMonthCard(
              month: 'December',
              holidayCount: '1 Holiday',
              iconColor: Colors.blue,
              iconBgColor: Colors.blue.withValues(alpha: 0.1),
              holidays: [
                _HolidayItem('25 Dec, Thu', 'Christmas', 'National Holiday', Colors.green),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Iconsax.info_circle, color: AppColors.primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('Note', fontSize: 13, fontWeight: FontWeight.bold),
                        const SizedBox(height: 4),
                        const AppText(
                          'Holiday dates are subject to change as per government declarations and company announcements.',
                          fontSize: 11,
                          color: AppColors.textColorSecondary,
                          //height: 1.4,
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
    required List<_HolidayItem> holidays,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: month == 'January', // Expand the first one by default
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
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 80,
                          child: AppText(holiday.date, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: AppText(holiday.name, fontSize: 12, color: AppColors.textColorSecondary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: holiday.typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(holiday.type, fontSize: 10, fontWeight: FontWeight.bold, color: holiday.typeColor),
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
}

class _HolidayItem {
  final String date;
  final String name;
  final String type;
  final Color typeColor;

  _HolidayItem(this.date, this.name, this.type, this.typeColor);
}
