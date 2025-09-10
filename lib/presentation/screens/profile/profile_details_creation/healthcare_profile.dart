import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';

class HealthcareProfile extends StatelessWidget {
  const HealthcareProfile({super.key});

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
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'MBBS / MD / DO / DM/MCh',),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'BSc / MSc / PhD',),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Alternative Medicine',),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Nurse / PA',),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Administrator /MBA',),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
