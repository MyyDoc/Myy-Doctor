import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/home/show_more_text.dart';

class FullPostViewScreen extends StatelessWidget {
  final String imageUrl;
  final String personName;
  final String profileImageUrl;
  final String caption;

  const FullPostViewScreen({
    super.key,
    required this.imageUrl,
    required this.personName,
    required this.profileImageUrl,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header (Profile + Name)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
                const SizedBox(width: 10),
                Text(
                  personName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          /// Full Image
          Expanded(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),

          /// Caption
          Padding(
            padding: const EdgeInsets.all(12),
            child: ShowMoreText(
              text: caption,
              maxLines: 3,
              textStyle: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
