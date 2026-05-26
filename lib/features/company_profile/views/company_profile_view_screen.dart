import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/company_profile_controller.dart';
import '../models/company_profile_model.dart';
import 'company_profile_edit_screen.dart';

class CompanyProfileViewScreen extends StatelessWidget {
  const CompanyProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompanyProfileController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          'Company Profile',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () {
              controller.initializeEditing();
              Get.to(() => const CompanyProfileEditScreen());
            },
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryColor, size: 16),
            label: const AppText(
              'Add Profile',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final profile = controller.profile.value;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. MAIN HERO COMPANY CARD ──
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.slate200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Logo, Verified Pill, Name
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Company Logo representation
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.slate50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.slate200, width: 1.5),
                              image: DecorationImage(
                                image: NetworkImage(profile.logoUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppText(
                                        profile.name,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        color: AppColors.textColorPrimary,
                                      ),
                                    ),
                                    if (profile.isVerified)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        margin: const EdgeInsets.only(left: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEAFAF1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AppText(
                                              'Verified Company',
                                              fontSize: 8,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.successColor,
                                            ),
                                            SizedBox(width: 2),
                                            Icon(
                                              Icons.check_circle,
                                              size: 10,
                                              color: AppColors.successColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                AppText(
                                  profile.tagline,
                                  fontSize: 12,
                                  color: AppColors.textColorSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(height: 1, color: AppColors.slate200),
                      const SizedBox(height: 18),

                      // Horizontal Metadata Strip
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _HeroStatBadge(
                              icon: Iconsax.briefcase,
                              label: profile.industry,
                            ),
                            const SizedBox(width: 16),
                            _HeroStatBadge(
                              icon: Iconsax.profile_2user,
                              label: '${profile.companySize} Employees',
                            ),
                            const SizedBox(width: 16),
                            _HeroStatBadge(
                              icon: Iconsax.calendar,
                              label: 'Founded in ${profile.foundedYear}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── 2. ABOUT COMPANY SECTION ──
                const AppText(
                  'About Company',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Text(
                    profile.about,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColorSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── 3. CONTACT INFORMATION PANEL ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Contact Information',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 14),
                      _ContactRowItem(icon: Iconsax.sms, label: profile.email),
                      const Divider(height: 20, color: AppColors.slate100),
                      _ContactRowItem(icon: Iconsax.call, label: profile.phone),
                      const Divider(height: 20, color: AppColors.slate100),
                      _ContactRowItem(icon: Iconsax.global, label: profile.website),
                      const Divider(height: 20, color: AppColors.slate100),
                      _ContactRowItem(icon: Iconsax.map, label: profile.address, isAddress: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── 4. SOCIAL LINKS PANEL ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Social Links',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 14),
                      if (profile.socialLinks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: AppText(
                              'No social links added.',
                              fontSize: 11,
                              color: AppColors.textColorHint,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        ...profile.socialLinks.map((social) {
                          return _SocialRowItem(social: social);
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── 4. VISION & MISSION STATEMENTS ──
                _CoreStatementCard(
                  icon: Iconsax.eye,
                  title: 'Our Vision',
                  description: profile.vision,
                  iconColor: const Color(0xFF6366F1),
                  iconBg: const Color(0xFFEEF2FF),
                ),
                const SizedBox(height: 14),
                _CoreStatementCard(
                  icon: Iconsax.award,
                  title: 'Our Mission',
                  description: profile.mission,
                  iconColor: const Color(0xFF8B5CF6),
                  iconBg: const Color(0xFFF5F3FF),
                ),
                const SizedBox(height: 20),
              ],
            )
          );
          }),
        ),
    //  ),
    );
  }
}

// ── CUSTOM SMALL STAT BADGE ──────────────────────────────────────────────────
class _HeroStatBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroStatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textColorSecondary),
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

// ── CONTACT INFORMATION ITEM CARD ────────────────────────────────────────────
class _ContactRowItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAddress;

  const _ContactRowItem({required this.icon, required this.label, this.isAddress = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF), // Indigo Light tint
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textColorPrimary,
              height: isAddress ? 1.4 : 1,
            ),
            maxLines: isAddress ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── SOCIAL ROW BRAND LINK ────────────────────────────────────────────────────
class _SocialRowItem extends StatelessWidget {
  final SocialLink social;

  const _SocialRowItem({required this.social});

  @override
  Widget build(BuildContext context) {
    
    // Clean URL for elegant display (remove https:// or http:// if present)
    String displayUrl = social.url;
    if (displayUrl.startsWith('https://')) {
      displayUrl = displayUrl.substring(8);
    } else if (displayUrl.startsWith('http://')) {
      displayUrl = displayUrl.substring(7);
    }
    if (displayUrl.isEmpty) {
      displayUrl = '${social.platform.toLowerCase()}.com/technova';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBrandIcon(social.platform),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Open dynamic web link if configured
              },
              child: Text(
                displayUrl,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColorPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandIcon(String platform) {
    final platformLower = platform.toLowerCase();
    if (platformLower.contains('linkedin')) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFF0077B5),
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: Alignment.center,
        child: const Text(
          'in',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      );
    } else if (platformLower.contains('twitter') || platformLower.contains('x.com')) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: Alignment.center,
        child: const Text(
          '𝕏',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (platformLower.contains('facebook')) {
      return const Icon(
        Icons.facebook,
        color: Color(0xFF1877F2),
        size: 20,
      );
    }
    return const Icon(
      Iconsax.link,
      color: AppColors.textColorHint,
      size: 18,
    );
  }
}

// ── VISION & MISSION STATEMENT GRAPHICS CARD ────────────────────────────────
class _CoreStatementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final Color iconBg;

  const _CoreStatementCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColorSecondary,
                    height: 1.45,
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
