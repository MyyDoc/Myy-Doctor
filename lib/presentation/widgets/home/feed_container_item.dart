import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/presentation/screens/profile/profile_screen.dart';
import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/bloc/upload_pic_cubit/upload_pic_cubit.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/post_comment_cubit/post_comment_cubit.dart';


class FeedContainerItem extends StatelessWidget {
  final String? postImageUrl;
  final String? personName;
  final String? profileImageUrl;
  final String? postId;
  final String? ownerId;
  final bool isInitiallySaved;
  final TextTheme textTheme;
  final bool isDoctor;
  const FeedContainerItem({
    super.key,
    required this.textTheme,
    this.postImageUrl,
    this.personName,
    this.profileImageUrl,
    this.postId,
    this.ownerId,
    required this.isInitiallySaved,
    required this.isDoctor
  });

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
                  onTap: isDoctor ?  () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: ownerId,),));
                  } :  null,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          profileImageUrl ??
                              "https://imgs.search.brave.com/Q40jLVzOHGTUVtrYicyrl9Wmxx3nCnz3xr9Crh_Nm_4/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93YWxs/cGFwZXJzLmNvbS9p/bWFnZXMvaGQvY2xv/c2UtdXAtaW1hZ2Ut/b2YtcGF1bC13YWxr/ZXItb2d1MWRheWd0/YnRramxlei5qcGc",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        personName ?? "Unknown",
                        style: textTheme.bodyLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
                PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                  ),
                  onSelected: (value) {
                    if (value == 'delete' && postId != null) {
                      context.read<UploadPicCubit>().deletePost(
                        postId: postId!,
                      );
                    }
                  },
                  itemBuilder:
                      (context) => const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Post'),
                        ),
                      ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// IMAGE
          SizedBox(
            width: double.infinity,
            height: 300,
            child: Image.network(
              postImageUrl ??
                  "https://imgs.search.brave.com/8SB8c98eLDaKU2XtzBkYn-3RMNGpc37mjtZVHwmXOHI/rs:fit:500:0:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/ZnJlZS1waG90by9h/ZXJpYWwtdmlldy1n/cmVlbi1tb3VudGFp/bm91cy1zY2VuZXJ5/LXN1bnJpc2VfMTgx/NjI0LTEyMzE5Lmpw/Zz9zZW10PWFpc19o/eWJyaWQmdz03NDA",
              fit: BoxFit.cover,
            ),
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
                  flex: 2,
                  child: Text(
                    "shared by others",
                    style: textTheme.bodyMedium!.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (postId == null || ownerId == null) return;

                          final cubit = context.read<PostCommentCubit>();

                          cubit.fetchComments(postId!);

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
                                    postId: postId!,
                                    ownerId: ownerId!,
                                  ),
                                ),
                          );
                        },
                        child: const Icon(
                          Icons.message_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(Icons.send_rounded, color: Colors.white),
                      const Icon(
                        Icons.bookmark_border_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                            backgroundImage: NetworkImage(c.userProfilePicUrl),
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

                  return const Center(child: CircularProgressIndicator());
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
