import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/presentation/screens/home/homescreen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_preference/save_profile_preference_cubit.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';

class HealthcareEnterprise extends StatelessWidget {
  const HealthcareEnterprise({super.key});

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
                            text: 'Bio Technology / Devices',
                            ontap: (){
                              context.read<SaveProfilePreferenceCubit>().savePreference('Bio Technology / Devices', Homescreen());
                            },
                          ),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Pharmaceutical',
                            ontap: (){
                              context.read<SaveProfilePreferenceCubit>().savePreference('Pharmaceutical', Homescreen());
                            },
                          ),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Insurance',
                            ontap: (){
                              context.read<SaveProfilePreferenceCubit>().savePreference('Insurance', Homescreen());
                            },
                          ),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'IT and Softwares',
                            ontap: (){
                              context.read<SaveProfilePreferenceCubit>().savePreference('IT and Softwares', Homescreen());
                            },
                          ),
                          SecondAppButton(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            text: 'Hospital / Lab / Foundation',
                            ontap: (){
                              context.read<SaveProfilePreferenceCubit>().savePreference('Hospital / Lab / Foundation', Homescreen());
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
