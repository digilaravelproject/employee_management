import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/clients_controller.dart';
import '../models/client_detail_model.dart';
import 'add_communication_screen.dart';
import 'communication_attachment_viewer_screen.dart';

class CommunicationDetailBottomSheet extends StatefulWidget {
  final dynamic clientId;
  final dynamic communicationId;
  final String? initialType;
  final String? initialSubject;
  final DateTime? initialDate;
  final String? initialRecipient;
  final String? initialDescription;
  final String? initialAttachmentName;
  final String? initialAttachmentUrl;

  const CommunicationDetailBottomSheet({
    super.key,
    required this.clientId,
    required this.communicationId,
    this.initialType,
    this.initialSubject,
    this.initialDate,
    this.initialRecipient,
    this.initialDescription,
    this.initialAttachmentName,
    this.initialAttachmentUrl,
  });

  static Future<void> show({
    required BuildContext context,
    required dynamic clientId,
    required dynamic communicationId,
    String? initialType,
    String? initialSubject,
    DateTime? initialDate,
    String? initialRecipient,
    String? initialDescription,
    String? initialAttachmentName,
    String? initialAttachmentUrl,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommunicationDetailBottomSheet(
        clientId: clientId,
        communicationId: communicationId,
        initialType: initialType,
        initialSubject: initialSubject,
        initialDate: initialDate,
        initialRecipient: initialRecipient,
        initialDescription: initialDescription,
        initialAttachmentName: initialAttachmentName,
        initialAttachmentUrl: initialAttachmentUrl,
      ),
    );
  }

  @override
  State<CommunicationDetailBottomSheet> createState() => _CommunicationDetailBottomSheetState();
}

class _CommunicationDetailBottomSheetState extends State<CommunicationDetailBottomSheet> {
  late ClientsController controller;
  ClientDetailCommunication? detail;
  bool isLoading = true;
  String? errorMessage;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ClientsController>();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final res = await controller.fetchCommunicationDetail(
        clientId: widget.clientId,
        communicationId: widget.communicationId,
      );

      if (mounted) {
        setState(() {
          detail = res;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _openAttachmentViewer(String name, String url) {
    Get.to(() => CommunicationAttachmentViewerScreen(
      fileName: name,
      fileUrl: url,
    ));
  }

  Future<void> _onEdit() async {
    final updated = await Get.to(() => AddCommunicationScreen(
      clientId: widget.clientId.toString(),
      isEditMode: true,
      communicationId: widget.communicationId,
      communication: detail,
    ));

    if (updated == true && mounted) {
      _loadDetail();
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
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
          'Are you sure you want to permanently delete this client communication? This action cannot be undone.',
          fontSize: 13,
          height: 1.5,
          color: AppColors.textColorSecondary,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
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
                  onPressed: () => Navigator.of(ctx).pop(true),
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

    if (confirmed == true && mounted) {
      setState(() => isDeleting = true);
      final success = await controller.deleteCommunication(
        clientId: widget.clientId,
        communicationId: widget.communicationId,
      );
      if (mounted) {
        setState(() => isDeleting = false);
        if (success) {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = detail?.type ?? widget.initialType ?? 'Communication';
    final subject = detail?.subject ?? widget.initialSubject ?? '';
    final commDate = detail?.communicatedAt ?? widget.initialDate;
    final recipient = detail?.recipient ?? widget.initialRecipient ?? '';
    final description = detail?.description ?? widget.initialDescription ?? '';
    final attName = detail?.attachmentName ?? widget.initialAttachmentName;
    final attUrl = detail?.attachmentUrl ?? widget.initialAttachmentUrl;
    final createdBy = detail?.createdBy;

    final typeColor = _getTypeColor(type);
    final typeIcon = _getTypeIcon(type);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.slate200,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(typeIcon, color: typeColor, size: 16),
                      const SizedBox(width: 6),
                      AppText(
                        type,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Iconsax.edit_2, color: AppColors.primaryColor, size: 18),
                  tooltip: 'Edit Communication',
                  onPressed: _onEdit,
                ),
                IconButton(
                  icon: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.errorColor),
                        )
                      : const Icon(Iconsax.trash, color: AppColors.errorColor, size: 18),
                  tooltip: 'Delete Communication',
                  onPressed: isDeleting ? null : _confirmDelete,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textColorHint, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.slate100),

          // Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject
                  AppText(
                    subject.isNotEmpty ? subject : 'Untitled Communication',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                  const SizedBox(height: 12),

                  // Communicated At & Recipient Chips
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (commDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Iconsax.calendar, size: 14, color: AppColors.textColorSecondary),
                              const SizedBox(width: 6),
                              AppText(
                                DateFormat('dd MMM yyyy, hh:mm a').format(commDate),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                      if (recipient.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Iconsax.sms, size: 14, color: AppColors.textColorSecondary),
                              const SizedBox(width: 6),
                              AppText(
                                recipient,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorSecondary,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description card
                  const AppText(
                    'Discussion / Summary',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorSecondary,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: AppText(
                      description.isNotEmpty ? description : 'No description provided.',
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textColorPrimary,
                    ),
                  ),

                  // Attachment Section
                  Builder(
                    builder: (context) {
                      final hasAttachment = (attName != null && attName.trim().isNotEmpty) ||
                          (attUrl != null && attUrl.trim().isNotEmpty);
                      if (!hasAttachment) return const SizedBox.shrink();

                      final displayName = (attName != null && attName.trim().isNotEmpty)
                          ? attName.trim()
                          : (attUrl != null ? attUrl.split('/').last.split('?').first : 'Attachment');
                      final resolvedUrl = (attUrl != null && attUrl.trim().isNotEmpty)
                          ? AppConstants.getFileUrl(attUrl)
                          : null;
                      final ext = displayName.contains('.') ? displayName.split('.').last.toLowerCase() : '';
                      final isImage = ['png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp'].contains(ext) ||
                          (resolvedUrl != null && (
                            resolvedUrl.toLowerCase().contains('.png') ||
                            resolvedUrl.toLowerCase().contains('.jpg') ||
                            resolvedUrl.toLowerCase().contains('.jpeg') ||
                            resolvedUrl.toLowerCase().contains('.webp')
                          ));
                      final isPdf = ext == 'pdf' || (resolvedUrl != null && resolvedUrl.toLowerCase().contains('.pdf'));

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const AppText(
                                'Attachment',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColorSecondary,
                              ),
                              const Spacer(),
                              if (attUrl != null && attUrl.isNotEmpty)
                                InkWell(
                                  onTap: () => _openAttachmentViewer(displayName, attUrl),
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Row(
                                      children: [
                                        AppText(
                                          'Full View',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor,
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.fullscreen_rounded, size: 16, color: AppColors.primaryColor),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Image Attachment with Preview & Zoom View
                          if (isImage && resolvedUrl != null) ...[
                            GestureDetector(
                              onTap: () => _openAttachmentViewer(displayName, attUrl!),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.slate200),
                                  color: AppColors.slate50,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        SizedBox(
                                          height: 180,
                                          width: double.infinity,
                                          child: Image.network(
                                            resolvedUrl,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, progress) {
                                              if (progress == null) return child;
                                              return Container(
                                                height: 180,
                                                color: AppColors.slate100,
                                                child: const Center(
                                                  child: SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: 140,
                                                color: AppColors.slate100,
                                                child: const Center(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.broken_image_rounded, size: 36, color: AppColors.textColorHint),
                                                      SizedBox(height: 6),
                                                      AppText('Failed to preview image', fontSize: 11, color: AppColors.textColorHint),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.65),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.fullscreen_rounded, color: Colors.white, size: 16),
                                                SizedBox(width: 4),
                                                AppText('Tap for Full View', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.image_outlined, size: 18, color: AppColors.primaryColor),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: AppText(
                                              displayName,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textColorPrimary,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const AppText(
                                            'Pinch to Zoom',
                                            fontSize: 11,
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primaryColor),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]
                          // PDF Attachment with Full PDF Viewer
                          else if (isPdf) ...[
                            GestureDetector(
                              onTap: (attUrl != null && attUrl.isNotEmpty)
                                  ? () => _openAttachmentViewer(displayName, attUrl)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 26),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AppText(
                                            displayName,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textColorPrimary,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          const Row(
                                            children: [
                                              AppText(
                                                'PDF Document',
                                                fontSize: 11,
                                                color: Color(0xFFDC2626),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              SizedBox(width: 6),
                                              Expanded(
                                                child: AppText(
                                                  '• Tap to open PDF Viewer',
                                                  fontSize: 11,
                                                  color: AppColors.textColorSecondary,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDC2626),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.visibility_rounded, color: Colors.white, size: 14),
                                          SizedBox(width: 4),
                                          AppText('Open', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]
                          // Generic Document / Other Files
                          else ...[
                            GestureDetector(
                              onTap: (attUrl != null && attUrl.isNotEmpty)
                                  ? () => _openAttachmentViewer(displayName, attUrl)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.slate200),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.description_rounded, color: AppColors.primaryColor, size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AppText(
                                            displayName,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textColorPrimary,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          AppText(
                                            ext.isNotEmpty ? '${ext.toUpperCase()} Document • Tap to open' : 'Tap to open document',
                                            fontSize: 11,
                                            color: AppColors.textColorSecondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textColorHint),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  // Created By / Metadata Section
                  if (createdBy != null || detail?.createdAt != null) ...[
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.slate100),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate100),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
                            child: const Icon(Iconsax.user, size: 16, color: AppColors.primaryColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (createdBy != null && createdBy.name.isNotEmpty)
                                  AppText(
                                    'Logged by ${createdBy.name}',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColorPrimary,
                                  ),
                                if (createdBy != null && createdBy.email.isNotEmpty)
                                  AppText(
                                    createdBy.email,
                                    fontSize: 11,
                                    color: AppColors.textColorSecondary,
                                  ),
                                if (detail?.createdAt != null) ...[
                                  const SizedBox(height: 2),
                                  AppText(
                                    'Created: ${DateFormat('dd MMM yyyy, hh:mm a').format(detail!.createdAt!)}',
                                    fontSize: 10,
                                    color: AppColors.textColorHint,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: isDeleting ? null : _confirmDelete,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    backgroundColor: const Color(0xFFFEF2F2),
                    minimumSize: const Size(46, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.errorColor),
                        )
                      : const Icon(Iconsax.trash, color: AppColors.errorColor, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.slate200),
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const AppText(
                      'Close',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onEdit,
                    icon: const Icon(Iconsax.edit_2, color: Colors.white, size: 16),
                    label: const AppText(
                      'Edit',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 46),
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
  }

  Color _getTypeColor(String type) {
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

  IconData _getTypeIcon(String type) {
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
