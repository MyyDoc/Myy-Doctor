import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myydoctor/data/payment/payment_model.dart';
import 'package:myydoctor/domain/payment/payments_repository.dart';

import '../../../core/loader/loader.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedPlanIndex = 0;
  bool isLoading = false;
  List<Payment> availablePayments = [];

  fetchAvailablePaymentOffers() async {
    setState(() {
      isLoading = true;
    });

    availablePayments = await PaymentsRepository().getPayments();

    setState(() {
      isLoading = false;
    });

    print(availablePayments);
    print("Payments fetched ✅");
  }

  @override
  void initState() {
    super.initState();
    fetchAvailablePaymentOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A23),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: MyyDocLoader())
                : availablePayments.isEmpty
                ? const Center(
                  child: Text(
                    "No payments available",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                : Column(
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

                            // Oval Avatar placeholder
                            Container(
                              width: 60,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: const Color(0xFFF6C14D),
                                  width: 3,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                availablePayments.length,
                                (index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          index == selectedPlanIndex
                                              ? const Color(0xFFF6C14D)
                                              : Colors.white54,
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Carousel
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 200,
                                enlargeCenterPage: true,
                                enableInfiniteScroll: false,
                                autoPlay: false,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    selectedPlanIndex = index;
                                  });
                                },
                              ),
                              items:
                                  availablePayments.map((payment) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            border: Border.all(color: Colors.amber),
                                            borderRadius: BorderRadius.circular(2)
                                          ),
                                          padding: EdgeInsets.all(8),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(payment.duration, style: TextStyle(color: Colors.white, fontSize: 25),),
                                              const SizedBox(height: 10,),
                                              Text("${payment.amount}/month", style: TextStyle(color: Colors.amber, fontSize: 30)),
                                              const SizedBox(height: 10,),
                                              Text(
                                                "₹ ${payment.amount}", style: TextStyle(color: Colors.white, fontSize: 30),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                            ),

                            const Spacer(),

                            // CONTINUE Button
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
                                    final selected =
                                        availablePayments[selectedPlanIndex];
                                    print(
                                      'Selected plan: ${selected.paymentId} - ${selected.description}',
                                    );
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
