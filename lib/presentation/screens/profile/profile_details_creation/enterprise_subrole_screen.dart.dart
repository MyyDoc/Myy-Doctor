import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/influencer_type_screen.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/app_button.dart';
import 'package:myydoctor/presentation/widgets/profile/app_title_text.dart';


class HealthcareEnterpriseScreen extends StatelessWidget {
  const HealthcareEnterpriseScreen({super.key});

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
              const AppTitleText(title: 'Select your Enterprise sub-role'),
              const SizedBox(height: 32),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Bio Technology/Devices',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfluencerTypeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Pharmaceutical',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfluencerTypeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Insurance',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfluencerTypeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'IT and Software',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfluencerTypeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Hospital/Lab/Foundation',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfluencerTypeScreen(),
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
