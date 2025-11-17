// lib/screens/curious_about_health/curious_about_health_screen.dart
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/patient_screen.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';

class CuriousAboutHealthScreen extends StatelessWidget {
  const CuriousAboutHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'General Health',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientFeaturesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'Organ Health',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientFeaturesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'Sports Performance',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientFeaturesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'Aging Health',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientFeaturesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'Public Health',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientFeaturesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
