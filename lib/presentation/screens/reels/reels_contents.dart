import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/data/user/reels_model.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/cubit/reel_feed_cubit.dart';
import 'package:myydoctor/presentation/widgets/app_snackbar.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<ReelFeedCubit, ReelFeedState>(
        listener: (context, state) {
          if(state is ReelFeedError){
            showAppSnackBar(context, state.error.toString());
          }
        },
        child: BlocBuilder<ReelFeedCubit, ReelFeedState>(
          builder: (context, state) {
            if (state is ReelFeedLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReelFeedLoaded) {
              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: state.reels.length,
                onPageChanged: (index) {
                  if (index >= state.reels.length - 2) {
                    context.read<ReelFeedCubit>().fetchMore();
                  }
                },
                itemBuilder: (_, index) {
                  return FirebaseReelWidget(reel: state.reels[index]);
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class FirebaseReelWidget extends StatefulWidget {
  final ReelItems reel;
  const FirebaseReelWidget({super.key, required this.reel});

  @override
  State<FirebaseReelWidget> createState() => _FirebaseReelWidgetState();
}

class _FirebaseReelWidgetState extends State<FirebaseReelWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.videoUrl),
    )..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openComments() {
    _controller.pause();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsBottomSheet(reelId: widget.reel.reelId),
    ).whenComplete(() {
      if (_controller.value.isInitialized) {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_controller.value.isInitialized) return;
        _controller.value.isPlaying
            ? _controller.pause()
            : _controller.play();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// VIDEO
          _controller.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),

          /// USER INFO (BOTTOM LEFT)
          Positioned(
            left: 16,
            bottom: 80,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.reel.ownerProfilePicUrl.isNotEmpty
                      ? NetworkImage(widget.reel.ownerProfilePicUrl)
                      : null,
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.reel.ownerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// CAPTION
          Positioned(
            left: 16,
            bottom: 40,
            right: 80,
            child: Text(
              widget.reel.caption,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          /// COMMENT ICON (RIGHT SIDE)
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.mode_comment_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _openComments,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.reel.commentCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentsBottomSheet extends StatelessWidget {
  final String reelId;

  const CommentsBottomSheet({super.key, required this.reelId});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              /// HANDLE
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              /// TITLE
              const Text(
                "Comments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(),

              /// COMMENTS LIST (DUMMY FOR NOW)
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 10,
                  itemBuilder: (_, index) {
                    return ListTile(
                      leading: const CircleAvatar(),
                      title: const Text(
                        "username",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text("This is a comment"),
                    );
                  },
                ),
              ),

              /// COMMENT INPUT
              Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 16),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Add a comment...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: post comment
                        },
                        child: const Text("Post"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
