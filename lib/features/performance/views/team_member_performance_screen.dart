import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../attendance/controllers/attendance_history_controller.dart';
import '../../attendance/views/attendance_history_screen.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../chat/models/chat_models.dart';
import '../../chat/views/chat_room_screen.dart';
import '../bindings/performance_binding.dart';
import '../controllers/employee_performance_detail_controller.dart';
import '../models/employee_performance_response_model.dart';
import '../models/performance_model.dart';
import '../models/performance_quality_api_response.dart';

class TeamMemberPerformanceScreen extends StatefulWidget {
  final EmployeePerformance? emp;
  final dynamic employeeId;

  const TeamMemberPerformanceScreen({
    super.key,
    this.emp,
    this.employeeId,
  });

  @override
  State<TeamMemberPerformanceScreen> createState() =>
      _TeamMemberPerformanceScreenState();
}

class _TeamMemberPerformanceScreenState
    extends State<TeamMemberPerformanceScreen> {
  late final EmployeePerformanceDetailController _controller;

  dynamic get _targetEmployeeId =>
      widget.employeeId ?? widget.emp?.id ?? '17';

  @override
  void initState() {
    super.initState();
    // Ensure dependencies are ready
    PerformanceBinding().dependencies();

    _controller = Get.isRegistered<EmployeePerformanceDetailController>()
        ? Get.find<EmployeePerformanceDetailController>()
        : Get.put(EmployeePerformanceDetailController());

    // Fetch employee performance detail for current month
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchEmployeeDetail(employeeId: _targetEmployeeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final empName = _controller.detail.value?.employee.name ??
              widget.emp?.name ??
              'Employee';
          return AppText(
            "$empName's Performance",
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textColorPrimary,
          );
        }),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Choose Date / Month',
            icon: const Icon(Iconsax.calendar_1,
                color: AppColors.primaryColor, size: 22),
            onPressed: () => _controller.openDatePickerCalendar(
              context,
              employeeId: _targetEmployeeId,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.detail.value == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          );
        }

        if (_controller.errorMessage.value.isNotEmpty &&
            _controller.detail.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_outline,
                        color: Colors.red, size: 44),
                  ),
                  const SizedBox(height: 16),
                  AppText(
                    _controller.errorMessage.value,
                    fontSize: 14,
                    color: AppColors.textColorSecondary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _controller.fetchEmployeeDetail(
                      employeeId: _targetEmployeeId,
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const AppText('Retry',
                        color: Colors.white, fontWeight: FontWeight.bold),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final detail = _controller.detail.value;

        // Extract employee basic info with fallback to widget.emp
        final empName = detail?.employee.name ?? widget.emp?.name ?? 'Employee';
        final empDesignation = detail?.employee.designation ??
            widget.emp?.designation ??
            'Team Member';
        final empDepartment = detail?.employee.department ??
            widget.emp?.department ??
            'General';
        final empAvatar = detail?.employee.resolvedAvatar.isNotEmpty == true
            ? detail!.employee.resolvedAvatar
            : (widget.emp?.imageUrl ?? '');
        final empCode = detail?.employee.employeeId.isNotEmpty == true
            ? detail!.employee.employeeId
            : (widget.emp?.employeeCode ?? '');
        final empTeam = detail?.employee.team ?? widget.emp?.team;

        final rawScore = detail?.score ?? widget.emp?.rawScore;
        final score = rawScore?.round() ?? widget.emp?.performanceScore ?? 0;
        final ratingLabel = detail?.evaluation ??
            widget.emp?.ratingLabel ??
            (score > 0 ? 'Rated' : 'Not Rated');
        final rank = detail?.rank ?? widget.emp?.rank ?? 1;

        final sourceCounts = detail?.sourceCounts;
        final metrics = detail?.metrics;

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () => _controller.fetchEmployeeDetail(
            employeeId: _targetEmployeeId,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Employee Info Card ──
                _buildEmployeeHeaderCard(
                  name: empName,
                  designation: empDesignation,
                  department: empDepartment,
                  avatarUrl: empAvatar,
                  employeeCode: empCode,
                  team: empTeam,
                ),
                const SizedBox(height: 16),

                // ── Date Filter & Calendar Selection Banner ──
                _buildDateFilterBanner(context),
                const SizedBox(height: 16),

                // ── Overall Performance Card ──
                _buildPerformanceCard(
                  context: context,
                  score: score,
                  rawScore: rawScore,
                  ratingLabel: ratingLabel,
                  rank: rank,
                ),
                const SizedBox(height: 20),

                // ── Source Counts Strip (Projects, Tasks, Reviews) ──
                if (sourceCounts != null) ...[
                  _buildSourceCountsStrip(sourceCounts),
                  const SizedBox(height: 20),
                ],

                // ── Detailed Metrics Section ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText(
                      'Performance Metrics',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textColorPrimary,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const AppText(
                        'Period Breakdown',
                        fontSize: 10,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Metric: Attendance
                _buildAttendanceMetricItem(context, empName),

                // Metric: Project Progress
                // _buildProjectProgressMetricItem(metrics?.projectProgress),

                // Metric: Task Completion
                _buildTaskCompletionMetricItem(context),

                // Metric: Timely Submissions
                _buildTimelySubmissionMetricItem(context),

                // Metric: Quality of Work
                _buildQualityMetricItem(context),

                // Metric: Leaves
                _buildLeaveMetricItem(context),

                const SizedBox(height: 24),

                // ── Action: Send Message / Warning Button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openChatWithEmployee(
                      employeeId: _targetEmployeeId.toString(),
                      name: empName,
                      avatar: empAvatar,
                      designation: empDesignation,
                    ),
                    icon: Icon(
                      score < 75 && rawScore != null
                          ? Icons.warning_amber_rounded
                          : Iconsax.message,
                      color: Colors.white,
                    ),
                    label: AppText(
                      score < 75 && rawScore != null
                          ? 'Send Warning / Note'
                          : 'Send Message',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: score < 75 && rawScore != null
                          ? Colors.red
                          : AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Employee Header Profile Card ──
  Widget _buildEmployeeHeaderCard({
    required String name,
    required String designation,
    required String department,
    required String avatarUrl,
    required String employeeCode,
    String? team,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          _buildEmployeeAvatarWidget(avatarUrl, radius: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        name,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColorPrimary,
                      ),
                    ),
                    if (employeeCode.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: AppText(
                          employeeCode,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                AppText(
                  '$designation • $department',
                  fontSize: 12,
                  color: AppColors.textColorSecondary,
                ),
                if (team != null && team.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Iconsax.people,
                          size: 12, color: AppColors.primaryColor),
                      const SizedBox(width: 4),
                      AppText(
                        team,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Date Filter & Interactive Calendar Banner ──
  Widget _buildDateFilterBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.calendar_tick,
                size: 16, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Selected Period',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorSecondary,
              ),
              AppText(
                _controller.selectedMonthDisplay.value,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryColor,
              ),
            ],
          ),
          const Spacer(),
          // Calendar Date Picker Button
          InkWell(
            onTap: () => _controller.openDatePickerCalendar(
              context,
              employeeId: _targetEmployeeId,
            ),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.calendar_search,
                      size: 13, color: AppColors.primaryColor),
                  SizedBox(width: 5),
                  AppText(
                    'Pick Date',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Overall Performance Card ──
  Widget _buildPerformanceCard({
    required BuildContext context,
    required int score,
    required num? rawScore,
    required String ratingLabel,
    required int rank,
  }) {
    final hasScore = rawScore != null;
    final isLowScore = hasScore && score < 75;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLowScore
              ? [const Color(0xFFEF4444), const Color(0xFFF87171)]
              : [AppColors.primaryGradientLight, AppColors.primaryGradientDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (isLowScore
                    ? const Color(0xFFEF4444)
                    : AppColors.primaryGradientLight)
                .withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Overall Performance',
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              // Quick Calendar icon button
              InkWell(
                onTap: () => _controller.openDatePickerCalendar(
                  context,
                  employeeId: _targetEmployeeId,
                ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.calendar_1,
                          size: 12, color: Colors.white),
                      const SizedBox(width: 5),
                      AppText(
                        _controller.selectedMonthApi.value,
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_drop_down,
                          size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: CustomPaint(
                  painter: _PerformanceRingPainter(
                    score: hasScore ? score.toDouble() : 0.0,
                    label: hasScore ? ratingLabel : 'Not Rated',
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildMiniGridItem('Rank', '#$rank'),
                        const SizedBox(width: 10),
                        _buildMiniGridItem(
                            'Score', hasScore ? '$score%' : '-'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMiniGridItem(
                          'Period',
                          _controller.selectedMonthApi.value,
                        ),
                        const SizedBox(width: 10),
                        _buildMiniGridItem('Evaluation', ratingLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniGridItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(label,
                fontSize: 8.5,
                color: Colors.white70,
                fontWeight: FontWeight.w600),
            const SizedBox(height: 2),
            AppText(
              value,
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Source Counts Strip ──
  Widget _buildSourceCountsStrip(PerformanceSourceCountsModel sourceCounts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSourceItem(
            label: 'Projects',
            count: sourceCounts.projects.toString(),
            icon: Iconsax.folder_2,
            color: AppColors.primaryColor,
          ),
          Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
          _buildSourceItem(
            label: 'Tasks',
            count: sourceCounts.tasks.toString(),
            icon: Iconsax.task,
            color: const Color(0xFF10B981),
          ),
          Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
          _buildSourceItem(
            label: 'Reviews',
            count: sourceCounts.qualityReviews.toString(),
            icon: Iconsax.star,
            color: const Color(0xFFF43F5E),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceItem({
    required String label,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(count,
                fontSize: 15, fontWeight: FontWeight.w900, color: color),
            AppText(label,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textColorSecondary),
          ],
        ),
      ],
    );
  }

  // ── Metric: Attendance ──
  Widget _buildAttendanceMetricItem(BuildContext context, String empName) {
    return Obx(() {
      final attSummary = _controller.attendanceSummary.value;
      final int presentDays = attSummary?.present ?? 0;
      final int workingDays = attSummary?.workingDays ?? 0;
      final double pct = attSummary?.attendancePercentage ?? 0.0;

      final label = attSummary != null
          ? '${pct.round()}% ($presentDays / $workingDays Days)'
          : 'View History ›';
      final progress = workingDays > 0
          ? (presentDays / workingDays).clamp(0.0, 1.0)
          : (pct > 0 ? (pct / 100.0).clamp(0.0, 1.0) : 0.0);

      return _buildMetricCard(
        title: 'Attendance',
        label: label,
        progress: attSummary != null ? progress : 1.0,
        icon: Iconsax.calendar,
        accentColor: AppColors.primaryColor,
        bgLightColor: AppColors.primaryLight,
        onTap: () {
          final attendanceCtrl = Get.put(AttendanceHistoryController());
          attendanceCtrl.employeeId.value = _targetEmployeeId;
          attendanceCtrl.employeeName.value = empName;
          attendanceCtrl.selectedMonth.value = _controller.selectedDate.value;
          attendanceCtrl.fetchAttendanceHistory(
            _controller.selectedDate.value,
            empId: _targetEmployeeId,
          );
          Get.to(() => AttendanceHistoryScreen(
                showBackButton: true,
                employeeName: empName,
                employeeId: _targetEmployeeId.toString(),
                employeeDesignation: widget.emp?.designation ?? 'Employee',
                initialMonth: _controller.selectedDate.value,
              ));
        },
      );
    });
  }

  // ── Metric: Project Progress ──
  Widget _buildProjectProgressMetricItem(ProjectProgressMetric? metric) {
    final avg = metric?.averagePercent;
    final total = metric?.totalProjects ?? 0;
    final label = avg != null ? '${avg.round()}% ($total Projects)' : '$total Projects';
    final progress = avg != null ? (avg / 100.0).clamp(0.0, 1.0) : 0.0;

    return _buildMetricCard(
      title: 'Project Progress',
      label: label,
      progress: progress,
      icon: Iconsax.folder_connection,
      accentColor: const Color(0xFF6366F1),
      bgLightColor: const Color(0xFFEEF2FF),
      onTap: null,
    );
  }

  // ── Metric: Task Completion ──
  Widget _buildTaskCompletionMetricItem(BuildContext context) {
    return Obx(() {
      final apiResponse = _controller.apiTaskCompletionResponse.value;
      final summary = apiResponse?.summary;
      final apiTasks = _controller.apiTaskCompletionList.toList();

      final completed = summary?.completed ?? apiTasks.where((t) => t.status.toLowerCase() == 'completed').length;
      final total = summary?.total ?? apiTasks.length;
      final num pctVal = summary?.completionPercent ?? (total > 0 ? (completed / total * 100) : 0);

      final label = '$completed / $total Tasks (${pctVal.round()}%)';
      final progress = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

      return _buildMetricCard(
        title: 'Task Completion',
        label: label,
        progress: progress,
        icon: Iconsax.task_square,
        accentColor: const Color(0xFF16A34A),
        bgLightColor: const Color(0xFFDCFCE7),
        onTap: () => _showTaskDetailsBottomSheet(context),
      );
    });
  }

  // ── Metric: Timely Submissions ──
  Widget _buildTimelySubmissionMetricItem(BuildContext context) {
    return Obx(() {
      final apiResponse = _controller.apiTimelySubmissionsResponse.value;
      final summary = apiResponse?.summary;
      final apiTasks = _controller.apiTimelySubmissionsList.toList();

      final onTime = summary?.onTime ?? apiTasks.where((t) => t.isOnTime == true).length;
      final total = summary?.total ?? apiTasks.length;
      final num? pctVal = summary?.timelinessPercent ?? (total > 0 ? (onTime / total * 100) : null);

      final label = pctVal != null
          ? '${pctVal.round()}% ($onTime / $total On Time)'
          : '$onTime / $total Tasks On Time';

      final progress = pctVal != null
          ? (pctVal / 100.0).clamp(0.0, 1.0)
          : (total > 0 ? (onTime / total).clamp(0.0, 1.0) : 0.0);

      return _buildMetricCard(
        title: 'Timely Submissions',
        label: label,
        progress: progress,
        icon: Iconsax.clock,
        accentColor: const Color(0xFFD97706),
        bgLightColor: const Color(0xFFFEF3C7),
        onTap: () => _showTimelySubmissionsBottomSheet(context),
      );
    });
  }

  // ── Metric: Quality of Work ──
  Widget _buildQualityMetricItem(BuildContext context) {
    return Obx(() {
      final apiResponse = _controller.apiQualityResponse.value;
      final summary = apiResponse?.summary;
      final reviews = _controller.apiQualityReviewsList.toList();

      String label;
      double progress = 0.0;

      final overall = summary?.overallPercent;
      final reviewCount = summary?.reviewCount ?? reviews.length;

      if (overall != null) {
        label = '${overall.round()}% ($reviewCount Review${reviewCount == 1 ? '' : 's'})';
        progress = (overall / 100.0).clamp(0.0, 1.0);
      } else if (reviewCount > 0) {
        label = '$reviewCount Review${reviewCount == 1 ? '' : 's'}';
        progress = 0.5;
      } else {
        label = '0 Reviews (N/A)';
        progress = 0.0;
      }

      return _buildMetricCard(
        title: 'Quality of Work',
        label: label,
        progress: progress,
        icon: Iconsax.star,
        accentColor: const Color(0xFFF43F5E),
        bgLightColor: const Color(0xFFFFF1F2),
        onTap: () => _showQualityDetailsBottomSheet(context),
      );
    });
  }

  // ── Metric: Leaves ──
  Widget _buildLeaveMetricItem(BuildContext context) {
    return Obx(() {
      final apiResponse = _controller.apiLeaveResponse.value;
      final summary = apiResponse?.summary;
      final leaves = _controller.apiLeaves.toList();

      String label;
      double progress = 1.0;

      if (summary != null) {
        final allowance = summary.annualAllowance;
        final taken = summary.annualTaken;
        final balance = summary.annualBalance;
        final approvedThisPeriod = summary.approvedDaysInPeriod;
        final pending = summary.pendingRequests;

        if (leaves.isNotEmpty) {
          label = '${leaves.length} Request${leaves.length > 1 ? 's' : ''} ($approvedThisPeriod Approved)';
          progress = pending > 0 ? 0.6 : 1.0;
        } else if (allowance > 0) {
          label = '$balance Days Balance ($taken Taken / $allowance Annual)';
          progress = 1.0;
        } else {
          label = '0 Days Taken ($balance Balance)';
          progress = 1.0;
        }
      } else if (leaves.isNotEmpty) {
        final pending = leaves.where((l) => l.status.toLowerCase() == 'pending').length;
        label = '${leaves.length} Request${leaves.length > 1 ? 's' : ''}, $pending Pending';
        progress = pending > 0 ? 0.6 : 1.0;
      } else {
        label = '0 Days Taken';
        progress = 1.0;
      }

      return _buildMetricCard(
        title: 'Leaves',
        label: label,
        progress: progress,
        icon: Iconsax.sun_1,
        accentColor: const Color(0xFF0284C7),
        bgLightColor: const Color(0xFFE0F2FE),
        onTap: () => _showLeaveDetailsBottomSheet(context),
      );
    });
  }

  // ── Reusable Metric Card ──
  Widget _buildMetricCard({
    required String title,
    required String label,
    required double progress,
    required IconData icon,
    required Color accentColor,
    required Color bgLightColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgLightColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(title,
                            fontSize: 13, fontWeight: FontWeight.w700),
                        AppText(
                          label,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppColors.slate300),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Task Details Bottom Sheet ──
  void _showTaskDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Obx(() {
          final apiResponse = _controller.apiTaskCompletionResponse.value;
          final summary = apiResponse?.summary;
          final apiTasks = _controller.apiTaskCompletionList.toList();

          final total = summary?.total ?? apiTasks.length;
          final completed = summary?.completed ?? apiTasks.where((t) => t.status.toLowerCase() == 'completed').length;
          final inProgress = summary?.inProgress ?? apiTasks.where((t) => t.status.toLowerCase() == 'in progress').length;
          final completionPct = summary?.completionPercent ?? (total > 0 ? (completed / total * 100) : 0);

          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.task_square,
                            color: Color(0xFF16A34A), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'Task Completion Details',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              'Recorded for ${_controller.selectedMonthDisplay.value}',
                              fontSize: 11,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textColorSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // ── 1. Summary Stats Strip ──
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF15803D), Color(0xFF16A34A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLeaveStatChip('Total Tasks', '$total', Icons.task_alt_rounded, Colors.white),
                            _buildLeaveStatDivider(),
                            _buildLeaveStatChip('Completed', '$completed', Icons.check_circle_outline_rounded, const Color(0xFF86EFAC)),
                            _buildLeaveStatDivider(),
                            _buildLeaveStatChip('In Progress', '$inProgress', Icons.autorenew_rounded, const Color(0xFFBAE6FD)),
                            _buildLeaveStatDivider(),
                            _buildLeaveStatChip('Completion %', '${completionPct.round()}%', Icons.pie_chart_outline_rounded, const Color(0xFFFDE047)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── 2. Section Header ──
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const AppText(
                              'Tasks List',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColorPrimary,
                            ),
                            if (apiTasks.isNotEmpty)
                              AppText(
                                '${apiTasks.length} Total',
                                fontSize: 11,
                                color: AppColors.textColorSecondary,
                              ),
                          ],
                        ),
                      ),

                      // ── 3. Task Cards or Empty State ──
                      if (apiTasks.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Iconsax.task,
                                  size: 30,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              AppText(
                                'No tasks recorded for ${_controller.selectedMonthDisplay.value}',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColorPrimary,
                              ),
                            ],
                          ),
                        )
                      else
                        ...apiTasks.map((item) {
                          final statusLower = item.status.toLowerCase();
                          final isCompleted = statusLower == 'completed';
                          final isSubmitted = statusLower == 'submitted for testing';
                          final isInProgress = statusLower == 'in progress';

                          final statusBg = isCompleted
                              ? const Color(0xFFDCFCE7)
                              : isSubmitted
                                  ? const Color(0xFFF3E8FF)
                                  : isInProgress
                                      ? const Color(0xFFE0F2FE)
                                      : const Color(0xFFFEF3C7);

                          final statusFg = isCompleted
                              ? const Color(0xFF15803D)
                              : isSubmitted
                                  ? const Color(0xFF7C3AED)
                                  : isInProgress
                                      ? const Color(0xFF0284C7)
                                      : const Color(0xFFD97706);

                          final priorityLower = item.priority.toLowerCase();
                          final priorityBg = priorityLower == 'urgent'
                              ? const Color(0xFFFFE4E6)
                              : priorityLower == 'high'
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFE0F2FE);
                          final priorityFg = priorityLower == 'urgent'
                              ? const Color(0xFFE11D48)
                              : priorityLower == 'high'
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF0284C7);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Project Tag + Priority + Status
                                Row(
                                  children: [
                                    if (item.project != null && item.project!.name.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: AppText(
                                          item.project!.name,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: priorityBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: AppText(
                                        item.priority,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: priorityFg,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: AppText(
                                        item.status,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: statusFg,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Title & Description
                                AppText(
                                  item.name,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                ),
                                if (item.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  AppText(
                                    item.description,
                                    fontSize: 11.5,
                                    color: AppColors.textColorSecondary,
                                  ),
                                ],

                                // Dates & Assignee Row
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: [
                                    if (item.dueDate.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Iconsax.calendar_1, size: 12, color: Color(0xFF0284C7)),
                                          const SizedBox(width: 4),
                                          AppText(
                                            'Due: ${item.dueDate}',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF0284C7),
                                          ),
                                        ],
                                      ),
                                    if (item.assignedBy != null && item.assignedBy!.name.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Iconsax.user_tag, size: 12, color: AppColors.slate400),
                                          const SizedBox(width: 4),
                                          AppText(
                                            'By ${item.assignedBy!.name}',
                                            fontSize: 11,
                                            color: AppColors.textColorSecondary,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),

                                // Subtasks Section
                                if (item.subtasks != null && item.subtasks!.items.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            AppText(
                                              'Subtasks (${item.subtasks!.completed}/${item.subtasks!.total})',
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textColorPrimary,
                                            ),
                                            AppText(
                                              '${item.subtasks!.total > 0 ? (item.subtasks!.completed / item.subtasks!.total * 100).round() : 0}%',
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF16A34A),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(3),
                                          child: LinearProgressIndicator(
                                            value: item.subtasks!.total > 0
                                                ? (item.subtasks!.completed / item.subtasks!.total)
                                                : 0,
                                            backgroundColor: const Color(0xFFE2E8F0),
                                            color: const Color(0xFF16A34A),
                                            minHeight: 5,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ...item.subtasks!.items.map((sub) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  sub.isCompleted
                                                      ? Icons.check_circle_rounded
                                                      : Icons.radio_button_unchecked_rounded,
                                                  size: 14,
                                                  color: sub.isCompleted
                                                      ? const Color(0xFF16A34A)
                                                      : AppColors.slate400,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: AppText(
                                                    sub.title,
                                                    fontSize: 11.5,
                                                    color: sub.isCompleted
                                                        ? AppColors.textColorSecondary
                                                        : AppColors.textColorPrimary,
                                                    decoration: sub.isCompleted
                                                        ? TextDecoration.lineThrough
                                                        : TextDecoration.none,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ── Timely Submissions Bottom Sheet ──
  void _showTimelySubmissionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Obx(() {
          final apiResponse = _controller.apiTimelySubmissionsResponse.value;
          final summary = apiResponse?.summary;
          final apiTasks = _controller.apiTimelySubmissionsList.toList();

          final total = summary?.total ?? apiTasks.length;
          final completed = summary?.completed ?? apiTasks.where((t) => t.status.toLowerCase() == 'completed').length;
          final onTime = summary?.onTime ?? apiTasks.where((t) => t.isOnTime == true).length;
          final num? timelinessPct = summary?.timelinessPercent ?? (total > 0 ? (onTime / total * 100) : null);

          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.clock,
                            color: Color(0xFFD97706), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'Timely Submission Details',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              'Recorded for ${_controller.selectedMonthDisplay.value}',
                              fontSize: 11,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textColorSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // ── 1. Summary Stats Strip ──
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB45309), Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLeaveStatChip('Total Tasks', '$total', Icons.task_alt_rounded, Colors.white),
                            _buildLeaveStatDivider(),
                            _buildLeaveStatChip('Completed', '$completed', Icons.check_circle_outline_rounded, const Color(0xFF86EFAC)),
                            _buildLeaveStatDivider(),
                            _buildLeaveStatChip('On-Time', '$onTime', Icons.timer_outlined, const Color(0xFFFDE047)),
                            _buildLeaveStatDivider(),
                            _buildLeaveStatChip('Timeliness %', timelinessPct != null ? '${timelinessPct.round()}%' : 'N/A', Icons.speed_rounded, const Color(0xFFBAE6FD)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── 2. Section Header ──
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const AppText(
                              'Submission Timelines',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColorPrimary,
                            ),
                            if (apiTasks.isNotEmpty)
                              AppText(
                                '${apiTasks.length} Total',
                                fontSize: 11,
                                color: AppColors.textColorSecondary,
                              ),
                          ],
                        ),
                      ),

                      // ── 3. Task Cards or Empty State ──
                      if (apiTasks.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFEF3C7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Iconsax.clock,
                                  size: 30,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                              const SizedBox(height: 12),
                              AppText(
                                'No submission records for ${_controller.selectedMonthDisplay.value}',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColorPrimary,
                              ),
                            ],
                          ),
                        )
                      else
                        ...apiTasks.map((item) {
                          final statusLower = item.status.toLowerCase();
                          final isCompleted = statusLower == 'completed';
                          final isSubmitted = statusLower == 'submitted for testing';

                          final statusBg = isCompleted
                              ? const Color(0xFFDCFCE7)
                              : isSubmitted
                                  ? const Color(0xFFF3E8FF)
                                  : const Color(0xFFFEF3C7);
                          final statusFg = isCompleted
                              ? const Color(0xFF15803D)
                              : isSubmitted
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFFD97706);

                          final isOnTime = item.isOnTime == true;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Project + Timeliness Tag + Status
                                Row(
                                  children: [
                                    if (item.project != null && item.project!.name.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: AppText(
                                          item.project!.name,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                    const Spacer(),
                                    if (item.isOnTime != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isOnTime ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E6),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isOnTime ? Icons.check_circle_rounded : Icons.warning_rounded,
                                              size: 11,
                                              color: isOnTime ? const Color(0xFF15803D) : const Color(0xFFE11D48),
                                            ),
                                            const SizedBox(width: 3),
                                            AppText(
                                              isOnTime ? 'On-Time' : 'Overdue',
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: isOnTime ? const Color(0xFF15803D) : const Color(0xFFE11D48),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: AppText(
                                        item.status,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: statusFg,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Title & Description
                                AppText(
                                  item.name,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                ),
                                if (item.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  AppText(
                                    item.description,
                                    fontSize: 11.5,
                                    color: AppColors.textColorSecondary,
                                  ),
                                ],

                                const SizedBox(height: 12),
                                // Timelines Grid
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const AppText('Assigned Date', fontSize: 10, color: AppColors.textColorSecondary),
                                              const SizedBox(height: 2),
                                              AppText(
                                                item.startDate.isNotEmpty ? item.startDate : (item.assignedOn.split('T').first),
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF1E293B),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const AppText('Due Date', fontSize: 10, color: AppColors.textColorSecondary),
                                              const SizedBox(height: 2),
                                              AppText(
                                                item.dueDate.isNotEmpty ? item.dueDate : 'No deadline',
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFFD97706),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (item.completedAt != null && item.completedAt!.isNotEmpty) ...[
                                        const Divider(height: 14, color: Color(0xFFE2E8F0)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const AppText('Completed On', fontSize: 10, color: AppColors.textColorSecondary),
                                            AppText(
                                              item.completedAt!.split('T').first,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF15803D),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (item.daysFromDeadline != null) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const AppText('Deadline Variance', fontSize: 10, color: AppColors.textColorSecondary),
                                            AppText(
                                              item.daysFromDeadline! >= 0
                                                  ? '${item.daysFromDeadline} days early'
                                                  : '${item.daysFromDeadline!.abs()} days late',
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: item.daysFromDeadline! >= 0
                                                  ? const Color(0xFF15803D)
                                                  : const Color(0xFFE11D48),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ── Leave Details Bottom Sheet ──
  void _showLeaveDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Obx(() {
          final apiResponse = _controller.apiLeaveResponse.value;
          final summary = apiResponse?.summary;
          final balances = apiResponse?.balances ?? [];
          final leaves = _controller.apiLeaves.toList();

          final pendingCount = summary?.pendingRequests ?? leaves.where((l) => l.status.toLowerCase() == 'pending').length;
          final approvedCount = summary?.approvedDaysInPeriod ?? leaves.where((l) => l.status.toLowerCase() == 'approved').length;
          final annualBalance = summary?.annualBalance ?? 12;
          final annualTaken = summary?.annualTaken ?? 0;

          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // ── Drag Handle ──
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // ── Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.sun_1, color: Color(0xFF0284C7), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText('Leave Details & Balance',
                                fontSize: 16, fontWeight: FontWeight.w800),
                            const SizedBox(height: 2),
                            AppText(
                              'Recorded for ${_controller.selectedMonthDisplay.value}',
                              fontSize: 11,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textColorSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // ── 1. Summary Stats Strip ──
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0369A1), Color(0xFF0284C7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLeaveStatChip('Annual Balance', '$annualBalance Days', Icons.account_balance_wallet_rounded, Colors.white),
                            _buildLeaveStatDivider(),
                            _buildLeaveStatChip('Taken (Year)', '$annualTaken Days', Icons.history_rounded, const Color(0xFFBAE6FD)),
                            _buildLeaveStatDivider(),
                            _buildLeaveStatChip('Approved (Period)', '$approvedCount Days', Icons.check_circle_outline_rounded, const Color(0xFF34D399)),
                            _buildLeaveStatDivider(),
                            _buildLeaveStatChip('Pending', '$pendingCount', Icons.hourglass_top_rounded, const Color(0xFFFBBF24)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── 2. Leave Balances Section ──
                      if (balances.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10, left: 2),
                          child: AppText(
                            'Leave Entitlements & Balances',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textColorPrimary,
                          ),
                        ),
                        ...balances.map((bal) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: AppText(
                                    bal.code.isNotEmpty ? bal.code : 'CL',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0284C7),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppText(
                                        bal.name,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      const SizedBox(height: 2),
                                      AppText(
                                        'Allowance: ${bal.annualAllowance} Days  |  Taken: ${bal.taken} Days',
                                        fontSize: 11,
                                        color: AppColors.textColorSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: AppText(
                                    '${bal.balance} Days Left',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      // ── 3. Leave Requests Section Header ──
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const AppText(
                              'Leave Requests (Period)',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColorPrimary,
                            ),
                            if (leaves.isNotEmpty)
                              AppText(
                                '${leaves.length} Total',
                                fontSize: 11,
                                color: AppColors.textColorSecondary,
                              ),
                          ],
                        ),
                      ),

                      // ── 4. Leave Request Cards or Empty State ──
                      if (leaves.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Iconsax.calendar_tick,
                                  size: 30,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                              const SizedBox(height: 12),
                              AppText(
                                'No Leave Requests for ${_controller.selectedMonthDisplay.value}',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textColorPrimary,
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                'Employee has full remaining balance of $annualBalance days.',
                                fontSize: 11.5,
                                color: AppColors.textColorSecondary,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ...leaves.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item  = entry.value;
                          final statusLower = item.status.toLowerCase();
                          final isPending  = statusLower == 'pending';
                          final isApproved = statusLower == 'approved';

                          final statusBg = isPending
                              ? const Color(0xFFFEF3C7)
                              : isApproved
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFFE4E6);
                          final statusFg = isPending
                              ? const Color(0xFFD97706)
                              : isApproved
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFE11D48);
                          final statusIcon = isPending
                              ? Icons.hourglass_top_rounded
                              : isApproved
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.cancel_outlined;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card header with leave type + status
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    border: Border(
                                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2FE),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: AppText(
                                          '#${index + 1} ${item.type}',
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0284C7),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(statusIcon, size: 10, color: statusFg),
                                            const SizedBox(width: 4),
                                            AppText(
                                              item.status,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: statusFg,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Card body
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (item.dates.isNotEmpty)
                                        _buildLeaveInfoRow(
                                          icon: Iconsax.calendar_2,
                                          label: 'Duration',
                                          value: item.dates,
                                          color: const Color(0xFF0284C7),
                                        ),
                                      if (item.reason.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        _buildLeaveInfoRow(
                                          icon: Iconsax.message_text,
                                          label: 'Reason',
                                          value: item.reason,
                                          color: const Color(0xFF7C3AED),
                                        ),
                                      ],
                                      if (item.appliedDate.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        _buildLeaveInfoRow(
                                          icon: Iconsax.clock,
                                          label: 'Applied On',
                                          value: _formatDate(item.appliedDate),
                                          color: const Color(0xFF0284C7),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildLeaveStatChip(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        AppText(value,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white),
        AppText(label,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Colors.white70),
      ],
    );
  }

  Widget _buildLeaveStatDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildLeaveInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(label,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColorSecondary),
              const SizedBox(height: 1),
              AppText(value,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColorPrimary),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  // ── Quality Assessment Bottom Sheet ──
  void _showQualityDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Obx(() {
          final apiResponse = _controller.apiQualityResponse.value;
          final summary = apiResponse?.summary;
          final criteria = summary?.criteria;
          final reviews = _controller.apiQualityReviewsList.toList();

          final overall = summary?.overallPercent;
          final reviewCount = summary?.reviewCount ?? reviews.length;

          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.star,
                            color: Color(0xFFF43F5E), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'Quality Assessment Details',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              'Recorded for ${_controller.selectedMonthDisplay.value}',
                              fontSize: 11,
                              color: AppColors.textColorSecondary,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textColorSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // ── 1. Summary Header Card ──
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF43F5E).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLeaveStatChip(
                              'Overall Score',
                              overall != null ? '${overall.round()}%' : 'N/A',
                              Iconsax.star,
                              const Color(0xFFFDE047),
                            ),
                            _buildLeaveStatDivider(),
                            _buildLeaveStatChip(
                              'Total Reviews',
                              '$reviewCount',
                              Iconsax.messages_2,
                              Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── 2. Quality Criteria Breakdown ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'Quality Criteria Breakdown',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(height: 14),
                            _buildQualityCriteriaRow(
                              'Deliverable Accuracy',
                              criteria?.deliverableAccuracy,
                              const Color(0xFF10B981),
                            ),
                            _buildQualityCriteriaRow(
                              'Deadline Adherence',
                              criteria?.deadlineAdherence,
                              const Color(0xFF3B82F6),
                            ),
                            _buildQualityCriteriaRow(
                              'Defect Prevention',
                              criteria?.defectPrevention,
                              const Color(0xFF8B5CF6),
                            ),
                            _buildQualityCriteriaRow(
                              'Team Collaboration',
                              criteria?.collaboration,
                              const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── 3. Reviews & Feedback List ──
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const AppText(
                              'Stakeholder Reviews',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColorPrimary,
                            ),
                            if (reviews.isNotEmpty)
                              AppText(
                                '${reviews.length} Review${reviews.length > 1 ? 's' : ''}',
                                fontSize: 11,
                                color: AppColors.textColorSecondary,
                              ),
                          ],
                        ),
                      ),

                      if (reviews.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Iconsax.note_remove,
                                size: 40,
                                color: AppColors.textColorHint,
                              ),
                              const SizedBox(height: 10),
                              AppText(
                                'No quality reviews recorded for ${_controller.selectedMonthDisplay.value}',
                                color: AppColors.textColorSecondary,
                                fontSize: 12.5,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ...reviews.map((rev) => _buildQualityReviewCard(rev)),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildQualityCriteriaRow(String title, num? value, Color accentColor) {
    final displayVal = value != null ? '${value.round()}%' : 'N/A';
    final progress = value != null ? (value / 100.0).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title,
                fontSize: 11.5,
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
              AppText(
                displayVal,
                fontSize: 11.5,
                color: value != null ? accentColor : AppColors.textColorHint,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                value != null ? accentColor : const Color(0xFFCBD5E1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityReviewCard(PerformanceQualityReviewItemApiData rev) {
    final reviewer = rev.author.isNotEmpty ? rev.author : 'Anonymous Reviewer';
    final ratingPct = rev.overallRating;
    final comments = rev.comment;
    final dateStr = rev.date.isNotEmpty ? _formatDate(rev.date) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText(
                  reviewer,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
              ),
              if (ratingPct != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.star1, size: 12, color: Color(0xFFF43F5E)),
                      const SizedBox(width: 4),
                      AppText(
                        '${ratingPct.round()}%',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE11D48),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (comments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"$comments"',
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF475569),
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ],
          if (dateStr != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: AppText(
                dateStr,
                fontSize: 10,
                color: AppColors.textColorHint,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openChatWithEmployee({
    required String employeeId,
    required String name,
    required String avatar,
    required String designation,
  }) {
    final chatCtrl = Get.put(ChatController());
    final existingIdx =
        chatCtrl.conversations.indexWhere((c) => c.id == employeeId);
    if (existingIdx == -1) {
      chatCtrl.conversations.insert(
          0,
          ChatConversation(
            id: employeeId,
            name: name,
            avatarUrl: avatar,
            designation: designation,
            lastMessage: '',
            lastMessageTime: DateTime.now(),
          ));
    }
    chatCtrl.selectConversation(employeeId);
    chatCtrl.loadPerformanceMessages(employeeId);
    Get.to(() => const ChatRoomScreen());
  }
}

class _PerformanceRingPainter extends CustomPainter {
  final double score;
  final String label;

  _PerformanceRingPainter({required this.score, required this.label});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 8.0;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFFFEF08A), Color(0xFF10B981), Color(0xFFFEF08A)],
        startAngle: 0,
        endAngle: pi * 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final sweepAngle = (score / 100.0) * pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final scoreSpan = TextSpan(
      style: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 18,
        height: 1.1,
      ),
      text: '${score.round()}%\n',
      children: [
        TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 7.5,
          ),
        ),
      ],
    );

    textPainter.text = scoreSpan;
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Widget _buildEmployeeAvatarWidget(String imageUrl, {double radius = 18}) {
  final cleanUrl = imageUrl.trim();
  final hasValidUrl = cleanUrl.isNotEmpty &&
      (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) &&
      !cleanUrl.contains('127.0.0.1') &&
      !cleanUrl.contains('localhost');

  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Container(
      width: radius * 2,
      height: radius * 2,
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: hasValidUrl
          ? Image.network(
              cleanUrl,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Iconsax.user,
                  size: radius * 1.1,
                  color: AppColors.primaryColor,
                );
              },
            )
          : Icon(
              Iconsax.user,
              size: radius * 1.1,
              color: AppColors.primaryColor,
            ),
    ),
  );
}
