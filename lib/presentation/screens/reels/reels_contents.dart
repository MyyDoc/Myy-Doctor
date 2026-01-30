import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/data/user/reel_comment_model.dart';
import 'package:myydoctor/data/user/reels_model.dart';
import 'package:myydoctor/presentation/screens/chat/chat_screen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_screen.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/reel_comment_cubit/reel_comment_cubit.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/reel_feed_cubit/reel_feed_cubit.dart';
import 'package:myydoctor/presentation/widgets/app_snackbar.dart';
import 'package:video_player/video_player.dart';

import '../../../core/loader/loader.dart';
import '../../../core/services/chat_service.dart';

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
              return const Center(child: MyyDocLoader());
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
      builder: (_) => CommentsBottomSheet(reelId: widget.reel.reelId,reelOwnerId: widget.reel.ownerId,),
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
              : const Center(child: MyyDocLoader()),

          /// USER INFO (BOTTOM LEFT)
          Positioned(
            left: 16,
            bottom: 80,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: widget.reel.ownerId,),)),
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
          Positioned(
            right: 16,
            bottom: 55,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async{
                    final chatId = await ChatService().getOrCreateChatRoom(
                      widget.reel.ownerId,
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId, isDoctor: true),));
                  },
                  child: SizedBox(
                    height: 40,
                      child: Image.asset("assets/images/8ad19fdbc58af4bd5b0a3f9441f03fe5c09755ca.png")),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class CommentsBottomSheet extends StatefulWidget {
  final String reelId;
  final String reelOwnerId;

  const CommentsBottomSheet({
    super.key,
    required this.reelId,
    required this.reelOwnerId,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ReelCommentCubit>().fetchComments(widget.reelId);
  }

  void _post() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ReelCommentCubit>().postComment(
          reelId: widget.reelId,
          reelOwnerId: widget.reelOwnerId,
          text: text,
        );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return BlocListener<ReelCommentCubit, ReelCommentState>(
      listener: (context, state) {
        if (state is CommentError) {
          showAppSnackBar(context, state.message);
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Comments",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(),

                /// COMMENTS
                Expanded(
                  child: BlocBuilder<ReelCommentCubit, ReelCommentState>(
                    builder: (context, state) {
                      if (state is CommentLoading) {
                        return const Center(
                          child: MyyDocLoader(),
                        );
                      }

                      if (state is CommentLoaded) {
                        if (state.comments.isEmpty) {
                          return const Center(
                            child: Text("No comments yet"),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: state.comments.length,
                          itemBuilder: (_, i) {
                            final ReelComment c = state.comments[i];
                            final isOwner = c.userId == currentUid;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    c.userProfilePicUrl.isNotEmpty
                                        ? NetworkImage(c.userProfilePicUrl)
                                        : null,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      c.userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isOwner)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          context
                                              .read<ReelCommentCubit>()
                                              .deleteComment(
                                                reelId: widget.reelId,
                                                reelOwnerId:
                                                    widget.reelOwnerId,
                                                commentId: c.commentId,
                                              );
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              subtitle: Text(c.text),
                            );
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),

                /// INPUT
                SafeArea(
                  child: Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Add a comment...",
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _post(),
                          ),
                        ),
                        TextButton(
                          onPressed: _post,
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
      ),
    );
  }
}
