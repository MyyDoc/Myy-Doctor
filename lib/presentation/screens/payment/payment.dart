import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedPlanIndex = 0;

  final List<Map<String, dynamic>> plans = [
    {
      'duration': '1',
      'period': 'Month',
      'price': '₹1000/Mo',
      'total': '₹1000',
    },
    {
      'duration': '3',
      'period': 'Months',
      'price': '₹900/Mo',
      'total': '₹2700',
    },
    {
      'duration': '6',
      'period': 'Months',
      'price': '₹800/Mo',
      'total': '₹4800',
    },
    {
      'duration': '12',
      'period': 'Months',
      'price': '₹700/Mo',
      'total': '₹8400',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A23),
      body: SafeArea(
        child: Column(
          children: [
            // Close Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      'MYYDOCTOR\nPREMIUM',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF6C14D),
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Avatar placeholder
                    Container(
                      width: 70,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: const Color(0xFFF6C14D),
                          width: 3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Price
                    Text(
                      '₹1000',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Watch unlimited content',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == 0
                                ? const Color(0xFFF6C14D)
                                : Colors.white54,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 30),

                    // Plan box
                    Container(
                      width: 150,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFF6C14D),
                          width: 2,
                        ),
                        color: Colors.black,
                      ),
                      child: Column(
                        children: [
                          Text(
                            plans[selectedPlanIndex]['duration'],
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plans[selectedPlanIndex]['period'],
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            plans[selectedPlanIndex]['price'],
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              color: const Color(0xFFF6C14D),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            plans[selectedPlanIndex]['total'],
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // CONTINUE Button with double border effect
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFFF6C14D),
                          width: 3,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFF6C14D),
                            width: 6,
                          ),
                          color: const Color(0xFF0E1A23),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            print('Selected plan: ${plans[selectedPlanIndex]}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'CONTINUE',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF6C14D),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
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