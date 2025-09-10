import 'package:flutter/material.dart';
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'Medical influencer',
                    ontap: () {
                    
                    },
                  ),
                  const SizedBox(height: 16),
                    
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'Lifestyle Influencer',
                    ontap: () {
                     
                    },
                  ),
                  const SizedBox(height: 16),
                    
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'IT influencer',
                    ontap: () {
                    
                    },
                  ),
                  const SizedBox(height: 16),
                    
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'Finance influencer',
                    ontap: () {
                     
                    },
                  ),
                  const SizedBox(height: 16),
                    
                  SecondAppButton(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    text: 'Legal influencer',
                    ontap: () {
                      
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
