import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shlih_kitchen/services/database/firestore.dart';

class RedemptionProvider extends ChangeNotifier {
  bool isLoading = false;
  String? redemptionStatus;
  final FirestoreServices _firestoreServices = FirestoreServices();

  String? get currentUserEmail {
    const maxRetries = 3;
    var attempt = 0;

    while (attempt < maxRetries) {
      try {
        final email = FirebaseAuth.instance.currentUser?.email;
        if (email != null) {
          print('Successfully fetched currentUserEmail: $email');
          return email;
        }
        print('No authenticated user found, attempt ${attempt + 1}');
        attempt++;
        if (attempt < maxRetries) {
          return null; 
        }
      } catch (e) {
        print('Error getting current user email, attempt ${attempt + 1}: $e');
        attempt++;
        if (attempt < maxRetries) {
          return null; 
        }
      }
    }
    print('Failed to fetch currentUserEmail after $maxRetries attempts');
    return null;
  }

  Future<void> initiateRedemption({
    required double amount,
    required String receipt,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    isLoading = true;
    redemptionStatus = 'initiating';
    notifyListeners();

    const maxRetries = 3;
    var attempt = 0;
    String? orderId;

    while (attempt < maxRetries) {
      try {
        final userEmail = currentUserEmail;
        if (userEmail == null) {
          isLoading = false;
          redemptionStatus = 'error';
          notifyListeners();
          onError("Please sign in to redeem points 🌟");
          return;
        }

        // Validate required fields
        if (amount <= 0 || receipt.isEmpty) {
          isLoading = false;
          redemptionStatus = 'error';
          notifyListeners();
          onError("Invalid amount or receipt 😞");
          return;
        }

        // Check if user has sufficient points (1 point = 1 KES)
        final requiredPoints = amount;
        final hasEnoughPoints = await _firestoreServices.hasSufficientPoints(
            userEmail, requiredPoints);

        if (!hasEnoughPoints) {
          isLoading = false;
          redemptionStatus = 'insufficient_points';
          notifyListeners();
          final currentPoints =
              await _firestoreServices.getUserPoints(userEmail);
          final pointsNeeded = requiredPoints - currentPoints;
          onError(
              "Oops! You need ${pointsNeeded.toStringAsFixed(2)} more points to redeem this order! 😋 Keep ordering to earn more!");
          return;
        }

        // Generate unique orderId and receipt number
        orderId = await _firestoreServices.generateOrderId();
        final receiptNumber = await _firestoreServices.generateReceiptNumber();
        final estimatedDeliveryTime =
            DateTime.now().add(const Duration(minutes: 45));

        // Create identical order data for both collections
        final orderData = {
          'orderId': orderId,
          'userEmail': userEmail,
          'receipt': receipt,
          'ReceiptNumber': receiptNumber,
          'delivery_status': 'pending',
          'estimatedDeliveryTime': Timestamp.fromDate(estimatedDeliveryTime),
          'date': FieldValue.serverTimestamp(),
          'pointsEarned': 0.0,
          'paymentMethod': 'redemption',
        };

        // Use transaction to ensure atomic writes
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // Deduct points
          print('Deducting $requiredPoints points for $userEmail');
          await _firestoreServices.deductPointsFromUser(
              userEmail, requiredPoints);

          // Save to orders collection
          print(
              'Saving to orders collection with orderId=$orderId: $orderData');
          transaction.set(FirestoreServices.orders.doc(orderId), orderData);

          // Save to payments collection
          print(
              'Saving to payments collection with orderId=$orderId: $orderData');
          transaction.set(FirestoreServices.payments.doc(orderId), orderData);
        });

        isLoading = false;
        redemptionStatus = 'success';
        notifyListeners();

        onSuccess("🎉 Redemption Successful!\n\n"
            "📋 Order ID: $orderId\n"
            "🧾 Receipt Number: $receiptNumber\n"
            "📦 Status: PENDING\n"
            "🚚 Estimated delivery: 45 minutes\n\n"
            "Thank you for choosing Shlih Kitchen!");
        return;
      } catch (e) {
        attempt++;
        print(
            'Redemption attempt $attempt failed${orderId != null ? " for orderId=$orderId" : ""}: $e');
        if (attempt == maxRetries) {
          isLoading = false;
          redemptionStatus = 'error';
          notifyListeners();
          if (e.toString().contains('Connection reset by peer') ||
              e.toString().contains('network')) {
            onError(
                "Network error, please check your connection and try again 😞");
          } else {
            onError(
                "Redemption failed${orderId != null ? " for orderId=$orderId" : ""}: $e 😞");
          }
          return;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  void cancelRedemption() {
    print('Redemption cancelled by user');
    isLoading = false;
    redemptionStatus = 'cancelled';
    notifyListeners();
  }

  void resetRedemptionState() {
    print('Resetting redemption state');
    isLoading = false;
    redemptionStatus = null;
    notifyListeners();
  }

  @override
  void dispose() {
    print('Disposing RedemptionProvider...');
    super.dispose();
  }
}
