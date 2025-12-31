import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_preference/save_profile_preference_cubit.dart';
import 'package:myydoctor/presentation/widgets/app_snackbar.dart';

<<<<<<< HEAD
=======
import 'package:myydoctor/presentation/screens/home/homescreen.dart';
import 'package:myydoctor/presentation/screens/home/homescreen_body.dart';
import 'package:myydoctor/presentation/widgets/profile/vip.dart';
import 'package:shared_preferences/shared_preferences.dart';

>>>>>>> maxwell_dev
class ReconfirmRegistrationScreen extends StatefulWidget {
  final String registerNumber;
  final String cityCode;

  const ReconfirmRegistrationScreen({
    super.key,
    required this.registerNumber,
    required this.cityCode,
  });

  @override
  State<ReconfirmRegistrationScreen> createState() =>
      _ReconfirmRegistrationScreenState();
}

class _ReconfirmRegistrationScreenState
    extends State<ReconfirmRegistrationScreen> {
  late final TextEditingController cityCodeController;
  late final TextEditingController reregisterNumberController;

  @override
  void initState() {
    super.initState();
    cityCodeController = TextEditingController(text: widget.cityCode);
    reregisterNumberController = TextEditingController();
  }

  @override
  void dispose() {
    cityCodeController.dispose();
    reregisterNumberController.dispose();
    super.dispose();
  }

  void _onConfirmPressed() {
    if (reregisterNumberController.text.trim() !=
        widget.registerNumber.trim()) {
      showAppSnackBar(
        context,
        'Registration number does not match, please re-enter',
      );
      return;
    }

    SaveProfilePreferenceCubit.doctorRegistrationNumber =
        widget.registerNumber;

    showAppSnackBar(
      context,
      'Registration number confirmed successfully',
    );

    /// navigation will be handled in next flow
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFDDEFF4),
              Color(0xFF6F9BAA),
              Color(0xFF0D1A1F),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: screenHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 61),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE6BA63),
                          width: 10,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    const SizedBox(height: 43),
                    const Text(
                      "MEDICAL REGISTRATION",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                        color: Color(0xFF752C00),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// CITY CODE (TN)
                        _inputBox(
                          width: 64,
                          controller: cityCodeController,
                          hint: "TN",
                        ),
                        const SizedBox(width: 10),

                        /// REG NUMBER
                        _inputBox(
                          width: 210,
                          controller: reregisterNumberController,
                          hint: "XXXXXXXX",
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.15),
<<<<<<< HEAD
                    _confirmButton(),
=======

                    // Reconfirm Button
                    Container(
                      width: 360,
                      height: 53,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: const Color(0xFFE6BA63), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(255),
                            offset: const Offset(0, 4),
                            blurRadius: 20,
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF000000),
                            Color(0xFF51839D),
                          ],
                          stops: [0.0217, 0.4848],
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if(reregisterNumberController.text != widget.registerNumber){
                            showAppSnackBar(context, 'registoration number dees not match, please re-enter');
                            return;
                          }
                          SaveProfilePreferenceCubit.doctorRegistrationNumber = widget.registerNumber;
                          showAppSnackBar(context, 'Registration number confirmed successfully');
                          // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Homescreen(),), (route) => false,);
                        // onPressed: () async{
                        //   SharedPreferences prefs = await SharedPreferences.getInstance();
                        //   await prefs.setBool('isLoggedIn', true);
                        //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Homescreen(),), (route) => false,);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Reconfirm Registration Number",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),



                      
                    ),
>>>>>>> maxwell_dev
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputBox({
    required double width,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6BA63), width: 2),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 40),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 40,
            color: Colors.black38,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _confirmButton() {
    return Container(
      width: 360,
      height: 53,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE6BA63), width: 3),
        gradient: const LinearGradient(
          colors: [Colors.black, Color(0xFF51839D)],
        ),
      ),
      child: TextButton(
        onPressed: _onConfirmPressed,
        child: const Text(
          "Reconfirm Registration Number",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
