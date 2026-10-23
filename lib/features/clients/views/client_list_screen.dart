import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../controllers/clients_controller.dart';
import '../models/client_model.dart';
import 'client_details_screen.dart';
import 'add_edit_client_screen.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put or find controller in memory
    final controller = Get.isRegistered<ClientsController>()
        ? Get.find<ClientsController>()
        : Get.put(ClientsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clients Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Active accounts & client directory',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          // Refresh Button
          IconButton(
            tooltip: 'Refresh Clients',
            icon: const Icon(Iconsax.refresh, color: Color(0xFF3B206A), size: 20),
            onPressed: () => controller.fetchClientsFromApi(),
          ),
          // Add Client Button
          Padding(
            padding: const EdgeInsets.only(right: 14.0, left: 4.0),
            child: GestureDetector(
              onTap: () {
                controller.clearForm();
                Get.to(() => const AddEditClientScreen(isEditMode: false));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF3B206A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter Section ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: const InputDecoration(
                  hintText: 'Search by client name, email, phone, city...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  prefixIcon: Icon(Iconsax.search_normal, color: Color(0xFF3B206A), size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Horizontal Status Filter Deck (All, Active, Inactive) ──
          SizedBox(
            height: 42,
            child: Obx(() {
              return ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterTab(
                    controller,
                    label: 'All',
                    count: controller.totalClientsCount,
                    isSelected: controller.selectedStatusFilter.value == 'All',
                    onTap: () {
                      controller.selectedStatusFilter.value = 'All';
                      controller.fetchClientsFromApi(status: 'all');
                    },
                  ),
                  _buildFilterTab(
                    controller,
                    label: 'Active',
                    count: controller.activeClientsCount,
                    isSelected: controller.selectedStatusFilter.value == 'Active',
                    onTap: () {
                      controller.selectedStatusFilter.value = 'Active';
                      controller.fetchClientsFromApi(status: 'active');
                    },
                  ),
                  _buildFilterTab(
                    controller,
                    label: 'Inactive',
                    count: controller.inactiveClientsCount,
                    isSelected: controller.selectedStatusFilter.value == 'Inactive',
                    onTap: () {
                      controller.selectedStatusFilter.value = 'Inactive';
                      controller.fetchClientsFromApi(status: 'inactive');
                    },
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),

          // ── Client List Feed with Pull-to-Refresh ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.clients.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF3B206A),
                  ),
                );
              }

              final list = controller.filteredClients;
              if (list.isEmpty) {
                return RefreshIndicator(
                  color: const Color(0xFF3B206A),
                  onRefresh: () => controller.fetchClientsFromApi(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Iconsax.profile_2user, size: 30, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No Clients Found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'No clients match the selected criteria or search.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () => controller.fetchClientsFromApi(),
                              icon: const Icon(Iconsax.refresh, size: 16, color: Colors.white),
                              label: const Text('Refresh Directory', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B206A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF3B206A),
                onRefresh: () => controller.fetchClientsFromApi(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final client = list[index];
                    return _ClientCardItem(client: client);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    ClientsController controller, {
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeColor = label == 'Inactive' 
        ? const Color(0xFFDC2626) 
        : (label == 'Active' ? const Color(0xFF16A34A) : const Color(0xFF3B206A));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientCardItem extends StatelessWidget {
  final Client client;
  const _ClientCardItem({required this.client});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientsController>();
    final isActive = client.status.toLowerCase() == 'active';
    final statusColor = isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final statusBg = isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);

    final initials = client.name.trim().isNotEmpty
        ? client.name.trim().split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
        : 'CL';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            controller.selectedClient.value = client;
            controller.fetchClientDetail(client.id);
            Get.to(() => const ClientDetailsScreen());
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar, Title, Status
                Row(
                  children: [
                    // Avatar Box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B206A), Color(0xFF5B349A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                'ID: #${client.id}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              if (client.leadId != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Lead #${client.leadId}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(16),
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
                          Text(
                            client.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Compact Contact Line: Mobile & Email
                Row(
                  children: [
                    if (client.mobile.isNotEmpty) ...[
                      const Icon(Iconsax.call, size: 13, color: Color(0xFF10B981)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          client.mobile,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                    if (client.mobile.isNotEmpty && client.email.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                      ),
                    if (client.email.isNotEmpty) ...[
                      const Icon(Iconsax.sms, size: 13, color: Color(0xFF3B206A)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          client.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                // Clean Summary Metrics Bar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F0FB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.folder_2, size: 12, color: Color(0xFF3B206A)),
                          const SizedBox(width: 4),
                          Text(
                            '${client.projectsCount} ${client.projectsCount == 1 ? 'Project' : 'Projects'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B206A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.messages_2, size: 12, color: Color(0xFF059669)),
                          const SizedBox(width: 4),
                          Text(
                            '${client.communicationsCount} ${client.communicationsCount == 1 ? 'Log' : 'Logs'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(client.createdOn),
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF3B206A)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
