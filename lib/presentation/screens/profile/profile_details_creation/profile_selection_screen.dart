import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/curious_about_health_screen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/healthcare_enterprise.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/healthcare_profile.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/influencer_type_screen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/patient_page.dart';
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
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'I am a Healthcare Professional',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HealthcareProfile()),
                      );
                    },
                  ),
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'I am a Healthcare Enterprise',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HealthcareEnterprise(),
                        ),
                      );
                    },
                  ),
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'I want to be an Influencer',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InfluencerTypeScreen(),
                        ),
                      );
                    },
                  ),
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'I am curios about health',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CuriousAboutHealthScreen(),
                        ),
                      );
                    },
                  ),
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'I am a Patient',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientPage(),
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
