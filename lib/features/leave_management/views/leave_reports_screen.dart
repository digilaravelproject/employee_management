import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'dart:math' as math;

class LeaveReportsScreen extends StatelessWidget {
  const LeaveReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Leave Reports', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.document_download, color: AppColors.textColorPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: [
                  _buildFilterRow(Iconsax.calendar_1, 'Date Range', '01 May 2025 - 31 May 2025'),
                  _buildDivider(),
                  _buildFilterRow(Iconsax.building, 'Department', 'All Departments'),
                  _buildDivider(),
                  _buildFilterRow(Iconsax.edit_2, 'Leave Type', 'All Leave Types'),
                  _buildDivider(),
                  _buildFilterRow(Iconsax.menu_board, 'Status', 'All Status'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats Row
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Requests', '32', Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Approved', '24', Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Rejected', '6', Colors.red)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Pending', '2', Colors.orange)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Chart Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                children: [
                  // Donut Chart
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(120, 120),
                          painter: DonutChartPainter(),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AppText('32', fontSize: 24, fontWeight: FontWeight.bold),
                            AppText('Total', fontSize: 10, color: AppColors.textColorSecondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Legend
                  Expanded(
                    child: Column(
                      children: [
                        _buildChartLegend(Colors.blue, 'Casual Leave', '12 (37.5%)'),
                        _buildChartLegend(Colors.orange, 'Sick Leave', '8 (25.0%)'),
                        _buildChartLegend(Colors.green, 'Paid Leave', '6 (18.8%)'),
                        _buildChartLegend(Colors.purple, 'Comp Off', '4 (12.5%)'),
                        _buildChartLegend(Colors.pink, 'Other Leave', '2 (6.2%)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Department Summary
            const AppText('Department Summary', fontSize: 14, fontWeight: FontWeight.bold),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(flex: 3, child: SizedBox()),
                      Expanded(child: AppText('Approved', fontSize: 10, color: AppColors.textColorSecondary, textAlign: TextAlign.center)),
                      Expanded(child: AppText('Rejected', fontSize: 10, color: AppColors.textColorSecondary, textAlign: TextAlign.center)),
                      Expanded(child: AppText('Pending', fontSize: 10, color: AppColors.textColorSecondary, textAlign: TextAlign.center)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDepartmentRow('Design', 9, 7, 1, 1, Colors.blue),
                  _buildDepartmentRow('Development', 11, 8, 2, 1, Colors.green),
                  _buildDepartmentRow('Marketing', 5, 4, 1, 0, Colors.purple),
                  _buildDepartmentRow('HR', 4, 3, 0, 1, Colors.orange),
                  _buildDepartmentRow('Sales', 3, 2, 1, 0, Colors.pink),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textColorSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AppText(label, fontSize: 12, color: AppColors.textColorSecondary),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: AppText(
                    value,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textColorSecondary, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(color: AppColors.borderColor, height: 1),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          AppText(label, fontSize: 10, color: AppColors.textColorSecondary, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          AppText(value, fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ],
      ),
    );
  }

  Widget _buildChartLegend(Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: AppText(label, fontSize: 11, color: AppColors.textColorSecondary)),
          AppText(value, fontSize: 11, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }

  Widget _buildDepartmentRow(String name, int total, int approved, int rejected, int pending, Color color) {
    // Max width factor based on highest total (11)
    double widthFactor = total / 11;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(name, fontSize: 12, fontWeight: FontWeight.w600),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widthFactor,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppText(total.toString(), fontSize: 10, color: AppColors.textColorSecondary),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: AppText(approved.toString(), fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green, textAlign: TextAlign.center)),
          Expanded(child: AppText(rejected.toString(), fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red, textAlign: TextAlign.center)),
          Expanded(child: AppText(pending.toString(), fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

// Custom Painter for Donut Chart
class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    final strokeWidth = 20.0;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Data: 37.5%, 25%, 18.8%, 12.5%, 6.2%
    // Casual (Blue), Sick (Orange), Paid (Green), Comp (Purple), Other (Pink)
    final values = [37.5, 25.0, 18.8, 12.5, 6.2];
    final colors = [Colors.blue, Colors.orange, Colors.green, Colors.purple, Colors.pink];
    
    double startAngle = -math.pi / 2; // Start at top

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / 100) * 2 * math.pi;
      paint.color = colors[i];
      
      // Add slight gap by reducing sweepAngle
      final gap = 0.05;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle - gap,
        false,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
