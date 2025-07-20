import 'package:flutter/material.dart';

class SelfieScreen extends StatelessWidget {
  const SelfieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF172832),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 154,
              left: 64,
              child: Container(
                width: 300,
                height: 500,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  border: Border.all(
                    color: const Color(0xFFE6BA63),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(150),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 64),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Adjust your face to fill up the bubble\nHold the pose for 3 seconds",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'EB Garamond',
                        fontWeight: FontWeight.w400,
                        fontSize: 30,
                        color: Color(0xFFE6BA63),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/age-verification');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6BA63),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text("Capture Selfie"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
