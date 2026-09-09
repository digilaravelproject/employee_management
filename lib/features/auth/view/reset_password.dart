import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/admin_signup_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<AdminSignupController>();
    if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['email'] != null && args['email'].toString().isNotEmpty) {
        controller.resetEmailController.text = args['email'].toString();
      }
      if (args['otp'] != null && args['otp'].toString().isNotEmpty) {
        controller.resetOtpController.text = args['otp'].toString();
      }
    } else if (controller.forgotEmailController.text.isNotEmpty &&
        controller.resetEmailController.text.isEmpty) {
      controller.resetEmailController.text =
          controller.forgotEmailController.text.trim();
    }
    if (controller.forgotPasswordOtpDebug.value.isNotEmpty &&
        controller.resetOtpController.text.isEmpty) {
      controller.resetOtpController.text =
          controller.forgotPasswordOtpDebug.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminSignupController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── Top Header ──
          _TopHeader(height: size.height * 0.35),

          // ── Content ──
          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Title
                _HeaderContent(),

                const SizedBox(height: 30),

                // Card
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _ResetCard(
                      controller: controller,
                      obscurePass: _obscurePass,
                      obscureConfirm: _obscureConfirm,
                      onTogglePass: () => setState(() => _obscurePass = !_obscurePass),
                      onToggleConfirm: () => setState(() => _obscureConfirm = !_obscureConfirm),
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

class _TopHeader extends StatelessWidget {
  final double height;
  const _TopHeader({required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ResetWaveClipper(),
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

class _ResetWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 20,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_ResetWaveClipper oldClipper) => false;
}

class _HeaderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
          ),
          child: const Icon(
            Icons.security_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        const AppText(
          'Set New Password',
          style: AppTextStyle.heading,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const AppText(
          'Create a strong password to secure your account',
          style: AppTextStyle.body,
          fontSize: 14,
          color: Colors.white70,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ResetCard extends StatelessWidget {
  final AdminSignupController controller;
  final bool obscurePass;
  final bool obscureConfirm;
  final VoidCallback onTogglePass;
  final VoidCallback onToggleConfirm;

  const _ResetCard({
    required this.controller,
    required this.obscurePass,
    required this.obscureConfirm,
    required this.onTogglePass,
    required this.onToggleConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: controller.resetPasswordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Email ──
              const AppText(
                'Email Address',
                style: AppTextStyle.label,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              AppInputField(
                hint: 'Enter registered email',
                controller: controller.resetEmailController,
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
                validator: controller.validateResetEmail,
              ),
              const SizedBox(height: 20),

              // ── Verification Code ──
              const AppText(
                'Verification Code',
                style: AppTextStyle.label,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              AppInputField(
                hint: 'Enter 6-digit OTP',
                controller: controller.resetOtpController,
                keyboardType: TextInputType.number,
                icon: Iconsax.password_check,
                validator: controller.validateResetOtp,
              ),
              const SizedBox(height: 20),

              // ── New Password ──
              const AppText(
                'New Password',
                style: AppTextStyle.label,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              AppInputField(
                hint: 'Enter new password',
                controller: controller.resetNewPasswordController,
                isPassword: true,
                obscureText: obscurePass,
                icon: Icons.lock_outline_rounded,
                validator: controller.validateResetNewPassword,
                suffixIcon: IconButton(
                  onPressed: onTogglePass,
                  icon: Icon(
                    obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.textColorHint,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Confirm Password ──
              const AppText(
                'Confirm Password',
                style: AppTextStyle.label,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              AppInputField(
                hint: 'Re-enter new password',
                controller: controller.resetConfirmPasswordController,
                isPassword: true,
                obscureText: obscureConfirm,
                icon: Icons.lock_reset_rounded,
                validator: controller.validateResetConfirmPassword,
                suffixIcon: IconButton(
                  onPressed: onToggleConfirm,
                  icon: Icon(
                    obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.textColorHint,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Submit Button ──
              Obx(() => AppButton(
                    text: 'Update Password',
                    onPressed: controller.resetPassword,
                    isLoading: controller.isResetPasswordLoading.value,
                    height: 50,
                    borderRadius: 16,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
