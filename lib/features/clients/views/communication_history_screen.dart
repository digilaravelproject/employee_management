import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/clients_controller.dart';
import '../models/client_model.dart';
import 'add_communication_screen.dart';

class CommunicationHistoryScreen extends StatefulWidget {
  const CommunicationHistoryScreen({super.key});

  @override
  State<CommunicationHistoryScreen> createState() => _CommunicationHistoryScreenState();
}

class _CommunicationHistoryScreenState extends State<CommunicationHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Communication History',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        final client = controller.selectedClient.value;
        if (client == null) {
          return const Center(child: AppText('No client selected'));
        }

        final allComms = client.communications;
        final emailComms = allComms.where((c) => c.type == 'Email').toList();
        final callComms = allComms.where((c) => c.type == 'Call').toList();
        final meetComms = allComms.where((c) => c.type == 'Meeting').toList();
        final noteComms = allComms.where((c) => c.type == 'Note').toList();

        return Column(
          children: [
            // Tabs Header for Type filters
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.textColorHint,
                indicatorColor: AppColors.primaryColor,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Emails'),
                  Tab(text: 'Calls'),
                  Tab(text: 'Meetings'),
                  Tab(text: 'Notes'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Timeline Feed
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTimelineFeed(allComms),
                  _buildTimelineFeed(emailComms),
                  _buildTimelineFeed(callComms),
                  _buildTimelineFeed(meetComms),
                  _buildTimelineFeed(noteComms),
                ],
              ),
            ),

            // Symmetrical trigger bottom action button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.slate200)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.clearCommForm();
                    Get.to(() => AddCommunicationScreen(clientId: client.id));
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const AppText(
                    'Add New Communication',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTimelineFeed(List<ClientCommunication> comms) {
    if (comms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.message_text, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const AppText('No communication history recorded.', fontSize: 12, color: AppColors.textColorHint),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: comms.length,
      itemBuilder: (context, index) {
        final comm = comms[index];
        final typeColor = _getTimelineTypeColor(comm.type);
        final typeIcon = _getTimelineTypeIcon(comm.type);

        final dateStr = DateFormat('dd MMMM yyyy, hh:mm a').format(comm.dateTime);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Symmetrical Left Vertical Line & Icon Column
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 16),
                ),
                if (index != comms.length - 1)
                  Container(
                    width: 2,
                    height: 90,
                    color: AppColors.slate200,
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Content Column
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                        AppText(
                          comm.type,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: typeColor,
                        ),
                        AppText(
                          dateStr,
                          fontSize: 10,
                          color: AppColors.textColorHint,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      comm.subject,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      'To/Participant: ${comm.to}',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      comm.description,
                      fontSize: 12,
                      color: AppColors.textColorSecondary,
                    ),
                    if (comm.attachmentName != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.slate100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.picture_as_pdf, color: AppColors.errorColor, size: 16),
                            const SizedBox(width: 6),
                            AppText(
                              comm.attachmentName!,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColorPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getTimelineTypeColor(String type) {
    switch (type) {
      case 'Email':
        return AppColors.primaryColor;
      case 'Call':
        return AppColors.warningColor;
      case 'Meeting':
        return AppColors.successColor;
      case 'Note':
        return AppColors.indigo500;
      default:
        return AppColors.textColorSecondary;
    }
  }

  IconData _getTimelineTypeIcon(String type) {
    switch (type) {
      case 'Email':
        return Iconsax.direct;
      case 'Call':
        return Iconsax.call;
      case 'Meeting':
        return Iconsax.people;
      case 'Note':
        return Iconsax.note_1;
      default:
        return Iconsax.message_text;
    }
  }
}
