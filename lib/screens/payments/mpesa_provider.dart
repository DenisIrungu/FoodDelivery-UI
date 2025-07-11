import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MpesaProvider extends ChangeNotifier {
  bool isLoading = false;
  String? paymentStatus;

  Future<void> initiatePayment({
    required String phone,
    required double amount,
    required String name,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse("https://stkpush-jiaqytu5na-uc.a.run.app"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "amount": amount, "name": name}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final checkoutID = data['CheckoutRequestID'];
        listenForPayment(checkoutID, onSuccess, onError);
      } else {
        isLoading = false;
        notifyListeners();
        onError("Payment request failed");
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      onError("Error: $e");
    }
  }

  void listenForPayment(String checkoutID, Function(String) onSuccess, Function(String) onError) {
    FirebaseFirestore.instance
        .collection('payments')
        .where('CheckoutRequestID', isEqualTo: checkoutID)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        isLoading = false;
        notifyListeners();

        final data = snapshot.docs.first.data();
        final resultCode = data['ResultCode'];

        if (resultCode == 0) {
          final amount = data['Amount'];
          final receipt = data['MpesaReceiptNumber'];
          onSuccess("Payment of Ksh $amount successful!\nReceipt: $receipt");
        } else {
          onError("Payment failed: ${data['ResultDesc']}");
        }
      }
    });
  }
}
