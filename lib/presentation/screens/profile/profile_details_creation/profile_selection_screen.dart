

import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/curious_about_health_screen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/enterprise_subrole_screen.dart.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/healthcare_subrole_screen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/influencer_type_screen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/patient_screen.dart';
import 'package:myydoctor/presentation/widgets/profile/app_title_text.dart';
import 'package:myydoctor/presentation/widgets/profile/profile_option.dart';


class ProfileTypeScreen extends StatelessWidget {
  const ProfileTypeScreen({super.key});

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
              const AppTitleText(title: 'Select your Profile Type'),
              const SizedBox(height: 32),
              ProfileOptionButton(
                text: 'I am a Healthcare Professional',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthcareProfessionalScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ProfileOptionButton(
                text: 'I am a Healthcare Enterprise',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthcareEnterpriseScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ProfileOptionButton(
                text: 'I want to be an Influencer',
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
              ProfileOptionButton(
                text: 'I am curious about health',
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
              ProfileOptionButton(
                text: 'I am a Patient',
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
