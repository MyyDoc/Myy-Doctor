import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vs_story_designer/vs_story_designer.dart';
import 'package:provider/provider.dart';

import '../../screens/profile/story_view/bloc/upload_story_cubit/upload_story_cubit.dart';

class StoryCreatorHome extends StatefulWidget {
  const StoryCreatorHome({Key? key}) : super(key: key);

  @override
  State<StoryCreatorHome> createState() => _StoryCreatorHomeState();
}

class _StoryCreatorHomeState extends State<StoryCreatorHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create Your Story'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon/Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade400,
                    Colors.pink.shade400,
                    Colors.orange.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),

            // Title
            const Text(
              'Share Your Moment',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle
            Text(
              'Create amazing stories with photos, text & drawings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 60),

            // Create Story Button
            ElevatedButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();

                // First, show bottom sheet: Camera or Gallery?
                final String? source = await showModalBottomSheet<String>(
                  context: context,
                  backgroundColor: Colors.grey[900],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt, color: Colors.white),
                          title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                          onTap: () => Navigator.pop(context, 'camera'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library, color: Colors.white),
                          title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                          onTap: () => Navigator.pop(context, 'gallery'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );

                if (source == null) return; // User canceled

                XFile? pickedFile;

                if (source == 'camera') {
                  pickedFile = await picker.pickImage(source: ImageSource.camera);
                } else {
                  pickedFile = await picker.pickImage(source: ImageSource.gallery);
                }

                if (pickedFile == null) return; // User didn't pick anything

                // Now open VSStoryDesigner with the selected/taken image pre-loaded
                if (!mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VSStoryDesigner(
                      // Important: Pass the file path to pre-load the image
                      mediaPath: pickedFile!.path,

                      centerText: "Edit your story",

                      middleBottomWidget: const SizedBox(),

                      galleryThumbnailQuality: 200,

                      fontFamilyList: [
                        FontType.roboto,
                        FontType.notoSansGujarati,
                        FontType.dancingScript,
                        FontType.pacifico,
                      ],

                      colorList: const [
                        Colors.white, Colors.black, Colors.red, Colors.orange,
                        Colors.yellow, Colors.green, Colors.blue, Colors.purple,
                        Colors.pink, Colors.brown, Colors.grey,
                      ],

                      onDone: (editedFile) async {
                        final cubit = context.read<UploadStoryCubit>();
                        await cubit.uploadStory(editedFilePath: editedFile);

                        if (cubit.state is UploadStorySuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Story uploaded successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (cubit.state is UploadStoryError) {
                          final errorState = cubit.state as UploadStoryError;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${errorState.error}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }

                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: Colors.purple.withOpacity(0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_circle_outline, size: 28, color: Colors.white,),
                  SizedBox(width: 12),
                  Text(
                    'Create Story',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Features List
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade900.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey.shade800,
                ),
              ),
              child: Column(
                children: [
                  _buildFeatureRow(Icons.text_fields, 'Add Text'),
                  const SizedBox(height: 10),
                  _buildFeatureRow(Icons.brush, 'Draw & Sketch'),
                  const SizedBox(height: 10),
                  _buildFeatureRow(Icons.photo_library, 'Choose Photos'),
                  const SizedBox(height: 10),
                  _buildFeatureRow(Icons.color_lens, 'Apply Colors'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple.shade300, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}