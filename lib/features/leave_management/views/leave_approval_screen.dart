import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../bindings/admin_leave_binding.dart';
import '../controllers/admin_leave_controller.dart';
import '../models/admin_leave_model.dart';

class LeaveApprovalScreen extends StatefulWidget {
  final int? leaveId;
  final Map<String, dynamic>? requestData;

  const LeaveApprovalScreen({
    super.key,
    this.leaveId,
    this.requestData,
  });

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  late final AdminLeaveController controller;

  int? get resolvedLeaveId {
    if (widget.leaveId != null) return widget.leaveId;
    if (widget.requestData != null && widget.requestData!['id'] != null) {
      return int.tryParse(widget.requestData!['id'].toString());
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AdminLeaveController>()) {
      AdminLeaveBinding().dependencies();
    }
    controller = Get.find<AdminLeaveController>();

    final id = resolvedLeaveId;
    if (id != null) {
      // Clear previous detail before fetching new
      controller.leaveDetail.value = null;
      controller.fetchLeaveDetails(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary),
          onPressed: () => Get.back(),
        ),
        title: const AppText('Leave Details', fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textColorPrimary),
            onPressed: () {
              final id = resolvedLeaveId;
              if (id != null) controller.fetchLeaveDetails(id);
            },
          ),
        ],
      ),
      body: Obx(() {
        final isLoading = controller.isDetailLoading.value;
        final detail = controller.leaveDetail.value;
        final error = controller.detailError.value;
        final fallback = widget.requestData;

        // 1. Loading state with no fallback
        if (isLoading && detail == null && fallback == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryColor),
                SizedBox(height: 12),
                AppText('Loading leave details...', fontSize: 13, color: AppColors.textColorSecondary),
              ],
            ),
          );
        }

        // 2. Error state with no fallback
        if (error.isNotEmpty && detail == null && fallback == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  AppText(error, fontSize: 14, color: AppColors.textColorSecondary, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      final id = resolvedLeaveId;
                      if (id != null) controller.fetchLeaveDetails(id);
                    },
                    icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                    label: const AppText('Retry', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            if (isLoading)
              const LinearProgressIndicator(minHeight: 2, color: AppColors.primaryColor, backgroundColor: Colors.transparent),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    _buildProfileHeader(detail, fallback),

                    const SizedBox(height: 20),

                    // Leave Details Card
                    const AppText('Leave Details', fontSize: 14, fontWeight: FontWeight.bold),
                    const SizedBox(height: 10),
                    _buildLeaveDetailsCard(detail, fallback),

                    const SizedBox(height: 20),

                    // Leave Balance Card
                    const AppText('Leave Balance', fontSize: 14, fontWeight: FontWeight.bold),
                    const SizedBox(height: 10),
                    _buildLeaveBalanceCard(detail),

                    // Attachment (if present)
                    if (detail?.attachmentName != null || detail?.attachmentPath != null || fallback?['documentUrl'] != null) ...[
                      const SizedBox(height: 20),
                      const AppText('Attachment', fontSize: 14, fontWeight: FontWeight.bold),
                      const SizedBox(height: 10),
                      _buildAttachmentCard(detail, fallback),
                    ],

                    // Approval Timeline / Actions
                    const SizedBox(height: 20),
                    const AppText('Approval Timeline', fontSize: 14, fontWeight: FontWeight.bold),
                    const SizedBox(height: 10),
                    _buildApprovalTimeline(detail, fallback),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            _buildBottomActionBar(detail, fallback),
          ],
        );
      }),
    );
  }

  // ── Profile Header ─────────────────────────────────────────────
  Widget _buildProfileHeader(AdminLeaveDetailDataModel? detail, Map<String, dynamic>? fallback) {
    final name = detail?.employee.name ?? fallback?['name'] ?? 'Employee';
    final designation = detail?.employee.designation ?? fallback?['designation'] ?? 'Designation';
    final empId = detail?.employee.employeeId ?? fallback?['employee_id'] ?? 'EMP';
    final department = detail?.employee.department ?? fallback?['department'] ?? 'Department';
    final leaveCode = detail?.leaveType.code ?? (detail?.leaveType.name.isNotEmpty == true ? detail!.leaveType.name[0] : (fallback?['type'] ?? 'CL'));

    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'E';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(name, fontSize: 16, fontWeight: FontWeight.bold),
                const SizedBox(height: 2),
                AppText(designation, fontSize: 12, color: AppColors.textColorSecondary),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: AppText(
                        empId.isNotEmpty ? empId : 'EMP',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: AppText(
                        department.isNotEmpty ? '$department Dept' : 'General Dept',
                        fontSize: 12,
                        color: AppColors.textColorSecondary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              leaveCode,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // ── Leave Details Card ─────────────────────────────────────────
  Widget _buildLeaveDetailsCard(AdminLeaveDetailDataModel? detail, Map<String, dynamic>? fallback) {
    final leaveType = detail?.leaveType.name ?? fallback?['type'] ?? 'Casual Leave';
    final fromDate = detail?.formattedFromDate ?? fallback?['startDate']?.toString() ?? 'N/A';
    final toDate = detail?.formattedToDate ?? fallback?['endDate']?.toString() ?? fromDate;
    final duration = detail?.durationString ?? fallback?['duration'] ?? '1 Day';
    final status = detail?.status ?? fallback?['status'] ?? 'Pending';
    final reason = detail?.reason.isNotEmpty == true
        ? detail!.reason
        : (fallback?['reason']?.toString().isNotEmpty == true ? fallback!['reason'] : 'Personal work');
    final contact = detail?.contactDuringLeave ?? fallback?['phone'] ?? '';
    final appliedOn = detail?.formattedAppliedOn ?? fallback?['appliedOn'] ?? 'Recently';
    final reviewNote = detail?.reviewNote ?? fallback?['rejectionReason'];

    Color statusColor = Colors.orange;
    if (status == 'Approved') {
      statusColor = Colors.green;
    } else if (status == 'Rejected') {
      statusColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          _buildDetailRow('Leave Type', leaveType),
          _buildDivider(),
          _buildDetailRow('From Date', fromDate),
          _buildDivider(),
          _buildDetailRow('To Date', toDate),
          _buildDivider(),
          _buildDetailRow('Total Days', duration, isBoldValue: true),
          _buildDivider(),
          _buildDetailRow('Session', detail?.session ?? fallback?['session'] ?? 'Full Day'),
          _buildDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Status', fontSize: 12, color: AppColors.textColorSecondary),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(status, fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ],
            ),
          ),
          _buildDivider(),
          _buildDetailRow('Reason', reason),
          if (contact.isNotEmpty) ...[
            _buildDivider(),
            _buildDetailRow('Contact During Leave', contact),
          ],
          if (detail?.addressDuringLeave != null && detail!.addressDuringLeave!.isNotEmpty) ...[
            _buildDivider(),
            _buildDetailRow('Address During Leave', detail.addressDuringLeave!),
          ],
          if (detail?.assigneeName != null && detail!.assigneeName!.isNotEmpty) ...[
            _buildDivider(),
            _buildDetailRow(
              'Handover / Assigned To',
              '${detail.assigneeName!}${detail.assigneeDesignation != null && detail.assigneeDesignation!.isNotEmpty ? ' (${detail.assigneeDesignation!})' : ''}',
            ),
          ],
          _buildDivider(),
          _buildDetailRow('Applied On', appliedOn),
          if (reviewNote != null && reviewNote.isNotEmpty) ...[
            _buildDivider(),
            _buildDetailRow('Review Note', reviewNote, valueColor: statusColor),
          ],
        ],
      ),
    );
  }

  // ── Leave Balance Card ─────────────────────────────────────────
  Widget _buildLeaveBalanceCard(AdminLeaveDetailDataModel? detail) {
    final balance = detail?.leaveBalance;
    final total = balance != null ? '${balance.total} Days' : '12 Days';
    final taken = balance != null ? '${balance.taken} Days' : '3 Days';
    final pending = balance != null ? '${balance.pending} Days' : '0 Days';
    final remaining = balance != null ? '${balance.remaining} Days' : '9 Days';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBalanceItem('Total', total, AppColors.textColorPrimary),
          _buildVerticalDivider(),
          _buildBalanceItem('Taken', taken, AppColors.textColorPrimary),
          _buildVerticalDivider(),
          _buildBalanceItem('Pending', pending, Colors.orange),
          _buildVerticalDivider(),
          _buildBalanceItem('Remaining', remaining, Colors.green),
        ],
      ),
    );
  }

  // ── Attachment Card ────────────────────────────────────────────
  Widget _buildAttachmentCard(AdminLeaveDetailDataModel? detail, Map<String, dynamic>? fallback) {
    final name = detail?.attachmentName ??
        (detail?.attachmentPath?.split('/').last) ??
        'Attached_Document.pdf';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.document, color: AppColors.primaryColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(name, fontSize: 13, fontWeight: FontWeight.w600, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                const AppText('Document Attachment', fontSize: 11, color: AppColors.textColorSecondary),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.document_download, color: AppColors.primaryColor),
            onPressed: () {
              Get.snackbar(
                'Attachment',
                'Attachment: $name',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Approval Timeline / Actions ────────────────────────────────
  Widget _buildApprovalTimeline(AdminLeaveDetailDataModel? detail, Map<String, dynamic>? fallback) {
    final actions = detail?.actions ?? [];

    if (actions.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: actions.asMap().entries.map((entry) {
            final idx = entry.key;
            final action = entry.value;
            final isLast = idx == actions.length - 1;
            final actorName = action.actor?.name ?? 'Administrator';
            final actionName = action.action;
            final note = action.note ?? '';

            Color actionColor = AppColors.primaryColor;
            if (actionName.toLowerCase() == 'approved') {
              actionColor = Colors.green;
            } else if (actionName.toLowerCase() == 'rejected') {
              actionColor = Colors.red;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: actionColor.withValues(alpha: 0.15),
                      child: Icon(
                        actionName.toLowerCase() == 'approved'
                            ? Icons.check
                            : (actionName.toLowerCase() == 'rejected' ? Icons.close : Icons.arrow_upward),
                        color: actionColor,
                        size: 14,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: AppColors.slate200,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(actorName, fontSize: 13, fontWeight: FontWeight.w600),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: actionColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: AppText(actionName, fontSize: 10, fontWeight: FontWeight.bold, color: actionColor),
                          ),
                        ],
                      ),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        AppText(note, fontSize: 11, color: AppColors.textColorSecondary),
                      ],
                      const SizedBox(height: 2),
                      AppText(action.formattedCreatedAt, fontSize: 10, color: AppColors.textColorHint),
                      if (!isLast) const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );
    }

    // Default Timeline from fallback
    final empName = detail?.employee.name ?? fallback?['name'] ?? 'Employee';
    final appliedOn = detail?.formattedAppliedOn ?? fallback?['appliedOn'] ?? 'Recently';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            child: const Icon(Iconsax.send_2, color: AppColors.primaryColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(empName, fontSize: 13, fontWeight: FontWeight.w600),
                const SizedBox(height: 2),
                const AppText('Leave Request Submitted', fontSize: 11, color: AppColors.textColorSecondary),
                const SizedBox(height: 2),
                AppText(appliedOn, fontSize: 10, color: AppColors.textColorHint),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Action Bar ──────────────────────────────────────────
  Widget _buildBottomActionBar(AdminLeaveDetailDataModel? detail, Map<String, dynamic>? fallback) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const AppText('Back', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBoldValue = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AppText(label, fontSize: 12, color: AppColors.textColorSecondary),
          ),
          Expanded(
            flex: 3,
            child: AppText(
              value,
              fontSize: 12,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? AppColors.textColorPrimary,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Divider(color: AppColors.borderColor, height: 1),
    );
  }

  Widget _buildBalanceItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        AppText(label, fontSize: 11, color: AppColors.textColorSecondary),
        const SizedBox(height: 4),
        AppText(
          value,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: valueColor,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.slate200,
    );
  }
}
