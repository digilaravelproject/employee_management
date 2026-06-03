import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final String fileName;
  const DocumentPreviewScreen({super.key, required this.fileName});

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  int _currentPage = 1;
  final int _totalPages = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light grey background like a PDF reader
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
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
                size: 18,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: AppText(
          widget.fileName,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.textColorPrimary),
            onPressed: () {
              Get.snackbar(
                'File Downloaded',
                'Successfully downloaded "${widget.fileName}"',
                backgroundColor: AppColors.successColor,
                colorText: Colors.white,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textColorPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      // Renders standard formal page sheet
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 500),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Letterhead Header ──
                            Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Iconsax.briefcase5,
                                    color: Color(0xFF3B82F6),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  const AppText(
                                    'Tech Solutions Pvt. Ltd.',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                  ),
                                  const SizedBox(height: 2),
                                  const AppText(
                                    'Innovation & Excellence in Engineering',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColorHint,
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 1,
                                    width: double.infinity,
                                    color: AppColors.borderColor,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 32),

                            // ── Document Title ──
                            const Center(
                              child: AppText(
                                'OFFER LETTER',
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                                letterSpacing: 1.5,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Date ──
                            const AppText(
                              '20 May 2024',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF475569),
                            ),

                            const SizedBox(height: 20),

                            // ── Addressee ──
                            const AppText(
                              'Dear Rahul Sharma,',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),

                            const SizedBox(height: 16),

                            // ── Body Content ──
                            const AppText(
                              'We are pleased to offer you the position of Software Engineer at Tech Solutions Pvt. Ltd. Your employment terms and conditions are mentioned in the attached document.',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                            ),
                            const SizedBox(height: 16),
                            const AppText(
                              'We look forward to having you on our team! Your onboarding session is scheduled for 1st June 2024.',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                            ),

                            const SizedBox(height: 48),

                            // ── Sign Off ──
                            const AppText(
                              'Sincerely,',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                            const SizedBox(height: 8),
                            const AppText(
                              'HR Team',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                            const AppText(
                              'Tech Solutions Pvt. Ltd.',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom Page Slider Navigation ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: _currentPage > 1 ? AppColors.textColorPrimary : AppColors.textColorHint,
                    onPressed: _currentPage > 1 
                      ? () => setState(() => _currentPage--)
                      : null,
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.slate900,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AppText(
                      '$_currentPage / $_totalPages',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: _currentPage < _totalPages ? AppColors.textColorPrimary : AppColors.textColorHint,
                    onPressed: _currentPage < _totalPages 
                      ? () => setState(() => _currentPage++)
                      : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
