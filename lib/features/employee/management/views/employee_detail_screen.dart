import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../../../core/widgets/app_text.dart';
import '../controllers/employee_controller.dart';
import '../models/employee_model.dart';
import 'add_employee_screen.dart';
import '../../../performance/controllers/performance_controller.dart';
import '../../../performance/models/performance_model.dart';
import '../../../performance/views/team_member_performance_screen.dart';
import '../../../attendance/views/attendance_history_screen.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final EmployeeModel employee;
  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen>
    with SingleTickerProviderStateMixin {
  late final EmployeeController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _controller = Get.isRegistered<EmployeeController>()
        ? Get.find<EmployeeController>()
        : Get.put(EmployeeController());

    _controller.setEmployeeDetail(widget.employee);
    if (widget.employee.id.isNotEmpty) {
      _controller.fetchEmployeeDetail(widget.employee.id, showLoader: false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return '—';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        return DateFormat('dd MMM yyyy').format(parsed);
      }
    } catch (_) {}
    return rawDate;
  }

  String _formatDateTime(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return '—';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        return DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
      }
    } catch (_) {}
    return rawDate;
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return formatter.format(amount);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) {
      CustomSnackbar.showInfo('Phone number not available');
      return;
    }
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Clipboard.setData(ClipboardData(text: phoneNumber));
      CustomSnackbar.showSuccess('Phone number copied to clipboard: $phoneNumber');
    }
  }

  Future<void> _sendSms(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) {
      CustomSnackbar.showInfo('Phone number not available');
      return;
    }
    final uri = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Clipboard.setData(ClipboardData(text: phoneNumber));
      CustomSnackbar.showSuccess('Phone number copied to clipboard: $phoneNumber');
    }
  }

  Future<void> _sendEmail(String email) async {
    if (email.trim().isEmpty) {
      CustomSnackbar.showInfo('Email address not available');
      return;
    }
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Clipboard.setData(ClipboardData(text: email));
      CustomSnackbar.showSuccess('Email address copied to clipboard: $email');
    }
  }

  void _showImagePickerSheet(BuildContext context, EmployeeModel emp) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const AppText(
              'Change Profile Picture',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 4),
            const AppText(
              'Select an image source to update profile avatar',
              fontSize: 12,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.gallery, color: AppColors.primaryColor, size: 22),
              ),
              title: const AppText('Choose from Gallery', fontSize: 14, fontWeight: FontWeight.w700),
              subtitle: const AppText('Select an existing photo from gallery', fontSize: 11, color: AppColors.textColorHint),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textColorHint),
              onTap: () {
                Get.back();
                _pickAndUploadImage(ImageSource.gallery, emp);
              },
            ),
            const Divider(height: 1, color: AppColors.slate100),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.camera, color: Color(0xFF10B981), size: 22),
              ),
              title: const AppText('Take Photo with Camera', fontSize: 14, fontWeight: FontWeight.w700),
              subtitle: const AppText('Capture a new photo right away', fontSize: 11, color: AppColors.textColorHint),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textColorHint),
              onTap: () {
                Get.back();
                _pickAndUploadImage(ImageSource.camera, emp);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source, EmployeeModel emp) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        await _controller.updateEmployeeAvatar(emp.id, file);
      }
    } catch (e) {
      CustomSnackbar.showError('Could not select image: $e', title: 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final emp = _controller.employeeDetail.value ?? widget.employee;
      final isRefreshing = _controller.isLoadingDetail.value;

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textColorPrimary, size: 18),
            onPressed: () => Get.back(),
          ),
          title: const AppText(
            'Employee Profile',
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          actions: [
            IconButton(
              onPressed: () async {
                final res = await Get.to(() => AddEmployeeScreen(employee: emp));
                if (res == true && emp.id.isNotEmpty) {
                  _controller.fetchEmployeeDetail(emp.id, showLoader: false);
                }
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.edit, color: AppColors.primaryColor, size: 18),
              ),
            ),
            IconButton(
              onPressed: () => _showDeleteConfirmationDialog(context, _controller, emp),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.trash, color: Color(0xFFDC2626), size: 18),
              ),
            ),
            const SizedBox(width: 6),
          ],
          bottom: isRefreshing
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                )
              : null,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (emp.id.isNotEmpty) {
              await _controller.fetchEmployeeDetail(emp.id, showLoader: false);
            }
          },
          color: AppColors.primaryColor,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      children: [
                        // Profile Card
                        _buildProfileCard(context, emp),
                        const SizedBox(height: 12),
                        // Quick Stats Strip
                        _buildSummaryStrip(emp),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    height: 54,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.slate200.withValues(alpha: 0.9),
                          width: 1,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.textColorSecondary,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                        tabs: const [
                          Tab(
                            height: 36,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.dashboard_rounded, size: 15),
                                SizedBox(width: 6),
                                Text('Overview'),
                              ],
                            ),
                          ),
                          Tab(
                            height: 36,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.business_center_rounded, size: 15),
                                SizedBox(width: 6),
                                Text('Job & Organization'),
                              ],
                            ),
                          ),
                          Tab(
                            height: 36,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_rounded, size: 15),
                                SizedBox(width: 6),
                                Text('Personal & Contact'),
                              ],
                            ),
                          ),
                          Tab(
                            height: 36,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.payments_rounded, size: 15),
                                SizedBox(width: 6),
                                Text('Payroll & Compensation'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, emp),
                _buildJobAndOrgTab(emp),
                _buildPersonalAndContactTab(emp),
                _buildPayrollAndTargetTab(emp),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ── 1. COMPACT PROFILE CARD ──
  Widget _buildProfileCard(BuildContext context, EmployeeModel emp) {
    String initial = '';
    if (emp.name.trim().isNotEmpty) {
      final parts = emp.name.trim().split(' ');
      initial = parts.map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase();
    }
    if (initial.isEmpty) initial = 'EM';

    ImageProvider? imageProvider;
    if (emp.profilePic != null && emp.profilePic!.trim().isNotEmpty) {
      final pic = emp.profilePic!.trim();
      if (pic.startsWith('http://') || pic.startsWith('https://')) {
        imageProvider = NetworkImage(pic);
      } else {
        try {
          final f = File(pic);
          if (f.existsSync()) {
            imageProvider = FileImage(f);
          }
        } catch (_) {}
      }
    }

    final statusText = emp.employmentStatus.isNotEmpty
        ? emp.employmentStatus
        : (emp.isActive ? 'Active' : 'Inactive');

    Color statusBgColor = const Color(0xFFDCFCE7);
    Color statusTextColor = const Color(0xFF16A34A);
    if (statusText.toLowerCase() == 'inactive' || statusText.toLowerCase() == 'terminated') {
      statusBgColor = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFDC2626);
    } else if (statusText.toLowerCase() == 'probation' || statusText.toLowerCase() == 'notice period') {
      statusBgColor = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFD97706);
    }

    final isUploading = _controller.isUploadingAvatar.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with camera icon overlay
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2), width: 2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? AppText(
                                  initial,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryColor,
                                )
                              : null,
                        ),
                        if (isUploading)
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showImagePickerSheet(context, emp),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Iconsax.camera,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Name, designation & ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AppText(
                            emp.name.isNotEmpty ? emp.name : 'Unnamed Employee',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textColorPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AppText(
                            statusText,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      emp.designation.isNotEmpty
                          ? emp.designation
                          : (emp.role.isNotEmpty ? emp.role.toUpperCase() : 'Employee'),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (emp.employeeId.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText(
                              emp.employeeId,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        if (emp.department.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText(
                              emp.department,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.slate100),
          const SizedBox(height: 12),

          // Quick Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(
                icon: Iconsax.call,
                label: 'Call',
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                onTap: () => _makePhoneCall(emp.mobile),
              ),
              _buildQuickActionButton(
                icon: Iconsax.message,
                label: 'Message',
                color: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF),
                onTap: () => _sendSms(emp.mobile),
              ),
              _buildQuickActionButton(
                icon: Iconsax.sms,
                label: 'Email',
                color: const Color(0xFFF97316),
                bgColor: const Color(0xFFFFF7ED),
                onTap: () => _sendEmail(emp.email),
              ),
              _buildQuickActionButton(
                icon: Iconsax.copy,
                label: 'Copy ID',
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF5F3FF),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: emp.employeeId));
                  CustomSnackbar.showSuccess('Employee ID copied: ${emp.employeeId}');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 4),
            AppText(label, fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
          ],
        ),
      ),
    );
  }

  // ── 2. SUMMARY METRICS STRIP ──
  Widget _buildSummaryStrip(EmployeeModel emp) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Base Salary',
            value: _formatCurrency(emp.salary),
            subtitle: emp.salaryType.isNotEmpty ? emp.salaryType : 'Monthly',
            icon: Iconsax.wallet_3,
            bgColors: [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
            borderColor: const Color(0xFF86EFAC),
            iconColor: const Color(0xFF059669),
            textColor: const Color(0xFF14532D),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            title: 'Work Mode',
            value: emp.workMode.isNotEmpty ? emp.workMode : 'Office',
            subtitle: emp.employeeType.isNotEmpty ? emp.employeeType : 'Full-time',
            icon: Iconsax.briefcase,
            bgColors: [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
            borderColor: const Color(0xFF93C5FD),
            iconColor: const Color(0xFF2563EB),
            textColor: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            title: 'Assigned Shift',
            value: emp.shift.isNotEmpty ? emp.shift : 'Default',
            subtitle: 'Schedule',
            icon: Iconsax.clock,
            bgColors: [const Color(0xFFFAF5FF), const Color(0xFFEDE9FE)],
            borderColor: const Color(0xFFC4B5FD),
            iconColor: const Color(0xFF7C3AED),
            textColor: const Color(0xFF4C1D95),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required List<Color> bgColors,
    required Color borderColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 13, color: iconColor),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: AppText(
                  title,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: textColor.withValues(alpha: 0.8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AppText(
            value,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: textColor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          AppText(
            subtitle,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: textColor.withValues(alpha: 0.7),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── TAB 1: OVERVIEW ──
  Widget _buildOverviewTab(BuildContext context, EmployeeModel emp) {
    final perfController = Get.isRegistered<PerformanceController>()
        ? Get.find<PerformanceController>()
        : Get.put(PerformanceController());

    final matched = perfController.employees.firstWhereOrNull(
      (e) => e.name.toLowerCase() == emp.name.toLowerCase() || e.id == emp.id,
    );
    final perfScore = matched?.performanceScore ?? 94;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        // Performance & Attendance Row
        Row(
          children: [
            Expanded(
              child: _buildInteractiveScoreCard(
                title: 'Performance Score',
                score: '$perfScore%',
                badge: 'Rating',
                icon: Iconsax.chart_21,
                color: const Color(0xFF8B5CF6),
                onTap: () => _openEmployeePerformance(context, emp, matched),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInteractiveScoreCard(
                title: 'Attendance Record',
                score: '98%',
                badge: 'Monthly',
                icon: Iconsax.user_tick,
                color: const Color(0xFF0D9488),
                onTap: () => _openEmployeeAttendance(context, emp),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Quick Highlights Card
        _buildCardWrapper(
          title: 'Quick Information',
          icon: Iconsax.info_circle,
          iconColor: AppColors.primaryColor,
          children: [
            _buildInfoTile('Date of Joining', _formatDate(emp.joiningDate), icon: Iconsax.calendar),
            _buildInfoTile('Reporting Manager', emp.reportingManager.isNotEmpty ? emp.reportingManager : '—', icon: Iconsax.user_tag),
            _buildInfoTile('Work Mode', emp.workMode.isNotEmpty ? emp.workMode : 'Office', icon: Iconsax.buildings),
            _buildInfoTile('Lifecycle Status', emp.employmentStatus.isNotEmpty ? emp.employmentStatus : 'Active', icon: Iconsax.status_up, isLast: true),
          ],
        ),
        const SizedBox(height: 16),

        // Technical Skills
        _buildCardWrapper(
          title: 'Technical Skills & Expertise',
          icon: Iconsax.code,
          iconColor: const Color(0xFF6366F1),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppText(
              '${emp.skills.length} listed',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4F46E5),
            ),
          ),
          children: [
            if (emp.skills.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: AppText('No technical skills added to profile.',
                    fontSize: 12, color: AppColors.textColorHint),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    emp.skills.length,
                    (idx) => _buildSkillTag(emp.skills[idx], idx),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Record Audit Timestamps
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Created At', fontSize: 10, color: AppColors.textColorHint, fontWeight: FontWeight.w600),
                  const SizedBox(height: 2),
                  AppText(_formatDateTime(emp.createdAt), fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const AppText('Last Updated', fontSize: 10, color: AppColors.textColorHint, fontWeight: FontWeight.w600),
                  const SizedBox(height: 2),
                  AppText(_formatDateTime(emp.updatedAt), fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textColorSecondary),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveScoreCard({
    required String title,
    required String score,
    required String badge,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
              ],
            ),
            const SizedBox(height: 12),
            AppText(score, fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textColorPrimary),
            const SizedBox(height: 2),
            AppText(title, fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTag(String skill, int index) {
    final palettes = [
      {'bg': const Color(0xFFEFF6FF), 'border': const Color(0xFFBFDBFE), 'text': const Color(0xFF1D4ED8), 'dot': const Color(0xFF2563EB)},
      {'bg': const Color(0xFFF0FDF4), 'border': const Color(0xFFBBF7D0), 'text': const Color(0xFF15803D), 'dot': const Color(0xFF16A34A)},
      {'bg': const Color(0xFFFAF5FF), 'border': const Color(0xFFE9D5FF), 'text': const Color(0xFF7E22CE), 'dot': const Color(0xFF9333EA)},
      {'bg': const Color(0xFFFFF7ED), 'border': const Color(0xFFFED7AA), 'text': const Color(0xFFC2410C), 'dot': const Color(0xFFEA580C)},
      {'bg': const Color(0xFFECFEFF), 'border': const Color(0xFFA5F3FC), 'text': const Color(0xFF0E7490), 'dot': const Color(0xFF06B6D4)},
    ];
    final p = palettes[index % palettes.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: p['bg'],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p['border']!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: p['dot'],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          AppText(
            skill,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: p['text'],
          ),
        ],
      ),
    );
  }

  // ── TAB 2: JOB & ORG ──
  Widget _buildJobAndOrgTab(EmployeeModel emp) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildCardWrapper(
          title: 'Organization Details',
          icon: Iconsax.briefcase,
          iconColor: const Color(0xFF2563EB),
          children: [
            _buildInfoTile('Employee ID', emp.employeeId.isNotEmpty ? emp.employeeId : '—', icon: Iconsax.personalcard, isHighlight: true),
            _buildInfoTile('System Role', emp.role.isNotEmpty ? emp.role.toUpperCase() : 'EMPLOYEE', icon: Iconsax.user_tag),
            _buildInfoTile('Department', emp.department.isNotEmpty ? emp.department : '—', icon: Iconsax.building),
            _buildInfoTile('Designation', emp.designation.isNotEmpty ? emp.designation : '—', icon: Iconsax.award),
            _buildInfoTile('Assigned Shift', emp.shift.isNotEmpty ? emp.shift : '—', icon: Iconsax.clock),
            _buildInfoTile('Reporting Manager', emp.reportingManager.isNotEmpty ? emp.reportingManager : '—', icon: Iconsax.user_cirlce_add, isLast: true),
          ],
        ),
        const SizedBox(height: 16),

        _buildCardWrapper(
          title: 'Employment Lifecycle',
          icon: Iconsax.timer,
          iconColor: const Color(0xFF8B5CF6),
          children: [
            _buildInfoTile('Work Mode', emp.workMode.isNotEmpty ? emp.workMode : 'Office', icon: Iconsax.category),
            _buildInfoTile('Employment Type', emp.employeeType.isNotEmpty ? emp.employeeType : 'Full-time', icon: Iconsax.briefcase),
            _buildInfoTile('Date of Joining', _formatDate(emp.joiningDate), icon: Iconsax.calendar_tick),
            _buildInfoTile('Status', emp.employmentStatus.isNotEmpty ? emp.employmentStatus : 'Active', icon: Iconsax.status_up),
            _buildInfoTile('Probation Period', emp.probationPeriod.isNotEmpty ? emp.probationPeriod : 'None', icon: Iconsax.timer),
            _buildInfoTile('Notice Period', emp.noticePeriod.isNotEmpty ? emp.noticePeriod : 'None', icon: Iconsax.timer_1, isLast: true),
          ],
        ),
      ],
    );
  }

  // ── TAB 3: PERSONAL & CONTACT ──
  Widget _buildPersonalAndContactTab(EmployeeModel emp) {
    final addressParts = [
      emp.address,
      if (emp.city.isNotEmpty) emp.city,
      if (emp.state.isNotEmpty) emp.state,
      if (emp.pincode.isNotEmpty) 'PIN: ${emp.pincode}',
      if (emp.country.isNotEmpty) emp.country,
    ].where((s) => s.trim().isNotEmpty).toList();

    final fullAddress = addressParts.isNotEmpty ? addressParts.join(', ') : '—';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildCardWrapper(
          title: 'Contact Information',
          icon: Iconsax.call,
          iconColor: const Color(0xFFF97316),
          children: [
            _buildInfoTile(
              'Work Email',
              emp.email.isNotEmpty ? emp.email : '—',
              icon: Iconsax.sms,
              onTap: emp.email.isNotEmpty ? () => _sendEmail(emp.email) : null,
            ),
            _buildInfoTile(
              'Mobile Number',
              emp.mobile.isNotEmpty ? emp.mobile : '—',
              icon: Iconsax.call,
              onTap: emp.mobile.isNotEmpty ? () => _makePhoneCall(emp.mobile) : null,
            ),
            if (emp.alternateMobile.isNotEmpty)
              _buildInfoTile(
                'Alternate Mobile',
                emp.alternateMobile,
                icon: Iconsax.call_calling,
                onTap: () => _makePhoneCall(emp.alternateMobile),
              ),
            _buildInfoTile(
              'Emergency Contact',
              emp.emergencyContact.isNotEmpty ? emp.emergencyContact : '—',
              icon: Iconsax.security_user,
              onTap: emp.emergencyContact.isNotEmpty ? () => _makePhoneCall(emp.emergencyContact) : null,
            ),
            _buildInfoTile('Complete Address', fullAddress, icon: Iconsax.location, isLast: true),
          ],
        ),
        const SizedBox(height: 16),

        _buildCardWrapper(
          title: 'Personal Details',
          icon: Iconsax.user,
          iconColor: const Color(0xFF0D9488),
          children: [
            _buildInfoTile('Gender', emp.gender.isNotEmpty ? emp.gender : '—', icon: Iconsax.man),
            _buildInfoTile('Date of Birth', _formatDate(emp.dob), icon: Iconsax.calendar_1),
            _buildInfoTile('Marital Status', emp.maritalStatus.isNotEmpty ? emp.maritalStatus : '—', icon: Iconsax.heart),
            _buildInfoTile('Blood Group', emp.bloodGroup.isNotEmpty ? emp.bloodGroup : '—', icon: Iconsax.drop, isLast: true),
          ],
        ),
      ],
    );
  }

  // ── TAB 4: PAYROLL & TARGET ──
  Widget _buildPayrollAndTargetTab(EmployeeModel emp) {
    final hasBank = emp.accountNumber.isNotEmpty ||
        emp.bankName.isNotEmpty ||
        emp.ifscCode.isNotEmpty ||
        emp.accountHolderName.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildCardWrapper(
          title: 'Compensation & Goals',
          icon: Iconsax.wallet_money,
          iconColor: const Color(0xFF10B981),
          children: [
            _buildInfoTile(
              'Monthly Base Salary',
              _formatCurrency(emp.salary),
              icon: Iconsax.money_recive,
              isHighlight: true,
            ),
            _buildInfoTile('Salary Type', emp.salaryType.isNotEmpty ? emp.salaryType : 'Monthly', icon: Iconsax.calendar),
            _buildInfoTile(
              'Sales Target Status',
              emp.hasSalesTarget ? 'Enabled' : 'Disabled / Not Applicable',
              icon: Iconsax.chart_2,
              isLast: !emp.hasSalesTarget,
            ),
            if (emp.hasSalesTarget) ...[
              _buildInfoTile(
                'Target Metric (${emp.targetPeriod.isNotEmpty ? emp.targetPeriod : "Monthly"})',
                emp.targetType == 'Revenue' ? '₹${emp.targetAmount}' : '${emp.targetAmount} ${emp.targetType}',
                icon: Iconsax.radar,
              ),
              _buildInfoTile(
                'Incentive Commission',
                '${emp.incentivePercent}% on achievement',
                icon: Iconsax.percentage_circle,
                isLast: true,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        _buildCardWrapper(
          title: 'Bank & Payroll Account',
          icon: Iconsax.bank,
          iconColor: const Color(0xFF2563EB),
          children: hasBank
              ? [
                  _buildInfoTile('Account Holder Name', emp.accountHolderName.isNotEmpty ? emp.accountHolderName : emp.name, icon: Iconsax.user),
                  _buildInfoTile('Bank Name', emp.bankName.isNotEmpty ? emp.bankName : '—', icon: Iconsax.bank),
                  _buildInfoTile('Account Number', emp.accountNumber.isNotEmpty ? emp.accountNumber : '—', icon: Iconsax.card_pos),
                  _buildInfoTile('IFSC Code', emp.ifscCode.isNotEmpty ? emp.ifscCode : '—', icon: Iconsax.code),
                  _buildInfoTile('Branch Name', emp.branchName.isNotEmpty ? emp.branchName : '—', icon: Iconsax.buildings, isLast: true),
                ]
              : [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Iconsax.info_circle, size: 18, color: AppColors.textColorHint),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: AppText(
                            'No bank details linked to this employee profile yet.',
                            fontSize: 12,
                            color: AppColors.textColorSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
        ),
      ],
    );
  }

  // ── REUSABLE CARD WRAPPER ──
  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required Color iconColor,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  title,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textColorPrimary,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // ── REUSABLE INFO TILE ──
  Widget _buildInfoTile(
    String label,
    String value, {
    required IconData icon,
    bool isHighlight = false,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.slate100),
              ),
              child: Icon(icon, size: 15, color: AppColors.textColorSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    label,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorHint,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    value,
                    fontSize: isHighlight ? 14 : 13,
                    fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
                    color: isHighlight ? AppColors.primaryColor : AppColors.textColorPrimary,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primaryColor),
              ),
          ],
        ),
      ),
    );
  }

  void _openEmployeePerformance(
    BuildContext context,
    EmployeeModel emp,
    EmployeePerformance? matchedPerf,
  ) {
    final targetEmp = matchedPerf ??
        EmployeePerformance(
          id: emp.id,
          name: emp.name,
          designation: emp.designation.isNotEmpty ? emp.designation : 'Executive',
          department: emp.department.isNotEmpty ? emp.department : 'Engineering',
          performanceScore: 94,
          ratingLabel: 'Excellent',
          imageUrl: emp.profilePic != null && emp.profilePic!.isNotEmpty
              ? emp.profilePic!
              : 'https://i.pravatar.cc/150?u=${emp.name.replaceAll(' ', '')}',
          rank: 1,
        );

    Get.to(() => TeamMemberPerformanceScreen(emp: targetEmp));
  }

  void _openEmployeeAttendance(BuildContext context, EmployeeModel emp) {
    Get.to(() => AttendanceHistoryScreen(
      showBackButton: true,
      employeeName: emp.name,
      employeeId: emp.employeeId,
      employeeDesignation: emp.designation,
    ));
  }

  // ── CONFIRMATION DELETE DIALOG ──
  void _showDeleteConfirmationDialog(
    BuildContext context,
    EmployeeController controller,
    EmployeeModel emp,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFECACA), width: 2),
                ),
                child: const Icon(
                  Iconsax.trash,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const AppText(
                'Delete Employee?',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textColorPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: AppColors.textColorSecondary, height: 1.4),
                  children: [
                    const TextSpan(text: 'Are you sure you want to delete '),
                    TextSpan(
                      text: emp.name.isNotEmpty ? emp.name : 'this employee',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textColorPrimary),
                    ),
                    if (emp.employeeId.isNotEmpty)
                      TextSpan(
                        text: ' (${emp.employeeId})',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                      ),
                    const TextSpan(text: '? This action cannot be undone.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.slate300),
                      ),
                      child: const AppText(
                        'Cancel',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColorSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final isDeleting = controller.isDeleting.value;
                      return ElevatedButton(
                        onPressed: isDeleting
                            ? null
                            : () async {
                                final success = await controller.deleteEmployee(emp.id);
                                if (success) {
                                  Get.back();
                                  Get.back();
                                } else {
                                  Get.back();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          elevation: 0,
                          padding:  EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isDeleting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const AppText(
                                'Delete',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverTabBarDelegate({
    required this.child,
    this.height = 56,
  });

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: shrinkOffset > 0 ? AppColors.slate200 : Colors.transparent,
            width: 1,
          ),
        ),
        boxShadow: shrinkOffset > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
