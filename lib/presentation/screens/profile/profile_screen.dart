import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/chat/chat_list.dart';
import 'package:myydoctor/presentation/widgets/common_widgets.dart';
import 'package:myydoctor/presentation/widgets/home/feed_container_item.dart';
import 'package:myydoctor/presentation/widgets/home/story_circle.dart';
import 'package:myydoctor/presentation/widgets/profile/goto_payment_container.dart';
import 'package:myydoctor/presentation/widgets/profile/saved_contents.dart';
import 'package:myydoctor/presentation/widgets/profile/vip.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
    final theme = Theme.of(context); // ThemeData
    final textTheme = Theme.of(context).textTheme; // TextTheme
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1F323C),
        title: Row(
          children: [
            Text(
              "Antony Maxwell",
              style: textTheme.titleLarge!.copyWith(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
          ],
        ),
        leading: Icon(Icons.lock_person_rounded, color: Colors.amber),
        automaticallyImplyLeading: false,
        actions: [
          Icon(Icons.add_box_outlined, color: Color(0xFFD4AF37), size: 30),
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatListScreen()),
                ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                Icons.message_outlined,
                color: Color(0xFFD4AF37),
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Profile details section
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFFFFFFFF), Color(0xFFCDE4EA)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: profileDetailsMainContainer(textTheme, context),
                    ),
                  ),

                  // Tab bar
                  Container(
                    color: Color(0xFF1F323C),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      tabs: [
                        Tab(
                          child: Icon(
                            Icons.grid_view_rounded,
                            color: Color(0xFFD4AF37),
                            size: 32,
                          ),
                        ),
                        Tab(
                          child: Icon(
                            Icons.list_rounded,
                            color: Color(0xFFD4AF37),
                            size: 40,
                          ),
                        ),
                        Tab(
                          child: Icon(
                            Icons.bookmark,
                            color: Color(0xFFD4AF37),
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1F323C), // Top
                    Color(0xFF000000), // Bottom
                  ],
                ),
              ),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 10),
                itemCount: 10,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 30),
                itemBuilder:
                    (context, index) => FeedContainerItem(textTheme: textTheme),
              ),
            ),

            Column(
              children: [
                PaymentPosterContainer(textTheme: textTheme),
                Expanded(child: VipPrivilages()),
              ],
            ),

            SavedContents(),
          ],
        ),
      ),
    );
  }

  Column profileDetailsMainContainer(
    TextTheme textTheme,
    BuildContext context,
  ) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                "https://imgs.search.brave.com/Q40jLVzOHGTUVtrYicyrl9Wmxx3nCnz3xr9Crh_Nm_4/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93YWxs/cGFwZXJzLmNvbS9p/bWFnZXMvaGQvY2xv/c2UtdXAtaW1hZ2Ut/b2YtcGF1bC13YWxr/ZXItb2d1MWRheWd0/YnRramxlei5qcGc",
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      profileDetailsCounts(textTheme, "10", "Posts"),
                      profileDetailsCounts(textTheme, "150", "Followers"),
                      profileDetailsCounts(textTheme, "50", "Following"),
                      profileDetailsCounts(textTheme, "80", "Subscribers"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: customContainerWidget("Edit Profile")),
                      const SizedBox(width: 10),
                      Expanded(child: customContainerWidget("Subscriber Chat")),
                      const SizedBox(width: 15),
                      Icon(
                        Icons.person_add_alt,
                        color: Color(0xFFD4AF37),
                        size: 29,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Dr. Antony Max",
                      style: textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      width: 40,
                      child: Image.asset(
                        "assets/images/8ad19fdbc58af4bd5b0a3f9441f03fe5c09755ca.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                Text("@antonymax"),
                Text(
                  "Developer of myydoc",
                  style: textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(child: customContainerWidget("Tele Medicine")),
            const SizedBox(width: 15),
            Text("🪙", style: TextStyle(fontSize: 22)),
            const SizedBox(width: 5),
            Text(
              "256",
              style: textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            scrollDirection: Axis.horizontal,
            itemBuilder:
                (context, index) => StoryCircleItem(
                  isFromProfile: true,
                  textTheme: textTheme,
                  index: index,
                ),
            itemCount: 10,
          ),
        ),
      ],
    );
  }

  Column profileDetailsCounts(TextTheme textTheme, String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        Text(
          label,
          style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Container customContainerWidget(String text) {
    return Container(
      alignment: Alignment.center,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color(0xFF1F323C),
      ),
      child: Text(
        text,
        style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
      ),
    );
  }
}
