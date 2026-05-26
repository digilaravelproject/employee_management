import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── Top blue wave background ──
          _TopWaveBackground(height: size.height * 0.42),

          // ── Scrollable content ──
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Back Button Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),

                  // ── Icon + Headline ──
                  _HeaderSection(screenHeight: size.height),

                  SizedBox(height: size.height * 0.04),

                  // ── White card with form ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.08),
                            blurRadius: 40,
                            spreadRadius: 0,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Update Password',
                            style: AppTextStyle.subheading,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            'Enter your current and new password below',
                            style: AppTextStyle.caption,
                            fontSize: 13,
                            color: AppColors.textColorHint,
                          ),
                          
                          const SizedBox(height: 24),

                          // Current Password
                          AppText(
                            'Current Password',
                            style: AppTextStyle.label,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 8),
                          AppInputField(
                            hint: 'Enter your current password',
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrent,
                            isPassword: true,
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() => _obscureCurrent = !_obscureCurrent),
                              child: Icon(
                                _obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                                color: AppColors.textColorHint,
                              ),
                            ),
                          ),


                          const SizedBox(height: 16),
                          // New Password
                          AppText(
                            'New Password',
                            style: AppTextStyle.label,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 8),
                          AppInputField(
                            hint: 'Create new password',
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            isPassword: true,
                            icon: Icons.key_outlined,
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() => _obscureNew = !_obscureNew),
                              child: Icon(
                                _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                                color: AppColors.textColorHint,
                              ),
                            ),
                          ),


                          const SizedBox(height: 16),
                          // Confirm Password
                          AppText(
                            'Confirm Password',
                            style: AppTextStyle.label,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorPrimary,
                          ),
                          const SizedBox(height: 8),
                          AppInputField(
                            hint: 'Re-enter your new password',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            isPassword: true,
                            icon: Icons.key_outlined,
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              child: Icon(
                                _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                                color: AppColors.textColorHint,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Password Requirements
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.slate200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppText('Password must contain:', fontSize: 12, fontWeight: FontWeight.bold),
                                const SizedBox(height: 8),
                                _buildRequirementRow(Icons.check_circle, 'At least 8 characters', Colors.green),
                                const SizedBox(height: 6),
                                _buildRequirementRow(Icons.circle_outlined, 'One uppercase letter', AppColors.textColorSecondary),
                                const SizedBox(height: 6),
                                _buildRequirementRow(Icons.circle_outlined, 'One special character (!@#\$&*)', AppColors.textColorSecondary),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          
                          const SizedBox(height: 32),
                          
                          // Save Button
                          AppButton(
                            text: 'Update Password',
                            onPressed: () {
                              if (_newPasswordController.text != _confirmPasswordController.text) {
                                Get.snackbar(
                                  'Error',
                                  'Passwords do not match',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              Get.back();
                              Get.snackbar(
                                'Success',
                                'Password changed successfully',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            },
                            height: 50,
                            borderRadius: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        AppText(text, fontSize: 11, color: color == Colors.green ? AppColors.textColorPrimary : AppColors.textColorSecondary),
      ],
    );
  }
}

// ── Top curved blue background ────────────────────────────────────────────────
class _TopWaveBackground extends StatelessWidget {
  final double height;
  const _TopWaveBackground({required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 60,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
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

// ── Icon + headline on the blue section ───────────────────────────────────────
class _HeaderSection extends StatelessWidget {
  final double screenHeight;
  const _HeaderSection({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon with white border ring
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Iconsax.shield_tick, size: 50, color: AppColors.primaryColor),
        ),

        const SizedBox(height: 16),

        AppText(
          'Secure Account',
          style: AppTextStyle.heading,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        AppText(
          'Keep your password strong and safe',
          style: AppTextStyle.body,
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.82),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
