// lib/screens/curious_about_health/curious_about_health_screen.dart
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/patient_screen.dart';
import 'package:myydoctor/presentation/widgets/profile/app_title_text.dart';
import 'package:myydoctor/presentation/widgets/profile/profile_option.dart';


class CuriousAboutHealthScreen extends StatelessWidget {
  const CuriousAboutHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF172832),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppTitleText(title: 'Curious about health'),
              const SizedBox(height: 32),
              ProfileOptionButton(
                text: 'General Health',
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
              ProfileOptionButton(
                text: 'Organ Health',
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
              ProfileOptionButton(
                text: 'Sports Performance',
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
              ProfileOptionButton(
                text: 'Aging Health',
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
              ProfileOptionButton(
                text: 'Public Health',
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
