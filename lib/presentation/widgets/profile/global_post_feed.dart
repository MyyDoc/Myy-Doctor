import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myydoctor/data/posts/pic_post_model.dart';
import 'package:myydoctor/presentation/widgets/home/feed_container_item.dart';
import 'package:myydoctor/repository/pic_post_repository.dart';

class GlobalPostFeed extends StatefulWidget {
  const GlobalPostFeed({super.key});

  @override
  State<GlobalPostFeed> createState() => _GlobalPostFeedState();
}

class _GlobalPostFeedState extends State<GlobalPostFeed>
    with AutomaticKeepAliveClientMixin<GlobalPostFeed> {
      

  @override
  bool get wantKeepAlive => true;
late final Stream<List<PicPostModel>> globalUserPostFeed;


  @override
  void initState() {
    super.initState();
    globalUserPostFeed = PicPostRepository().getPostsStream(useOwnerProfile: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // REQUIRED for AutomaticKeepAlive

    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1F323C),
            Color(0xFF000000),
          ],
        ),
      ),
      child: StreamBuilder(
        stream: globalUserPostFeed,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 30),
            itemBuilder: (context, index) {
              return FeedContainerItem(
                textTheme: textTheme,
                postImageUrl: posts[index].imageUrl,
                personName: posts[index].name,
                profileImageUrl: posts[index].profileImageUrl,
                isInitiallySaved: posts[index].isSaved,
                ownerId: posts[index].ownerId,
                postId: posts[index].postId,
              );
            },
          );
        },
      ),
    );
  }
}
