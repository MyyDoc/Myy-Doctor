import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_preference/save_profile_preference_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile_screen.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';

class HealthcareInfluencer extends StatelessWidget {
  const HealthcareInfluencer({super.key});

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
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Medical influencer',
                  ontap: (){
                    SaveProfilePreferenceCubit.fieldOfWork = 'medical influencer';
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ProfileScreen()));
                  },),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Lifestyle Influencer',
                  ontap: (){
                    SaveProfilePreferenceCubit.fieldOfWork = 'lifestyle influencer';
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ProfileScreen()));
                  },),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'IT influencer',
                  ontap: (){
                    SaveProfilePreferenceCubit.fieldOfWork = 'IT influencer';
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ProfileScreen()));
                  },),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Finance influencer',
                  ontap: (){
                    SaveProfilePreferenceCubit.fieldOfWork = 'finance influencer';
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ProfileScreen()));
                  },),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Legal influencer',
                  ontap: (){
                    SaveProfilePreferenceCubit.fieldOfWork = 'legal influencer';
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ProfileScreen()));
                  },),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
