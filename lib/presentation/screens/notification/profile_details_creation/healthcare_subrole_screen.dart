import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/patient_screen.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/app_button.dart';
import 'package:myydoctor/presentation/widgets/profile/app_title_text.dart';


class HealthcareProfessionalScreen extends StatelessWidget {
  const HealthcareProfessionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppTitleText(title: 'Healthcare Professional'),
              const SizedBox(height: 32),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'MBBS / MD / DO / DM / MCh',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientFeaturesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'BSc / MSc / PhD',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientFeaturesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Alternative Medicine',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientFeaturesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Nurse / PA',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientFeaturesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Administrator / MBA',
                onTap: () {
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
    );
  }
}
