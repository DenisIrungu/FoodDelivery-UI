import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shlih_kitchen/models/restaurant.dart';
import 'package:shlih_kitchen/screens/payments/mpesa/mpesapayment.dart';
import 'package:shlih_kitchen/screens/payments/paymentpage.dart';
import 'package:shlih_kitchen/screens/payments/redeem/redemptionpaymentpage.dart';
import 'package:shlih_kitchen/services/database/firestore.dart';

class SelectPayment extends StatefulWidget {
  const SelectPayment({super.key});

  @override
  State<SelectPayment> createState() => _SelectPaymentState();
}

class _SelectPaymentState extends State<SelectPayment> {
  static const popupTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0F2A12),
  );

  String _statusMessage = '';
  double? _userPoints;
  bool _isPointsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserPoints();
  }

  Future<void> _fetchUserPoints() async {
    final userEmail = context.read<FirestoreServices>().currentUserEmail;
    if (userEmail != null) {
      try {
        final points =
            await context.read<FirestoreServices>().getUserPoints(userEmail);
        setState(() {
          _userPoints = points;
          _isPointsLoading = false;
        });
      } catch (e) {
        setState(() {
          _statusMessage = 'Error fetching points: $e 😞';
          _isPointsLoading = false;
        });
      }
    } else {
      setState(() {
        _statusMessage = 'Sign in to view your points 🌟';
        _isPointsLoading = false;
      });
    }
  }

  void _handleRedemptionTap(BuildContext context, double totalAmount) async {
    if (_isPointsLoading || _userPoints == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, loading your points... ⏳'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final userEmail = context.read<FirestoreServices>().currentUserEmail;
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to redeem points! 🌟'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final hasEnoughPoints = await context
        .read<FirestoreServices>()
        .hasSufficientPoints(userEmail, totalAmount);
    if (!hasEnoughPoints) {
      final pointsNeeded = totalAmount - (_userPoints ?? 0.0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Oops! You don’t have enough points. You need ${pointsNeeded.toStringAsFixed(2)} more points to redeem this order! 😋 Keep ordering to earn more!',
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    // Navigate to RedemptionPaymentPage if sufficient points
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RedemptionPaymentPage()),
    );
    print('Redemption selected');
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<Restaurant>();
    final totalAmount = restaurant.getTotalPrice();
    final isRedemptionEnabled =
        _userPoints != null && _userPoints! >= totalAmount && !_isPointsLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text(
          'Payment Option',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your payment method',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select how you would like to pay for your order',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: _statusMessage.contains('Error') ||
                            _statusMessage.contains('Sorry')
                        ? Colors.redAccent
                        : const Color(0xFF0F2A12),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            // Mpesa Option
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MpesaPaymentPage()),
                );
                print('Mpesa selected');
              },
              child: Card(
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  height: 100,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset('assets/mpesa.png'),
                      ),
                      const SizedBox(width: 25),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'M-Pesa',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pay with mobile money',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Credit Card Option (Disabled)

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentPage()),
                );
                print('Credit Card selected');
              },
              child: Card(
                elevation: 4,
                color: Theme.of(context).colorScheme.secondary,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      SizedBox(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset('assets/creditcard.jpg'),
                        ),
                      ),
                      const SizedBox(width: 25),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Credit Card',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pay with credit/debit card',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Redemption Option
            GestureDetector(
              onTap: () => _handleRedemptionTap(context, totalAmount),
              child: Card(
                elevation: 4,
                color: isRedemptionEnabled
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey[300],
                child: Container(
                  height: 100,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.redeem, size: 40),
                      ),
                      const SizedBox(width: 25),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Redeem Points',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _isPointsLoading
                                ? 'Loading points... ⏳'
                                : _userPoints == null
                                    ? 'Sign in to view points 🌟'
                                    : 'Use ${_userPoints!.toStringAsFixed(2)} points${_userPoints! < totalAmount ? ' (Need ${(totalAmount - _userPoints!).toStringAsFixed(2)} more)' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
