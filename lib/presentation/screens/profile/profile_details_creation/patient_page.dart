import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/core/loader/loader.dart';
import 'package:myydoctor/presentation/screens/home/homescreen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_preference/save_profile_preference_cubit.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';

class PatientPage extends StatelessWidget {
  const PatientPage({super.key});

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
                            text: 'Search your doctor',
                            ontap: (){
                              context.read<SaveProfilePreferenceCubit>().savePreference('Search your doctor', const Homescreen());
                            },
                          ),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Search your disease',
                            ontap: (){
                              context.read<SaveProfilePreferenceCubit>().savePreference('Search your disease', const Homescreen());
                            },
                          ),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Book an appointment',
                            ontap: (){
                              context.read<SaveProfilePreferenceCubit>().savePreference('book an appointment', const Homescreen());
                            },
                          ),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Search your treatment',
                            ontap: (){
                              context.read<SaveProfilePreferenceCubit>().savePreference('search your treatment', const Homescreen());
                            },
                          ),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Search patient community',
                            ontap: (){
                              context.read<SaveProfilePreferenceCubit>().savePreference('search patient community', const Homescreen());
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
