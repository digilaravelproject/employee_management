import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/route_helper.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
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
                  SizedBox(height: size.height * 0.06),

                  // ── Logo + Headline ──
                  _HeaderSection(screenHeight: size.height),

                  SizedBox(height: size.height * 0.04),

                  // ── White card with form ──
                  _LoginCard(controller: controller),

                  const SizedBox(height: 24),

                  // ── Sign up link ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        "Don't have an account? ",
                        style: AppTextStyle.body,
                        fontSize: 14,
                        color: AppColors.textColorSecondary,
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(RouteHelper.getSignupRoute()),
                        child: AppText(
                          'Sign Up',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
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

// ── Logo + headline on the blue section ───────────────────────────────────────
class _HeaderSection extends StatelessWidget {
  final double screenHeight;
  const _HeaderSection({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo with white border ring
        Container(
          padding: const EdgeInsets.all(4),
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
          child: const AppLogo(size: 84, showShadow: false),
        ),

        const SizedBox(height: 16),

        AppText(
          'Welcome Back!',
          style: AppTextStyle.heading,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        AppText(
          'Sign in to continue to your account',
          style: AppTextStyle.body,
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.82),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── White form card ───────────────────────────────────────────────────────────
class _LoginCard extends StatefulWidget {
  final AuthController controller;
  const _LoginCard({required this.controller});

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  bool _obscurePassword = true;

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
          key: widget.controller.loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title inside card
              AppText(
                'Login',
                style: AppTextStyle.subheading,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 4),
              AppText(
                'Enter your credentials to access the dashboard',
                style: AppTextStyle.caption,
                fontSize: 13,
                color: AppColors.textColorHint,
              ),

              const SizedBox(height: 24),

              // Email field
              AppText(
                'Email Address',
                style: AppTextStyle.label,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 8),
              AppInputField(
                hint: 'Enter your email',
                controller: widget.controller.emailController,
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
                validator: widget.controller.validateEmail,
              ),

              const SizedBox(height: 20),

              // Password field (hidden for now since flow uses OTP)
              AppText(
                'Password',
                style: AppTextStyle.label,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 8),
              AppInputField(
                hint: 'Enter your password',
                controller: widget.controller.passwordController,
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
                obscureText: _obscurePassword,
                icon: Icons.lock_outline_rounded,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.textColorHint,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.toNamed(RouteHelper.getForgotPasswordRoute()),
                  child: AppText(
                    'Forgot Password?',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Login button
              Obx(() => AppButton(
                text: 'Continue',
                //onPressed: widget.controller.login,
                onPressed: (){
                  Get.toNamed(RouteHelper.getDashboardRoute());
                },
                isLoading: widget.controller.isLoading.value,
                height: 50,
                borderRadius: 16,
               // icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              )),

              const SizedBox(height: 20),

              // Divider
              /*Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.slate200)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AppText(
                      'OR',
                      style: AppTextStyle.label,
                      fontSize: 12,
                      color: AppColors.textColorHint,
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.slate200)),
                ],
              ),

              const SizedBox(height: 20),

              // OTP login button
              AppButton.outline(
                text: 'Login with OTP',
                onPressed: widget.controller.login,
                icon: const Icon(Icons.sms_outlined, size: 18),
                height: 54,
                borderRadius: 16,
                color: AppColors.primaryColor,
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
