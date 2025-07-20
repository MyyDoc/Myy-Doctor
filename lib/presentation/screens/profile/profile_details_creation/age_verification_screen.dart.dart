import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/profile_selection_screen.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';
import 'package:myydoctor/presentation/widgets/profile/second_app_button.dart';



class AgeVerificationScreen extends StatefulWidget {
  const AgeVerificationScreen({super.key,});

  @override
  State<AgeVerificationScreen> createState() => _AgeVerificationScreenState();
}

class _AgeVerificationScreenState extends State<AgeVerificationScreen> {
  final TextEditingController _age1Controller = TextEditingController();
  final TextEditingController _age2Controller = TextEditingController();
  final FocusNode _age1Focus = FocusNode();
  final FocusNode _age2Focus = FocusNode();

  @override
  void dispose() {
    _age1Controller.dispose();
    _age2Controller.dispose();
    _age1Focus.dispose();
    _age2Focus.dispose();
    super.dispose();
  }

  void _handleInput(String value, int index) {
    if (value.length == 1) {
      if (index == 1) {
        _age2Focus.requestFocus();
      }
    }
  }

  void _handleBackspace(RawKeyEvent event, int index) {
    if (event.logicalKey.keyLabel == 'Backspace') {
      if (index == 2 && _age2Controller.text.isEmpty) {
        _age1Controller.clear();
        _age1Focus.requestFocus();
      }
      if (index == 1 && _age1Controller.text.isEmpty) {
        _age1Focus.unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final boxWidth = screenWidth * 0.28;
    final boxHeight = screenHeight * 0.22;
    final borderSize = 10;
    final outerRadius = 25.0;
    final middleRadius = outerRadius * 0.9;
    // final innerRadius = outerRadius * 0.8;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBlue, AppColors.lightBlue],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shadow container
                      Container(
                        width: boxWidth,
                        height: boxHeight,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(-4, 0),
                            ),
                          ],
                        ),
                      ),
                      // Border (outer colored layer)
                      Container(
                        width: boxWidth - borderSize,
                        height: boxHeight - borderSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(middleRadius),
                          color: AppColors.gold,
                        ),
                      ),
                      // Inner actual profile background
                      //  Container(
                      //   width: boxHeight - borderSize * 2 - 2,
                      //   height: boxHeight - borderSize * 2 - 2,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(innerRadius),
                      //     color: AppColors.blue,
                      //   ),
                      //   child: const Center(
                      //     child: Text(
                      //       'Selfie',
                      //       style: TextStyle(color: Colors.white),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(width: boxWidth - borderSize * 2 - 2,height: boxHeight - borderSize * 2 - 2, child: Image.file(File(widget.imagePath)))
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'How old are you',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAgeBox(
                    context,
                    controller: _age1Controller,
                    focusNode: _age1Focus,
                    index: 1,
                    onChanged: _handleInput,
                    onKey: _handleBackspace,
                  ),
                  const SizedBox(width: 10),
                  _buildAgeBox(
                    context,
                    controller: _age2Controller,
                    focusNode: _age2Focus,
                    index: 2,
                    onChanged: _handleInput,
                    onKey: _handleBackspace,
                  ),
                ],
              ),
              SecondAppButton(screenHeight: screenHeight, screenWidth: screenWidth,text: 'Confirm Age',ontap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=> ProfileTypeScreen()));
              },)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeBox(
    BuildContext context, {
    required TextEditingController controller,
    required FocusNode focusNode,
    required int index,
    required Function(String, int) onChanged,
    required Function(RawKeyEvent, int) onKey,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) => onKey(event, index),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          maxLength: 1,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
          ),
          onChanged: (val) => onChanged(val, index),
        ),
      ),
    );
  }
}
