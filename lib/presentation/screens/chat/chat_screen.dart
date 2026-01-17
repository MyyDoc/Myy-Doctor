import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/chat_service.dart';
import '../../../data/chat/message_model.dart';
import '../../widgets/chat/chat_bubble_widget.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;           // Required - we pass this from previous screen
  final bool isFromTeleMed;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.isFromTeleMed = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  String? _otherUserId;
  String _otherUserName = "Loading...";
  String _otherUserPhoto = '';
  String _status = "offline";

  @override
  void initState() {
    super.initState();
    _loadChatInfo();
    // Optional: mark as read when opening chat
    _chatService.markChatAsRead(widget.chatId);
  }

  Future<void> _loadChatInfo() async {
    try {
      final otherId = await _chatService.getOtherParticipant(widget.chatId);
      if (otherId == null || otherId.isEmpty) {
        setState(() => _otherUserName = "Unknown");
        return;
      }

      setState(() => _otherUserId = otherId);

      // Get real user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          _otherUserName = data['fullName'] ?? "User";
          _otherUserPhoto = data['profilePicture'] ?? '';
          // You can add lastActive logic later for real status
          _status = "online"; // placeholder
        });
      } else {
        setState(() => _otherUserName = "User not found");
      }
    } catch (e) {
      setState(() => _otherUserName = "Error");
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _chatService.sendTextMessage(
      chatId: widget.chatId,
      text: text,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: animate ? const Duration(milliseconds: 300) : Duration.zero,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFF1F323C),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _otherUserName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "",
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Telemedicine special banner (keep your existing design)
          if (widget.isFromTeleMed)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IntrinsicWidth(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3EBF3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              "I want to book an appointment.\nWhen can I visit the clinic?",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Appointment Request",
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ... keep your cancel button, read status, etc.
                ],
              ),
            ),

          // Real-time messages list
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                final messages = snapshot.data!;

                // Scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom(animate: false);
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  reverse: true, // Important: newest messages at bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;

                    return MessageBubble(
                      message: LocalMessageAdapter(
                        text: message.text,
                        isMe: isMe,
                        time: _formatTimestamp(message.createdAt),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.emoji_emotions_outlined,
                              color: Colors.grey.shade600),
                          onPressed: () {},
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
                          onPressed: () {
                            // TODO: Implement image/file picker later
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF075E54),
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (diff.inHours > 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${diff.inMinutes} min ago';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Simple adapter so you can keep using your existing MessageBubble
class LocalMessageAdapter {
  final String text;
  final bool isMe;
  final String time;

  LocalMessageAdapter({
    required this.text,
    required this.isMe,
    required this.time,
  });
}