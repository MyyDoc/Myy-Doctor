
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class ProfileOptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ProfileOptionButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.buttonBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.buttonText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
