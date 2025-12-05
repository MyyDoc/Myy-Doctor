import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String paymentId;
  final String amount;
  final String description;
  final String duration;

  Payment({
    required this.paymentId,
    required this.amount,
    required this.description,
    required this.duration,
  });

  factory Payment.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Payment(
      paymentId: data['paymentId'] ?? '',
      amount: data['amount'] ?? '',
      description: data['description'] ?? '',
      duration: data['duration'] ?? '',
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'] ?? '',
      amount: json['amount'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
    );
  }
}
