import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:shlih_kitchen/components/mybutton.dart';
import 'package:shlih_kitchen/screens/manageaccount.dart';
import 'package:shlih_kitchen/screens/orders/deliveredorders.dart';
import 'package:shlih_kitchen/screens/orders/pendingorders.dart';
import 'package:shlih_kitchen/utils/whatsapp_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shlih_kitchen/services/database/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? '';

    // Static data for loyalty rewards
    const int points = 450;
    const List<Map<String, dynamic>> rewards = [
      {'name': 'Cover Delivery Fee', 'pointsRequired': 140, 'type': 'discount'},
      {'name': 'Cover Meal Bill', 'pointsRequired': 550, 'type': 'meal'},
    ];

    // Determine next achievable reward for progress bar
    final nextRewardPoints = points >= 140 ? 550 : 140;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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

                  // Fetch latest order
                  final firestore = FirestoreServices();
                  final latestOrder =
                      await firestore.fetchLatestOrderForUser(email);
                  final orderId = latestOrder?['id'] ?? 'N/A';

                  whatsAppChatOption(context, name, email, orderId);
                }
              },
              text: 'Chat with us',
              color: Color(0xFF0F2A12),
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
                                builder: (context) => PendingOrders()));
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
                                builder: (context) => DeliveredOrders()));
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
                  Text(
                    '🏆 Points Earned: $points',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2A12),
                    ),
                  ),
                  const SizedBox(height: 3),
                  LinearProgressIndicator(
                    value: points / nextRewardPoints,
                    color: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.grey.shade300,
                    minHeight: 6,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'You are ${nextRewardPoints - points} points away from ${points >= 140 ? 'Covering a Meal Bill' : 'Covering a Delivery Fee'}!',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Available Rewards',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2A12),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // TODO: Replace static pointsRequired with dynamic values from Firestore (e.g., distance-based fee, order total)
                  SizedBox(
                    height: 100, // As you added
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        final reward = rewards[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${reward['name']} (${reward['pointsRequired']} pts)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F2A12),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Redemption'),
                                      content: Text(
                                        'Redeem ${reward['pointsRequired']} points for ${reward['name']} worth KES ${reward['pointsRequired']}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                        TextButton(
                                          child: const Text('Confirm'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title:
                                                    const Text('Redeem Reward'),
                                                content: Text(
                                                  points >=
                                                          reward[
                                                              'pointsRequired']
                                                      ? 'Redeemed ${reward['name']} worth KES ${reward['pointsRequired']} successfully!'
                                                      : 'Need ${reward['pointsRequired'] - points} more points to redeem ${reward['name']}.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('OK'),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Redeem',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF0F2A12),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Note: Delivery Fee is KES 35/km (min KES 35). Meal Bill includes food + taxes.',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('How Loyalty Works'),
                          content: const Text(
                            'Earn 1 point for every KES 10 spent.\n\nRedeem 1 point = KES 1 for:\n- Cover Delivery Fee (KES 35/km, min KES 35)\n- Cover Meal Bill (food + taxes)\nPoints must cover the full cost.',
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Got it'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'How it works',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0F2A12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
