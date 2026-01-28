import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/data/user/story_model.dart';
import 'package:myydoctor/data/user/user_model.dart';
import 'package:myydoctor/presentation/screens/auth/login.dart';
import 'package:myydoctor/presentation/screens/chat/chat_list.dart';
import 'package:myydoctor/presentation/screens/chat/chat_screen.dart';
import 'package:myydoctor/presentation/screens/profile/get_user/bloc/get_user_cubit/get_user_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile/bloc/profile_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile_by_id/bloc/fetch_user_details_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/edit_profile.dart';
import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/reel_post_uploding.dart';
import 'package:myydoctor/presentation/screens/profile/story_view/bloc/fetch_story_cubit/fetch_my_stories_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/story_view/watch_story_screen.dart';
import 'package:myydoctor/presentation/widgets/home/story_circle.dart';
import 'package:myydoctor/presentation/widgets/profile/create_story_screen.dart';
import 'package:myydoctor/presentation/widgets/profile/global_post_feed.dart';
import 'package:myydoctor/presentation/widgets/profile/goto_payment_container.dart';
import 'package:myydoctor/presentation/widgets/profile/saved_contents.dart';
import 'package:myydoctor/presentation/widgets/profile/vip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/chat_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});
  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {

  TabController? _tabController;

  int postsCount = 0;
  bool _isFollowing = false;

  // Real-time followers & following counts
  int _followersCount = 0;
  int _followingCount = 0;

  StreamSubscription? _followersListener;
  StreamSubscription? _followingListener;

  bool _tabControllerInitialized = false; // Prevent multiple initializations

  @override
  void initState() {
    super.initState();

    final targetUserId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid ?? "";

    context.read<FetchMyStoriesCubit>().fetchMyStories();

    if (widget.userId != null) {
      context.read<FetchUserDetailsCubit>().fetchUserById(targetUserId);
      _checkIfFollowing(targetUserId);
      _listenToFollowersAndFollowing(targetUserId);
    } else {
      context.read<FetchUserCubit>().fetchUser();
      context.read<ProfileCubit>().listenToUserProfile();
      _listenToFollowersAndFollowing(targetUserId);
    }

    showPostCount();
  }

  void _initializeTabController(bool showMultipleTabs) {
    if (_tabControllerInitialized) return; // Prevent multiple calls

    final tabLength = showMultipleTabs ? 3 : 1;

    _tabController?.dispose();
    _tabController = TabController(
      length: tabLength,
      vsync: this,
      initialIndex: 0,
    );

    _tabControllerInitialized = true;
  }

  void showPostCount() async {
    postsCount = await getUserPostsCount(widget.userId ?? FirebaseAuth.instance.currentUser?.uid ?? "");
    if (mounted) setState(() {});
  }

  Future<int> getUserPostsCount(String userId) async {
    try {
      final postsRef = FirebaseDatabase.instance.ref('posts/$userId');
      final snapshot = await postsRef.get();

      if (!snapshot.exists || snapshot.value == null) return 0;

      if (snapshot.value is Map) return (snapshot.value as Map).length;
      if (snapshot.value is List) return (snapshot.value as List).length;
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _checkIfFollowing(String targetUserId) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null || currentUid == targetUserId) return;

    final followingRef = FirebaseDatabase.instance
        .ref('users/$currentUid/followingList/$targetUserId');

    final snapshot = await followingRef.get();
    if (mounted) {
      setState(() {
        _isFollowing = snapshot.exists;
      });
    }
  }

  void _listenToFollowersAndFollowing(String targetUserId) {
    // Followers count
    final followersRef = FirebaseDatabase.instance
        .ref('users/$targetUserId/followersList');
    _followersListener = followersRef.onValue.listen((event) {
      final data = event.snapshot.value;
      final count = data is Map ? data.length : 0;
      if (mounted) {
        setState(() {
          _followersCount = count;
        });
      }
    });

    // Following count (only for own profile)
    if (targetUserId == FirebaseAuth.instance.currentUser?.uid) {
      final followingRef = FirebaseDatabase.instance
          .ref('users/$targetUserId/followingList');
      _followingListener = followingRef.onValue.listen((event) {
        final data = event.snapshot.value;
        final count = data is Map ? data.length : 0;
        if (mounted) {
          setState(() {
            _followingCount = count;
          });
        }
      });
    }
  }

  Future<void> _toggleFollow(String targetUserId) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null || currentUid == targetUserId) return;

    final followingRef = FirebaseDatabase.instance
        .ref('users/$currentUid/followingList/$targetUserId');
    final followersRef = FirebaseDatabase.instance
        .ref('users/$targetUserId/followersList/$currentUid');

    if (_isFollowing) {
      final bool? confirmUnfollow = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF1F323C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.person_remove_rounded, color: Color(0xFFD4AF37), size: 28),
              SizedBox(width: 12),
              Text(
                "Unfollow",
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Unfollow this user?\nYou won't see their posts in your feed anymore.",
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD4AF37),
                backgroundColor: const Color(0xFFD4AF37).withOpacity(0.15),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                ),
              ),
              child: const Text("Unfollow", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (confirmUnfollow != true) return;

      await followingRef.remove();
      await followersRef.remove();
    } else {
      await followingRef.set(true);
      await followersRef.set(true);
    }

    if (mounted) {
      setState(() {
        _isFollowing = !_isFollowing;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _followersListener?.cancel();
    _followingListener?.cancel();
    super.dispose();
  }

  bool get isOwnProfile => widget.userId == null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F323C),
        title: _buildAppBarTitle(textTheme),
        leading: GestureDetector(
          onTap: widget.userId != null
              ? () => Navigator.pop(context)
              : () async {
            final bool? shouldLogout = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  backgroundColor: const Color(0xFF1F323C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Color(0xFFD4AF37), size: 28),
                      SizedBox(width: 12),
                      Text(
                        "Logout",
                        style: TextStyle(color: Color(0xFFD4AF37), fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: const Text(
                    "Are you sure you want to logout?\nYou'll need to sign in again to continue.",
                    style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
                  ),
                  actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: TextButton.styleFrom(foregroundColor: Colors.white70),
                      child: const Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFD4AF37),
                        backgroundColor: const Color(0xFFD4AF37).withOpacity(0.15),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                        ),
                      ),
                      child: const Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
              },
            );

            if (shouldLogout == true) {
              try {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await FirebaseAuth.instance.signOut();
                await prefs.setBool('isLoggedIn', false);

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginAndSignUp()),
                      (route) => false,
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Logout failed: ${e.toString()}"), backgroundColor: Colors.redAccent),
                );
              }
            }
          },
          child: widget.userId != null
              ? const Icon(Icons.arrow_back_ios, color: Colors.amber)
              : const Icon(Icons.lock_person_rounded, color: Colors.amber),
        ),
        automaticallyImplyLeading: false,
        actions: [
          BlocBuilder<FetchUserCubit, FetchUserState>(
            builder: (context, state) {
              if (state is FetchUserSuccess && state.isDoctor && isOwnProfile) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReelPostUplodingScreen()),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.add_box_outlined, color: Color(0xFFD4AF37), size: 30),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
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
            if (widget.userId != null) ...[
              context.read<FetchUserDetailsCubit>().fetchUserById(targetUserId),
              _checkIfFollowing(targetUserId),
            ] else ...[
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
                      if (state is FetchUserLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is FetchUserError) {
                        return Center(child: Text(state.error));
                      }
                      if (state is FetchUserSuccess) {
                        final isDoctorProfile = state.isDoctor || widget.userId != null;

                        // Initialize TabController only once after build
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && !_tabControllerInitialized) {
                            _initializeTabController(isDoctorProfile);
                            setState(() {}); // Ensure rebuild after initialization
                          }
                        });

                        if (isDoctorProfile) {
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
                      return const SizedBox.shrink();
                    },
                  ),

                  BlocBuilder<FetchUserCubit, FetchUserState>(
                    builder: (context, state) {
                      if (state is! FetchUserSuccess || !state.isDoctor) {
                        return const SizedBox.shrink();
                      }

                      if (_tabController == null) return const SizedBox.shrink();

                      return Container(
                        color: const Color(0xFF1F323C),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Colors.black,
                          tabs: [
                            const Tab(child: Icon(Icons.grid_view_rounded, color: Color(0xFFD4AF37), size: 32)),
                            if (widget.userId == null)
                              const Tab(child: Icon(Icons.list_rounded, color: Color(0xFFD4AF37), size: 40)),
                            if (widget.userId == null)
                              const Tab(child: Icon(Icons.bookmark, color: Color(0xFFD4AF37), size: 32)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          body: Builder(
            builder: (context) {
              if (_tabController == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  GlobalPostFeed(anotherProfile: widget.userId ?? "",),
                  if (widget.userId == null)
                    Column(
                      children: [
                        PaymentPosterContainer(textTheme: textTheme),
                        const Expanded(child: VipPrivilages()),
                      ],
                    ),
                  if (widget.userId == null) const SavedContents(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

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

  Widget profileDetailsMainContainer(TextTheme textTheme, BuildContext context) {
    if (widget.userId != null) {
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

  Widget _buildProfileBody(TextTheme textTheme, UserModel user, BuildContext context) {
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
                      profileDetailsCounts(textTheme, postsCount.toString(), "Posts"),
                      profileDetailsCounts(textTheme, _followersCount.toString(), "Followers"),
                      profileDetailsCounts(textTheme, _followingCount.toString(), "Following"),
                      profileDetailsCounts(textTheme, user.subscribers.length.toString(), "Subscribers"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (isOwnProfile)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  initialUser: context.read<ProfileCubit>().state is ProfileLoaded
                                      ? (context.read<ProfileCubit>().state as ProfileLoaded).user
                                      : null,
                                ),
                              ),
                            ),
                            child: customContainerWidget("Edit Profile"),
                          ),
                        ),
                      if (isOwnProfile) const SizedBox(width: 10),
                      if (isOwnProfile) Expanded(child: customContainerWidget("Subscriber Chat")),
                      if (isOwnProfile) const SizedBox(width: 15),
                      if (widget.userId != null)
                        GestureDetector(
                          onTap: () => _toggleFollow(user.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isFollowing ? Colors.transparent : const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFD4AF37),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isFollowing ? Icons.check_circle : Icons.person_add_alt,
                                  color: _isFollowing ? const Color(0xFFD4AF37) : Colors.black,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isFollowing ? "Following" : "Follow",
                                  style: TextStyle(
                                    color: _isFollowing ? const Color(0xFFD4AF37) : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
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
                            child: Image(
                              image: AssetImage("assets/images/8ad19fdbc58af4bd5b0a3f9441f03fe5c09755ca.png"),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text("@${user.username}"),
                  if (user.bio?.isNotEmpty == true)
                    Text(user.bio!, style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (widget.userId != null)
            const SizedBox(width: 10),
            if (widget.userId != null)
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final chatId = await ChatService().getOrCreateChatRoom(user.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(isFromTeleMed: true, chatId: chatId),
                    ),
                  );
                },
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
        if (widget.userId != null)
          const SizedBox()
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
                      if (widget.userId != null) {
                        return const SizedBox();
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