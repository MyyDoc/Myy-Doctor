
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/app_button.dart';
import 'package:myydoctor/presentation/widgets/profile/app_title_text.dart';



class PatientFeaturesScreen extends StatelessWidget {
  const PatientFeaturesScreen({super.key});

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
              const AppTitleText(title: 'Patient Features'),
              const SizedBox(height: 32),
              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Search your doctor',
              ),
              const SizedBox(height: 16),
              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Search your disease',
              ),
              const SizedBox(height: 16),
              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Book an appointment',
              ),
              const SizedBox(height: 16),
              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Search your treatment',
              ),
              const SizedBox(height: 16),
              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Search patient community',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
