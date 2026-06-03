import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/documents_controller.dart';
import '../models/document_model.dart';
import 'access_control_screen.dart';
import 'document_preview_screen.dart';

class DocumentDetailsScreen extends StatefulWidget {
  final AppDocument document;
  final int initialTab;

  const DocumentDetailsScreen({
    super.key,
    required this.document,
    this.initialTab = 0,
  });

  @override
  State<DocumentDetailsScreen> createState() => _DocumentDetailsScreenState();
}

class _DocumentDetailsScreenState extends State<DocumentDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();
    final iconColor = _getIconColor(widget.document.type);
    final iconData = _getIconData(widget.document.type);

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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textColorPrimary,
                size: 18,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Document Details',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textColorPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header File Card ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(iconData, color: iconColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: AppText(
                                widget.document.name,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textColorPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const AppText(
                                'Active',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          '${widget.document.size} • ${widget.document.status}',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorSecondary,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          'Uploaded by ${widget.document.uploadedBy} • ${widget.document.uploadedDate}',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColorHint,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab Bar ──
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF3B82F6),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: const Color(0xFF3B82F6),
                unselectedLabelColor: AppColors.textColorHint,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Access'),
                  Tab(text: 'Versions'),
                  Tab(text: 'Activity'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Tab Content ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDetailsTab(),
                  _buildAccessTab(controller),
                  _buildVersionsTab(controller),
                  _buildActivityTab(controller),
                ],
              ),
            ),

            // ── Bottom Action Row ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildBottomBtn(
                    icon: Iconsax.eye,
                    label: 'Preview',
                    color: const Color(0xFF4F46E5),
                    onTap: () => Get.to(() => DocumentPreviewScreen(fileName: widget.document.name)),
                  ),
                  const SizedBox(width: 8),
                  _buildBottomBtn(
                    icon: Iconsax.document_download,
                    label: 'Download',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Get.snackbar(
                        'Downloading...',
                        'Started downloading "${widget.document.name}"',
                        backgroundColor: AppColors.successColor,
                        colorText: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildBottomBtn(
                    icon: Iconsax.share,
                    label: 'Share',
                    color: const Color(0xFFF97316),
                    onTap: () {
                      Get.snackbar(
                        'Share Engine',
                        'Preparing highly-secure external share link...',
                        backgroundColor: const Color(0xFF1E293B),
                        colorText: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textColorSecondary),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEEF2FF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetaRow(Iconsax.folder, 'Folder', widget.document.folderName),
            const Divider(height: 24, color: AppColors.borderColor),
            _buildMetaRow(Iconsax.document, 'File Type', widget.document.type.toUpperCase()),
            const Divider(height: 24, color: AppColors.borderColor),
            _buildMetaRow(Iconsax.weight, 'File Size', widget.document.size),
            const Divider(height: 24, color: AppColors.borderColor),
            _buildMetaRow(Iconsax.calendar, 'Created On', widget.document.uploadedDate),
            const Divider(height: 24, color: AppColors.borderColor),
            _buildMetaRow(Iconsax.clock, 'Last Modified', widget.document.lastModified),
            const Divider(height: 24, color: AppColors.borderColor),
            
            const AppText(
              'Description',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 8),
            AppText(
              widget.document.description,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textColorHint, size: 18),
        const SizedBox(width: 12),
        AppText(
          label,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textColorSecondary,
        ),
        const Spacer(),
        AppText(
          value,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorPrimary,
        ),
      ],
    );
  }

  Widget _buildAccessTab(DocumentsController controller) {
    return Obx(() {
      final list = controller.activeAccessList;
      final isAdmin = controller.isAdminView.value;

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Who has access',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textColorPrimary,
                ),
                if (isAdmin)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: const Color(0xFFEFF6FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Iconsax.user_add, size: 14, color: Color(0xFF3B82F6)),
                    label: const AppText('Add People', fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF3B82F6)),
                    onPressed: () {
                      Get.to(() => AccessControlScreen(fileName: widget.document.name));
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEEF2FF)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderColor),
                itemBuilder: (context, index) {
                  final access = list[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getAccessTypeColor(access.type).withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getAccessTypeIcon(access.type),
                            color: _getAccessTypeColor(access.type),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                access.name,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textColorPrimary,
                              ),
                              const SizedBox(height: 3),
                              AppText(
                                access.details,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColorHint,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: access.role.toLowerCase() == 'editor' 
                              ? const Color(0xFFFEF2F2) 
                              : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: AppText(
                            access.role,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: access.role.toLowerCase() == 'editor' 
                              ? const Color(0xFFEF4444) 
                              : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVersionsTab(DocumentsController controller) {
    return Obx(() {
      final list = controller.versionsList;

      return ListView.separated(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ver = list[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEEF2FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        ver.version,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    AppText(
                      ver.updatedDate,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColorHint,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppText(
                  'Uploaded by ${ver.updatedBy}',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColorSecondary,
                ),
                const SizedBox(height: 6),
                AppText(
                  ver.changeLog,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColorSecondary,
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildActivityTab(DocumentsController controller) {
    return Obx(() {
      final list = controller.activityList;

      return ListView.separated(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final act = list[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Node Line & Dot
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getActivityColor(act.iconType),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index != list.length - 1)
                    Container(
                      width: 2,
                      height: 50,
                      color: AppColors.borderColor,
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Activity Detail Box
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      act.activity,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textColorPrimary,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      'Action by ${act.user}',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      act.timestamp,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColorHint,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildBottomBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 46,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.08),
            foregroundColor: color,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: EdgeInsets.zero,
          ),
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              AppText(label, fontSize: 12, fontWeight: FontWeight.w800, color: color),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Iconsax.document_text5;
      case 'xlsx':
      case 'xls':
        return Iconsax.document_text;
      case 'docx':
      case 'doc':
        return Iconsax.document;
      case 'zip':
      case 'rar':
        return Iconsax.folder;
      default:
        return Iconsax.document_text;
    }
  }

  Color _getIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFEF4444);
      case 'xlsx':
      case 'xls':
        return const Color(0xFF10B981);
      case 'docx':
      case 'doc':
        return const Color(0xFF3B82F6);
      case 'zip':
      case 'rar':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getAccessTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'group':
        return Iconsax.people;
      case 'department':
        return Iconsax.briefcase;
      case 'individual':
      default:
        return Iconsax.user;
    }
  }

  Color _getAccessTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'group':
        return const Color(0xFF3B82F6);
      case 'department':
        return const Color(0xFF8B5CF6);
      case 'individual':
      default:
        return const Color(0xFF10B981);
    }
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'share':
        return const Color(0xFFF97316);
      case 'update':
        return const Color(0xFF3B82F6);
      case 'download':
        return const Color(0xFF10B981);
      case 'view':
      default:
        return const Color(0xFF64748B);
    }
  }
}

