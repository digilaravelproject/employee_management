import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/clients_controller.dart';
import '../models/client_model.dart';
import '../models/client_detail_model.dart';
import 'add_edit_client_screen.dart';
import 'assigned_projects_screen.dart';
import 'communication_history_screen.dart';

class ClientDetailsScreen extends StatefulWidget {
  const ClientDetailsScreen({super.key});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<ClientsController>();
      final client = controller.selectedClient.value;
      if (client != null && client.id.isNotEmpty) {
        controller.fetchClientDetail(client.id);
      }
    });
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWebsite(String url) async {
    String formattedUrl = url.trim();
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    final uri = Uri.parse(formattedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientsController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Client Details',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            final client = controller.selectedClient.value;
            if (client == null) return const SizedBox();
            return IconButton(
              icon: const Icon(Iconsax.edit_2, color: AppColors.textColorSecondary),
              onPressed: () {
                controller.initializeEditing(client);
                Get.to(() => AddEditClientScreen(isEditMode: true, clientId: client.id));
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        final client = controller.selectedClient.value;
        if (client == null) {
          return const Center(
            child: AppText('No client details found', fontSize: 15, fontWeight: FontWeight.bold),
          );
        }

        final detail = controller.clientDetailData.value;
        final isLoading = controller.isDetailLoading.value;

        return RefreshIndicator(
          onRefresh: () => controller.fetchClientDetail(client.id),
          color: AppColors.primaryColor,
          child: Column(
            children: [
              if (isLoading)
                const LinearProgressIndicator(
                  minHeight: 2.5,
                  backgroundColor: AppColors.primaryLight,
                  color: AppColors.primaryColor,
                ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header card
                      _buildProfileHeader(client, detail),
                      const SizedBox(height: 14),

                      // Quick Action Buttons (Call, Email, Website)
                      _buildQuickActionButtons(client),
                      const SizedBox(height: 16),

                      // Navigation Quick Links (Assigned Projects & Comm History)
                      _buildNavigationPills(context, client, detail),
                      const SizedBox(height: 16),

                      // Activity & Statistics grid
                      _buildStatsCard(client, detail),
                      const SizedBox(height: 16),

                      // Projects from API (Live CRM details)
                      if (detail != null && detail.projects.isNotEmpty) ...[
                        _buildProjectsSection(detail.projects),
                        const SizedBox(height: 16),
                      ],

                      // Communications Log from API (Live History)
                      if (detail != null && detail.communications.isNotEmpty) ...[
                        _buildCommunicationsSection(detail.communications),
                        const SizedBox(height: 16),
                      ],

                      // Contact & Location card
                      _buildAddressCard(client),
                      const SizedBox(height: 16),

                      // About client note card
                      _buildAboutClientCard(client),
                      const SizedBox(height: 16),

                      // Key Contacts Section (if any)
                      _buildKeyContactsSection(client),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(Client client, ClientDetailData? detail) {
    final statusColor = client.status.toLowerCase() == 'active' ? AppColors.successColor : AppColors.errorColor;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Initials Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryColor, Color(0xFF6B3BA6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: AppText(
                    client.name.isNotEmpty 
                        ? client.name.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
                        : 'CL',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      client.name,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // ID Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: AppText(
                            'ID: #${client.id}',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColorSecondary,
                          ),
                        ),
                        // Lead Tag if available
                        if (client.leadId != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Iconsax.user_search, size: 11, color: AppColors.primaryColor),
                                const SizedBox(width: 3),
                                AppText(
                                  'Lead #${client.leadId}',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    AppText(
                      client.status,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.slate100),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Iconsax.calendar_1, size: 13, color: AppColors.textColorHint),
              const SizedBox(width: 6),
              AppText(
                'Added: ${DateFormat('dd MMM yyyy').format(client.createdOn)}',
                fontSize: 11,
                color: AppColors.textColorHint,
              ),
              if (client.updatedAt != null) ...[
                const Spacer(),
                const Icon(Iconsax.refresh, size: 12, color: AppColors.textColorHint),
                const SizedBox(width: 4),
                AppText(
                  'Updated: ${DateFormat('dd MMM, hh:mm a').format(client.updatedAt!)}',
                  fontSize: 10,
                  color: AppColors.textColorHint,
                ),
              ],
            ],
          ),
          if (detail?.createdBy != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Iconsax.user_octagon, size: 13, color: AppColors.primaryColor),
                const SizedBox(width: 6),
                AppText(
                  'Created by: ${detail!.createdBy!.name}',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
                if (detail.createdBy!.designation != null && detail.createdBy!.designation!.isNotEmpty) ...[
                  AppText(
                    ' (${detail.createdBy!.designation})',
                    fontSize: 11,
                    color: AppColors.textColorHint,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(Client client) {
    return Row(
      children: [
        if (client.mobile.isNotEmpty)
          Expanded(
            child: InkWell(
              onTap: () => _makePhoneCall(client.mobile),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.call, color: Color(0xFF10B981), size: 16),
                    SizedBox(width: 6),
                    AppText('Call', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                  ],
                ),
              ),
            ),
          ),
        if (client.mobile.isNotEmpty && client.email.isNotEmpty)
          const SizedBox(width: 10),
        if (client.email.isNotEmpty)
          Expanded(
            child: InkWell(
              onTap: () => _sendEmail(client.email),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.sms, color: AppColors.primaryColor, size: 16),
                    SizedBox(width: 6),
                    AppText('Email', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                  ],
                ),
              ),
            ),
          ),
        if (client.website.isNotEmpty) ...[
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () => _openWebsite(client.website),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.25)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.global, color: Color(0xFF3B82F6), size: 16),
                    SizedBox(width: 6),
                    AppText('Website', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationPills(BuildContext context, Client client, ClientDetailData? detail) {
    final pCount = detail != null ? detail.projects.length : client.projectsCount;
    final cCount = detail != null ? detail.communications.length : client.communicationsCount;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.to(() => const AssignedProjectsScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.01),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Icon(Iconsax.briefcase, color: AppColors.primaryColor, size: 20),
                  const SizedBox(height: 6),
                  AppText('Assigned Projects ($pCount)', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => Get.to(() => const CommunicationHistoryScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.01),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Icon(Iconsax.message_text, color: AppColors.indigo500, size: 20),
                  const SizedBox(height: 6),
                  AppText('Comm. History ($cCount)', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsSection(List<ClientDetailProject> projects) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Projects',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              InkWell(
                onTap: () => Get.to(() => const AssignedProjectsScreen()),
                child: const AppText(
                  'View All',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...projects.map((proj) {
            final f = NumberFormat.currency(locale: 'HI', symbol: '₹', decimalDigits: 0);
            final valStr = f.format(proj.estimatedValue);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          proj.name,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColorPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          proj.status,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    proj.description,
                    fontSize: 12,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AppText(
                          proj.category,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        'Value: $valStr',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColorPrimary,
                      ),
                    ],
                  ),
                  if (proj.projectManager != null) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.slate200),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Iconsax.user, size: 14, color: AppColors.primaryColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AppText(
                            'Manager: ${proj.projectManager!.name} (${proj.projectManager!.designation ?? 'PM'})',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorSecondary,
                          ),
                        ),
                        if (proj.team.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText(
                              '${proj.team.length} Members',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCommunicationsSection(List<ClientDetailCommunication> comms) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Communications Log',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorPrimary,
              ),
              InkWell(
                onTap: () => Get.to(() => const CommunicationHistoryScreen()),
                child: const AppText(
                  'View All',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...comms.map((comm) {
            final dateStr = comm.communicatedAt != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(comm.communicatedAt!)
                : 'Recent';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText(
                          comm.type,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      AppText(
                        dateStr,
                        fontSize: 11,
                        color: AppColors.textColorHint,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    comm.subject,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    comm.description,
                    fontSize: 12,
                    color: AppColors.textColorSecondary,
                  ),
                  if (comm.attachmentUrl != null && comm.attachmentUrl!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => _openUrl(comm.attachmentUrl!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.document, size: 14, color: AppColors.primaryColor),
                            const SizedBox(width: 6),
                            Flexible(
                              child: AppText(
                                comm.attachmentName ?? 'View Attachment',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.download_rounded, size: 14, color: AppColors.primaryColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (comm.createdBy != null) ...[
                    const SizedBox(height: 8),
                    AppText(
                      'Logged by: ${comm.createdBy!.name}',
                      fontSize: 10.5,
                      color: AppColors.textColorHint,
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAboutClientCard(Client client) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'About Client',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 8),
          AppText(
            client.notes.isNotEmpty ? client.notes : 'No client notes added yet.',
            fontSize: 13,
            color: AppColors.textColorSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Client client) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Contact & Location',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 12),
          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Iconsax.location, color: AppColors.primaryColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  client.address.isNotEmpty ? client.address : 'No address provided.',
                  fontSize: 13,
                  color: AppColors.textColorPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Phone
          InkWell(
            onTap: client.mobile.isNotEmpty ? () => _makePhoneCall(client.mobile) : null,
            child: Row(
              children: [
                const Icon(Iconsax.call, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: AppText(
                    client.mobile.isNotEmpty ? client.mobile : 'No phone number',
                    fontSize: 13,
                    color: client.mobile.isNotEmpty ? const Color(0xFF10B981) : AppColors.textColorSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Email
          InkWell(
            onTap: client.email.isNotEmpty ? () => _sendEmail(client.email) : null,
            child: Row(
              children: [
                const Icon(Iconsax.sms, color: AppColors.primaryColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: AppText(
                    client.email.isNotEmpty ? client.email : 'No email address',
                    fontSize: 13,
                    color: client.email.isNotEmpty ? AppColors.primaryColor : AppColors.textColorSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (client.website.isNotEmpty) ...[
            const SizedBox(height: 10),
            // Website
            InkWell(
              onTap: () => _openWebsite(client.website),
              child: Row(
                children: [
                  const Icon(Iconsax.global, color: Color(0xFF3B82F6), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(
                      client.website,
                      fontSize: 13,
                      color: const Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.open_in_new_rounded, size: 14, color: Color(0xFF3B82F6)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyContactsSection(Client client) {
    if (client.keyContacts.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Key Contacts',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        const SizedBox(height: 10),
        ...client.keyContacts.map((contact) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.user, color: AppColors.primaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        contact.name,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        contact.designation,
                        fontSize: 11,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.call, color: AppColors.primaryColor, size: 18),
                  onPressed: () => _makePhoneCall(contact.mobile),
                ),
                IconButton(
                  icon: const Icon(Iconsax.message, color: AppColors.indigo500, size: 18),
                  onPressed: () => _sendEmail(contact.email),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsCard(Client client, ClientDetailData? detail) {
    final projCount = detail != null ? detail.projects.length : (client.projectsCount > 0 ? client.projectsCount : client.projects.length);
    final commCount = detail != null ? detail.communications.length : client.communicationsCount;
    final activeCount = detail != null
        ? detail.projects.where((p) => p.status.toLowerCase().contains('progress') || p.status.toLowerCase() == 'active').length
        : client.projects.where((p) => p.status == 'Active').length;

    double totalVal = 0.0;
    if (detail != null) {
      totalVal = detail.projects.fold<double>(0.0, (sum, p) => sum + p.estimatedValue);
    } else {
      totalVal = client.projects.fold<double>(0.0, (sum, p) => sum + p.estimatedValue);
    }

    final f = NumberFormat.currency(locale: 'HI', symbol: '₹', decimalDigits: 0);
    final formattedVal = f.format(totalVal);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Activity & Statistics',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatPill('Total Projects', '$projCount'),
              _buildStatPill('Communications', '$commCount', color: const Color(0xFF3B82F6)),
              _buildStatPill('Active Projects', '$activeCount', color: AppColors.warningColor),
            ],
          ),
          if (totalVal > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText('Total Value', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textColorSecondary),
                  AppText(formattedVal, fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textColorPrimary),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatPill(String title, String value, {Color color = AppColors.primaryColor}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            AppText(title, fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
            const SizedBox(height: 4),
            AppText(value, fontSize: 16, fontWeight: FontWeight.w900, color: color),
          ],
        ),
      ),
    );
  }
}
