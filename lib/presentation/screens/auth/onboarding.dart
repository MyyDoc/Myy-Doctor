import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/auth/login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  String currentText = "";
  
  // Add your onboarding image paths here
  final List<String> onboardingImages = [
    "assets/images/myydoclogo.png",
    "assets/images/onboard1.png",
    "assets/images/onboard2.png",
    "assets/images/onboard3.jpg",
    "assets/images/onboard4.png",
    "assets/images/onboard5.png",
    "assets/images/onboard6.png",
    "assets/images/onboard7.png",
    "assets/images/onboard8.png",
    "assets/images/onboard9.png",
    "assets/images/onboard10.png",
  ];

  final List<String> buttonText = [
    "Learn health through foolproof minigames",
    "Relevant collection of  health news you need",
    "Know why you are sick with expert AI",
    "Search your Doctor at Myydoctor",
    "Private Flights to Doctors across the world",
    "Luxury Real Estate to heal with your Family",
    "Rejuvenation, Anti-aging and Gene Therapy ",
    "Accelerate Research with our developer tools",
    "Medical Courses, Conferences and Workshops",
    "Become a health influencer today",
  ];

  void _nextImage() {
    if (currentIndex < onboardingImages.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      // Navigate to login screen when reached the last image
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginAndSignUp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: currentIndex == 0 ? (){
          setState(() {
            currentIndex = currentIndex +1;
          });
          
        } : _nextImage,
        child: Container(
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
                  onboardingImages[currentIndex],
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),

if(currentIndex == 0)
              Positioned(
                bottom: -250,
                left: 0,
                right: 0,
                child: Image.asset("assets/images/myydocText.png", fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,)),
              
              // Page indicators
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingImages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              
              if(currentIndex != 0)
              // Skip button
              Positioned(
                top: 50,
                right: 20,
                child: TextButton(
                  onPressed: _navigateToLogin,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              if(currentIndex != 0)
              // Next/Get Started button
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: _nextImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F323C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: const Color.fromARGB(255, 180, 180, 0),
                        width: 2
                      )
                    ),
                  ),
                  child: Text(
                    currentIndex == onboardingImages.length - 1
                        ? 'Get Started'
                        : buttonText[currentIndex],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}