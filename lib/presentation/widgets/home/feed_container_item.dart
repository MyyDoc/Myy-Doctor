import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/core/loader/loader.dart';
import 'package:myydoctor/presentation/screens/profile/profile_screen.dart';
import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/bloc/upload_pic_cubit/upload_pic_cubit.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/post_comment_cubit/post_comment_cubit.dart';
import 'package:myydoctor/presentation/widgets/feed_image.dart';
import 'package:myydoctor/presentation/widgets/home/show_more_text.dart';

import '../../screens/profile/reel_post_uploding/bloc/save_post_cubit/save_post_cubit.dart';
import '../../screens/profile/story_view/bloc/fetch_story_cubit/fetch_my_stories_cubit.dart';
import 'full_screen_view.dart';

class FeedContainerItem extends StatefulWidget {
  final String? postImageUrl;
  final String? personName;
  final String? profileImageUrl;
  final String? postId;
  final String? ownerId;
  final bool isInitiallySaved;
  final TextTheme textTheme;
  final bool isDoctor;
  final String caption;

  const FeedContainerItem({
    super.key,
    required this.textTheme,
    this.postImageUrl,
    this.personName,
    this.profileImageUrl,
    this.postId,
    this.ownerId,
    required this.isInitiallySaved,
    required this.isDoctor,
    required this.caption,
  });

  @override
  State<FeedContainerItem> createState() => _FeedContainerItemState();
}

class _FeedContainerItemState extends State<FeedContainerItem> {
  late bool isSaved;

  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    isSaved = widget.isInitiallySaved;
  }

  void _showReportPostDialog(
      BuildContext context, {
        required String postId,
        required String ownerId,
      }) {
    final TextEditingController reasonController = TextEditingController();
    final primaryColor = const Color(0xFF1F323C);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.report, color: primaryColor),
              const SizedBox(width: 10),
              Text(
                "Report Post",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tell us what's wrong",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),

              // ✅ TextField
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter reason...",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actionsPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final reason = reasonController.text.trim();

                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a reason")),
                  );
                  return;
                }

                Navigator.pop(context);

                bool result =
                await context.read<UploadPicCubit>().reportPost(
                  postId: postId,
                  postOwnerId: ownerId,
                  reason: reason,
                );

                if (result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Post reported")),
                  );
                }
              },
              child: const Text("Submit", style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          /// HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                GestureDetector(
                  // In FeedContainerItem
                  onTap:
                      widget.isDoctor
                          ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ProfileScreen(userId: widget.ownerId),
                              ),
                            );

                            if (mounted) {
                              final currentUserId =
                                  FirebaseAuth.instance.currentUser?.uid ?? "";
                              context
                                  .read<FetchMyStoriesCubit>()
                                  .fetchMyStories(userId: currentUserId);
                            }
                          }
                          : null,
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: ClipOval(
                          child: FeedImage(
                            url:
                                widget.profileImageUrl ??
                                "https://imgs.search.brave.com/Q40jLVzOHGTUVtrYicyrl9Wmxx3nCnz3xr9Crh_Nm_4/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93YWxs/cGFwZXJzLmNvbS9p/bWFnZXMvaGQvY2xv/c2UtdXAtaW1hZ2Ut/b2YtcGF1bC13YWxr/ZXItb2d1MWRheWd0/YnRramxlei5qcGc",
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.personName ?? "Unknown",
                        style: widget.textTheme.bodyLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  onSelected: (value) async {
                    if (value == 'delete' && widget.postId != null) {
                      context.read<UploadPicCubit>().deletePost(
                        postId: widget.postId!,
                      );
                    }
                    if (value == 'Report' && widget.postId != null) {
                      _showReportPostDialog(
                        context,
                        postId: widget.postId!,
                        ownerId: widget.ownerId!,
                      );
                    }
                  },
                  itemBuilder:
                      (context) => [
                        if (currentUserId != null &&
                            widget.ownerId == currentUserId)
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete Post'),
                          ),
                        PopupMenuItem(
                          value: 'Report',
                          child: Text('report Post'),
                        ),
                      ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// IMAGE
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => FullPostViewScreen(
                        imageUrl:
                            widget.postImageUrl ?? "https://fallback-url.com",
                        personName: widget.personName ?? "Unknown",
                        profileImageUrl:
                            widget.profileImageUrl ??
                            "https://default-profile.com",
                        caption: widget.caption,
                      ),
                ),
              );
            },
            child: SizedBox(
              width: double.infinity,
              height: 300,
              child: FeedImage(
                url:
                    widget.postImageUrl ??
                    "https://imgs.search.brave.com/8SB8c98eLDaKU2XtzBkYn-3RMNGpc37mjtZVHwmXOHI/rs:fit:500:0:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/ZnJlZS1waG90by9h/ZXJpYWwtdmlldy1n/cmVlbi1tb3VudGFp/bm91cy1zY2VuZXJ5/LXN1bnJpc2VfMTgx/NjI0LTEyMzE5Lmpw/Zz9zZW10PWFpc19o/eWJyaWQmdz03NDA",
              ),
            ),
          ),

          const SizedBox(height: 13),

          /// CAPTION
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ShowMoreText(
                  text: widget.caption,
                  maxLines: 2,
                  textStyle: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          /// ACTION BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const CircleAvatar(radius: 10),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "shared by others",
                    style: widget.textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.postId == null || widget.ownerId == null)
                          return;

                        final cubit = context.read<PostCommentCubit>();

                        cubit.fetchComments(widget.postId!);

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder:
                              (_) => BlocProvider.value(
                                value: cubit,
                                child: PostCommentBottomSheet(
                                  postId: widget.postId!,
                                  ownerId: widget.ownerId!,
                                ),
                              ),
                        );
                      },
                      child: const Icon(
                        Icons.message_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Icon(Icons.send_rounded, color: Colors.white),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? Colors.purple : Colors.white,
                        size: 28,
                      ),
                      onPressed: () async {
                        if (widget.postId == null || widget.ownerId == null) {
                          return;
                        }

                        final cubit = context.read<SavePostCubit>();

                        // Optimistic UI
                        setState(() {
                          isSaved = !isSaved;
                        });

                        await cubit.toggleSave(
                          postId: widget.postId!,
                          ownerId: widget.ownerId!,
                          isCurrentlySaved: !isSaved,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isSaved ? 'Post saved!' : 'Post unsaved',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade200, thickness: 0.5),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// COMMENT BOTTOM SHEET
/// ─────────────────────────────────────────────
class PostCommentBottomSheet extends StatelessWidget {
  final String postId;
  final String ownerId;

  const PostCommentBottomSheet({
    super.key,
    required this.postId,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 10),

            /// COMMENT LIST
            Expanded(
              child: BlocBuilder<PostCommentCubit, PostCommentState>(
                builder: (context, state) {
                  if (state is PostCommentLoaded) {
                    if (state.comments.isEmpty) {
                      return const Center(
                        child: Text(
                          "No comments yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.comments.length,
                      itemBuilder: (_, i) {
                        final c = state.comments[i];
                        final isOwner = c.userId == currentUid;

                        return ListTile(
                          leading: CircleAvatar(
                            child: ClipOval(child: FeedImage(url: c.userProfilePicUrl)),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isOwner)
                                PopupMenuButton(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      context
                                          .read<PostCommentCubit>()
                                          .deleteComment(
                                            postId: postId,
                                            postOwnerId: ownerId,
                                            commentId: c.commentId,
                                          );
                                    }
                                  },
                                  itemBuilder:
                                      (_) => const [
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                ),
                            ],
                          ),
                          subtitle: Text(
                            c.text,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    );
                  }

                  if (state is PostCommentError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return const Center(child: MyyDocLoader());
                },
              ),
            ),

            _CommentInput(postId: postId, ownerId: ownerId),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// COMMENT INPUT
/// ─────────────────────────────────────────────
class _CommentInput extends StatefulWidget {
  final String postId;
  final String ownerId;

  const _CommentInput({required this.postId, required this.ownerId});

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Add a comment…",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () {
              if (controller.text.trim().isEmpty) return;

              context.read<PostCommentCubit>().postComment(
                postId: widget.postId,
                postOwnerId: widget.ownerId,
                text: controller.text,
              );

              controller.clear();
            },
          ),
        ],
      ),
    );
  }
}
