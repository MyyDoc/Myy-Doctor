
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/payment/payment.dart';

class PaymentPosterContainer extends StatelessWidget {
  const PaymentPosterContainer({
    super.key,
    required this.textTheme,
  });

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15,
          right: 15,
          left: 15,
        ),
        child: Container(
          padding: EdgeInsets.all(15),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xFF1F323C),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "VIP",
                    style: textTheme.headlineSmall!
                        .copyWith(
                          color: Color(0xFFE5C7A2),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    "With 10 privileges".toUpperCase(),
                    style: textTheme.headlineSmall!
                        .copyWith(color: Color(0xFFE5C7A2)),
                  ),
                  Icon(
                    Icons
                        .keyboard_double_arrow_right_rounded,
                    color: Color(0xFFE5C7A2),
                    size: 32,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                height: 2,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF000000), // black
                      Color(0xFFE2C29A), // gold
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      "See Who Follows you",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE5C7A2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: 2,
                      height: 50, 
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF272C33), // top
                            Color(0xFFDCB98C), // middle
                            Color(0xFF1D242E), // bottom
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      "Send Message To Anyone",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE5C7A2),
                      ),
                    ),
                  ),
                  Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: 2,
                      height: 50, 
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF272C33), // top
                            Color(0xFFDCB98C), // middle
                            Color(0xFF1D242E), // bottom
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentScreen(),
                                ),
                              );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFFE5C7A2),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text("GET NOW", style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
