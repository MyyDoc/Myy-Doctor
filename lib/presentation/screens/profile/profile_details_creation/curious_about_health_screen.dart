// lib/screens/curious_about_health/curious_about_health_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/core/loader/loader.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_preference/save_profile_preference_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/patient_page.dart';
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
              child: BlocConsumer<SaveProfilePreferenceCubit, SaveProfilePreferenceState>(
                listener: (context, state) {
                  if(state is SavingProfilePreferenceSuccessState){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => state.page),
                    );
                  }
                  if(state is SavingProfilePreferenceFailureState){
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'General Health',
                            ontap: () {
                              context.read<SaveProfilePreferenceCubit>().savePreference('general health', const PatientPage());
                              
                            },
                          ),
                          const SizedBox(height: 16),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Organ Health',
                            ontap: () {
                              context.read<SaveProfilePreferenceCubit>().savePreference('Organ health', const PatientPage());
                            },
                          ),
                          const SizedBox(height: 16),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Sports Performance',
                            ontap: () {
                              context.read<SaveProfilePreferenceCubit>().savePreference('Sports health', const PatientPage());
                            },
                          ),
                          const SizedBox(height: 16),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Aging Health',
                            ontap: () {
                              context.read<SaveProfilePreferenceCubit>().savePreference('Aging health', const PatientPage());
                            },
                          ),
                          const SizedBox(height: 16),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Public Health',
                            ontap: () {
                              context.read<SaveProfilePreferenceCubit>().savePreference('Public health', const PatientPage());
                            },
                          ),
                        ],
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
      ),
    );
  }
}
