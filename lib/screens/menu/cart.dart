// cart.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shlih_kitchen/components/mybutton.dart';
import 'package:shlih_kitchen/models/restaurant.dart';
import 'package:shlih_kitchen/screens/select_payment.dart';
import '../../components/my_cart_tile.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant>(builder: (context, restaurant, child) {
      // Cart
      final userCart = restaurant.cart;

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          centerTitle: true,
          title: Text(
            'Cart',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title:
                                Text('Are you sure you want to clear the cart'),
                            actions: [
                              // Cancel button
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel')),
                              // Yes button
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    restaurant.clearCart();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Cart cleared successfully!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Text('Yes'))
                            ],
                          ));
                },
                icon: Icon(Icons.delete))
          ],
        ),
        body: Column(
          children: [
            // List of Cart
            Expanded(
              child: userCart.isEmpty
                  ? Center(child: Text('The cart is empty...'))
                  : ListView.builder(
                      itemCount: userCart.length,
                      itemBuilder: (context, index) {
                        final cartItem = userCart[index];
                        return MyCartTile(cartItem: cartItem);
                      },
                    ),
            ),
            // Total price display
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  Text(
                    '\$${restaurant.getTotalPrice().toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            // Checkout button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyButton(
                  text: 'Go to CheckOut',
                  onPress: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SelectPayment()));
                  },
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    });
  }
}
