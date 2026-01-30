import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/core/loader/loader.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_preference/save_profile_preference_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile_screen.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';

class InfluencerTypeScreen extends StatelessWidget {
  const InfluencerTypeScreen({super.key});

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
                            text: 'Medical influencer',
                            ontap: () {
                              context.read<SaveProfilePreferenceCubit>().savePreference('medical influencer', ProfileScreen());
                            },
                          ),
                          const SizedBox(height: 16),

                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Lifestyle Influencer',
                            ontap: () {
                              context.read<SaveProfilePreferenceCubit>().savePreference('lifestyle influencer', ProfileScreen());
                            },
                          ),
                          const SizedBox(height: 16),

                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'IT influencer',
                            ontap: () {
                              context.read<SaveProfilePreferenceCubit>().savePreference('IT influencer', ProfileScreen());
                            },
                          ),
                          const SizedBox(height: 16),

                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Finance influencer',
                            ontap: () {
                              context.read<SaveProfilePreferenceCubit>().savePreference('Finance influencer', ProfileScreen());
                            },
                          ),
                          const SizedBox(height: 16),

                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Legal influencer',
                            ontap: () {
                              context.read<SaveProfilePreferenceCubit>().savePreference('Legal influencer', ProfileScreen());
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
