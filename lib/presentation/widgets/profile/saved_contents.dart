import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/bloc/upload_reel_cubit/upload_reel_cubit.dart';
import 'package:video_player/video_player.dart';

import 'package:myydoctor/data/posts/pic_post_model.dart';
import 'package:myydoctor/data/user/reels_model.dart';
import 'package:myydoctor/presentation/widgets/profile/saved_feeds_detailed_screen.dart';
import 'package:myydoctor/repository/pic_post_repository.dart';
import 'package:myydoctor/repository/reel_repostitory.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

/// ─────────────────────────────────────────────────────────
/// SNACKBAR HELPER
/// ─────────────────────────────────────────────────────────
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showAppSnackBar(
  BuildContext context,
  String message,
) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(backgroundColor: AppColors.red, content: Text(message)),
  );
}

/// ─────────────────────────────────────────────────────────
/// SAVED CONTENTS
/// ─────────────────────────────────────────────────────────
class SavedContents extends StatefulWidget {
  const SavedContents({super.key});

  @override
  State<SavedContents> createState() => _SavedContentsState();
}

class _SavedContentsState extends State<SavedContents>
    with AutomaticKeepAliveClientMixin<SavedContents> {
  @override
  bool get wantKeepAlive => true;

  int selectedIndex = 0; // 0 = posts, 1 = reels

  late final Stream<List<PicPostModel>> postStream;
  late final Stream<List<ReelItems>> reelStream;

  @override
  void initState() {
    super.initState();
    postStream = PicPostRepository()
        .getPostsStream(useOwnerProfile: false)
        .asBroadcastStream();

    reelStream = ReelRepository()
        .getCurrentUserReels()
        .asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        const SizedBox(height: 8),

        /// TOGGLE
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ToggleButton(
              label: "Posts",
              isActive: selectedIndex == 0,
              onTap: () => setState(() => selectedIndex = 0),
            ),
            const SizedBox(width: 20),
            _ToggleButton(
              label: "Reels",
              isActive: selectedIndex == 1,
              onTap: () => setState(() => selectedIndex = 1),
            ),
          ],
        ),

        const SizedBox(height: 8),

        /// 🔥 KEEP BOTH ALIVE
        Expanded(
          child: IndexedStack(
            index: selectedIndex,
            children: [
              _PostsGrid(postStream),
              _ReelsGrid(reelStream),
            ],
          ),
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// TOGGLE BUTTON
/// ─────────────────────────────────────────────────────────
class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// POSTS GRID
/// ─────────────────────────────────────────────────────────
class _PostsGrid extends StatelessWidget {
  final Stream<List<PicPostModel>> stream;

  const _PostsGrid(this.stream);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PicPostModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showAppSnackBar(context, "Failed to load posts");
          });
          return const Center(child: Text("Something went wrong"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            childAspectRatio: 0.8,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SavedFeedsDetailedScreen(),
                  ),
                );
              },
              child: Image.network(posts[index].imageUrl, fit: BoxFit.cover),
            );
          },
        );
      },
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// REELS GRID
/// ─────────────────────────────────────────────────────────
class _ReelsGrid extends StatelessWidget {
  final Stream<List<ReelItems>> stream;

  const _ReelsGrid(this.stream);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReelItems>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showAppSnackBar(context, "Failed to load reels");
          });
          return const Center(child: Text("Something went wrong"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reels = snapshot.data!;

        if (reels.isEmpty) {
          return const Center(child: Text("No reels yet"));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 9 / 16,
          ),
          itemCount: reels.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReelPlayerScreen(
                      reels: reels,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: _ReelGridItem(reels[index]),
            );
          },
        );
      },
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// REEL GRID ITEM
/// ─────────────────────────────────────────────────────────
class _ReelGridItem extends StatelessWidget {
  final ReelItems reel;

  const _ReelGridItem(this.reel);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black12),
        const Center(
          child: Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
        ),
      ],
    );
  }
}


/// ─────────────────────────────────────────────────────────
/// REEL PLAYER SCREEN (FULLY SAFE)
/// ─────────────────────────────────────────────────────────
class ReelPlayerScreen extends StatefulWidget {
  final List<ReelItems> reels;
  final int initialIndex;

  const ReelPlayerScreen({
    super.key,
    required this.reels,
    required this.initialIndex,
  });

  @override
  State<ReelPlayerScreen> createState() => _ReelPlayerScreenState();
}

class _ReelPlayerScreenState extends State<ReelPlayerScreen> {
  VideoPlayerController? _controller;
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();

    if (widget.reels.isEmpty) return;

    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
    _loadVideo(widget.reels[currentIndex].videoUrl);
  }

  Future<void> _loadVideo(String url) async {
    try {
      await _controller?.pause();
      await _controller?.dispose();

      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await _controller!.initialize();

      _controller!
        ..setLooping(true)
        ..play();

      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, "Unable to play video");
      }
    }
  }

  void _pauseVideo() {
    if (_controller?.value.isPlaying ?? false) {
      _controller?.pause();
    }
  }

  /// 🔴 DELETE ACTION (HOOK)
  void _onDeleteReel(String reelId, String ownerId) async {
    _pauseVideo();

    // OPTIONAL: confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Reel"),
        content: const Text("Are you sure you want to delete this reel?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<UploadReelCubit>().deleteReel(reelId: reelId , ownerId: ownerId);
              Navigator.pop(context, true);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final reel = widget.reels[currentIndex];

      // 👉 DELETE FROM FIREBASE HERE
      // Example:
      // FirebaseDatabase.instance
      //   .ref("reels/${reel.ownerId}/${reel.reelId}")
      //   .remove();

      showAppSnackBar(context, "Reel deleted");

      Navigator.pop(context); // exit player after delete
    } catch (e) {
      showAppSnackBar(context, "Failed to delete reel");
    }
  }

  @override
  void dispose() {
    _pauseVideo();
    _controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reels.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAppSnackBar(context, "No reels available");
      });

      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "No reels available",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.reels.length,
        onPageChanged: (index) {
          if (index < 0 || index >= widget.reels.length) return;
          currentIndex = index;
          _loadVideo(widget.reels[index].videoUrl);
        },
        itemBuilder: (context, index) {
          final reel = widget.reels[index];

          return Stack(
            children: [
              /// VIDEO
              Center(
                child: _controller != null &&
                        _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : const CircularProgressIndicator(color: Colors.white),
              ),

              /// BACK BUTTON
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    _pauseVideo();
                    Navigator.pop(context);
                  },
                ),
              ),

              /// MENU (TOP RIGHT)
              Positioned(
                top: 40,
                right: 16,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _onDeleteReel(reel.reelId, reel.ownerId);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

              /// CAPTION
              Positioned(
                bottom: 40,
                left: 16,
                right: 80,
                child: Text(
                  reel.caption,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
