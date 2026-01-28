import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class CurrentEmailWidget extends StatelessWidget {
  final String email;
  final bool isVerified;
  final VoidCallback onResend;
  final VoidCallback onChangeEmail;

  const CurrentEmailWidget({
    super.key,
    required this.email,
    required this.isVerified,
    required this.onResend,
    required this.onChangeEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVerified ? Icons.verified : Icons.mail_outline,
              size: 60,
              color: isVerified ? Colors.green : AppColors.scaffoldWhite,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isVerified
                ? 'Your email has been verified successfully!'
                : 'Please verify your email address',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            email,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 30),
          if (!isVerified)
            ElevatedButton.icon(
              onPressed: onResend,
              icon: const Icon(Icons.email),
              label: const Text('Resend Verification Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBlue,
              ),
            ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onChangeEmail,
            child: const Text(
              'Want to change your email address?',
              style: TextStyle(color: AppColors.buttonBlue),
            ),
          ),
        ],
      ),
    );
  }
}