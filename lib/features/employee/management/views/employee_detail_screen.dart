import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../controllers/employee_controller.dart';
import '../models/employee_model.dart';
import 'add_employee_screen.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final EmployeeModel employee;
  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmployeeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── PREMIUM SLIVER APP BAR ──
         /* SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Get.to(() => AddEmployeeScreen(employee: employee)),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Iconsax.edit, color: Colors.white, size: 18),
                ),
              ),
              IconButton(
                onPressed: () => _showDeleteDialog(context, controller, employee.id),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Iconsax.trash, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -30,
                    right: -30,
                    child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withValues(alpha: 0.05)),
                  ),
                  // Compact Profile Content
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Hero(
                            tag: 'emp_avatar_${employee.id}',
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                                child: AppText(employee.name[0], fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppText(employee.name, color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                            child: AppText(employee.designation, color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),*/



          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: AppColors.primaryColor,

            leading: IconButton(
                onPressed: () => Get.back(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),

            actions: [
              IconButton(
                onPressed: () => Get.to(
                      () => AddEmployeeScreen(employee: employee),
                ),
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Iconsax.edit,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),

              IconButton(
                onPressed: () =>
                    _showDeleteDialog(context, controller, employee.id),
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Iconsax.trash,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(width: 10),
            ],

            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],

              background: Stack(
                fit: StackFit.expand,
                children: [

                  /// BACKGROUND CURVE
                  ClipPath(
                    clipper: _EmployeeHeaderClipper(),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1E3A8A),
                            Color(0xFF2563EB),
                            Color(0xFF3B82F6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),

                  /// BIG CIRCLE
                  Positioned(
                    top: -45,
                    right: -35,
                    child: Container(
                      height: 170,
                      width: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),

                  /// SMALL CIRCLE
                  Positioned(
                    bottom: 25,
                    left: -30,
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                  ),

                  /// PROFILE CONTENT
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Hero(
                            tag: 'emp_avatar_${employee.id}',
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: const Color(0xFFEFF6FF),
                                child: AppText(
                                  employee.name[0].toUpperCase(),
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          AppText(
                            employee.name,
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),

                          const SizedBox(height: 6),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: AppText(
                              employee.designation,
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── QUICK ACTION BUTTONS ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAction(Iconsax.call, 'Call', Colors.green),
                  _buildDivider(),
                  _buildQuickAction(Iconsax.message, 'Message', Colors.blue),
                  _buildDivider(),
                  _buildQuickAction(Iconsax.sms, 'Email', Colors.orange),
                ],
              ),
            ),
          ),


          // ── MAIN CONTENT ──
          SliverPadding(
            padding: const EdgeInsets.only(top: 20,left: 20,right: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Employee Stats Row
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Performance', '94%', Iconsax.chart_21, Colors.purple)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildStatCard('Attendance', '98%', Iconsax.user_tick, Colors.teal)),
                  ],
                ),
                const SizedBox(height: 25),

                // Employment Details
                _buildSectionTitle('Employment Details'),
                const SizedBox(height: 12),
                _buildModernInfoCard([
                  _InfoTile(icon: Iconsax.personalcard, label: 'Employee ID', value: employee.employeeId),
                  _InfoTile(icon: Iconsax.calendar_tick, label: 'Date of Joining', value: employee.joiningDate),
                  _InfoTile(icon: Iconsax.wallet_money, label: 'Monthly Salary', value: '₹${employee.salary.toStringAsFixed(0)}'),
                ]),
                const SizedBox(height: 25),

                // Personal Details
                _buildSectionTitle('Personal & Contact'),
                const SizedBox(height: 12),
                _buildModernInfoCard([
                  _InfoTile(icon: Iconsax.sms, label: 'Work Email', value: employee.email),
                  _InfoTile(icon: Iconsax.call_calling, label: 'Emergency Contact', value: employee.emergencyContact),
                  _InfoTile(icon: Iconsax.location, label: 'Office Address', value: employee.address),
                ]),
                const SizedBox(height: 25),

                // Skills
                _buildSectionTitle('Expertise'),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: employee.skills.map((skill) => _buildSkillChip(skill)).toList(),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(title, fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B));
  }

  Widget _buildModernInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(children: children),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        AppText(label, fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
      ],
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 30, color: const Color(0xFFF1F5F9));

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(label, fontSize: 10, color: color, fontWeight: FontWeight.w700),
              AppText(value, fontSize: 18, fontWeight: FontWeight.w900, color: color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: AppText(skill, fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
    );
  }

  void _showDeleteDialog(BuildContext context, EmployeeController controller, String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const AppText('Delete Record?', fontWeight: FontWeight.w900),
        content: const AppText('Are you sure you want to remove this employee? This action cannot be undone.', fontSize: 14, color: AppColors.textColorSecondary),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const AppText('Keep Record', color: AppColors.textColorSecondary)),
          ElevatedButton(
            onPressed: () { controller.deleteEmployee(id); Get.back(); Get.back(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const AppText('Confirm Delete', color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)), child: Icon(icon, size: 18, color: const Color(0xFF64748B))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppText(label, fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              const SizedBox(height: 2),
              AppText(value, fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
            ]),
          ),
        ],
      ),
    );
  }
}


class _EmployeeHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 45);

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 35,
      size.width,
      size.height - 45,
    );

    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
