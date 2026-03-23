import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/core/loader/loader.dart';
import 'package:myydoctor/data/user/reel_comment_model.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/reel_comment_cubit/reel_comment_cubit.dart';
import 'package:myydoctor/presentation/widgets/app_snackbar.dart';
import 'package:myydoctor/presentation/widgets/feed_image.dart';

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
                        return const Center(child: MyyDocLoader());
                      }

                      if (state is CommentLoaded) {
                        if (state.comments.isEmpty) {
                          return const Center(child: Text("No comments yet"));
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
                                child:
                                    c.userProfilePicUrl.isNotEmpty
                                        ? ClipOval(
                                          child: FeedImage(
                                            url: c.userProfilePicUrl,
                                          ),
                                        )
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
                                                reelOwnerId: widget.reelOwnerId,
                                                commentId: c.commentId,
                                              );
                                        }
                                      },
                                      itemBuilder:
                                          (_) => [
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
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
                        TextButton(onPressed: _post, child: const Text("Post")),
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
