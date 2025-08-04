import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MpesaProvider extends ChangeNotifier {
  bool isLoading = false;
  String? paymentStatus;
  StreamSubscription? _orderListener;
  StreamSubscription? _failureListener;
  Timer? _timeoutTimer;

  String? get currentUserEmail => FirebaseAuth.instance.currentUser?.email;

  Future<void> initiatePayment({
    required String phone,
    required double amount,
    required String name,
    required String receipt,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    _cancelAllListeners();

    isLoading = true;
    paymentStatus = 'initiating';
    notifyListeners();

    final userEmail = currentUserEmail;
    if (userEmail == null) {
      isLoading = false;
      paymentStatus = 'error';
      notifyListeners();
      onError("User must be authenticated to make payments");
      return;
    }

    // Validate all required fields
    if (phone.isEmpty || amount <= 0 || name.isEmpty || receipt.isEmpty) {
      isLoading = false;
      paymentStatus = 'error';
      notifyListeners();
      onError("Missing required fields: "
          "${phone.isEmpty ? 'phone ' : ''}"
          "${amount <= 0 ? 'amount ' : ''}"
          "${name.isEmpty ? 'name ' : ''}"
          "${receipt.isEmpty ? 'receipt' : ''}");
      return;
    }

    try {
      print('Initiating M-Pesa payment...');
      print('Parameters: phone=$phone, amount=$amount, name=$name, '
          'receipt=$receipt, userEmail=$userEmail');

      final res = await http.post(
        Uri.parse(
            "https://us-central1-fooddelivery-36ca1.cloudfunctions.net/stkPush"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "amount": amount,
          "name": name,
          "receipt": receipt,
          "userEmail": userEmail,
        }),
      );

      print('STK Push response status: ${res.statusCode}');
      print('STK Push response body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final checkoutID = data['CheckoutRequestID'];

        if (checkoutID != null) {
          paymentStatus = 'waiting_for_payment';
          notifyListeners();

          print('CheckoutRequestID received: $checkoutID');
          _listenForOrderCreation(checkoutID, onSuccess, onError);
        } else {
          isLoading = false;
          paymentStatus = 'error';
          notifyListeners();
          onError("Failed to get checkout ID from payment request");
        }
      } else {
        isLoading = false;
        paymentStatus = 'error';
        notifyListeners();

        try {
          final errorData = jsonDecode(res.body);
          onError(
              "Payment request failed: ${errorData['errorMessage'] ?? 'Unknown error'}");
        } catch (e) {
          onError("Payment request failed with status ${res.statusCode}");
        }
      }
    } catch (e) {
      print('Payment initiation error: $e');
      isLoading = false;
      paymentStatus = 'error';
      notifyListeners();
      onError("Network error: $e");
    }
  }

  void _listenForOrderCreation(
      String checkoutID, Function(String) onSuccess, Function(String) onError) {
    print('Starting to listen for order creation with CheckoutID: $checkoutID');

    _timeoutTimer = Timer(Duration(minutes: 5), () {
      print('Payment timeout reached for CheckoutID: $checkoutID');
      _cancelAllListeners();
      isLoading = false;
      paymentStatus = 'timeout';
      notifyListeners();
      onError("Payment timeout - please try again");
    });

    _orderListener = FirebaseFirestore.instance
        .collection('orders')
        .where('orderId', isEqualTo: checkoutID)
        .limit(1)
        .snapshots()
        .listen(
      (snapshot) {
        print(
            'Order listener triggered. Documents found: ${snapshot.docs.length}');

        if (snapshot.docs.isNotEmpty) {
          _timeoutTimer?.cancel();
          _cancelAllListeners();

          isLoading = false;
          paymentStatus = 'success';
          notifyListeners();

          final orderData = snapshot.docs.first.data();
          final mpesaReceiptNumber = orderData['MpesaReceiptNumber'] ?? 'N/A';
          final orderId = orderData['orderId'] ?? checkoutID;
          final deliveryStatus = orderData['delivery_status'] ?? 'pending';

          print('Order created successfully: $orderData');

          onSuccess("🎉 Payment Successful!\n\n"
              "📋 Order ID: $orderId\n"
              "🧾 M-Pesa Receipt: $mpesaReceiptNumber\n"
              "📦 Status: ${deliveryStatus.toUpperCase()}\n"
              "🚚 Estimated delivery: 45 minutes\n\n"
              "Thank you for choosing Shlih Kitchen!");
        }
      },
      onError: (error) {
        print('Order listener error: $error');
        _timeoutTimer?.cancel();
        _cancelAllListeners();
        isLoading = false;
        paymentStatus = 'error';
        notifyListeners();
        onError("Error monitoring payment: $error");
      },
    );

    Timer(Duration(seconds: 15), () {
      if (isLoading && paymentStatus != 'success') {
        _listenForFailedPayment(checkoutID, onError);
      }
    });
  }

  void _listenForFailedPayment(String checkoutID, Function(String) onError) {
    print(
        'Starting to listen for payment failures with CheckoutID: $checkoutID');

    _failureListener = FirebaseFirestore.instance
        .collection('failed_payments')
        .where('checkoutRequestID', isEqualTo: checkoutID)
        .limit(1)
        .snapshots()
        .listen(
      (snapshot) {
        print(
            'Failure listener triggered. Documents found: ${snapshot.docs.length}');

        if (snapshot.docs.isNotEmpty) {
          _timeoutTimer?.cancel();
          _cancelAllListeners();

          isLoading = false;
          paymentStatus = 'failed';
          notifyListeners();

          final failureData = snapshot.docs.first.data();
          final resultDesc = failureData['resultDesc'] ?? 'Payment failed';
          final resultCode = failureData['resultCode'] ?? 'Unknown';

          print('Payment failed: $failureData');

          String failureMessage = "❌ Payment Failed\n\n";

          switch (resultCode) {
            case 1032:
              failureMessage += "🚫 Payment was cancelled by user";
              break;
            case 1037:
              failureMessage += "⏰ Payment request timed out";
              break;
            case 1025:
              failureMessage += "🔐 Invalid PIN entered";
              break;
            case 1001:
              failureMessage += "💰 Insufficient balance";
              break;
            default:
              failureMessage += "Reason: $resultDesc\nError Code: $resultCode";
          }

          failureMessage +=
              "\n\nPlease try again or contact support if the problem persists.";

          onError(failureMessage);
        }
      },
      onError: (error) {
        print('Failure listener error: $error');
      },
    );
  }

  Future<bool> hasPendingOrders() async {
    final userEmail = currentUserEmail;
    if (userEmail == null) return false;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userEmail', isEqualTo: userEmail)
          .where('delivery_status', isEqualTo: 'pending')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking pending orders: $e');
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getUserOrderHistory() {
    final userEmail = currentUserEmail;
    if (userEmail == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('orders')
        .where('userEmail', isEqualTo: userEmail)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  void retryPaymentMonitoring(
      String checkoutID, Function(String) onSuccess, Function(String) onError) {
    if (isLoading) {
      onError("Payment monitoring is already in progress");
      return;
    }

    isLoading = true;
    paymentStatus = 'retrying';
    notifyListeners();

    _listenForOrderCreation(checkoutID, onSuccess, onError);
  }

  void _cancelAllListeners() {
    _orderListener?.cancel();
    _orderListener = null;

    _failureListener?.cancel();
    _failureListener = null;

    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }
  // Add this method to your MpesaProvider class

  void cancelPayment() {
    print('Payment cancelled by user');

    // Cancel all active listeners and timers
    _cancelAllListeners();

    // Reset the loading state
    isLoading = false;
    paymentStatus = 'cancelled';

    // Notify listeners to update the UI
    notifyListeners();
  }

  void resetPaymentState() {
    _cancelAllListeners();
    isLoading = false;
    paymentStatus = null;
    notifyListeners();
  }

  @override
  void dispose() {
    print('Disposing MpesaProvider...');
    _cancelAllListeners();
    super.dispose();
  }
}
