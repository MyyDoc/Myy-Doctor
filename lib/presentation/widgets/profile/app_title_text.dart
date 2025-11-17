
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';


class AppTitleText extends StatelessWidget {
  final String title;

  const AppTitleText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.titleText,
      ),
    );
  }
}
