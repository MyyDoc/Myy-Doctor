import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class SecondAppButton extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String text;
  final Function? ontap;
  const SecondAppButton({super.key, required this.screenHeight, required this.screenWidth,required this.text, this.ontap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(ontap!= null){
          ontap!();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: screenWidth * 0.9,
            height: screenHeight * 0.07,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Container(
            width: screenWidth * 0.9 - 5,
            height: screenHeight * 0.07 - 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [AppColors.darkBlue, AppColors.lightBlue],
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
