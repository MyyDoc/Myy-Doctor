import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/home/homescreen.dart';


class ReconfirmRegistrationScreen extends StatelessWidget {
  const ReconfirmRegistrationScreen({super.key});

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

                    // Big Box
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFE6BA63),
                          width: 10,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),

                    const SizedBox(height: 43),

                    // Title
                    const SizedBox(
                      width: 359,
                      height: 36,
                      child: Text(
                        "MEDICAL REGISTRATION",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          height: 1.0,
                          color: Color(0xFF752C00),
                        ),
                      ),
                    ),

                    // Extra spacing to push TN/XXXXXXXX down into middle
                    const SizedBox(height: 60),

                    // TN + XXXXXXXX Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TN Box
                        Container(
                          width: 64,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(
                              color: const Color(0xFFE6BA63),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 55,
                            height: 48,
                            child: TextField(
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 40,
                                height: 1.0,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                hintText: "TN",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 40,
                                  color: Colors.black38,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              cursorColor: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // XXXXXXXX Box
                        Container(
                          width: 210,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(
                              color: const Color(0xFFE6BA63),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 183,
                            height: 48,
                            child: TextField(
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 40,
                                height: 1.0,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                hintText: "XXXXXXXX",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 40,
                                  color: Colors.black38,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              cursorColor: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Keep original button spacing
                    SizedBox(height: screenHeight * 0.15),

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
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Homescreen(),), (route) => false,);
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}