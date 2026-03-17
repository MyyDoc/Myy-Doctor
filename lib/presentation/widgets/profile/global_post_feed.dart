import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/core/loader/loader.dart';
import 'package:myydoctor/data/posts/pic_post_model.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/post_comment_cubit/post_comment_cubit.dart';
import 'package:myydoctor/presentation/widgets/home/feed_container_item.dart';
import 'package:myydoctor/repository/pic_post_repository.dart';

class GlobalPostFeed extends StatefulWidget {
  const GlobalPostFeed({super.key, required this.anotherProfile});
  final String anotherProfile;

  @override
  State<GlobalPostFeed> createState() => _GlobalPostFeedState();
}

class _GlobalPostFeedState extends State<GlobalPostFeed>
    with AutomaticKeepAliveClientMixin<GlobalPostFeed> {

  @override
  bool get wantKeepAlive => true;

  late final Stream<List<PicPostModel>> globalUserPostFeed;

  // 🔥 Cache to prevent flicker + reload
  List<PicPostModel>? _cachedPosts;

  @override
  void initState() {
    super.initState();

    final bool isAnotherProfile = widget.anotherProfile.isNotEmpty;

    globalUserPostFeed = PicPostRepository().getPostsStream(
      useOwnerProfile: !isAnotherProfile,
      anotherProfile: widget.anotherProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F323C), Color(0xFF000000)],
        ),
      ),

      // ✅ Bloc stays stable (not recreated per item)
      child: BlocProvider(
        create: (context) => PostCommentCubit(),

        child: StreamBuilder<List<PicPostModel>>(
          stream: globalUserPostFeed,
          builder: (context, snapshot) {

            // ✅ Cache latest data
            if (snapshot.hasData) {
              _cachedPosts = snapshot.data;
            }

            final posts = _cachedPosts;

            // 🔥 Show loader ONLY first time
            if (posts == null) {
              return const Center(child: MyyDocLoader());
            }

            return ListView.separated(
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
              cacheExtent: 1000,

              padding: const EdgeInsets.symmetric(vertical: 10),

              itemCount: posts.length,

              separatorBuilder: (_, __) =>
                  const SizedBox(height: 30),

              itemBuilder: (context, index) {
                final post = posts[index];

                return KeyedSubtree(
                  key: ValueKey(post.postId),

                  child: FeedContainerItem(
                    caption: post.caption,
                    isDoctor: post.isOwnerDoctor,
                    isInitiallySaved: post.isSaved,
                    textTheme: textTheme,
                    postId: post.postId,
                    ownerId: post.ownerId,
                    postImageUrl: post.imageUrl,
                    personName: post.name ?? 'no name here',
                    profileImageUrl: post.profileImageUrl,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}