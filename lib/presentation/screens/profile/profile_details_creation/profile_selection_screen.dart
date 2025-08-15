
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/influencer_type_screen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/medical_registration.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/patient_screen.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';

class ProfileTypeScreen extends StatelessWidget {
  const ProfileTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBlue, AppColors.lightBlue],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SizedBox(
              height: screenHeight * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'I am a Collage Administrator' ,ontap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=> MedicalRegistrationScreen()));
              },),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'I am a Educational Consultant',ontap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=> MedicalRegistrationScreen()));
              },),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'I want to be an Influencer' ,ontap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=> MedicalRegistrationScreen()));
              },),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'I am curios about educational institute' ,ontap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=> MedicalRegistrationScreen()));
              },),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'I am a Student',),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
