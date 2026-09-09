import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/admin_signup_controller.dart';
import '../../../routes/route_helper.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminSignupController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── Compact top blue header ──
          _TopHeader(height: size.height * 0.28),

          // ── Scrollable content ──
          SafeArea(
            child: Column(
              children: [
                // Back button row
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

                // Logo + title
                _HeaderContent(),

                const SizedBox(height: 16),

                // ── White card form (scrollable) ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _SignupCard(controller: controller),
                        const SizedBox(height: 24),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              'Already have an account? ',
                              style: AppTextStyle.body,
                              fontSize: 14,
                              color: AppColors.textColorSecondary,
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Get.offNamed(RouteHelper.getLoginRoute()),
                              child: AppText(
                                'Login',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
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

// ── Compact blue wave top header ──────────────────────────────────────────────
class _TopHeader extends StatelessWidget {
  final double height;
  const _TopHeader({required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _SignupWaveClipper(),
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
              top: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 80,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignupWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height + 10,
      size.width * 0.6,
      size.height - 30,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height - 55,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_SignupWaveClipper oldClipper) => false;
}

// ── Logo + headline on header ─────────────────────────────────────────────────
class _HeaderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 6),
        AppText(
          'Create Admin Account',
          style: AppTextStyle.heading,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6),
        AppText(
          'Register your company and manage everything easily',
          style: AppTextStyle.body,
          fontSize: 13,
          color: Colors.white70,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Signup form card ──────────────────────────────────────────────────────────
class _SignupCard extends StatelessWidget {
  final AdminSignupController controller;
  const _SignupCard({required this.controller});

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
        child: Form(
          key: controller.signupFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card title
              AppText(
                'Company Registration',
                style: AppTextStyle.subheading,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 4),
              AppText(
                'Fill in the details below to create your admin account',
                style: AppTextStyle.caption,
                fontSize: 13,
                color: AppColors.textColorHint,
              ),

              const SizedBox(height: 24),

              // ── Company Name ──
              const _FieldLabel('Company Name'),
              const SizedBox(height: 8),
              AppInputField(
                hint: 'e.g. Acme Solutions',
                controller: controller.companyNameController,
                keyboardType: TextInputType.text,
                icon: Icons.business_outlined,
                validator: controller.validateCompanyName,
              ),

              const SizedBox(height: 18),

              // ── Owner Name ──
              const _FieldLabel('Owner Name'),
              const SizedBox(height: 8),
              AppInputField(
                hint: 'e.g. Darshan Kondekar',
                controller: controller.ownerNameController,
                keyboardType: TextInputType.name,
                icon: Icons.person_outline_rounded,
                validator: controller.validateOwnerName,
              ),

              const SizedBox(height: 18),

              // ── Mobile Number ──
              const _FieldLabel('Mobile Number'),
              const SizedBox(height: 8),
              AppInputField(
                hint: 'e.g. 9876543210',
                controller: controller.mobileNumberController,
                keyboardType: TextInputType.phone,
                icon: Icons.phone_outlined,
                validator: controller.validateMobileNumber,
              ),

              const SizedBox(height: 18),

              // ── Email ──
              const _FieldLabel('Email Address'),
              const SizedBox(height: 8),
              AppInputField(
                hint: 'e.g. owner@acmesolutions.com',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
                validator: controller.validateEmail,
              ),

              const SizedBox(height: 18),

              // ── Password ──
              const _FieldLabel('Password'),
              const SizedBox(height: 8),
              Obx(() => AppInputField(
                    hint: 'Enter your password',
                    controller: controller.passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    obscureText: !controller.isPasswordVisible.value,
                    icon: Icons.lock_outline_rounded,
                    validator: controller.validatePassword,
                    suffixIcon: GestureDetector(
                      onTap: controller.togglePasswordVisibility,
                      child: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textColorHint,
                      ),
                    ),
                  )),

              const SizedBox(height: 18),

              // ── Confirm Password ──
              const _FieldLabel('Confirm Password'),
              const SizedBox(height: 8),
              Obx(() => AppInputField(
                    hint: 'Re-enter your password',
                    controller: controller.confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    icon: Icons.lock_outline_rounded,
                    validator: controller.validateConfirmPassword,
                    suffixIcon: GestureDetector(
                      onTap: controller.toggleConfirmPasswordVisibility,
                      child: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textColorHint,
                      ),
                    ),
                  )),

              const SizedBox(height: 20),

              // ── Terms checkbox ──
              Obx(() {
                final isChecked = controller.agreedToTerms.value;
                return GestureDetector(
                  onTap: () => controller.toggleTermsAgreement(null),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isChecked
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isChecked
                                ? AppColors.primaryColor
                                : AppColors.slate300,
                            width: 1.5,
                          ),
                        ),
                        child: isChecked
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: AppColors.textColorSecondary,
                              fontFamily: GoogleFonts.outfit().fontFamily,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: GoogleFonts.outfit().fontFamily,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: GoogleFonts.outfit().fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 28),

              // ── Register button ──
              Obx(() => AppButton(
                    text: 'Create Account',
                    onPressed: controller.agreedToTerms.value
                        ? controller.signup
                        : null,
                    isLoading: controller.isLoading.value,
                    height: 50,
                    borderRadius: 16,
                  )),

              Obx(() => (!controller.agreedToTerms.value)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: AppText(
                          'Please accept the terms to continue',
                          fontSize: 12,
                          color: AppColors.textColorHint,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable field label ──────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: AppTextStyle.label,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textColorPrimary,
    );
  }
}
