import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/home/homescreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(),)),
        child: Container(
          child: Container(
            height: 300,
            width: double.infinity,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}