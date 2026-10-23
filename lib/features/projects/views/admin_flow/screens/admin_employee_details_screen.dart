import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../models/admin_flow_models.dart';
import '../widgets/admin_flow_widgets.dart';
import 'admin_task_details_screen.dart';
import 'admin_handover_task_screen.dart';
import 'admin_handover_history_screen.dart';

class AdminEmployeeDetailsScreen extends StatelessWidget {
  final AdminFlowMember member;

  const AdminEmployeeDetailsScreen({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminFlowTheme.surfaceSlate,
      appBar: const AdminFlowAppBar(
        title: 'Employee Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile Card ──
            AdminFlowCard(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        member.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AdminFlowTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AdminFlowTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${member.role} • ${member.department}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AdminFlowTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AdminFlowStatusBadge(status: member.status),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            member.employeeId,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Handover Audit Card (User Req: ek employee kitni bar handover kiya hai vo bhi sab pura) ──
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Iconsax.refresh_2, size: 18, color: AdminFlowTheme.primaryBlue),
                          SizedBox(width: 8),
                          Text(
                            'Handover Audit Summary',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const AdminHandoverHistoryScreen());
                        },
                        child: const Text(
                          'View Audit Log',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AdminFlowTheme.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Iconsax.export_3, size: 14, color: Color(0xFF3B206A)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Handovers Given',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3B206A)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${member.handoversGivenCount} times',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF261042)),
                              ),
                              const SizedBox(height: 2),
                              const Text('Transferred to peers', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Iconsax.import_1, size: 14, color: Color(0xFF16A34A)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Received',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${member.handoversReceivedCount} times',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF14532D)),
                              ),
                              const SizedBox(height: 2),
                              const Text('Accepted from peers', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Residential & Contact Address Card (User Req: ek ek employee ka pura address) ──
            AdminFlowCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Iconsax.location, color: AdminFlowTheme.primaryBlue, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Residential & Contact Address',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AdminFlowTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AdminFlowTheme.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.fullAddress,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AdminFlowTheme.textDark,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_city_rounded, size: 14, color: AdminFlowTheme.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              '${member.city}, ${member.state}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AdminFlowTheme.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.pin_drop_rounded, size: 14, color: AdminFlowTheme.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              'PIN: ${member.pincode} • ${member.country}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AdminFlowTheme.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow(icon: Iconsax.sms, label: 'Email', value: member.email),
                  const Divider(height: 16, color: AdminFlowTheme.cardBorder),
                  _buildInfoRow(icon: Iconsax.call, label: 'Mobile', value: member.mobile),
                  const Divider(height: 16, color: AdminFlowTheme.cardBorder),
                  _buildInfoRow(icon: Iconsax.calendar_1, label: 'Joined On', value: member.joinedOn),
                  const Divider(height: 16, color: AdminFlowTheme.cardBorder),
                  _buildInfoRow(icon: Iconsax.folder, label: 'Assigned Modules', value: '${member.assignedModulesCount}'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section: Assigned Modules & All Tasks Breakdown ──
            // (User Req: ek ek employee ka pura module and module me task sbhi dikhenge and proper time ke sath kitna time mila tha kitna bcha huahai agar time extra lga hai to red me dikhna chahia)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Assigned Modules & Tasks',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AdminFlowTheme.textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${member.assignedModules.length} Modules',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (member.assignedModules.isEmpty)
              AdminFlowCard(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No modules currently assigned to ${member.name}',
                    style: const TextStyle(color: AdminFlowTheme.textMuted, fontSize: 13),
                  ),
                ),
              )
            else
              ...member.assignedModules.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildDetailedModuleCard(m),
                  )),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AdminFlowTheme.textHint),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: AdminFlowTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            color: AdminFlowTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedModuleCard(AdminFlowMemberModule module) {
    final percent = (module.progress * 100).toInt();

    return AdminFlowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module Top Header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.folder_2, color: AdminFlowTheme.primaryBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AdminFlowTheme.textDark,
                      ),
                    ),
                    Text(
                      '${module.tasks.length} Assigned Tasks  •  $percent% Complete',
                      style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AdminFlowTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AdminFlowProgressBar(
            progress: module.progress,
            color: AdminFlowTheme.primaryBlue,
            height: 6,
          ),
          const SizedBox(height: 14),

          // Detailed Tasks inside this module for this employee
          if (module.tasks.isNotEmpty) ...[
            const Text(
              'Tasks in this Module:',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 8),
            ...module.tasks.map((task) => _buildEmployeeTaskItem(task)),
          ] else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('No specific subtasks assigned yet.', style: TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted)),
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeTaskItem(AdminFlowTask task) {
    final bool isExceeded = task.isTimeExceeded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExceeded ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExceeded ? const Color(0xFFFECDD3) : AdminFlowTheme.cardBorder,
          width: isExceeded ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AdminFlowTheme.textDark,
                  ),
                ),
              ),
              AdminFlowStatusBadge(status: task.status, fontSize: 10),
            ],
          ),
          const SizedBox(height: 8),

          // ── Detailed Time Row (kitna time mila tha, kitna bacha hai, ya extra time red me) ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Kitna time mila tha (Allocated)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time Allocated',
                        style: TextStyle(fontSize: 10, color: AdminFlowTheme.textMuted, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Iconsax.clock, size: 12, color: AdminFlowTheme.primaryBlue),
                          const SizedBox(width: 4),
                          Text(
                            '${task.allocatedHours.toInt()}h',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                const SizedBox(width: 10),

                // Kitna time laga (Spent)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time Spent',
                        style: TextStyle(fontSize: 10, color: AdminFlowTheme.textMuted, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Iconsax.timer_1, size: 12, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            '${task.actualHours.toInt()}h',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminFlowTheme.textDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                const SizedBox(width: 10),

                // Kitna bacha hai YA Extra Time (in RED if exceeded)
                Expanded(
                  flex: 2,
                  child: isExceeded
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFF87171)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFDC2626)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '+${task.extraHours.toInt()}h Extra Time Taken',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB91C1C),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, size: 12, color: Color(0xFF16A34A)),
                              const SizedBox(width: 4),
                              Text(
                                '${task.remainingHours.toInt()}h Left',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Priority and Handover Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Priority: ', style: TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted)),
                  Text(
                    task.priority,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: task.priority == 'High' ? const Color(0xFFDC2626) : const Color(0xFF3B206A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('• Due: ${task.dueDate}', style: const TextStyle(fontSize: 11, color: AdminFlowTheme.textMuted)),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(() => AdminHandoverTaskScreen(task: task));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Iconsax.refresh_2, size: 11, color: AdminFlowTheme.primaryBlue),
                          SizedBox(width: 4),
                          Text('Handover', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AdminFlowTheme.primaryBlue)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      Get.to(() => AdminTaskDetailsScreen(task: task));
                    },
                    child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AdminFlowTheme.textHint),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
