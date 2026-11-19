import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/clients_controller.dart';
import '../models/client_model.dart';
import 'add_communication_screen.dart';
import 'communication_detail_bottom_sheet.dart';

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
                  _buildTimelineFeed(allComms, client.id),
                  _buildTimelineFeed(emailComms, client.id),
                  _buildTimelineFeed(callComms, client.id),
                  _buildTimelineFeed(meetComms, client.id),
                  _buildTimelineFeed(noteComms, client.id),
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
                  onPressed: () async {
                    controller.clearCommForm();
                    final added = await Get.to(() => AddCommunicationScreen(clientId: client.id));
                    if (added == true) {
                      controller.fetchClientDetail(client.id);
                    }
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

  Widget _buildTimelineFeed(List<ClientCommunication> comms, dynamic clientId) {
    final controller = Get.find<ClientsController>();

    if (comms.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.fetchClientDetail(clientId),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.message_text, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    const AppText('No communication history recorded.', fontSize: 12, color: AppColors.textColorHint),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchClientDetail(clientId),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      CommunicationDetailBottomSheet.show(
                        context: context,
                        clientId: clientId,
                        communicationId: comm.id,
                        initialType: comm.type,
                        initialSubject: comm.subject,
                        initialDate: comm.dateTime,
                        initialRecipient: comm.to,
                        initialDescription: comm.description,
                        initialAttachmentName: comm.attachmentName,
                        initialAttachmentUrl: comm.attachmentUrl,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: typeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  comm.type,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: typeColor,
                                ),
                              ),
                              const Spacer(),
                              AppText(
                                dateStr,
                                fontSize: 10,
                                color: AppColors.textColorHint,
                              ),
                              const SizedBox(width: 2),
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.more_vert, size: 16, color: AppColors.textColorHint),
                                  onSelected: (val) async {
                                    if (val == 'edit') {
                                      final updated = await Get.to(() => AddCommunicationScreen(
                                        clientId: clientId.toString(),
                                        isEditMode: true,
                                        communicationId: comm.id,
                                      ));
                                      if (updated == true) {
                                        controller.fetchClientDetail(clientId);
                                      }
                                    } else if (val == 'delete') {
                                      _confirmDeleteComm(context, controller, clientId, comm.id);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      height: 36,
                                      child: Row(
                                        children: [
                                          Icon(Iconsax.edit_2, size: 14, color: AppColors.primaryColor),
                                          SizedBox(width: 8),
                                          AppText('Edit', fontSize: 12, fontWeight: FontWeight.w600),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      height: 36,
                                      child: Row(
                                        children: [
                                          Icon(Iconsax.trash, size: 14, color: AppColors.errorColor),
                                          SizedBox(width: 8),
                                          AppText('Delete', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.errorColor),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          AppText(
                            comm.subject,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            'To/Participant: ${comm.to}',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          AppText(
                            comm.description,
                            fontSize: 12,
                            color: AppColors.textColorSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (comm.attachmentName != null && comm.attachmentName!.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.slate50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.slate100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.description_rounded, color: AppColors.primaryColor, size: 14),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: AppText(
                                      comm.attachmentName!,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColorPrimary,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () async {
                                  final updated = await Get.to(() => AddCommunicationScreen(
                                    clientId: clientId.toString(),
                                    isEditMode: true,
                                    communicationId: comm.id,
                                    clientCommunication: comm,
                                  ));
                                  if (updated == true) {
                                    controller.fetchClientDetail(clientId);
                                  }
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Iconsax.edit_2, size: 12, color: AppColors.textColorHint),
                                      SizedBox(width: 4),
                                      AppText(
                                        'Edit',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textColorHint,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppText(
                                    'View Full Details',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 9, color: AppColors.primaryColor),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
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

  void _confirmDeleteComm(BuildContext context, ClientsController controller, dynamic clientId, dynamic commId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.trash, color: AppColors.errorColor, size: 20),
            ),
            const SizedBox(width: 12),
            const AppText(
              'Delete Record',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
          ],
        ),
        content: const AppText(
          'Are you sure you want to permanently delete this communication record? This action cannot be undone.',
          fontSize: 13,
          color: AppColors.textColorSecondary,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.slate200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const AppText('Cancel', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await controller.deleteCommunication(
                      clientId: clientId,
                      communicationId: commId,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const AppText('Delete', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
