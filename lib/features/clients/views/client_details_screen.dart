import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/clients_controller.dart';
import '../models/client_model.dart';
import 'add_edit_client_screen.dart';
import 'assigned_projects_screen.dart';
import 'communication_history_screen.dart';

class ClientDetailsScreen extends StatelessWidget {
  const ClientDetailsScreen({super.key});

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

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Screen 3: Symmetrical Header card ──
                    _buildProfileHeader(client),
                    const SizedBox(height: 16),

                    // ── Navigation Quick Links ──
                    _buildNavigationPills(context, client),
                    const SizedBox(height: 16),

                    // ── About client note card ──
                    _buildAboutClientCard(client),
                    const SizedBox(height: 16),

                    // ── Address card ──
                    _buildAddressCard(client),
                    const SizedBox(height: 16),

                    // ── Key Contacts Section ──
                    _buildKeyContactsSection(client),
                    const SizedBox(height: 20),

                    // ── Symmetrical Statistics grid ──
                    _buildStatsCard(client),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProfileHeader(Client client) {
    final statusColor = client.status == 'Active' ? AppColors.successColor : AppColors.errorColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          // Circle Initials Avatar
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withValues(alpha: 0.15),
                  AppColors.indigo500.withValues(alpha: 0.15),
                ],
              ),
              border: Border.all(color: AppColors.slate100, width: 2),
            ),
            child: Center(
              child: AppText(
                client.name.isNotEmpty 
                    ? client.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                    : 'CL',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
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
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
                const SizedBox(height: 2),
                AppText(
                  client.email,
                  fontSize: 13,
                  color: AppColors.textColorSecondary,
                ),
                const SizedBox(height: 2),
                AppText(
                  client.mobile,
                  fontSize: 12,
                  color: AppColors.textColorHint,
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              client.status,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationPills(BuildContext context, Client client) {
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
              child: const Column(
                children: [
                  Icon(Iconsax.briefcase, color: AppColors.primaryColor, size: 20),
                  SizedBox(height: 6),
                  AppText('Assigned Projects', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
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
              child: const Column(
                children: [
                  Icon(Iconsax.message_text, color: AppColors.indigo500, size: 20),
                  SizedBox(height: 6),
                  AppText('Comm. History', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                ],
              ),
            ),
          ),
        ),
      ],
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
            'Address',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Iconsax.location, color: AppColors.textColorHint, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(
                  client.address.isNotEmpty ? client.address : 'No address provided.',
                  fontSize: 13,
                  color: AppColors.textColorSecondary,
                ),
              ),
            ],
          ),
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
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Iconsax.message, color: AppColors.indigo500, size: 18),
                  onPressed: () {},
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsCard(Client client) {
    final projCount = client.projects.length;
    final activeCount = client.projects.where((p) => p.status == 'Active').length;
    final completedCount = client.projects.where((p) => p.status == 'Completed').length;
    final totalVal = client.projects.fold<double>(0.0, (sum, p) => sum + p.estimatedValue);

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
            'Statistics',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatPill('Projects', '$projCount'),
              _buildStatPill('Active Projects', '$activeCount', color: AppColors.warningColor),
              _buildStatPill('Completed', '$completedCount', color: AppColors.successColor),
            ],
          ),
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
