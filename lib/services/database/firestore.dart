import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreServices {
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  String? get currentUserEmail => FirebaseAuth.instance.currentUser?.email;

  // Generate a short, unique order ID (4-6 characters)
  Future<String> generateOrderId({int length = 6}) async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String orderId;

    // Keep generating until a unique ID is found
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

  // Save the orders to the database
  Future<DocumentReference> saveOrdersToDatabase(String receipt,
      {String? mpesaReceiptNumber}) async {
    final userEmail = currentUserEmail;

    if (userEmail == null) {
      throw Exception('User must be authenticated to save orders');
    }

    // Generate unique order ID
    final orderId = await generateOrderId();

    // Calculate estimated delivery time (45 minutes from now)
    final estimatedDeliveryTime = DateTime.now().add(Duration(minutes: 45));

    return await orders.add({
      'orderId': orderId,
      'userEmail': userEmail,
      'date': DateTime.now(),
      'orders': receipt,
      'delivery_status': 'pending',
      'estimatedDeliveryTime': estimatedDeliveryTime,
      if (mpesaReceiptNumber != null) 'MpesaReceiptNumber': mpesaReceiptNumber,
    });
  }

  // Get real-time stream of pending orders for current user
  Stream<QuerySnapshot> getPendingOrdersStream() {
    final userEmail = currentUserEmail;

    if (userEmail == null) {
      return Stream.empty();
    }

    return orders
        .where('userEmail', isEqualTo: userEmail)
        .where('delivery_status', isEqualTo: 'pending')
        .snapshots();
  }

  // Get all orders for current user (for order history)
  Stream<QuerySnapshot> getUserOrdersStream() {
    final userEmail = currentUserEmail;

    if (userEmail == null) {
      return Stream.empty();
    }

    return orders
        .where('userEmail', isEqualTo: userEmail)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get orders by status for current user
  Stream<QuerySnapshot> getOrdersByStatus(String status) {
    final userEmail = currentUserEmail;

    if (userEmail == null) {
      return Stream.empty();
    }

    return orders
        .where('userEmail', isEqualTo: userEmail)
        .where('delivery_status', isEqualTo: status)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Update delivery status
  Future<void> updateDeliveryStatus(String orderId, String newStatus) async {
    await orders.doc(orderId).update({
      'delivery_status': newStatus,
    });
  }

  // Get single order by ID
  Future<DocumentSnapshot> getOrderById(String orderId) async {
    return await orders.doc(orderId).get();
  }

  // Get order by custom orderId field
  Future<DocumentSnapshot?> getOrderByOrderId(String orderId) async {
    try {
      final querySnapshot =
          await orders.where('orderId', isEqualTo: orderId).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print('Error fetching order by orderId: $e');
      return null;
    }
  }

  // Delete order (if needed)
  Future<void> deleteOrder(String orderId) async {
    await orders.doc(orderId).delete();
  }

  // Get orders by email (useful for admin functionality)
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
        // Include both Firestore document ID and custom orderId
        data['documentId'] = doc.id;
        return data;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching latest order: $e');
      return null;
    }
  }
}
