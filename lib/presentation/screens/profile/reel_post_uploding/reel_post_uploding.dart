import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/core/loader/loader.dart';

import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/bloc/upload_pic_cubit/upload_pic_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/bloc/upload_reel_cubit/upload_reel_cubit.dart';

import 'package:myydoctor/presentation/widgets/app_snackbar.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';

enum UploadType { post, reel }

class ReelPostUplodingScreen extends StatefulWidget {
  const ReelPostUplodingScreen({super.key});

  @override
  State<ReelPostUplodingScreen> createState() =>
      _ReelPostUplodingScreenState();
}

class _ReelPostUplodingScreenState
    extends State<ReelPostUplodingScreen> {
  UploadType uploadType = UploadType.post;
  String pickedFilePath = '';
  final captionController = TextEditingController();

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: uploadType == UploadType.post
          ? FileType.image
          : FileType.custom,
      allowedExtensions:
          uploadType == UploadType.reel ? ['mp4'] : null,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        pickedFilePath = result.files.single.path ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  uploadType == UploadType.post
                      ? 'Create Post'
                      : 'Create Reel',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 20),

                // POST / REEL SWITCH
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Post'),
                      selected: uploadType == UploadType.post,
                      onSelected: (_) {
                        setState(() {
                          uploadType = UploadType.post;
                          pickedFilePath = '';
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Reel'),
                      selected: uploadType == UploadType.reel,
                      onSelected: (_) {
                        setState(() {
                          uploadType = UploadType.reel;
                          pickedFilePath = '';
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // FILE PICKER
                GestureDetector(
                  onTap: pickFile,
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: pickedFilePath.isEmpty
                        ? Center(
                            child: Icon(
                              uploadType == UploadType.post
                                  ? Icons.add_a_photo
                                  : Icons.video_library,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                        : uploadType == UploadType.post
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(20),
                                child: Image.file(
                                  File(pickedFilePath),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.videocam,
                                    size: 60,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    File(pickedFilePath)
                                        .path
                                        .split('/')
                                        .last,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                  ),
                ),

                const SizedBox(height: 20),

                // CAPTION
                TextField(
                  controller: captionController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    hintText: 'Write caption...',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                // SUBMIT
                uploadType == UploadType.post
                    ? BlocConsumer<UploadPicCubit, UploadPicState>(
                        listener: (context, state) {
                          if (state is UploadPicErrorState) {
                            showAppSnackBar(context, state.error);
                          }
                          if (state is UploadPicSuccessState) {
                            Navigator.pop(context);
                          }
                        },
                        builder: (context, state) {
                          if (state is UploadLoadingState) {
                            return const MyyDocLoader();
                          }
                          return SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Post',
                            ontap: () {
                              if (pickedFilePath.isEmpty ||
                                  captionController.text.isEmpty) {
                                showAppSnackBar(
                                  context,
                                  'Select image & write caption',
                                );
                                return;
                              }
                              context
                                  .read<UploadPicCubit>()
                                  .uploadPic(
                                    picPath: pickedFilePath,
                                    caption:
                                        captionController.text,
                                  );
                            },
                          );
                        },
                      )
                    : BlocConsumer<UploadReelCubit, UploadReelState>(
                        listener: (context, state) {
                          if (state is UploadReelErrorState) {
                            showAppSnackBar(context, state.error);
                          }
                          if (state is UploadReelSuccessState) {
                            Navigator.pop(context);
                          }
                        },
                        builder: (context, state) {
                          if (state
                              is UploadingReelProgressState) {
                            return Column(
                              children: [
                                LinearProgressIndicator(
                                  value: state.progress,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(state.progress * 100).toStringAsFixed(0)}%',
                                ),
                              ],
                            );
                          }

                          return SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Upload Reel',
                            ontap: () {
                              if (pickedFilePath.isEmpty ||
                                  captionController.text.isEmpty) {
                                showAppSnackBar(
                                  context,
                                  'Select video & write caption',
                                );
                                return;
                              }
                              context
                                  .read<UploadReelCubit>()
                                  .uploadReel(
                                    videoPath: pickedFilePath,
                                    caption:
                                        captionController.text,
                                  );
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
