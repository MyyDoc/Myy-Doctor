import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/bloc/upload_pic_cubit/upload_pic_cubit.dart';
import 'package:myydoctor/presentation/widgets/app_snackbar.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';

class ReelPostUplodingScreen extends StatefulWidget {
  const ReelPostUplodingScreen({super.key});

  @override
  State<ReelPostUplodingScreen> createState() => _ReelPostUplodingScreenState();
}

class _ReelPostUplodingScreenState extends State<ReelPostUplodingScreen> {
  String pickedFilePath = '';
  final captionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Center(
                      child: Text(
                        'Select Content',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              Theme.of(context).textTheme.titleMedium?.fontSize,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.image,
                          );

                          if (result != null && result.files.isNotEmpty) {
                            setState(() {
                              pickedFilePath = result.files.single.path ?? '';
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child:
                              pickedFilePath.isEmpty
                                  ? Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                                  )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(
                                      File(pickedFilePath),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Write Caption',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              Theme.of(context).textTheme.titleMedium?.fontSize,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: captionController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: null, // expands infinitely
                      maxLength: 100,
                      expands: false,
                      decoration: InputDecoration(
                        hintText: "Type here...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 90),
                  ],
                ),

                BlocConsumer<UploadPicCubit, UploadPicState>(
                  listener: (context, state) {
                    if(state is UploadPicErrorState){
                      showAppSnackBar(context, state.error);
                    }
                    if(state is UploadPicSuccessState){
                      Navigator.pop(context);
                    }
                  },
                  builder: (context, state) {
                    if(state is UploadLoadingState){
                      return CircularProgressIndicator();
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
                            'Please select picture and write caption',
                          );
                          return;
                        }
                        context.read<UploadPicCubit>().uploadPic(
                          picPath: pickedFilePath,
                          caption: captionController.text,
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
