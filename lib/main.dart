import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myydoctor/presentation/screens/auth/onboarding.dart';
import 'package:myydoctor/presentation/screens/auth/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demoooooo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
         textTheme: GoogleFonts.cormorantGaramondTextTheme(),
      ),
      home: SplashScreen()
    );
  }
}

