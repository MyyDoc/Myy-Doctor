import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/age_verification_screen.dart.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
class SelfieScreen extends StatefulWidget {
  const SelfieScreen({super.key});

  @override
  State<SelfieScreen> createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen> {
  Timer? timer;
  @override
  void dispose() {
    if(timer != null){
      timer?.cancel();
      timer = null;
    }
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
                  // final ImagePicker picker = ImagePicker();
                  // XFile? image = await picker.pickImage(source: ImageSource.camera,preferredCameraDevice: CameraDevice.front);
                  // if(image != null){
                  //   context.read<ImageSelectorProvider>().setImagePath(image.path);
                  //   timer = Timer(Duration(seconds: 3), (){
                  //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> ProfileAddingScreen(imagePath: image.path,)));
                  //   });
                  // }
                  Navigator.push(context, MaterialPageRoute(builder: (_)=> AgeVerificationScreen()));
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
                        child: Center(
                          child: Text(
                            'Selfie',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }
}
