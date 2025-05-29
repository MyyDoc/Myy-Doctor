import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/auth/login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                ),
            child: Container(
              width: double.infinity,
              height: 300,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
