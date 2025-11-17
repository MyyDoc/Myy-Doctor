import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/auth/onboarding.dart';
import 'package:myydoctor/presentation/screens/home/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasVisited = prefs.getBool('hasVisited') ?? false;

    if (!hasVisited) {
      _navigateToHome();
    } else {
      await prefs.setBool('hasVisited', true);
      _navigateToOnboarding();
    }
  }

  void _navigateToOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen(),),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Homescreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1F323C), // Top
                Color(0xFF000000), // Bottom
              ],
            ),
          ),
          child: Stack(
            children: [
              // Main onboarding image
              Center(
                child: Image.asset(
                   "assets/images/myydoclogo.png",
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),

              Positioned(
                bottom: -250,
                left: 0,
                right: 0,
                child: Image.asset("assets/images/myydocText.png", fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,)),
            ],
          ),
        ),
    
    );
  }
}
