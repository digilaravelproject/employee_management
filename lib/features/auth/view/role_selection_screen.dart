import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../routes/route_helper.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Premium Background Gradient Wave
          ClipPath(
            clipper: _WaveClipper(),
            child: Container(
              height: size.height * 0.45,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Iconsax.arrow_left, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                const AppText(
                  'Select Your Role',
                  style: AppTextStyle.heading,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                AppText(
                  'Choose your portal to continue',
                  style: AppTextStyle.body,
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.8),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.06),
                
                // Cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        _RoleCard(
                          title: 'Admin / Manager',
                          description: 'Access full dashboard, team tracking, reports & configuration.',
                          icon: Iconsax.personalcard,
                          color: const Color(0xFF3B82F6),
                          onTap: () {
                            appController.setRole('admin');
                            Get.toNamed(RouteHelper.getLoginRoute());
                          },
                        ),
                        const SizedBox(height: 24),
                        _RoleCard(
                          title: 'Employee',
                          description: 'Access your shift schedule, attendance, and payslips.',
                          icon: Iconsax.user_square,
                          color: const Color(0xFF10B981),
                          onTap: () {
                            appController.setRole('employee');
                            Get.toNamed(RouteHelper.getLoginRoute());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.1), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    description,
                    fontSize: 13,
                    color: AppColors.textColorSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Iconsax.arrow_right_3, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height + 20,
      size.width * 0.5,
      size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 60,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
