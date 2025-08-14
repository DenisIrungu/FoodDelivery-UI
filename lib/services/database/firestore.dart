import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreServices {
  static final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');
  static final CollectionReference payments =
      FirebaseFirestore.instance.collection('payments');
  static final CollectionReference rewards =
      FirebaseFirestore.instance.collection('rewards');

  String? get currentUserEmail => FirebaseAuth.instance.currentUser?.email;

  Future<String> generateOrderId({int length = 6}) async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String orderId;

    while (true) {
      orderId =
          List.generate(length, (_) => chars[random.nextInt(chars.length)])
              .join();
      final orderQuery =
          await orders.where('orderId', isEqualTo: orderId).limit(1).get();
      final paymentQuery =
          await payments.where('orderId', isEqualTo: orderId).limit(1).get();
      if (orderQuery.docs.isEmpty && paymentQuery.docs.isEmpty) {
        break;
      }
    }

    return orderId;
  }

  Future<String> generateReceiptNumber() async {
    const prefix = 'RED';
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String receiptNumber;

    while (true) {
      final randomPart =
          List.generate(5, (_) => chars[random.nextInt(chars.length)]).join();
      receiptNumber = '$prefix$randomPart';
      final querySnapshot = await orders
          .where('ReceiptNumber', isEqualTo: receiptNumber)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        break;
      }
    }

    return receiptNumber;
  }

  Future<DocumentReference> saveOrdersToDatabase({
    String? orderId,
    required String receipt,
    String? ReceiptNumber,
    String? userEmail,
    String paymentMethod = 'mpesa',
  }) async {
    final effectiveUserEmail = userEmail ?? currentUserEmail;
    if (effectiveUserEmail == null) {
      print('Error: User must be authenticated to save orders');
      throw Exception('User must be authenticated to save orders');
    }

    // Generate orderId if not provided
    final effectiveOrderId = orderId ?? await generateOrderId();

    // Validate orderId uniqueness
    final orderQuery = await orders
        .where('orderId', isEqualTo: effectiveOrderId)
        .limit(1)
        .get();
    final paymentQuery = await payments
        .where('orderId', isEqualTo: effectiveOrderId)
        .limit(1)
        .get();
    if (orderQuery.docs.isNotEmpty || paymentQuery.docs.isNotEmpty) {
      print(
          'Error: orderId $effectiveOrderId already exists in orders or payments');
      throw Exception('Order ID $effectiveOrderId already exists');
    }

    final estimatedDeliveryTime =
        DateTime.now().add(const Duration(minutes: 45));
    final totalPriceMatch =
        RegExp(r'Total price:\s*\$?KES?\s*([\d.]+)').firstMatch(receipt);
    final totalPrice =
        totalPriceMatch != null ? double.parse(totalPriceMatch.group(1)!) : 0.0;
    final double pointsEarned =
        paymentMethod == 'redemption' ? 0.0 : totalPrice / 100;

    final orderData = {
      'orderId': effectiveOrderId,
      'userEmail': effectiveUserEmail,
      'receipt': receipt,
      'ReceiptNumber': ReceiptNumber ?? '',
      'delivery_status': 'pending',
      'estimatedDeliveryTime': Timestamp.fromDate(estimatedDeliveryTime),
      'date': FieldValue.serverTimestamp(),
      'pointsEarned': pointsEarned,
      'paymentMethod': paymentMethod,
    };

    print(
        'Saving order to orders collection with orderId=$effectiveOrderId: $orderData');
    await orders.doc(effectiveOrderId).set(orderData);
    final orderRef = orders.doc(effectiveOrderId);

    if (paymentMethod != 'redemption' && pointsEarned > 0) {
      try {
        print(
            'Attempting to add $pointsEarned points for $effectiveUserEmail (order)');
        await addPointsToUser(effectiveUserEmail, pointsEarned);
        print(
            'Successfully added $pointsEarned points for $effectiveUserEmail (order)');
      } catch (e) {
        print('Failed to add points for order $effectiveOrderId: $e');
        rethrow;
      }
    }

    return orderRef;
  }

  Future<void> savePaymentToDatabase({
    required String checkoutRequestId,
    required String receipt,
    String? userEmail,
    String? ReceiptNumber,
    String paymentMethod = 'mpesa',
  }) async {
    final effectiveUserEmail =
        userEmail ?? currentUserEmail ?? 'not-provided@example.com';
    final estimatedDeliveryTime =
        DateTime.now().add(const Duration(minutes: 45));
    final totalPriceMatch =
        RegExp(r'Total price:\s*\$?KES?\s*([\d.]+)').firstMatch(receipt);
    final totalPrice =
        totalPriceMatch != null ? double.parse(totalPriceMatch.group(1)!) : 0.0;
    final double pointsEarned =
        paymentMethod == 'redemption' ? 0.0 : totalPrice / 100;

    final paymentData = {
      'orderId': checkoutRequestId,
      'userEmail': effectiveUserEmail,
      'receipt': receipt,
      'ReceiptNumber': ReceiptNumber ?? '',
      'delivery_status': 'pending',
      'estimatedDeliveryTime': Timestamp.fromDate(estimatedDeliveryTime),
      'date': FieldValue.serverTimestamp(),
      'pointsEarned': pointsEarned,
      'paymentMethod': paymentMethod,
    };

    print(
        'Saving payment to payments collection with orderId=$checkoutRequestId: $paymentData');
    await payments.doc(checkoutRequestId).set(paymentData);

    if (paymentMethod != 'redemption' && pointsEarned > 0) {
      try {
        print(
            'Attempting to add $pointsEarned points for $effectiveUserEmail (payment)');
        await addPointsToUser(effectiveUserEmail, pointsEarned);
        print(
            'Successfully added $pointsEarned points for $effectiveUserEmail (payment)');
      } catch (e) {
        print('Failed to add points for payment $checkoutRequestId: $e');
        rethrow;
      }
    }
  }

  Future<double> getUserPoints(String userEmail) async {
    try {
      await ensureUserInRewards(userEmail);
      final docSnapshot = await rewards.doc(userEmail).get();
      final data = docSnapshot.data() as Map<String, dynamic>?;
      final points = (data?['points'] ?? 0.0).toDouble();
      print('Fetched points for $userEmail: $points');
      return points;
    } catch (e) {
      print('Error getting user points for $userEmail: $e');
      return 0.0;
    }
  }

  Future<void> addPointsToUser(String userEmail, double pointsToAdd) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docRef = rewards.doc(userEmail);
        final docSnapshot = await transaction.get(docRef);

        if (!docSnapshot.exists) {
          transaction.set(docRef, {
            'userEmail': userEmail,
            'points': pointsToAdd,
          });
          print(
              'Created rewards document for $userEmail with $pointsToAdd points');
        } else {
          final data = docSnapshot.data() as Map<String, dynamic>?;
          final currentPoints = (data?['points'] ?? 0.0).toDouble();
          transaction.update(docRef, {
            'points': FieldValue.increment(pointsToAdd),
          });
          print(
              'Updated $userEmail: Added $pointsToAdd points, new total: ${currentPoints + pointsToAdd}');
        }
      });
    } catch (e) {
      print('Error adding points to $userEmail: $e');
      throw Exception('Failed to add points: $e');
    }
  }

  Future<void> deductPointsFromUser(
      String userEmail, double pointsToDeduct) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docRef = rewards.doc(userEmail);
        final docSnapshot = await transaction.get(docRef);

        if (!docSnapshot.exists) {
          throw Exception('User not found in rewards collection');
        }

        final data = docSnapshot.data() as Map<String, dynamic>?;
        final currentPoints = (data?['points'] ?? 0.0).toDouble();
        if (currentPoints < pointsToDeduct) {
          throw Exception(
              'Insufficient points. Available: $currentPoints, Required: $pointsToDeduct');
        }

        transaction.update(docRef, {
          'points': FieldValue.increment(-pointsToDeduct),
        });
        print(
            'Deducted $pointsToDeduct points from $userEmail. Remaining: ${currentPoints - pointsToDeduct}');
      });
    } catch (e) {
      print('Error deducting points from $userEmail: $e');
      throw Exception('Failed to deduct points: $e');
    }
  }

  Future<bool> hasSufficientPoints(
      String userEmail, double requiredPoints) async {
    final userPoints = await getUserPoints(userEmail);
    return userPoints >= requiredPoints;
  }

  Future<void> ensureUserInRewards(String userEmail) async {
    try {
      final docSnapshot = await rewards.doc(userEmail).get();
      if (!docSnapshot.exists) {
        await rewards.doc(userEmail).set({
          'userEmail': userEmail,
          'points': 0.0,
        });
        print('Created new rewards document for $userEmail');
      }
    } catch (e) {
      print('Error ensuring user in rewards: $userEmail: $e');
      throw Exception('Failed to ensure user in rewards: $e');
    }
  }

  Stream<QuerySnapshot> getPendingOrdersStream() {
    final userEmail = currentUserEmail;
    if (userEmail == null) return Stream.empty();

    return orders
        .where('userEmail', isEqualTo: userEmail)
        .where('delivery_status', isEqualTo: 'pending')
        .snapshots();
  }

  Stream<QuerySnapshot> getUserOrdersStream() {
    final userEmail = currentUserEmail;
    if (userEmail == null) return Stream.empty();

    return orders
        .where('userEmail', isEqualTo: userEmail)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getOrdersByStatus(String status) {
    final userEmail = currentUserEmail;
    if (userEmail == null) return Stream.empty();

    return orders
        .where('userEmail', isEqualTo: userEmail)
        .where('delivery_status', isEqualTo: status)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> updateDeliveryStatus(String orderId, String newStatus) async {
    await orders.doc(orderId).update({
      'delivery_status': newStatus,
    });
  }

  Future<DocumentSnapshot> getOrderById(String orderId) async {
    return await orders.doc(orderId).get();
  }

  Future<DocumentSnapshot?> getOrderByOrderId(String orderId) async {
    try {
      final querySnapshot =
          await orders.where('orderId', isEqualTo: orderId).limit(1).get();
      return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
    } catch (e) {
      print('Error fetching order by orderId: $e');
      return null;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    await orders.doc(orderId).delete();
  }

  Stream<QuerySnapshot> getOrdersByEmail(String email) {
    return orders
        .where('userEmail', isEqualTo: email)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllPendingOrders() {
    return orders
        .where('delivery_status', isEqualTo: 'pending')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> fetchLatestOrderForUser(
      String userEmail) async {
    try {
      final querySnapshot = await orders
          .where('userEmail', isEqualTo: userEmail)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        data['documentId'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error fetching latest order: $e');
      return null;
    }
  }

  Future<void> fixExistingOrderPoints() async {
    print('Starting to fix existing order points...');
    final snapshot = await orders.get();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final receipt = data['receipt'] as String;
      final paymentMethod = data['paymentMethod'] ?? 'mpesa';

      final totalPriceMatch =
          RegExp(r'Total price:\s*\$?KES?\s*([\d.]+)').firstMatch(receipt);
      final totalPrice = totalPriceMatch != null
          ? double.parse(totalPriceMatch.group(1)!)
          : 0.0;
      final double correctPointsEarned =
          paymentMethod == 'redemption' ? 0.0 : totalPrice / 100;

      await orders.doc(doc.id).update({
        'pointsEarned': correctPointsEarned,
        'paymentMethod': paymentMethod,
      });

      if (paymentMethod != 'redemption' && correctPointsEarned > 0) {
        try {
          print(
              'Attempting to add $correctPointsEarned points for ${data['userEmail']} (fix)');
          await addPointsToUser(data['userEmail'], correctPointsEarned);
          print(
              'Successfully added $correctPointsEarned points for ${data['userEmail']} (fix)');
        } catch (e) {
          print('Failed to add points for order ${doc.id}: $e');
        }
      }
    }
    print('Finished fixing existing order points');
  }
}
