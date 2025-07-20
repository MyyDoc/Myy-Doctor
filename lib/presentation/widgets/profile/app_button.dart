
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class AppButton extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final String text;
  final VoidCallback? onTap;

  const AppButton({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.buttonBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
