import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class VerifyEmailButton extends StatelessWidget {
  final String text;
  final Function? onPress;
  const VerifyEmailButton({super.key, required this.text, this.onPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onPress != null) {
          onPress!();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.caramel,
          borderRadius: BorderRadius.circular(90)
        ),
        child: Center(child: Text(text,style: TextStyle(fontWeight: FontWeight.bold),),),
        
      ),
    );
  }
}