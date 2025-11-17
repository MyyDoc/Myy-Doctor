import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';

class HealthCareCurious extends StatelessWidget {
  const HealthCareCurious({super.key});

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
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'General Health',),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Sports Performance',),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Organ health',),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Aging health',),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Public health',),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
