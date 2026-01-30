import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/core/loader/loader.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_preference/save_profile_preference_cubit.dart';
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
            child: BlocConsumer<SaveProfilePreferenceCubit,
                SaveProfilePreferenceState>(
              listener: (context, state) {
                if (state is SavingProfilePreferenceSuccessState) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => state.page),
                  );
                }

                if (state is SavingProfilePreferenceFailureState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error)),
                  );
                }
              },
              builder: (context, state) {
                final loading =
                    state is SavingPrefilePreferenceLoadingState;

                return Stack(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'I am a Healthcare Professional ( Doctor )',
                            ontap: () {
                              SaveProfilePreferenceCubit.occupation =
                                  'Doctor';

                              context
                                  .read<SaveProfilePreferenceCubit>()
                                  .createAndsavePreference(
                                    'Doctor',
                                    const HealthcareProfile(),
                                  );
                            },
                          ),

                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'I am a Healthcare Enterprise',
                            ontap: () {
                              SaveProfilePreferenceCubit.occupation =
                                  'healthcare enterprise';

                              context
                                  .read<SaveProfilePreferenceCubit>()
                                  .createAndsavePreference(
                                    'Healthcare Enterprise',
                                    const HealthcareEnterprise(),
                                  );
                            },
                          ),

                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'I want to be an Influencer',
                            ontap: () {
                              context
                                  .read<SaveProfilePreferenceCubit>()
                                  .createAndsavePreference(
                                    'Influencer',
                                    const InfluencerTypeScreen(),
                                  );
                            },
                          ),

                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'I am curious about health',
                            ontap: () {
                              context
                                  .read<SaveProfilePreferenceCubit>()
                                  .createAndsavePreference(
                                    'Curious About Health',
                                    const CuriousAboutHealthScreen(),
                                  );
                            },
                          ),

                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'I am a Patient',
                            ontap: () {
                              context
                                  .read<SaveProfilePreferenceCubit>()
                                  .createAndsavePreference(
                                    'Patient',
                                    const PatientPage(),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),

                    if (loading)
                      Container(
                        width: screenWidth,
                        height: screenHeight,
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: MyyDocLoader()
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
