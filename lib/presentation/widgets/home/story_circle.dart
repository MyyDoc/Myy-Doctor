import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoryCircleItem extends StatelessWidget {
  final bool isFromProfile;
  final TextTheme textTheme;
  final int index;
  final String? imageUrl;
  final bool isAddButton;

  const StoryCircleItem({
    Key? key,
    required this.isFromProfile,
    required this.textTheme,
    required this.index,
    this.imageUrl,
    this.isAddButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isAddButton && imageUrl == null
                ? null
                : const LinearGradient(
              colors: [Colors.purple, Colors.pink, Colors.orange],
            ),
            border: Border.all(color: Colors.grey.shade800, width: 2),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade900,
              image: imageUrl != null
                  ? DecorationImage(
                image: CachedNetworkImageProvider(imageUrl!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: isAddButton
                ? const Icon(Icons.add, color: Colors.white, size: 32)
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isAddButton ? "Your Story" : "You",
          style: textTheme.bodySmall?.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}