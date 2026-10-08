import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

// ── TELE-CRM LEAD MODEL ──────────────────────────────────────────────────────
class TeleCrmLeadItem {
  final String id;
  final String customerName;
  final String phone;
  final String city;
  final String source;
  final String sourceColorHex;
  String status; // Interested, Follow-up, Pending Call, Converted, Unreachable, Wrong Number
  DateTime? nextFollowupDateTime;
  String lastCallNote;
  String lastCallDuration;
  String lastCallDate;
  double dealValue;

  TeleCrmLeadItem({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.city,
    required this.source,
    required this.sourceColorHex,
    required this.status,
    this.nextFollowupDateTime,
    this.lastCallNote = '',
    this.lastCallDuration = '',
    this.lastCallDate = '',
    this.dealValue = 0,
  });
}

// ── SALES EXECUTIVE TELE-CRM SCREEN ──────────────────────────────────────────
class SalesExecutiveTeleCrmScreen extends StatefulWidget {
  const SalesExecutiveTeleCrmScreen({super.key});

  @override
  State<SalesExecutiveTeleCrmScreen> createState() => _SalesExecutiveTeleCrmScreenState();
}

class _SalesExecutiveTeleCrmScreenState extends State<SalesExecutiveTeleCrmScreen> {
  String _selectedTab = 'Follow-ups Today';
  final TextEditingController _searchController = TextEditingController();

  final List<TeleCrmLeadItem> _myLeads = [
    TeleCrmLeadItem(
      id: 'TC-201',
      customerName: 'Rajesh Agrawal (Shree Logistics)',
      phone: '+91 98230 44556',
      city: 'Mumbai',
      source: 'Facebook Ads',
      sourceColorHex: '0xFF1877F2',
      status: 'Follow-up',
      nextFollowupDateTime: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
      lastCallNote: 'Interested in 40 biometric devices. Asked for custom pricing quotation.',
      lastCallDuration: '8m 45s',
      lastCallDate: 'Yesterday 04:30 PM',
      dealValue: 140000,
    ),
    TeleCrmLeadItem(
      id: 'TC-202',
      customerName: 'Dr. Alok Verma',
      phone: '+91 99112 88776',
      city: 'Delhi NCR',
      source: 'JustDial',
      sourceColorHex: '0xFFF58220',
      status: 'Follow-up',
      nextFollowupDateTime: DateTime.now().add(const Duration(hours: 5, minutes: 15)),
      lastCallNote: 'Call back in afternoon after surgery. Wants clinic staff app.',
      lastCallDuration: '3m 12s',
      lastCallDate: 'Today 11:00 AM',
      dealValue: 65000,
    ),
    TeleCrmLeadItem(
      id: 'TC-203',
      customerName: 'Meghna Sundaram (Apex Tech)',
      phone: '+91 97445 11223',
      city: 'Bengaluru',
      source: 'Website',
      sourceColorHex: '0xFF10B981',
      status: 'Interested',
      nextFollowupDateTime: DateTime.now().add(const Duration(days: 1)),
      lastCallNote: 'Demo completed. Shared trial login credentials with HR team.',
      lastCallDuration: '14m 20s',
      lastCallDate: '06 Oct 2026',
      dealValue: 220000,
    ),
    TeleCrmLeadItem(
      id: 'TC-204',
      customerName: 'Kishore Patel',
      phone: '+91 98980 33221',
      city: 'Ahmedabad',
      source: 'Google Ads',
      sourceColorHex: '0xFFEA4335',
      status: 'Pending Call',
      nextFollowupDateTime: null,
      lastCallNote: 'Fresh lead assigned today. High urgency requirement.',
      lastCallDuration: '-',
      lastCallDate: '-',
      dealValue: 90000,
    ),
    TeleCrmLeadItem(
      id: 'TC-205',
      customerName: 'Sunil Joshi',
      phone: '+91 94250 88990',
      city: 'Indore',
      source: 'Referral',
      sourceColorHex: '0xFF8B5CF6',
      status: 'Converted',
      nextFollowupDateTime: null,
      lastCallNote: 'Payment received ₹1,20,000 via NEFT. Account activated.',
      lastCallDuration: '6m 10s',
      lastCallDate: '05 Oct 2026',
      dealValue: 120000,
    ),
    TeleCrmLeadItem(
      id: 'TC-206',
      customerName: 'Amit Saxena',
      phone: '+91 90000 11111',
      city: 'Jaipur',
      source: 'JustDial',
      sourceColorHex: '0xFFF58220',
      status: 'Unreachable',
      nextFollowupDateTime: DateTime.now().add(const Duration(hours: 3)),
      lastCallNote: 'Switched off on 2 previous attempts.',
      lastCallDuration: '0m 45s',
      lastCallDate: 'Today 10:15 AM',
      dealValue: 50000,
    ),
  ];

  List<TeleCrmLeadItem> get _filteredLeads {
    final query = _searchController.text.trim().toLowerCase();
    return _myLeads.where((lead) {
      final matchesSearch = lead.customerName.toLowerCase().contains(query) ||
          lead.phone.toLowerCase().contains(query) ||
          lead.city.toLowerCase().contains(query) ||
          lead.id.toLowerCase().contains(query);
      if (!matchesSearch) return false;

      if (_selectedTab == 'Follow-ups Today') {
        return lead.status == 'Follow-up';
      } else if (_selectedTab == 'Interested') {
        return lead.status == 'Interested';
      } else if (_selectedTab == 'Pending Call') {
        return lead.status == 'Pending Call';
      } else if (_selectedTab == 'Converted') {
        return lead.status == 'Converted';
      } else if (_selectedTab == 'Unreachable') {
        return lead.status == 'Unreachable' || lead.status == 'Wrong Number';
      }
      return true; // 'All Leads'
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final followupsCount = _myLeads.where((l) => l.status == 'Follow-up').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Sales Tele-CRM Executive',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            AppText(
              'Call queue, follow-up timers & conversion log',
              fontSize: 11,
              color: AppColors.textColorSecondary,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── 1. Executive Performance Header Banner ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildExecStatItem('Calls Today', '28', Iconsax.call_calling, const Color(0xFFA7F3D0)),
                    _buildExecDivider(),
                    _buildExecStatItem('Follow-ups', '$followupsCount', Iconsax.timer_1, const Color(0xFFFDE047)),
                    _buildExecDivider(),
                    _buildExecStatItem('Closed Deals', '12', Iconsax.crown, Colors.white),
                    _buildExecDivider(),
                    _buildExecStatItem('Revenue', '₹6.5L', Iconsax.wallet_3, const Color(0xFF6EE7B7)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── 2. Search & Tab Filter Bar ──
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search customer name, phone, city...',
              hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Iconsax.search_normal_1, size: 18, color: Color(0xFF64748B)),
              fillColor: Colors.white,
              filled: true,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildTabChip('Follow-ups Today', count: followupsCount),
                _buildTabChip('All Leads'),
                _buildTabChip('Interested'),
                _buildTabChip('Pending Call'),
                _buildTabChip('Converted'),
                _buildTabChip('Unreachable'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 3. Tele-CRM Lead Queue List ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Lead Calling Queue (${_filteredLeads.length})',
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              const AppText(
                'Auto-sorted by priority',
                fontSize: 10.5,
                color: AppColors.textColorHint,
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_filteredLeads.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  Icon(Iconsax.call_remove, size: 40, color: AppColors.textColorHint),
                  SizedBox(height: 10),
                  AppText(
                    'No leads found in this filter category',
                    color: AppColors.textColorSecondary,
                    fontSize: 13,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._filteredLeads.map((lead) => _buildTeleCrmLeadCard(lead)),
        ],
      ),
    );
  }

  Widget _buildExecStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        AppText(value, fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
        const SizedBox(height: 2),
        AppText(label, fontSize: 9.5, color: const Color(0xFFD1FAE5)),
      ],
    );
  }

  Widget _buildExecDivider() {
    return Container(height: 28, width: 1, color: const Color(0xFF047857));
  }

  Widget _buildTabChip(String label, {int? count}) {
    final isSelected = _selectedTab == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              label,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText(
                  '$count',
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.primaryColor : const Color(0xFFCBD5E1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        onSelected: (val) {
          setState(() {
            _selectedTab = label;
          });
        },
      ),
    );
  }

  Widget _buildTeleCrmLeadCard(TeleCrmLeadItem lead) {
    Color statusColor;
    Color statusBgColor;

    switch (lead.status) {
      case 'Interested':
        statusColor = const Color(0xFF16A34A);
        statusBgColor = const Color(0xFFDCFCE7);
        break;
      case 'Follow-up':
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFEF3C7);
        break;
      case 'Converted':
        statusColor = const Color(0xFF2563EB);
        statusBgColor = const Color(0xFFDBEAFE);
        break;
      case 'Unreachable':
        statusColor = const Color(0xFF7C3AED);
        statusBgColor = const Color(0xFFEDE9FE);
        break;
      case 'Wrong Number':
        statusColor = const Color(0xFFDC2626);
        statusBgColor = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = const Color(0xFF475569);
        statusBgColor = const Color(0xFFF1F5F9);
    }

    final sourceColor = Color(int.parse(lead.sourceColorHex));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: sourceColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: sourceColor.withValues(alpha: 0.3)),
                    ),
                    child: AppText(
                      lead.source,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: sourceColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    lead.id,
                    fontSize: 10.5,
                    color: AppColors.textColorHint,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText(
                  lead.status,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      lead.customerName,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Iconsax.location, size: 12, color: AppColors.textColorSecondary),
                        const SizedBox(width: 4),
                        AppText(
                          lead.city,
                          fontSize: 11,
                          color: AppColors.textColorSecondary,
                        ),
                        const SizedBox(width: 10),
                        const Icon(Iconsax.call, size: 12, color: AppColors.textColorSecondary),
                        const SizedBox(width: 4),
                        AppText(
                          lead.phone,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Follow-up Timer Alert Bar (if follow-up date set)
          if (lead.nextFollowupDateTime != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.timer_1, size: 14, color: Color(0xFFD97706)),
                  const SizedBox(width: 6),
                  AppText(
                    'Next Follow-up Call: ${DateFormat('dd MMM, hh:mm a').format(lead.nextFollowupDateTime!)}',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB45309),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Last Discussion Note
          if (lead.lastCallNote.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText('Last Call Discussion:', fontSize: 9.5, color: AppColors.textColorHint, fontWeight: FontWeight.bold),
                      AppText('Duration: ${lead.lastCallDuration}', fontSize: 9.5, color: AppColors.textColorSecondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lead.lastCallNote,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF334155),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Action Buttons: Call Now & Log Call Result
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Dialing Call 📞',
                      'Calling ${lead.customerName} (${lead.phone})',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF10B981),
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Iconsax.call, size: 14, color: Color(0xFF10B981)),
                  label: const AppText('Call Now', fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF10B981)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showLogCallModal(context, lead),
                  icon: const Icon(Iconsax.edit_2, size: 14, color: Colors.white),
                  label: const AppText('Log Call', fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── TELE-CRM CALL LOGGING MODAL SHEET ─────────────────────────────────────
  void _showLogCallModal(BuildContext context, TeleCrmLeadItem lead) {
    String selectedOutcome = lead.status;
    final noteController = TextEditingController(text: lead.lastCallNote);
    final durationController = TextEditingController(text: '5m 30s');
    final amountController = TextEditingController(text: lead.dealValue > 0 ? lead.dealValue.round().toString() : '');
    DateTime selectedFollowupDate = DateTime.now().add(const Duration(days: 1, hours: 2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Iconsax.call_calling, color: AppColors.primaryColor, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                'Log Call: ${lead.customerName}',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                              AppText(
                                '${lead.phone} • ${lead.source}',
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
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Outcome Selector
                        const AppText('Select Call Outcome / Result:', fontSize: 13, fontWeight: FontWeight.bold),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildOutcomeRadioChip('Interested', selectedOutcome, (val) => setModalState(() => selectedOutcome = val)),
                            _buildOutcomeRadioChip('Follow-up', selectedOutcome, (val) => setModalState(() => selectedOutcome = val)),
                            _buildOutcomeRadioChip('Converted', selectedOutcome, (val) => setModalState(() => selectedOutcome = val)),
                            _buildOutcomeRadioChip('Unreachable', selectedOutcome, (val) => setModalState(() => selectedOutcome = val)),
                            _buildOutcomeRadioChip('Wrong Number', selectedOutcome, (val) => setModalState(() => selectedOutcome = val)),
                            _buildOutcomeRadioChip('Not Interested', selectedOutcome, (val) => setModalState(() => selectedOutcome = val)),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Deal Value if Converted or Interested
                        if (selectedOutcome == 'Converted' || selectedOutcome == 'Interested') ...[
                          const AppText('Potential / Deal Amount (₹):', fontSize: 12.5, fontWeight: FontWeight.bold),
                          const SizedBox(height: 6),
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'e.g. 150000',
                              prefixIcon: const Icon(Icons.currency_rupee, size: 18, color: AppColors.primaryColor),
                              fillColor: const Color(0xFFF8FAFC),
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        // Follow-up Date Time Picker if Follow-up or Interested
                        if (selectedOutcome == 'Follow-up' || selectedOutcome == 'Interested') ...[
                          const AppText('Schedule Next Call & Reminder:', fontSize: 12.5, fontWeight: FontWeight.bold),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedFollowupDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 90)),
                              );
                              if (pickedDate != null && context.mounted) {
                                final pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(selectedFollowupDate),
                                );
                                if (pickedTime != null) {
                                  setModalState(() {
                                    selectedFollowupDate = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                  });
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFCD34D)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Iconsax.calendar_1, color: Color(0xFFD97706), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const AppText('Next Follow-up Date & Time', fontSize: 10, color: Color(0xFFB45309)),
                                        AppText(
                                          DateFormat('EEEE, dd MMM yyyy - hh:mm a').format(selectedFollowupDate),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF92400E),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Iconsax.arrow_right_3, size: 16, color: Color(0xFFB45309)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        // Call Duration
                        const AppText('Call Duration:', fontSize: 12.5, fontWeight: FontWeight.bold),
                        const SizedBox(height: 6),
                        TextField(
                          controller: durationController,
                          decoration: InputDecoration(
                            hintText: 'e.g. 6m 30s',
                            prefixIcon: const Icon(Iconsax.clock, size: 18, color: Color(0xFF64748B)),
                            fillColor: const Color(0xFFF8FAFC),
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Discussion Notes
                        const AppText('Call Discussion Notes:', fontSize: 12.5, fontWeight: FontWeight.bold),
                        const SizedBox(height: 6),
                        TextField(
                          controller: noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Enter customer feedback, requirements, objections...',
                            fillColor: const Color(0xFFF8FAFC),
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                lead.status = selectedOutcome;
                                lead.lastCallNote = noteController.text.trim();
                                lead.lastCallDuration = durationController.text.trim();
                                lead.lastCallDate = 'Just Now';
                                if (selectedOutcome == 'Follow-up' || selectedOutcome == 'Interested') {
                                  lead.nextFollowupDateTime = selectedFollowupDate;
                                } else {
                                  lead.nextFollowupDateTime = null;
                                }
                                if (amountController.text.isNotEmpty) {
                                  lead.dealValue = double.tryParse(amountController.text.trim()) ?? lead.dealValue;
                                }
                              });
                              Navigator.pop(ctx);
                              Get.snackbar(
                                'Call Recorded ✅',
                                'Updated status for ${lead.customerName} to $selectedOutcome',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF10B981),
                                colorText: Colors.white,
                              );
                            },
                            icon: const Icon(Iconsax.document_upload, size: 18, color: Colors.white),
                            label: const AppText('Save Call Record', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOutcomeRadioChip(String label, String currentSelected, ValueChanged<String> onSelect) {
    final isSelected = currentSelected == label;
    return ChoiceChip(
      selected: isSelected,
      label: AppText(
        label,
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        color: isSelected ? Colors.white : const Color(0xFF334155),
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      selectedColor: AppColors.primaryColor,
      onSelected: (selected) {
        if (selected) onSelect(label);
      },
    );
  }
}
