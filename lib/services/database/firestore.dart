import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  //Get collection of orders
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  //Save the orders to the database
  Future<void> saveOrdersToDatabase(String receipt) async {
    await orders.add({
      'date': DateTime.now(),
      'orders': receipt,
    });
  }
}
