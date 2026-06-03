import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/chat_controller.dart';
import 'chat_room_screen.dart';
import 'new_chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller in memory
    final controller = Get.put(ChatController());
    final searchFieldController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          'Chats',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const NewChatScreen()),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 6,
        child: const Icon(Icons.message, color: Colors.white, size: 22),
      ),
      body: Column(
        children: [
          // ── Search & Filter Tabs ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchFieldController,
                        onChanged: (val) => controller.searchQuery.value = val,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          hintText: 'Search chats or messages...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                          prefixIcon: const Icon(Iconsax.search_normal_1, color: Color(0xFF64748B), size: 18),
                          suffixIcon: Obx(() {
                            final q = controller.searchQuery.value;
                            if (q.isEmpty) return const SizedBox();
                            return IconButton(
                              icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 18),
                              onPressed: () {
                                searchFieldController.clear();
                                controller.searchQuery.value = '';
                              },
                            );
                          }),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Horizontal Filter Chips Row
                Obx(() {
                  final activeTab = controller.selectedTab.value;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterTab(controller, 'All', activeTab == 'All'),
                        const SizedBox(width: 8),
                        _buildFilterTab(controller, 'Personal', activeTab == 'Personal'),
                        const SizedBox(width: 8),
                        _buildFilterTab(controller, 'Groups', activeTab == 'Groups'),
                        const SizedBox(width: 8),
                        _buildFilterTab(controller, 'Unread', activeTab == 'Unread'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // ── Scrollable Body ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Conversations List ──
                  // const Padding(
                  //   padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
                  //   child: AppText(
                  //     'Recent Chats',
                  //     fontSize: 13,
                  //     fontWeight: FontWeight.w800,
                  //     color: Color(0xFF475569),
                  //   ),
                  // ),
                  _buildConversationsList(controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(ChatController controller, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.selectedTab.value = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
          ),
        ),
        child: AppText(
          label,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
        ),
      ),
    );
  }


  Widget _buildConversationsList(ChatController controller) {
    return Obx(() {
      final list = controller.filteredConversations;
      if (list.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Iconsax.message_remove, color: Color(0xFF94A3B8), size: 40),
                SizedBox(height: 12),
                AppText('No conversations found.', fontSize: 13, color: Color(0xFF64748B)),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: list.length,
        separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0), height: 1),
        itemBuilder: (context, index) {
          final chat = list[index];
          final timeStr = DateFormat('hh:mm a').format(chat.lastMessageTime);
          final hasUnread = chat.unreadCount > 0;

          return ListTile(
            onTap: () {
              controller.selectConversation(chat.id);
              Get.to(() => const ChatRoomScreen());
            },
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(chat.avatarUrl),
                  backgroundColor: const Color(0xFFCBD5E1),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppText(
                    chat.name,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                AppText(
                  timeStr,
                  fontSize: 9.5,
                  fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                  color: hasUnread ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                        color: hasUnread ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  if (hasUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${chat.unreadCount}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
