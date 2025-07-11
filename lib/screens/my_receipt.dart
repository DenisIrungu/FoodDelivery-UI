import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shlih_kitchen/models/restaurant.dart';

class MyReceipt extends StatelessWidget {
  const MyReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thank you message
        Text(
          'Thank you for your order!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),

        const SizedBox(height: 25),

        // Receipt container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(25),
          child: Consumer<Restaurant>(
            builder: (context, restaurant, child) => Text(
              restaurant.displayCartReceipt(),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 25),

        // Delivery time
        Text(
          'Estimated delivery time is 5:20 PM',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
