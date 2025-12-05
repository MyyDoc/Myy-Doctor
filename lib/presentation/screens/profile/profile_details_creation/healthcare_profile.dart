import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_preference/save_profile_preference_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/medical_registration.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';

class HealthcareProfile extends StatelessWidget {
  const HealthcareProfile({super.key});

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
                            text: 'MBBS / MD / DO / DM/MCh',
                            ontap: () {
                              SaveProfilePreferenceCubit.fieldOfWork =
                                  'MBBS / MD / DO / DM/MCH';
                              context.read<SaveProfilePreferenceCubit>().savePreference('MBBS / MD / DO / DM/MCH', MedicalRegistrationScreen());
                            },
                          ),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'BSc / MSc / PhD',
                            ontap: () {
                              SaveProfilePreferenceCubit.fieldOfWork =
                                  'BSc / MSc / PhD';
                                  context.read<SaveProfilePreferenceCubit>().savePreference('BSc / MSc / PhD', MedicalRegistrationScreen());
                            },
                          ),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Alternative Medicine',
                            ontap: () {
                              SaveProfilePreferenceCubit.fieldOfWork =
                                  'Alternative Medicine';
                              context.read<SaveProfilePreferenceCubit>().savePreference('Alternative Medicine', MedicalRegistrationScreen());
                            },
                          ),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Nurse / PA',
                            ontap: () {
                              SaveProfilePreferenceCubit.fieldOfWork = 'Nurse / PA';
                              context.read<SaveProfilePreferenceCubit>().savePreference('Nurse / PA', MedicalRegistrationScreen());
                            },
                          ),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Administrator /MBA',
                            ontap: () {
                              SaveProfilePreferenceCubit.fieldOfWork =
                                  'Administrator / MBA';
                              context.read<SaveProfilePreferenceCubit>().savePreference('Administrator / MBA', MedicalRegistrationScreen());
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
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
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
