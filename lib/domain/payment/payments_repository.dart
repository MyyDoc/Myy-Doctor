import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myydoctor/data/payment/payment_model.dart';


class PaymentsRepository {
  Future<List<Payment>> getPayments() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('payment').get();

  return snapshot.docs
      .map((doc) => Payment.fromSnapshot(doc))
      .toList();
}
}


