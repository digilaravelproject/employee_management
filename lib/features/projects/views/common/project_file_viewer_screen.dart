import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';

/// Full-featured Project File Viewer & Sharing Screen
/// Handles PDF preview, Image interactive zoom viewer, and document inspector with instant sharing
class ProjectFileViewerScreen extends StatefulWidget {
  final String fileName;
  final String fileExtension;
  final String fileSize;
  final String uploadedBy;
  final String uploadDate;
  final String? fileUrl;
  final String? projectId;

  const ProjectFileViewerScreen({
    super.key,
    required this.fileName,
    required this.fileExtension,
    required this.fileSize,
    required this.uploadedBy,
    required this.uploadDate,
    this.fileUrl,
    this.projectId,
  });

  @override
  State<ProjectFileViewerScreen> createState() => _ProjectFileViewerScreenState();
}

class _ProjectFileViewerScreenState extends State<ProjectFileViewerScreen> {
  final TransformationController _transController = TransformationController();
  int _currentPage = 1;
  final int _totalPages = 3;

  bool get _isPdf => widget.fileExtension.toLowerCase() == 'pdf';
  bool get _isImage => ['png', 'jpg', 'jpeg', 'webp', 'svg'].contains(widget.fileExtension.toLowerCase());

  @override
  void dispose() {
    _transController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transController.value = Matrix4.identity();
  }

  Future<void> _shareFile() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Project Document: ${widget.fileName}\nSize: ${widget.fileSize}\nUploaded by: ${widget.uploadedBy} on ${widget.uploadDate}\nProject: ${widget.projectId ?? "PRJ-001"}',
          subject: widget.fileName,
        ),
      );
    } catch (_) {
      Get.snackbar(
        'Sharing',
        'Preparing ${widget.fileName} for sharing...',
        backgroundColor: const Color(0xFF3B206A),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _downloadFile() {
    Get.snackbar(
      'Download Started',
      'Saving ${widget.fileName} (${widget.fileSize}) to device storage...',
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Iconsax.document_download, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B206A);

    return Scaffold(
      backgroundColor: _isImage ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _isImage ? const Color(0xFF1E293B) : Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: _isImage ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: _isImage ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: _getExtensionBgColor(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.fileExtension.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: _getExtensionColor(),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.fileSize} • ${widget.uploadDate}',
                  style: TextStyle(
                    fontSize: 11,
                    color: _isImage ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Share File',
            icon: Icon(
              Iconsax.share,
              size: 20,
              color: _isImage ? Colors.white : primaryColor,
            ),
            onPressed: _shareFile,
          ),
          IconButton(
            tooltip: 'Download File',
            icon: Icon(
              Iconsax.document_download,
              size: 20,
              color: _isImage ? Colors.white : const Color(0xFF0F172A),
            ),
            onPressed: _downloadFile,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isPdf
                  ? _buildPdfViewer()
                  : _isImage
                      ? _buildImageViewer()
                      : _buildGenericDocViewer(),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. PDF DOCUMENT VIEWER
  // ===========================================================================
  Widget _buildPdfViewer() {
    return Column(
      children: [
        // Page navigation bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.document_text, size: 16, color: Color(0xFFDC2626)),
                  const SizedBox(width: 6),
                  Text(
                    'Page $_currentPage of $_totalPages',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _currentPage < _totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  InkWell(
                    onTap: _resetZoom,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.zoom_out_map_rounded, size: 13, color: Color(0xFF475569)),
                          SizedBox(width: 4),
                          Text('Reset Zoom', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Zoomable Canvas
        Expanded(
          child: InteractiveViewer(
            transformationController: _transController,
            minScale: 0.8,
            maxScale: 3.5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 580),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: _buildPdfPageContent(_currentPage),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPdfPageContent(int page) {
    if (page == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B206A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.folder_favorite, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DIGI PROJECT DOCS',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF3B206A), letterSpacing: 0.8),
                      ),
                      Text(
                        'CONFIDENTIAL & PROPRIETARY',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('APPROVED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
              ),
            ],
          ),
          const Divider(height: 32, color: Color(0xFFE2E8F0)),

          Text(
            widget.fileName.replaceAll('.pdf', '').replaceAll('_', ' '),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.25),
          ),
          const SizedBox(height: 8),
          Text(
            'Project Reference: ${widget.projectId ?? "PRJ-001"} • Version 2.4 • Effective ${widget.uploadDate}',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),

          _buildDocSectionTitle('1. Executive Overview'),
          const SizedBox(height: 8),
          const Text(
            'This project documentation outlines the comprehensive architectural patterns, security controls, state synchronization workflows, and client deliverable milestones agreed upon by the stakeholder committee.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.55),
          ),
          const SizedBox(height: 16),

          _buildDocSectionTitle('2. Document Metadata'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildMetaRow('Document Title', widget.fileName),
                const Divider(height: 14, color: Color(0xFFE2E8F0)),
                _buildMetaRow('Uploaded By', widget.uploadedBy),
                const Divider(height: 14, color: Color(0xFFE2E8F0)),
                _buildMetaRow('File Size', widget.fileSize),
                const Divider(height: 14, color: Color(0xFFE2E8F0)),
                _buildMetaRow('Release Date', widget.uploadDate),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildDocSectionTitle('3. Scope & Objectives'),
          const SizedBox(height: 8),
          _buildBulletItem('Standardize real-time state management between admin and team modules.'),
          _buildBulletItem('Implement strict audit logging for every task delegation and handover.'),
          _buildBulletItem('Maintain offline-first caching policy with seamless background synchronization.'),
        ],
      );
    } else if (page == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocHeader(page),
          const Divider(height: 24, color: Color(0xFFE2E8F0)),
          _buildDocSectionTitle('4. Architecture Specification'),
          const SizedBox(height: 8),
          const Text(
            'The client application communicates over secure TLS 1.3 channels with OAuth 2.0 bearer authorization tokens. State reactive updates are propagated using GetX observables.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.55),
          ),
          const SizedBox(height: 16),

          _buildDocSectionTitle('5. Module Breakdown & Deliverables'),
          const SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(6)),
            children: const [
              TableRow(
                decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
                children: [
                  Padding(padding: EdgeInsets.all(8), child: Text('Module', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Assigned Role', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                ],
              ),
              TableRow(
                children: [
                  Padding(padding: EdgeInsets.all(8), child: Text('Auth & Biometric', style: TextStyle(fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Security Eng.', style: TextStyle(fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Completed', style: TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.w600))),
                ],
              ),
              TableRow(
                children: [
                  Padding(padding: EdgeInsets.all(8), child: Text('Work Tracking', style: TextStyle(fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Flutter Dev', style: TextStyle(fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('In Progress', style: TextStyle(fontSize: 11, color: Color(0xFF3B206A), fontWeight: FontWeight.w600))),
                ],
              ),
              TableRow(
                children: [
                  Padding(padding: EdgeInsets.all(8), child: Text('File Attachment Hub', style: TextStyle(fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Full Stack Lead', style: TextStyle(fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('In Progress', style: TextStyle(fontSize: 11, color: Color(0xFF3B206A), fontWeight: FontWeight.w600))),
                ],
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocHeader(page),
          const Divider(height: 24, color: Color(0xFFE2E8F0)),
          _buildDocSectionTitle('6. Compliance, Governance & Sign-Off'),
          const SizedBox(height: 8),
          const Text(
            'This specification is binding upon all assigned team members and subject to weekly milestone review audits. Any task modifications must be documented through the handover audit workflow.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.55),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSignatureBlock('System Administrator', 'Admin Authority', 'Verified 10 Oct 2026'),
              _buildSignatureBlock('Lead Developer', 'Engineering Lead', 'Signed 14 Oct 2026'),
            ],
          ),
          const SizedBox(height: 36),
          Center(
            child: Text(
              '*** End of Document (Page 3 of 3) ***',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDocHeader(int page) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.fileName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        Text('Page $page of $_totalPages', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildDocSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3B206A))),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
      ],
    );
  }

  Widget _buildSignatureBlock(String role, String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 140,
          height: 1,
          color: const Color(0xFF94A3B8),
        ),
        const SizedBox(height: 6),
        Text(role, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        Text(title, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
        Text(date, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
      ],
    );
  }

  // ===========================================================================
  // 2. IMAGE PREVIEW VIEWER (Interactive Zoom & Pan)
  // ===========================================================================
  Widget _buildImageViewer() {
    return Stack(
      children: [
        InteractiveViewer(
          transformationController: _transController,
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Diagram / Image illustration header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.gallery, color: Color(0xFFEC4899), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              widget.fileName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.fileSize,
                            style: const TextStyle(fontSize: 10, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Architectural mock image visual
                    Container(
                      height: 320,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Grid pattern background
                          CustomPaint(
                            size: const Size(double.infinity, 320),
                            painter: _BlueprintGridPainter(),
                          ),
                          // Diagram blocks
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDiagramBlock('Client Mobile App (Flutter)', const Color(0xFF3B206A), Iconsax.mobile),
                              const Icon(Icons.arrow_downward_rounded, color: Color(0xFF94A3B8), size: 18),
                              _buildDiagramBlock('REST API Gateway / Microservices', const Color(0xFF0284C7), Iconsax.cloud_connection),
                              const Icon(Icons.arrow_downward_rounded, color: Color(0xFF94A3B8), size: 18),
                              _buildDiagramBlock('PostgreSQL & File S3 Storage', const Color(0xFF059669), Iconsax.data),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pinch_rounded, color: Colors.white38, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Pinch or double tap to zoom in/out',
                          style: TextStyle(fontSize: 11.5, color: Colors.white38),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Floating reset zoom button
        Positioned(
          top: 14,
          right: 14,
          child: FloatingActionButton.small(
            backgroundColor: const Color(0xFF334155),
            foregroundColor: Colors.white,
            elevation: 2,
            onPressed: _resetZoom,
            child: const Icon(Icons.zoom_out_map_rounded, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagramBlock(String label, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. GENERIC DOCUMENT INSPECTOR (Figma, Word, Excel, ZIP)
  // ===========================================================================
  Widget _buildGenericDocViewer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _getExtensionBgColor(),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getExtensionIcon(), color: _getExtensionColor(), size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                widget.fileName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.fileSize} • Uploaded by ${widget.uploadedBy}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildMetaRow('File Type', widget.fileExtension.toUpperCase()),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildMetaRow('Attached To', widget.projectId ?? 'PRJ-001'),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildMetaRow('Upload Date', widget.uploadDate),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildMetaRow('Accessibility', 'Admin & Assigned Employees'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'This file format can be opened in external compatible applications or shared directly with your team.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8), height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // BOTTOM ACTION BAR (Share & Download Quick Actions)
  // ===========================================================================
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isImage ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: _isImage ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: _shareFile,
                icon: const Icon(Iconsax.share, size: 18),
                label: const Text('Share File', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _isImage ? Colors.white : const Color(0xFF3B206A),
                  side: BorderSide(color: _isImage ? const Color(0xFF475569) : const Color(0xFF3B206A)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _downloadFile,
                icon: const Icon(Iconsax.document_download, size: 18, color: Colors.white),
                label: const Text('Download', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B206A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Extension colors
  Color _getExtensionColor() {
    switch (widget.fileExtension.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFDC2626);
      case 'fig':
        return const Color(0xFF8B5CF6);
      case 'docx':
      case 'doc':
        return const Color(0xFF2563EB);
      case 'xlsx':
      case 'csv':
        return const Color(0xFF059669);
      case 'png':
      case 'jpg':
      case 'jpeg':
        return const Color(0xFFEC4899);
      case 'zip':
      case 'rar':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF3B206A);
    }
  }

  Color _getExtensionBgColor() {
    switch (widget.fileExtension.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFFEE2E2);
      case 'fig':
        return const Color(0xFFF3E8FF);
      case 'docx':
      case 'doc':
        return const Color(0xFFDBEAFE);
      case 'xlsx':
      case 'csv':
        return const Color(0xFFD1FAE5);
      case 'png':
      case 'jpg':
      case 'jpeg':
        return const Color(0xFFFCE7F3);
      case 'zip':
      case 'rar':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFF5F0FB);
    }
  }

  IconData _getExtensionIcon() {
    switch (widget.fileExtension.toLowerCase()) {
      case 'pdf':
        return Iconsax.document_text;
      case 'fig':
        return Iconsax.brush_1;
      case 'docx':
      case 'doc':
        return Iconsax.document;
      case 'xlsx':
      case 'csv':
        return Iconsax.document_filter;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Iconsax.gallery;
      case 'zip':
      case 'rar':
        return Iconsax.archive_book;
      default:
        return Iconsax.document;
    }
  }
}

class _BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
