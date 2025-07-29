import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/setting_options/verify_email/global_variable.dart';
import 'package:myydoctor/presentation/screens/setting_options/verify_email/widgets/change_email_widget.dart';
import 'package:myydoctor/presentation/screens/setting_options/verify_email/widgets/current_email_widget.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isChangeEmailScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWhite,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        centerTitle: true,
        title: Text(
          'Verify Email',
          style: TextStyle(
            color: AppColors.caramel,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: isForChangeEmailG ? ChangeEmailWidget(onPress: (){
              setState(() {
                isForChangeEmailG = false;
              });
            }) : CurrentEmailWidget(onPress: (){
              setState(() {
                isForChangeEmailG = true;
              });
            },)
          ),
        ),
      ),
    );
  }
}
