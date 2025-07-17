import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:shlih_kitchen/components/mybutton.dart';
import 'package:shlih_kitchen/screens/manageaccount.dart';
import 'package:shlih_kitchen/screens/orders/deliveredorders.dart';
import 'package:shlih_kitchen/screens/orders/pendingorders.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight - 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
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
                    text: 'Chat with us',
                    color: Theme.of(context).colorScheme.onSurface,
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
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary),
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

                  // 🟡 Loyalty Rewards Section (New)
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
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(3),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🏆 Points Earned: 450',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F2A12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.9, // 450 / 500
                          color: Theme.of(context).colorScheme.primary,
                          backgroundColor: Colors.grey.shade300,
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You are 50 points away from your next reward!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('How Loyalty Works'),
                                content: const Text(
                                  'Earn 1 point for every Ksh 10 spent.\n\nAt 500 points, get free delivery or a discount!',
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Got it'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text(
                            'How it works',
                            style: TextStyle(
                              color: Color(0xFF0F2A12),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     const Text(
              //       'Account Management',
              //       style: TextStyle(
              //         color: Color(0xFF0F2A12),
              //         fontSize: 30,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //     const SizedBox(height: 10),
              //     Container(
              //       padding: const EdgeInsets.all(10),
              //       width: double.infinity,
              //       decoration: BoxDecoration(
              //         border: Border.all(
              //             color: Theme.of(context).colorScheme.primary),
              //         borderRadius: BorderRadius.circular(3),
              //         color: Theme.of(context).colorScheme.surface,
              //       ),
              //       child: GestureDetector(
              //         onTap: () {
              //           Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                   builder: (context) => ManageAccount()));
              //         },
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: const [
              //             Text(
              //               'Manage Account',
              //               style: TextStyle(
              //                 color: Color(0xFF0F2A12),
              //                 fontSize: 15,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //             Icon(Icons.chevron_right, size: 24),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
