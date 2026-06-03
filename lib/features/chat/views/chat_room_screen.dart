import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_models.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final ScrollController scrollController = ScrollController();

    // Auto-scroll timeline to bottom upon launch or list changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });

    // We can observe active messages list and auto-scroll when new messages arrive
    controller.activeMessages.listen((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    final convoId = controller.activeConversationId.value;
    final conversation = controller.conversations.firstWhere((c) => c.id == convoId);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 70,
        leading: Row(
          children: [
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
              onPressed: () => Get.back(),
            ),
          ],
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(conversation.avatarUrl),
              backgroundColor: const Color(0xFFCBD5E1),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    conversation.name,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                  ),
                  const SizedBox(height: 2),
                  Obx(() {
                    final isTyping = controller.isRecipientTyping.value;
                    if (isTyping) {
                      return const AppText(
                        'typing...',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      );
                    }
                    return AppText(
                      conversation.isOnline ? 'Online Now' : 'Offline',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: conversation.isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.video5, color: Color(0xFF2563EB), size: 20),
            onPressed: () => _simulateCallAction('Video Call'),
          ),
          IconButton(
            icon: const Icon(Iconsax.call5, color: Color(0xFF2563EB), size: 18),
            onPressed: () => _simulateCallAction('Audio Call'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Scrollable Messages Timeline ──
          Expanded(
            child: Obx(() {
              final messages = controller.activeMessages;
              return ListView.separated(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: messages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageBubble(message);
                },
              );
            }),
          ),

          // ── Bottom Message Input & Attachments Panel ──
          _buildInputBar(context, controller),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Render media if present
            if (message.mediaType != null) ...[
              _buildMediaPreview(message),
              const SizedBox(height: 6),
            ],

            // Text Content
            if (message.mediaType == null || (message.text.isNotEmpty && !message.text.contains('📷') && !message.text.contains('📄')))
              Text(
                message.text,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isMe ? Colors.white : const Color(0xFF1E293B),
                  height: 1.35,
                  fontFamily: 'Outfit',
                ),
              ),

            const SizedBox(height: 4),

            // Timestamp & Status indicators inside bubble at bottom right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 40), // Push the text over to not overlap
                const Spacer(),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: isMe ? const Color(0xFFDBEAFE) : const Color(0xFF8B96A5),
                    fontFamily: 'Outfit',
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    color: message.isRead ? const Color(0xFF93C5FD) : Colors.white70,
                    size: 12,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(ChatMessage message) {
    if (message.mediaType == 'image') {
      final isNetwork = message.mediaUrl!.startsWith('http') || message.mediaUrl!.startsWith('https');
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isNetwork
            ? Image.network(
                message.mediaUrl!,
                width: 200,
                height: 130,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200,
                    height: 130,
                    color: Colors.black.withValues(alpha: 0.05),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                      ),
                    ),
                  );
                },
              )
            : Image.file(
                File(message.mediaUrl!),
                width: 200,
                height: 130,
                fit: BoxFit.cover,
              ),
      );
    } else if (message.mediaType == 'document') {
      final Color tintColor = const Color(0xFFEF4444); // Crimson for PDF
      final Color boxColor = message.isMe ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9);
      return Container(
        width: 220,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: message.isMe ? const Color(0xFFBFDBFE).withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tintColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.document_text5, color: tintColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.fileSize!,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Iconsax.document_download,
              color: Color(0xFF64748B),
              size: 16,
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }


  Widget _buildInputBar(BuildContext context, ChatController controller) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(top: 8,left: 8,right: 8,bottom: 15),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Emoji button
                    // IconButton(
                    //   icon: const Icon(
                    //     Icons.emoji_emotions_outlined,
                    //     color: Color(0xFF64748B),
                    //     size: 20,
                    //   ),
                    //   onPressed: () => _showEmojiPicker(context, controller),
                    //   constraints: const BoxConstraints(),
                    //   padding: const EdgeInsets.all(6),
                    // ),
                    // const SizedBox(width: 2),

                    // Text Field
                    Expanded(
                      child: TextField(
                        controller: controller.messageInputController,
                        minLines: 1,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: const Color(0xFF2563EB),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),

                    // Paperclip Attachment button
                    IconButton(
                      icon: const Icon(
                        Icons.attach_file_rounded,
                        color: Color(0xFF64748B),
                        size: 18,
                      ),
                      onPressed: () => _showAttachmentSelector(context, controller),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),

                    // Camera button
                    IconButton(
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Color(0xFF64748B),
                        size: 18,
                      ),
                      onPressed: () {
                        controller.sendMediaAttachment('image');
                      },
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send Button
            GestureDetector(
              onTap: controller.sendTextMessage,
              child: Container(
                height: 38,
                width: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker(BuildContext context, ChatController controller) {
    final emojis = [
      '😊', '😂', '❤️', '👍', '🔥', '🙌', '👏', '🎉', '😎', '😮',
      '😢', '😡', '🙏', '✨', '💡', '🚀', '⭐', '✅', '❌', '👀',
      '💬', '💻', '💼', '📱', '🔔', '🌍', '⚡', '☕', '🍕', '🚗'
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const AppText(
              'Select Emoji',
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                final emoji = emojis[index];
                return GestureDetector(
                  onTap: () {
                    final text = controller.messageInputController.text;
                    controller.messageInputController.text = text + emoji;
                    Get.back();
                  },
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAttachmentSelector(BuildContext context, ChatController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const AppText(
              'Share Document / Media',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  'Send Image',
                  Iconsax.image5,
                  const Color(0xFF3B82F6),
                  () {
                    Get.back();
                    controller.sendMediaAttachment('image');
                  },
                ),
                _buildAttachmentOption(
                  'Send PDF',
                  Iconsax.document_text5,
                  const Color(0xFFEF4444),
                  () {
                    Get.back();
                    controller.sendMediaAttachment('document');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          AppText(
            label,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF475569),
          ),
        ],
      ),
    );
  }

  void _simulateCallAction(String type) {
    Get.snackbar(
      'Establishing Connection 📞',
      'Initiating peer-to-peer security protocol for $type.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2563EB),
      colorText: Colors.white,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 16,
    );
  }
}
