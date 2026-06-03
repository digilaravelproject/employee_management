import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/chat_controller.dart';
import 'chat_room_screen.dart';

class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final searchController = TextEditingController();
    final searchQuery = ''.obs;

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Select Contact',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Deck
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) => searchQuery.value = val,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      hintText: 'Search contacts by name or designation...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5, fontWeight: FontWeight.w500),
                      prefixIcon: const Icon(Iconsax.search_normal_1, color: Color(0xFF64748B), size: 18),
                      suffixIcon: Obx(() {
                        final q = searchQuery.value;
                        if (q.isEmpty) return const SizedBox();
                        return IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 18),
                          onPressed: () {
                            searchController.clear();
                            searchQuery.value = '';
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
                        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contacts List
          Expanded(
            child: Obx(() {
              final query = searchQuery.value.trim().toLowerCase();
              final contacts = controller.contactsDirectory.where((c) {
                return c.name.toLowerCase().contains(query) ||
                    c.designation.toLowerCase().contains(query);
              }).toList();

              if (contacts.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.profile_remove, color: Color(0xFF94A3B8), size: 40),
                      SizedBox(height: 12),
                      AppText('No matching employee contacts found.', fontSize: 13, color: Color(0xFF64748B)),
                    ],
                  ),
                );
              }

              return Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFEEF2FF)),
                ),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: contacts.length,
                  separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 16),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];

                    return ListTile(
                      onTap: () {
                        controller.selectConversation(contact.id);
                        // Swap New Chat screen with Chat Room screen directly
                        Get.off(() => const ChatRoomScreen());
                      },
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(contact.avatarUrl),
                        backgroundColor: const Color(0xFFCBD5E1),
                      ),
                      title: AppText(
                        contact.name,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: AppText(
                          contact.designation,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF94A3B8),
                        size: 14,
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
