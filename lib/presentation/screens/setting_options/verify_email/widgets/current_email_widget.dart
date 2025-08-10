import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class CurrentEmailWidget extends StatelessWidget {
  final Function()? onPress;
  const CurrentEmailWidget({super.key, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 40),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mail, size: 50, color: AppColors.scaffoldWhite),
          ),
          SizedBox(height: 10),
          Text(
            'Your Email address has been verified successfully.',
            style: TextStyle(color: AppColors.grey),
          ),
          SizedBox(height: 20),
          Text(
            'rahuljaicsam@gmail.com',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          TextButton(
            onPressed: () {
              if (onPress != null) {
                onPress!();
              }
            },
            child: Text(
              'Want to change your email address?',
              style: TextStyle(color: AppColors.buttonBlue),
            ),
          ),
        ],
      ),
    );
  }
}
