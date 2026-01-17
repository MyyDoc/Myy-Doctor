import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/chat_service.dart'; // adjust path
import '../../../data/chat/chat_model.dart';       // your ChatRoom model
import '../../widgets/chat/call_list_widget.dart';
import '../../widgets/chat/chat_list_widget.dart'; // if you want to keep custom tile
import '../../widgets/home/story_circle.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool searchClicked = false;
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F323C),
        title: Text(
          "Messages",
          style: textTheme.headlineMedium!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (searchClicked)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => setState(() => searchClicked = false),
            )
          else
            IconButton(
              padding: const EdgeInsets.only(right: 15),
              icon: const Icon(Icons.search, color: Colors.white, size: 30),
              onPressed: () => setState(() => searchClicked = true),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: const Color(0xFF1F323C),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.grey,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(icon: Icon(Icons.chat_bubble_outline)),
                Tab(icon: Icon(Icons.groups_outlined)),
                Tab(icon: Icon(Icons.call_outlined)),
              ],
            ),
          ),

          // Search bar (keep your design)
          if (searchClicked)
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 215, 176, 85),
                        Colors.grey.shade300,
                        Color.fromARGB(255, 215, 176, 85),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'SEARCH MESSAGES',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
            ),

          // Visitors / recent stories (optional - you can keep or remove)
          if (searchClicked)
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Text("Visitors", style: textTheme.titleMedium),
            ),
          if (searchClicked)
            SizedBox(
              height: 130,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: 8, // ← can be dynamic later
                itemBuilder: (_, index) => StoryCircleItem(
                  isFromProfile: false,
                  textTheme: textTheme,
                  index: 0,
                ),
              ),
            ),

          // Real chat list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Chats Tab - REAL DATA
                StreamBuilder<List<ChatRoom>>(
                  stream: _chatService.getUserChats(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No conversations yet"));
                    }

                    final chats = snapshot.data!;

                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chatRoom = chats[index];
                        return FutureBuilder<Map<String, dynamic>>(
                          future: _getOtherUserInfo(chatRoom),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return const ListTile(
                                leading: CircleAvatar(),
                                title: Text("Loading..."),
                              );
                            }

                            final userData = userSnapshot.data!;
                            final lastMsg = chatRoom.lastMessage;
                            final isUnread = false; // TODO: implement real unread count

                            return ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: userData['photo'] != null
                                    ? NetworkImage(userData['photo'])
                                    : null,
                                child: userData['photo'] == null
                                    ? Text(userData['initial'] ?? '?')
                                    : null,
                              ),
                              title: Text(
                                userData['name'] ?? 'Unknown',
                                style: TextStyle(
                                  color: userData['isDoctor'] == true
                                      ? const Color(0xFFD4AF37)
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                lastMsg?['text'] ?? 'Start a conversation',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (chatRoom.lastMessageTime != null)
                                    Text(
                                      _formatTime(chatRoom.lastMessageTime!.toDate()),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),

                                  StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('chats')
                                        .doc(chatRoom.id)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return const SizedBox.shrink();

                                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                                      final unreadMap = data?['unreadCount'] as Map<String, dynamic>?;
                                      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                                      final unread = (unreadMap?[currentUid] as num?)?.toInt() ?? 0;

                                      return AnimatedOpacity(
                                        opacity: unread > 0 ? 1.0 : 0.0,
                                        duration: const Duration(milliseconds: 400),
                                        child: Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF25D366),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      chatId: chatRoom.id,
                                      isFromTeleMed: false, // or detect based on context
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                // Groups Tab
                const Center(child: Text("Groups feature coming soon")),

                // Calls Tab
                CallsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fetch other user's name, photo, etc.
  Future<Map<String, dynamic>> _getOtherUserInfo(ChatRoom chatRoom) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final otherId = chatRoom.participants.firstWhere((id) => id != currentUid, orElse: () => '');

    if (otherId.isEmpty) return {'name': 'Unknown', 'initial': '?'};

    final doc = await FirebaseFirestore.instance.collection('users').doc(otherId).get();
    if (!doc.exists) return {'name': 'User', 'initial': '?'};

    final data = doc.data()!;
    return {
      'name': data['fullName'] ?? 'User',
      'photo': data['profilePicture'],
      'initial': (data['fullName'] as String?)?.substring(0, 1).toUpperCase(),
      'isDoctor': data['isDoctor'] == true,
    };
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 6) {
      return '${time.day}/${time.month}';
    } else if (diff.inDays > 0) {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][time.weekday - 1];
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}