import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shlih_kitchen/components/mybutton.dart';
import 'package:shlih_kitchen/screens/orders/deliveredorders.dart';
import 'package:shlih_kitchen/screens/orders/pendingorders.dart';
import 'package:shlih_kitchen/screens/select_payment.dart';
import 'package:shlih_kitchen/services/database/firestore.dart';
import 'package:shlih_kitchen/utils/whatsapp_helper.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  Future<Map<String, dynamic>?> _fetchLatestOrder(String email) async {
    final firestore = FirestoreServices();
    return await firestore.fetchLatestOrderForUser(email);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreServices().ensureUserInRewards(user.email!);
    }

    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome $displayName',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              email,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            MyButton(
              onPress: () async {
                if (user != null) {
                  final email = user.email!;
                  final name = user.displayName ?? 'User';
                  final latestOrder =
                      await FirestoreServices().fetchLatestOrderForUser(email);
                  final orderId = latestOrder?['documentId'] ?? 'N/A';
                  whatsAppChatOption(context, name, email, orderId);
                }
              },
              text: 'Chat with us',
              color: const Color(0xFF0F2A12),
            ),
            const SizedBox(height: 10),
            const Text(
              'My Account',
              style: TextStyle(
                color: Color(0xFF0F2A12),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              thickness: 0.5,
              color: Theme.of(context).colorScheme.secondary,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(3),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shopping_bag, size: 30),
                        SizedBox(width: 20),
                        Text(
                          'Orders',
                          style: TextStyle(
                            color: Color(0xFF0F2A12),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 1,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PendingOrders()),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Pending Orders',
                            style: TextStyle(
                              color: Color(0xFF0F2A12),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 24),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DeliveredOrders()),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Delivered Orders',
                            style: TextStyle(
                              color: Color(0xFF0F2A12),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Loyalty Rewards',
              style: TextStyle(
                color: Color(0xFF0F2A12),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              thickness: 0.5,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(3),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  user == null
                      ? const Text(
                          'Sign in to view your points 🌟',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F2A12),
                          ),
                        )
                      : StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('rewards')
                              .doc(user.email)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                'Loading points... ⏳',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F2A12),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Text(
                                'Error loading points 😞',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              );
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text(
                                'Points: 0.00 🌟',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F2A12),
                                ),
                              );
                            }
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final points = (data['points'] ?? 0.0).toDouble();
                            return Text(
                              'Points: ${points.toStringAsFixed(2)} 🌟',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F2A12),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 10),
                  const Text(
                    'Earn 1 point for every KES 100 spent. Redeem points (1 point = KES 1) to pay for your order via Payment Options.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyButton(
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SelectPayment()),
                      );
                    },
                    text: 'Redeem Points',
                    color: const Color(0xFF0F2A12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
