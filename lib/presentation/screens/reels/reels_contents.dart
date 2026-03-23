import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/data/user/reels_model.dart';
import 'package:myydoctor/presentation/screens/chat/chat_screen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_screen.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/reel_feed_cubit/reel_feed_cubit.dart';
import 'package:myydoctor/presentation/screens/reels/widgets/comment_bottomsheet.dart';
import 'package:myydoctor/presentation/widgets/feed_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';

import '../../../core/loader/loader.dart';
import '../../../core/services/chat_service.dart';

class ReelsScreen extends StatefulWidget {
  final bool isVisible;
  const ReelsScreen({super.key, required this.isVisible});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  void preloadVideo(String url) {
    final controller = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(url),
    );

    controller.initialize().then((_) {
      controller.dispose();
    });
  }

  @override
  void didUpdateWidget(covariant ReelsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.isVisible) {
      // force rebuild to pause all
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ReelFeedCubit, ReelFeedState>(
        builder: (context, state) {
          if (state is ReelFeedLoading) {
            return const Center(child: MyyDocLoader());
          }

          if (state is ReelFeedLoaded) {
            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: state.reels.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });

                /// Fetch more
                if (index >= state.reels.length - 2) {
                  context.read<ReelFeedCubit>().fetchMore();
                }

                /// 🔥 Preload next videos
                if (index + 1 < state.reels.length) {
                  preloadVideo(state.reels[index + 1].videoUrl);
                }

                if (index + 2 < state.reels.length) {
                  preloadVideo(state.reels[index + 2].videoUrl);
                }
              },
              itemBuilder: (_, index) {
                return FirebaseReelWidget(
                  reel: state.reels[index],
                  isActive:
                      widget.isVisible && index == currentIndex, // 🔥 KEY LINE
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class FirebaseReelWidget extends StatefulWidget {
  final ReelItems reel;
  final bool isActive;

  const FirebaseReelWidget({
    super.key,
    required this.reel,
    required this.isActive,
  });

  @override
  State<FirebaseReelWidget> createState() => _FirebaseReelWidgetState();
}

class _FirebaseReelWidgetState extends State<FirebaseReelWidget> {
  late CachedVideoPlayerPlusController _controller;

  @override
  void initState() {
    super.initState();

    _controller = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(widget.reel.videoUrl),
      )
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});

          /// ✅ FIX: autoplay if already active
          if (widget.isActive) {
            _controller.play();
          }
        }
      });
  }

  @override
  void didUpdateWidget(covariant FirebaseReelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive) {
      if (_controller.value.isInitialized && !_controller.value.isPlaying) {
        _controller.play();
      }
    } else {
      if (_controller.value.isPlaying) {
        _controller.pause();
      }
    }
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
      builder:
          (_) => CommentsBottomSheet(
            reelId: widget.reel.reelId,
            reelOwnerId: widget.reel.ownerId,
          ),
    ).whenComplete(() {
      if (_controller.value.isInitialized && widget.isActive) {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_controller.value.isInitialized) return;

        _controller.value.isPlaying ? _controller.pause() : _controller.play();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          _controller.value.isInitialized
              ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: CachedVideoPlayerPlus(_controller),
                ),
              )
              : const Center(child: MyyDocLoader()),

          /// USER INFO
          Positioned(
            left: 16,
            bottom: 80,
            child: GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProfileScreen(userId: widget.reel.ownerId),
                    ),
                  ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey,
                    child:
                        widget.reel.ownerProfilePicUrl.isNotEmpty
                            ? ClipOval(
                              child: FeedImage(
                                url: widget.reel.ownerProfilePicUrl,
                              ),
                            )
                            : null,
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

          /// COMMENTS
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

          /// CHAT
          Positioned(
            right: 16,
            bottom: 55,
            child: GestureDetector(
              onTap: () async {
                final chatId = await ChatService().getOrCreateChatRoom(
                  widget.reel.ownerId,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChatScreen(chatId: chatId, isDoctor: true),
                  ),
                );
              },
              child: SizedBox(
                height: 40,
                child: Image.asset(
                  "assets/images/8ad19fdbc58af4bd5b0a3f9441f03fe5c09755ca.png",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

