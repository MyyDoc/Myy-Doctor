import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/chat/call_list_widget.dart';
import 'package:myydoctor/presentation/widgets/chat/chat_list_widget.dart';
import 'package:myydoctor/presentation/widgets/home/story_circle.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool searchClicked = false;

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
          child: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        backgroundColor: Color(0xFF1F323C),
        title: Text(
          "Rahuljaicsam",
          style: textTheme.headlineMedium!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          searchClicked ? IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => setState(() {
              searchClicked = false;
            }),
          ) :
          IconButton(
            padding: EdgeInsets.only(right: 15),
            icon: Icon(Icons.search, color: Colors.white, size: 30),
            onPressed:
                () => setState(() {
                  searchClicked = true;
                }),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Color(0xFF1F323C),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.grey,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              tabs: [
                Tab(icon: Icon(Icons.chat_bubble_outline)),
                Tab(icon: Icon(Icons.groups_outlined)),
                Tab(icon: Icon(Icons.call_outlined)),
              ],
            ),
          ),
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
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'SEARCH MESSAGES',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (searchClicked) Padding(
            padding: const EdgeInsets.only(left: 15, top: 10),
            child: Text("Visitors", textAlign: TextAlign.left, ),
          ),
          if (searchClicked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              color: Colors.white,
              height: 130,
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                scrollDirection: Axis.horizontal,
                itemBuilder:
                    (context, index) => StoryCircleItem(
                      isFromProfile: false,
                      textTheme: textTheme,
                      index: index,
                    ),
                itemCount: 10,
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(color: Colors.white, child: ChatTileWidget()),
                Container(
                  color: Colors.white,
                  child: Center(child: Text("Groups will be here")),
                ),
                Container(color: Colors.white, child: CallsScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
