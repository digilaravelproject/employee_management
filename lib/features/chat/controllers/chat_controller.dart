import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/chat_models.dart';

class ChatController extends GetxController {
  // --- Active Session Info ---
  final activeConversationId = ''.obs;
  final isRecipientTyping = false.obs;

  // --- Search & Filters ---
  final selectedTab = 'All'.obs; // All, Personal, Groups, Unread
  final searchQuery = ''.obs;

  // --- Active Chat Room Inputs ---
  final messageInputController = TextEditingController();

  // --- Mock Database / States ---
  final conversations = <ChatConversation>[].obs;
  final activeMessages = <ChatMessage>[].obs;

  // Contact list for "New Chat" directory
  final contactsDirectory = <ChatConversation>[];

  // Complete offline message store per conversation ID
  final Map<String, List<ChatMessage>> _messagesStore = {};

  @override
  void onInit() {
    super.onInit();
    _loadMockConversations();
    _loadMockMessagesStore();
  }

  @override
  void onClose() {
    messageInputController.dispose();
    super.onClose();
  }

  // --- Computed stats & filters ---
  List<ChatConversation> get filteredConversations {
    final query = searchQuery.value.trim().toLowerCase();
    final tab = selectedTab.value;

    return conversations.where((chat) {
      final matchesSearch = chat.name.toLowerCase().contains(query) ||
          chat.designation.toLowerCase().contains(query);

      if (!matchesSearch) return false;
      if (tab == 'All') return true;
      if (tab == 'Personal') return !chat.isGroup;
      if (tab == 'Groups') return chat.isGroup;
      // Unread
      return chat.unreadCount > 0;
    }).toList();
  }

  // --- Actions ---

  // Select chat conversation and pull messaging log
  void selectConversation(String conversationId) {
    activeConversationId.value = conversationId;
    
    // Clear unread count for that conversation
    final index = conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      conversations[index] = conversations[index].copyWith(unreadCount: 0);
    }

    // Load matching messages
    activeMessages.assignAll(_messagesStore[conversationId] ?? []);
  }

  // Send message
  void sendTextMessage() {
    final text = messageInputController.text.trim();
    if (text.isEmpty) return;

    messageInputController.clear();
    
    _executeMessageSend(
      text: text,
      mediaType: null,
    );
  }

  // Send media attachments by picking actual files from the system
  Future<void> sendMediaAttachment(String mediaType) async {
    if (mediaType == 'image') {
      try {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image == null) return;

        final File file = File(image.path);
        final int sizeInBytes = await file.length();
        final double sizeInMb = sizeInBytes / (1024 * 1024);
        final String sizeStr = '${sizeInMb.toStringAsFixed(1)} MB';
        final String name = image.name;

        _executeMessageSend(
          text: '📷 Photo',
          mediaType: 'image',
          fileName: name,
          fileSize: sizeStr,
          mediaUrl: image.path, // Store local filepath
        );
      } catch (e) {
        Get.snackbar(
          'Error picking image',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
      }
    } else if (mediaType == 'document') {
      try {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        if (result == null || result.files.isEmpty) return;

        final PlatformFile pickedFile = result.files.first;
        if (pickedFile.path == null) return;

        final double sizeInMb = pickedFile.size / (1024 * 1024);
        final String sizeStr = '${sizeInMb.toStringAsFixed(1)} MB';
        final String name = pickedFile.name;

        _executeMessageSend(
          text: '📄 Document',
          mediaType: 'document',
          fileName: name,
          fileSize: sizeStr,
          mediaUrl: pickedFile.path, // Store local filepath
        );
      } catch (e) {
        Get.snackbar(
          'Error picking document',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
      }
    }
  }

  // Internal orchestrator for sending messages
  void _executeMessageSend({
    required String text,
    String? mediaType,
    String? fileName,
    String? fileSize,
    String? mediaUrl,
  }) {
    final convoId = activeConversationId.value;
    if (convoId.isEmpty) return;

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'Admin',
      senderAvatar: '',
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
      mediaType: mediaType,
      fileName: fileName,
      fileSize: fileSize,
      mediaUrl: mediaUrl,
    );

    // Append to live timeline
    activeMessages.add(newMessage);

    // Append to persistent store
    if (!_messagesStore.containsKey(convoId)) {
      _messagesStore[convoId] = [];
    }
    _messagesStore[convoId]!.add(newMessage);

    // Update conversation last message preview
    final idx = conversations.indexWhere((c) => c.id == convoId);
    if (idx != -1) {
      conversations[idx] = conversations[idx].copyWith(
        lastMessage: text,
        lastMessageTime: DateTime.now(),
      );
    }

    // Trigger auto responder simulated socket reply
    _simulateLiveResponse(convoId, text);
  }

  // Simulated WebSocket/Firebase live auto responder
  Future<void> _simulateLiveResponse(String convoId, String userMessage) async {
    // Find active contact details
    final convo = conversations.firstWhere((c) => c.id == convoId);
    final responderName = convo.name;
    final responderAvatar = convo.avatarUrl;

    // Split delay before typing indicator shows (simulating network check)
    await Future.delayed(const Duration(milliseconds: 600));

    // Show typing indicator in the appBar
    if (activeConversationId.value == convoId) {
      isRecipientTyping.value = true;
    }

    // Simulated typing duration lag
    await Future.delayed(const Duration(milliseconds: 1600));

    // Hide typing indicator
    isRecipientTyping.value = false;

    // Pick contextual response
    final responseText = _getContextualReply(userMessage, responderName);

    final replyMessage = ChatMessage(
      id: 'msg_reply_${DateTime.now().millisecondsSinceEpoch}',
      senderId: convoId,
      senderName: responderName,
      senderAvatar: responderAvatar,
      text: responseText,
      timestamp: DateTime.now(),
      isMe: false,
    );

    // Persist reply in database store
    if (!_messagesStore.containsKey(convoId)) {
      _messagesStore[convoId] = [];
    }
    _messagesStore[convoId]!.add(replyMessage);

    // If currently looking at this active conversation, render immediately
    if (activeConversationId.value == convoId) {
      activeMessages.add(replyMessage);
    } else {
      // If looking at another screen, increment unread badge
      final idx = conversations.indexWhere((c) => c.id == convoId);
      if (idx != -1) {
        conversations[idx] = conversations[idx].copyWith(
          unreadCount: conversations[idx].unreadCount + 1,
        );
      }
    }

    // Update last message preview
    final idx = conversations.indexWhere((c) => c.id == convoId);
    if (idx != -1) {
      conversations[idx] = conversations[idx].copyWith(
        lastMessage: responseText,
        lastMessageTime: DateTime.now(),
      );
    }

    // Dispatch message notification overlay if user is outside this chat room
    if (activeConversationId.value != convoId) {
      Get.snackbar(
        'New Message from $responderName 💬',
        responseText,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: const Color(0xFF1E293B),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
        margin: const EdgeInsets.all(12),
        borderRadius: 16,
        duration: const Duration(seconds: 3),
        icon: CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(responderAvatar),
        ),
      );
    }
  }

  // Pick response depending on user keywords
  String _getContextualReply(String inputMsg, String senderName) {
    final msg = inputMsg.toLowerCase();
    
    if (msg.contains('policy') || msg.contains('compliance')) {
      return 'Yes Admin, I reviewed the new company policies document. Preparing to submit acknowledgement now!';
    }
    if (msg.contains('project') || msg.contains('dev') || msg.contains('code') || msg.contains('hotfix')) {
      return 'The latest dev branch commits are verified. Testing all routes locally. Pushing to staging in a bit!';
    }
    if (msg.contains('leave') || msg.contains('vacation') || msg.contains('sick')) {
      return 'I submitted Ritesh\'s sick leave requests in the leave management screen. Please review them when free.';
    }
    if (msg.contains('salary') || msg.contains('payroll') || msg.contains('payslip')) {
      return 'Checking my Payslip history now! Everything looks clear on my dashboard. Thanks for the quick payroll!';
    }
    if (msg.contains('hello') || msg.contains('hi') || msg.contains('hey')) {
      return 'Hey Admin! 👋 How can I help you today?';
    }
    if (msg.contains('📷') || msg.contains('📄') || msg.contains('🎵')) {
      return 'Thanks for sharing the media attachments! I am reviewing the documents right away.';
    }

    return 'Perfect! I got your message, Admin. I will keep you updated on my task milestones.';
  }

  // --- Mock Database Prep ---
  void _loadMockConversations() {
    conversations.assignAll([
      ChatConversation(
        id: '1',
        name: 'Rahul Sharma',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        designation: 'Developer',
        lastMessage: 'The hotfix testing is complete. Ready to deploy!',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        isOnline: true,
      ),
      ChatConversation(
        id: '2',
        name: 'Dev Sync Group 🚀',
        avatarUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=150',
        designation: 'Group Chat',
        lastMessage: 'Neha: I uploaded the new interface mockups.',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 20)),
        isGroup: true,
        unreadCount: 0,
      ),
      ChatConversation(
        id: '3',
        name: 'Amit Singh',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        designation: 'Team Lead',
        lastMessage: 'Got it. I will approve the holiday request.',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        isOnline: true,
      ),
      ChatConversation(
        id: '4',
        name: 'HR Broadcast 📢',
        avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
        designation: 'Official Channel',
        lastMessage: 'Compliance alert: Acknowledge POSH policy.',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        isGroup: true,
        unreadCount: 1,
      ),
      ChatConversation(
        id: '5',
        name: 'Neha Kapoor',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        designation: 'UI Designer',
        lastMessage: 'Can you check the dashboard margins?',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
        isOnline: false,
      ),
    ]);

    // All available employee contact list for starting new chats
    contactsDirectory.addAll([
      ChatConversation(
        id: '1',
        name: 'Rahul Sharma',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        designation: 'Developer',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      ),
      ChatConversation(
        id: '3',
        name: 'Amit Singh',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        designation: 'Team Lead',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      ),
      ChatConversation(
        id: '5',
        name: 'Neha Kapoor',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        designation: 'UI Designer',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      ),
      ChatConversation(
        id: '6',
        name: 'Pooja Mehta',
        avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
        designation: 'HR Executive',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      ),
      ChatConversation(
        id: '7',
        name: 'Vikas Yadav',
        avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
        designation: 'Sales Executive',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      ),
      ChatConversation(
        id: '8',
        name: 'Sneha Patel',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        designation: 'Accountant',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      ),
    ]);
  }

  void _loadMockMessagesStore() {
    _messagesStore['1'] = [
      ChatMessage(
        id: 'm1_1',
        senderId: '1',
        senderName: 'Rahul Sharma',
        senderAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        text: 'Hey Admin, did we review the latest leave requests for the engineering team?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isMe: false,
      ),
      ChatMessage(
        id: 'm1_2',
        senderId: 'me',
        senderName: 'Admin',
        senderAvatar: '',
        text: 'Yes Rahul, I saw them. Ritesh has 2 sick leaves pending which I will process.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isMe: true,
      ),
      ChatMessage(
        id: 'm1_3',
        senderId: '1',
        senderName: 'Rahul Sharma',
        senderAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        text: 'Perfect! Also, the hotfix testing is complete. Ready to deploy!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isMe: false,
      ),
    ];

    _messagesStore['2'] = [
      ChatMessage(
        id: 'm2_1',
        senderId: '3',
        senderName: 'Amit Singh',
        senderAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        text: 'Team, the calendar sync has been configured. Let\'s verify all holiday entries.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isMe: false,
      ),
      ChatMessage(
        id: 'm2_2',
        senderId: '5',
        senderName: 'Neha Kapoor',
        senderAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        text: 'I uploaded the new interface mockups for the Compliance and Policy panels.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        isMe: false,
      ),
    ];

    _messagesStore['3'] = [
      ChatMessage(
        id: 'm3_1',
        senderId: 'me',
        senderName: 'Admin',
        senderAvatar: '',
        text: 'Hi Amit, did we schedule the shifts for June?',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isMe: true,
      ),
      ChatMessage(
        id: 'm3_2',
        senderId: '3',
        senderName: 'Amit Singh',
        senderAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        text: 'Got it. I will approve the holiday request and finalize the shift schedules.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isMe: false,
      ),
    ];

    _messagesStore['4'] = [
      ChatMessage(
        id: 'm4_1',
        senderId: 'hr',
        senderName: 'HR Admin',
        senderAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
        text: 'Compliance alert: Acknowledge the POSH and Leave policies inside the brand new Policy module dashboard.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isMe: false,
      ),
    ];

    _messagesStore['5'] = [
      ChatMessage(
        id: 'm5_1',
        senderId: '5',
        senderName: 'Neha Kapoor',
        senderAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        text: 'Can you check the dashboard margins? They seem a bit tight on smaller mobile devices.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isMe: false,
      ),
    ];
  }
}
