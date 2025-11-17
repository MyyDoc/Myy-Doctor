import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class SettingSubHeadingText extends StatelessWidget {
  final String text;
  const SettingSubHeadingText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey),
          ),
        ),
      ],
    );
  }
}
