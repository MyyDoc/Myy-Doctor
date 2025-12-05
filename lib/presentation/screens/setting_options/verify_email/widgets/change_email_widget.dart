import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/setting_options/verify_email/widgets/verify_email_button.dart';
import 'package:myydoctor/presentation/screens/setting_options/verify_email/widgets/verify_email_textfield.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class ChangeEmailWidget extends StatelessWidget {
  final Function? onPress;
  const ChangeEmailWidget({super.key, this.onPress});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          color: AppColors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info, color: AppColors.red),
              // SizedBox(width: 10),
              Text(
                'This new email address will be your login email.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your current email address:',
                style: TextStyle(color: AppColors.grey),
              ),
              SizedBox(height: 10),
              Text(
                'rahuljaicasam@gmail.com',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your new email address',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              VerifyEmailTextfield(hintText: 'Email Address'),
            ],
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your current password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              VerifyEmailTextfield(hintText: 'Password', isForPassword: true),
            ],
          ),
        ),
        SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth * 0.6,
              child: VerifyEmailButton(text: 'Send Email Verification',onPress: onPress,),
            ),
          ],
        ),
      ],
    );
  }
}
