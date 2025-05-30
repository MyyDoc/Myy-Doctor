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

// Container(
//         height: 50,
//         width: double.infinity,
//         color: Color(0xFF0A1A27),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Icon(Icons.home_rounded, color: Colors.white, size: 32,),
//             Icon(Icons.search, color: Colors.white, size: 32,),
//             Icon(Icons.add_box_outlined, color: Colors.white, size: 32,),
//             Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 32,),
//             Icon(Icons.notifications_none_rounded, color: Colors.white, size: 32,)
//           ],
//         ),
//       ),