import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/data/user/user_model.dart';
import 'package:myydoctor/presentation/screens/chat/chat_list.dart';
import 'package:myydoctor/presentation/screens/chat/chat_screen.dart';
import 'package:myydoctor/presentation/widgets/home/feed_container_item.dart';
import 'package:myydoctor/presentation/widgets/profile/goto_payment_container.dart';
import 'package:myydoctor/presentation/widgets/profile/saved_contents.dart';
import 'package:myydoctor/presentation/widgets/profile/vip.dart';
import 'package:myydoctor/services/bloc/profile_bloc.dart';

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

    // Load profile and start listening to updates
    context.read<ProfileBloc>().add(ProfileUpdates());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is ProfileError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        } else if (state is ProfileLoaded) {
          final user = state.user;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF1F323C),
              title: Row(
                children: [
                  Text(
                    user.fullName,
                    style: textTheme.titleLarge!.copyWith(
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
                ],
              ),
              leading: const Icon(Icons.lock_person_rounded, color: Colors.amber),
              automaticallyImplyLeading: false,
              actions: [
                const Icon(Icons.add_box_outlined, color: Color(0xFFD4AF37), size: 30),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatListScreen()),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Icon(Icons.message_outlined, color: Color(0xFFD4AF37), size: 30),
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
                            child: profileDetailsMainContainer(
                              textTheme,
                              context,
                              user,
                            ),
                          ),
                        ),
                        Container(
                          color: const Color(0xFF1F323C),
                          child: TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.grid_view_rounded, color: Color(0xFFD4AF37), size: 32),
                              ),
                              Tab(
                                icon: Icon(Icons.list_rounded, color: Color(0xFFD4AF37), size: 40),
                              ),
                              Tab(
                                icon: Icon(Icons.bookmark, color: Color(0xFFD4AF37), size: 32),
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
                  // Posts Tab
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1F323C), Color(0xFF000000)],
                      ),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: 10,
                      separatorBuilder: (_, __) => const SizedBox(height: 30),
                      itemBuilder: (_, __) => FeedContainerItem(textTheme: textTheme),
                    ),
                  ),

                  // VIP/Payment Tab
                  Column(
                    children: [
                      PaymentPosterContainer(textTheme: textTheme),
                      const Expanded(child: VipPrivilages()),
                    ],
                  ),

                  // Saved Contents Tab
                  const SavedContents(),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  /// ================= PROFILE DETAILS =================

  Column profileDetailsMainContainer(
    TextTheme textTheme,
    BuildContext context,
    UserModel user,
  ) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.profilePicture != null
                  ? NetworkImage(user.profilePicture!)
                  : null,
              child: user.profilePicture == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      const Icon(Icons.person_add_alt, color: Color(0xFFD4AF37), size: 29),
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
                Text(user.fullName, style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                Text("@${user.username}"),
                Text(user.bio ?? "", style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen(isFromTeleMed: true)),
              ),
              child: customContainerWidget("Tele Medicine"),
            ),
          ],
        ),
      ],
    );
  }

  Column profileDetailsCounts(TextTheme textTheme, String count, String label) {
    return Column(
      children: [
        Text(count, style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Container customContainerWidget(String text) {
    return Container(
      alignment: Alignment.center,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF1F323C),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
    );
  }
}
