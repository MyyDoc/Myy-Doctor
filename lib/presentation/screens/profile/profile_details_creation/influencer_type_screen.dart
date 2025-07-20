// lib/screens/influencer_type/influencer_type_screen.dart
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/curious_about_health_screen.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/app_button.dart';
import 'package:myydoctor/presentation/widgets/profile/app_title_text.dart';


class InfluencerTypeScreen extends StatelessWidget {
  const InfluencerTypeScreen({super.key});

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
              const AppTitleText(title: 'Select influencer type'),
              const SizedBox(height: 32),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Medical influencer',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CuriousAboutHealthScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Lifestyle Influencer',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CuriousAboutHealthScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'IT influencer',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CuriousAboutHealthScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Finance influencer',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CuriousAboutHealthScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppButton(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                text: 'Legal influencer',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CuriousAboutHealthScreen(),
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
