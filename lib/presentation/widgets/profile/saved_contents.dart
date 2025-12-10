
import 'package:flutter/material.dart';
import 'package:myydoctor/data/posts/pic_post_model.dart';
import 'package:myydoctor/presentation/widgets/profile/saved_feeds_detailed_screen.dart';
import 'package:myydoctor/repository/pic_post_repository.dart';

class SavedContents extends StatefulWidget {
  const SavedContents({
    super.key,
  });

  @override
  State<SavedContents> createState() => _SavedContentsState();
}

class _SavedContentsState extends State<SavedContents> with AutomaticKeepAliveClientMixin<SavedContents> {
  @override
  bool get wantKeepAlive => true;
  late final Stream<List<PicPostModel>> userPostFeed;

  @override
  void initState() {
    super.initState();
    userPostFeed = PicPostRepository().getPostsStream(useOwnerProfile: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
      stream: userPostFeed,
      builder: (context, asyncSnapshot) {
        if(!asyncSnapshot.hasData){
          return Center(child: CircularProgressIndicator(),);
        }
        final posts = asyncSnapshot.data!;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            childAspectRatio: 0.8
          ),
          itemCount: posts.length, 
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SavedFeedsDetailedScreen(),));
              },
              child: Image.network(posts[index].imageUrl, fit: BoxFit.cover,)
            );
          },
        );
      }
    );
  }
}
// Mc4jZ7kVD0RaEdMpfaB1QNtzvHh1