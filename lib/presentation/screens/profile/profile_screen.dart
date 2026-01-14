import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/data/user/story_model.dart';
import 'package:myydoctor/presentation/screens/chat/chat_list.dart';
import 'package:myydoctor/presentation/screens/chat/chat_screen.dart';
import 'package:myydoctor/presentation/screens/profile/get_user/bloc/get_user_cubit/get_user_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile/bloc/profile_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile_by_id/bloc/fetch_user_details_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/reel_post_uploding.dart';
import 'package:myydoctor/presentation/screens/profile/story_view/bloc/fetch_story_cubit/fetch_my_stories_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/story_view/watch_story_screen.dart';
import 'package:myydoctor/presentation/widgets/home/story_circle.dart';
import 'package:myydoctor/presentation/widgets/profile/create_story_screen.dart';
import 'package:myydoctor/presentation/widgets/profile/global_post_feed.dart';
import 'package:myydoctor/presentation/widgets/profile/goto_payment_container.dart';
import 'package:myydoctor/presentation/widgets/profile/saved_contents.dart';
import 'package:myydoctor/presentation/widgets/profile/vip.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});
  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int postsCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final targetUserId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid ?? "";

    // Always fetch stories of the profile owner
    context.read<FetchMyStoriesCubit>().fetchMyStories();

    if (widget.userId != null) {
      // We are viewing ANOTHER doctor's profile
      context.read<FetchUserDetailsCubit>().fetchUserById(targetUserId);
    } else {
      // Our own profile
      context.read<FetchUserCubit>().fetchUser();
      context.read<ProfileCubit>().listenToUserProfile();
    }

    showPostCount();
  }
  void showPostCount() async {
    postsCount =  await getUserPostsCount(widget.userId ?? "");
    print("postscount $postsCount");
  }


  Future<int> getUserPostsCount(String userId) async {
    try {
      final postsRef = FirebaseDatabase.instance.ref('posts/$userId');

      final snapshot = await postsRef.get();

      if (!snapshot.exists || snapshot.value == null) {
        return 0;
      }

      if (snapshot.value is Map) {
        return (snapshot.value as Map).length;
      }

      if (snapshot.value is List) {
        return (snapshot.value as List).length;
      }

      return 0;
    } catch (e) {
      print('Error fetching posts count for user $userId: $e');
      return 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper to know if we are viewing our own profile
  bool get isOwnProfile => widget.userId == null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F323C),
        title: _buildAppBarTitle(textTheme),
        leading: GestureDetector(
          onTap: widget.userId != null ? (){
            Navigator.pop(context);
          } : () {
            FirebaseAuth.instance.signOut();
          },
          child: widget.userId != null ? Icon(Icons.arrow_back_ios, color: Colors.amber,) : Icon(Icons.lock_person_rounded, color: Colors.amber),
        ),
        automaticallyImplyLeading: false,
        actions: [
          if (isOwnProfile)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReelPostUplodingScreen()),
              ),
              child: const Icon(Icons.add_box_outlined, color: Color(0xFFD4AF37), size: 30),
            ),
          if (isOwnProfile)
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
      body: RefreshIndicator(
        onRefresh: () async {
          final targetUserId = widget.userId ?? FirebaseAuth.instance.currentUser!.uid;
          await Future.wait([
            context.read<FetchMyStoriesCubit>().fetchMyStories(),
            if (widget.userId != null)
              context.read<FetchUserDetailsCubit>().fetchUserById(targetUserId)
            else ...[
              context.read<FetchUserCubit>().fetchUser(),
              context.read<ProfileCubit>().fetchCurrentUserProfile(),
            ],
          ]);
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  BlocBuilder<FetchUserCubit, FetchUserState>(
                    builder: (context, state) {

                      if( state is FetchUserInitial) {
                        print("initial");
                        return const SizedBox.shrink();
                      }
                      if (state is FetchUserLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is FetchUserError) {
                        return Center(child: Text(state.error));
                      }

                      else {
                        if(state is FetchUserSuccess) {
                          if(state.isDoctor || widget.userId != null){
                            return Container(
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
                            );
                          }
                        }
                      }

                      print(state);
                      return SizedBox();

                    },
                  ),

                  // TabBar - always shown for doctors
                  BlocBuilder<FetchUserCubit, FetchUserState>(
                    builder: (context, userState) {
                      if (userState is! FetchUserSuccess || !userState.isDoctor) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        color: const Color(0xFF1F323C),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Colors.black,
                          tabs: [
                            Tab(child: Icon(Icons.grid_view_rounded, color: Color(0xFFD4AF37), size: 32)),
                            if(widget.userId == null)
                            Tab(child: Icon(Icons.list_rounded, color: Color(0xFFD4AF37), size: 40)),
                            if(widget.userId == null)
                              Tab(child: Icon(Icons.bookmark, color: Color(0xFFD4AF37), size: 32)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              GlobalPostFeed(),
              if(widget.userId == null)
              Column(
                children: [
                  PaymentPosterContainer(textTheme: textTheme), // will use Theme inside the widget
                  Expanded(child: VipPrivilages()),
                ],
              ),
              if(widget.userId == null)
              SavedContents(),
            ],
          ),
        ),
      ),
    );
  }

  // AppBar title - works for both own profile and other doctors
  Widget _buildAppBarTitle(TextTheme textTheme) {
    if (widget.userId != null) {
      return BlocBuilder<FetchUserDetailsCubit, FetchUserDetailsState>(
        builder: (context, state) {
          String name = "Doctor";
          if (state is FetchUserDetailsSuccess) name = state.user.fullName;
          if (state is FetchUserDetailsLoading) name = "Loading...";
          return Row(
            children: [
              Text(
                name,
                style: textTheme.titleLarge!.copyWith(
                  color: const Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
            ],
          );
        },
      );
    } else {
      return BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          String name = "User";
          if (state is ProfileLoaded) name = state.user.fullName;
          if (state is ProfileLoading) name = "Loading...";
          return Row(
            children: [
              Text(
                name,
                style: textTheme.titleLarge!.copyWith(
                  color: const Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
            ],
          );
        },
      );
    }
  }

  // Main profile content
  Widget profileDetailsMainContainer(TextTheme textTheme, BuildContext context) {
    if (widget.userId != null) {
      // Viewing another doctor
      return BlocBuilder<FetchUserDetailsCubit, FetchUserDetailsState>(
        builder: (context, state) {
          if (state is FetchUserDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FetchUserDetailsError || state is FetchUserDetailsNotFound) {
            return Center(child: Text(state is FetchUserDetailsError ? state.message : "User not found"));
          }
          if (state is FetchUserDetailsSuccess) {
            final user = state.user;
            return _buildProfileBody(textTheme, user, context);
          }
          return const SizedBox();
        },
      );
    } else {
      // Own profile
      return BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          if (state is ProfileLoaded) {
            final user = state.user;
            return _buildProfileBody(textTheme, user, context);
          }
          return const SizedBox();
        },
      );
    }
  }

  // Shared UI for both cases
  Widget _buildProfileBody(TextTheme textTheme, dynamic user, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                user.profilePicture ??
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.fullName)}&background=0D8ABC&color=fff',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      profileDetailsCounts(textTheme, postsCount.toString(), "Posts"), // TODO: fetch real post count if needed
                      profileDetailsCounts(textTheme, user.followersCount.toString(), "Followers"),
                      profileDetailsCounts(textTheme, user.followingCount.toString(), "Following"),
                      profileDetailsCounts(textTheme, user.subscribers.length.toString(), "Subscribers"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (isOwnProfile) Expanded(child: customContainerWidget("Edit Profile")),
                      if (isOwnProfile) const SizedBox(width: 10),
                      if (isOwnProfile) Expanded(child: customContainerWidget("Subscriber Chat")),
                      if (isOwnProfile) const SizedBox(width: 15),
                      if (widget.userId != null) const Icon(Icons.person_add_alt, color: Color(0xFFD4AF37), size: 29),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.fullName,
                      style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (user.isVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: SizedBox(
                          height: 30,
                          width: 40,
                          child: Image(image: AssetImage("assets/images/8ad19fdbc58af4bd5b0a3f9441f03fe5c09755ca.png"), fit: BoxFit.contain),
                        ),
                      ),
                  ],
                ),
                Text("@${user.username}"),
                if (user.bio?.isNotEmpty == true)
                  Text(user.bio!, style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen(isFromTeleMed: true)),
                ),
                child: customContainerWidget("Tele Medicine"),
              ),
            ),
            const SizedBox(width: 15),
            const Text("🪙", style: TextStyle(fontSize: 22)),
            const SizedBox(width: 5),
            Text(
              user.walletBalance.toStringAsFixed(0),
              style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: 15),
        // Stories
        if(widget.userId != null)
          SizedBox()
        else
        BlocBuilder<FetchMyStoriesCubit, FetchMyStoriesState>(
          builder: (context, state) {
            if (state is FetchMyStoriesLoading || state is FetchMyStoriesInitial) {
              return const SizedBox(height: 100);
            }
            final stories = state is FetchMyStoriesSuccess ? state.stories : <StoryModel>[];
            final itemCount = stories.isNotEmpty ? stories.length + 1 : 1;

            return SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    if(widget.userId != null) {
                      return SizedBox();
                    }
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StoryCreatorHome()),
                        );
                        if (result == "success") {
                          context.read<FetchMyStoriesCubit>().fetchMyStories();
                        }
                      },
                      child: StoryCircleItem(
                        isFromProfile: true,
                        textTheme: textTheme,
                        index: 0,
                        isAddButton: true,
                        imageUrl: null,
                      ),
                    );
                  }
                  final story = stories[index - 1];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyStoryViewer(stories: stories, initialIndex: index - 1),
                        ),
                      );
                    },
                    child: StoryCircleItem(
                      isFromProfile: true,
                      textTheme: textTheme,
                      index: index,
                      imageUrl: story.imageUrl,
                      isAddButton: false,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Column profileDetailsCounts(TextTheme textTheme, String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
      ),
    );
  }
}