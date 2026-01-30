import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/loader/loader.dart';
import '../../../core/services/chat_service.dart';
import '../../../data/chat/chat_model.dart';
import '../../widgets/chat/call_list_widget.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin , AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  bool searchClicked = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final ChatService _chatService = ChatService();

  late final Stream<List<ChatRoom>> _chatStream;

  List<ChatRoom> _cachedChats = [];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _chatStream = _chatService.getUserChats();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
              onPressed: () {
                setState(() {
                  searchClicked = false;
                  _searchController.clear();
                });
              },
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

          // Search bar
          if (searchClicked)
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search messages or people',
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

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ✅ Use the stored stream variable
                StreamBuilder<List<ChatRoom>>(
                  stream: _chatStream,
                  initialData: _cachedChats,
                  builder: (context, snapshot) {
                    // ✅ Update cache when new data arrives
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      _cachedChats = snapshot.data!;
                    }

                    // ✅ Only show loader if we have no cached data
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        _cachedChats.isEmpty) {
                      return const Center(child: MyyDocLoader());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    // ✅ Use cached data if available
                    final chats = snapshot.hasData && snapshot.data!.isNotEmpty
                        ? snapshot.data!
                        : _cachedChats;

                    if (chats.isEmpty) {
                      return const Center(child: Text("No conversations yet"));
                    }

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
                            final name = (userData['name'] ?? '').toLowerCase();

                            // Hide item if searching and name doesn't match
                            if (_searchQuery.isNotEmpty && !name.contains(_searchQuery)) {
                              return const SizedBox.shrink();
                            }

                            final lastMsg = chatRoom.lastMessage;
                            final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                            final unreadCount = chatRoom.unreadCount[myUid] ?? 0;

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
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Text(
                                lastMsg?['text']?.toString() ?? 'Start a conversation',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (chatRoom.lastMessageTime != null)
                                    Text(
                                      _formatTime(chatRoom.lastMessageTime!),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  if (unreadCount > 0)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF25D366),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      chatId: chatRoom.id,
                                      isFromTeleMed: false,
                                      isDoctor: userData['isDoctor'] == true,
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
                const Center(child: Text("Calls feature coming soon")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getOtherUserInfo(ChatRoom chatRoom) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final otherId = chatRoom.participants.firstWhere(
          (id) => id != currentUid,
      orElse: () => '',
    );

    if (otherId.isEmpty) {
      return {'name': 'Unknown', 'initial': '?'};
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(otherId).get();
    if (!doc.exists) {
      return {'name': 'User', 'initial': '?'};
    }

    final data = doc.data()!;
    final List preferences = List.from(data['userPreference'] ?? []);
    final bool isDoctor = preferences.contains("Doctor");
    final String fullName = data['fullName'] ?? 'User';

    return {
      'name': fullName,
      'photo': data['profilePicture'],
      'initial': fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
      'isDoctor': isDoctor,
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