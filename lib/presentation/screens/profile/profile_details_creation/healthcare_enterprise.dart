import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';

class HealthcareEnterprise extends StatelessWidget {
  const HealthcareEnterprise({super.key});

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
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Bio Technology / Devices',),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Pharmaceutical',),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Insurance',),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'IT and Softwares',),
                  SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Hospital / Lab / Foundation',),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
