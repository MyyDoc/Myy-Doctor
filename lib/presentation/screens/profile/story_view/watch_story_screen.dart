import 'package:flutter/material.dart';
import 'package:myydoctor/core/loader/loader.dart';
import 'package:story_view/story_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../data/user/story_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/fetch_story_cubit/fetch_my_stories_cubit.dart';

class MyStoryViewer extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex; // Optional: to start from a specific story

  const MyStoryViewer({
    Key? key,
    required this.stories,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MyStoryViewer> createState() => _MyStoryViewerState();
}

class _MyStoryViewerState extends State<MyStoryViewer> {
  late StoryController storyController;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    storyController = StoryController();
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    storyController.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<void> _deleteStory(StoryModel story, int currentIndex) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Story?', style: TextStyle(color: Colors.white)),
        content: const Text('This action cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated')),
      );
      return;
    }

    try {
      // 1. Delete from Storage
      if (story.imageUrl.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(story.imageUrl);
        await storageRef.delete();
      }

      // 2. Delete from Realtime Database
      final storyRef = FirebaseDatabase.instance
          .ref()
          .child('stories')
          .child(user.uid)
          .child(story.storyId);

      await storyRef.remove();

      // 3. Remove from local list and update UI
      setState(() {
        widget.stories.removeAt(currentIndex);
      });

      // Optional: Refresh the home screen stories
      context.read<FetchMyStoriesCubit>().fetchMyStories();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story deleted')),
      );

      // If no stories left, close viewer
      if (widget.stories.isEmpty) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('No stories to show', style: TextStyle(color: Colors.white))),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          controller: pageController,
          itemCount: widget.stories.length,
          onPageChanged: (index) {
            // Sync with story_view if needed, but we're using PageView for more control
          },
          itemBuilder: (context, index) {
            final story = widget.stories[index];

            return Stack(
              fit: StackFit.expand,
              children: [
                // Full-screen image
                CachedNetworkImage(
                  imageUrl: story.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: MyyDocLoader(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                ),

                // Top safe area overlay (for notch)
                const SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CloseButton(color: Colors.white),
                    ),
                  ),
                ),

                // Delete button (bottom right)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GestureDetector(
                      onTap: () => _deleteStory(story, index),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),

                // Optional: Progress indicator at top (like Instagram)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: widget.stories.asMap().entries.map((entry) {
                      final isActive = entry.key == index;
                      final isPast = entry.key < index;
                      return Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          color: isPast
                              ? Colors.white
                              : isActive
                              ? Colors.white70
                              : Colors.white30,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}