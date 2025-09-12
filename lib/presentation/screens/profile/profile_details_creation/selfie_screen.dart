import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/age_verification_screen.dart.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_preference/save_profile_preference_cubit.dart';
import 'package:myydoctor/presentation/widgets/app_snackbar.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
class SelfieScreen extends StatefulWidget {
  const SelfieScreen({super.key});

  @override
  State<SelfieScreen> createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen> {
  XFile? _image;
  @override
  void dispose() {
    
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final ovalWidth = screenWidth * 0.6; // 60% of screen width
    final ovalHeight = screenHeight * 0.5; // 40% of screen height
    final borderSize = 5.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBlue, AppColors.darkBlue],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: InkWell(
                onTap: ()async{
                  final ImagePicker picker = ImagePicker();
                  XFile? image = await picker.pickImage(source: ImageSource.gallery,);
                  if(image != null){
                    setState(() {
                      SaveProfilePreferenceCubit.profileImage = image;
                      _image = image;
                    });
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer oval (border)
                    ClipOval(
                      child: Container(
                        width: ovalWidth + borderSize * 2,
                        height: ovalHeight + borderSize * 2,
                        color: AppColors.gold,
                      ),
                    ),
                    // Inner oval (content)
                    ClipOval(
                      child:  Container(
                        width: ovalWidth,
                        height: ovalHeight,
                        color: Colors.white,
                        child: _image == null ? Center(
                          child: Text(
                            'Selfie',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ) : ClipOval(
                          child: Image.file(
                            File(_image!.path),
                            width: ovalWidth,
                            height: ovalHeight,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Click on the selfie to add an image',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.02),
            IconButton(onPressed: (){
              if(_image == null){
                showAppSnackBar(context, 'Please select and Image to proceed');
                return;
              }
               Navigator.push(context, MaterialPageRoute(builder: (_)=> AgeVerificationScreen(imagePath: _image?.path ?? '',)));
            }, icon: Icon(Icons.arrow_forward_ios_outlined,color: AppColors.white,))
          ],
        ),
      ),
    );
  }
}
