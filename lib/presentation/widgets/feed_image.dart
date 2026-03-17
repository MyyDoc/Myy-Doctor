import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/profile/saved_contents.dart';

class FeedImage extends StatelessWidget {
  final String url;
  final BoxFit? fit;

  const FeedImage({super.key, required this.url, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      cacheKey: url,

      fit: fit,
      width: double.infinity,

      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),

      placeholder: (context, _) => SizedBox(
        child: Center(child: Text('Loading...'),),
      ),

      errorWidget: (context, error, __) {
        return CircularProgressIndicator();
      }

          // Container(color: Colors.grey[900]), // 👈 no flicker icon

    );
  }
}