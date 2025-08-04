import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreServices {
  // Centralized Firestore collection references
  static final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');
  static final CollectionReference payments =
      FirebaseFirestore.instance.collection('payments');

  String? get currentUserEmail => FirebaseAuth.instance.currentUser?.email;

  /// Generates a unique order ID of specified length (default 6 characters).
  Future<String> generateOrderId({int length = 6}) async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String orderId;

    while (true) {
      orderId =
          List.generate(length, (_) => chars[random.nextInt(chars.length)])
              .join();
      final querySnapshot =
          await orders.where('orderId', isEqualTo: orderId).limit(1).get();
      if (querySnapshot.docs.isEmpty) {
        break; // ID is unique
      }
    }

    return orderId;
  }

  /// Saves an order to the 'orders' collection, matching the structure in index.js.
  Future<DocumentReference> saveOrdersToDatabase({
    required String receipt,
    String? mpesaReceiptNumber,
    String? userEmail,
  }) async {
    final effectiveUserEmail = userEmail ?? currentUserEmail;
    if (effectiveUserEmail == null) {
      throw Exception('User must be authenticated to save orders');
    }

    final orderId = await generateOrderId();
    final estimatedDeliveryTime =
        DateTime.now().add(const Duration(minutes: 45));

    return await orders.add({
      'orderId': orderId,
      'userEmail': effectiveUserEmail,
      'orders': receipt,
      'ReceiptNumber': mpesaReceiptNumber ?? '',
      'delivery_status': 'pending',
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'date': FieldValue.serverTimestamp(),
    });
  }

  /// Saves temporary payment data to the 'payments' collection.
  Future<void> savePaymentToDatabase({
    required String checkoutRequestId,
    required String receipt,
    String? userEmail,
  }) async {
    final effectiveUserEmail = userEmail ?? 'not-provided@example.com';
    await payments.doc(checkoutRequestId).set({
      'orderId': checkoutRequestId,
      'userEmail': effectiveUserEmail,
      'orders': receipt,
      'status': 'initiating',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Retrieves a stream of pending orders for the current user.
  Stream<QuerySnapshot> getPendingOrdersStream() {
    final userEmail = currentUserEmail;
    if (userEmail == null) return Stream.empty();

    return orders
        .where('userEmail', isEqualTo: userEmail)
        .where('delivery_status', isEqualTo: 'pending')
        .snapshots();
  }

  /// Retrieves a stream of all orders for the current user, sorted by date.
  Stream<QuerySnapshot> getUserOrdersStream() {
    final userEmail = currentUserEmail;
    if (userEmail == null) return Stream.empty();

    return orders
        .where('userEmail', isEqualTo: userEmail)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Retrieves a stream of orders by status for the current user.
  Stream<QuerySnapshot> getOrdersByStatus(String status) {
    final userEmail = currentUserEmail;
    if (userEmail == null) return Stream.empty();

    return orders
        .where('userEmail', isEqualTo: userEmail)
        .where('delivery_status', isEqualTo: status)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Updates the delivery status of an order.
  Future<void> updateDeliveryStatus(String orderId, String newStatus) async {
    await orders.doc(orderId).update({
      'delivery_status': newStatus,
    });
  }

  /// Retrieves a single order by its document ID.
  Future<DocumentSnapshot> getOrderById(String orderId) async {
    return await orders.doc(orderId).get();
  }

  /// Retrieves a single order by its custom orderId field.
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

  /// Deletes an order by its document ID.
  Future<void> deleteOrder(String orderId) async {
    await orders.doc(orderId).delete();
  }

  /// Retrieves a stream of orders for a specific email (useful for admin).
  Stream<QuerySnapshot> getOrdersByEmail(String email) {
    return orders
        .where('userEmail', isEqualTo: email)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Retrieves a stream of all pending orders.
  Stream<QuerySnapshot> getAllPendingOrders() {
    return orders
        .where('delivery_status', isEqualTo: 'pending')
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Fetches the latest order for a specific user.
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
}
