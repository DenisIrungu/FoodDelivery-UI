import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shlih_kitchen/models/restaurant.dart';
import 'package:shlih_kitchen/screens/payments/redeem/redemptionprovider.dart';
import 'package:shlih_kitchen/services/database/firestore.dart';

class RedemptionPaymentPage extends StatefulWidget {
  const RedemptionPaymentPage({super.key});

  @override
  State<RedemptionPaymentPage> createState() => _RedemptionPaymentPageState();
}

class _RedemptionPaymentPageState extends State<RedemptionPaymentPage> {
  String resultMessage = '';
  double? userPoints;
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
          userPoints = points;
          _isPointsLoading = false;
        });
      } catch (e) {
        setState(() {
          if (e.toString().contains('Connection reset by peer') ||
              e.toString().contains('network')) {
            resultMessage =
                'Network error, please check your connection and try again 😞';
          } else {
            resultMessage = 'Error fetching points: $e 😞';
          }
          _isPointsLoading = false;
        });
      }
    } else {
      setState(() {
        resultMessage = 'Please sign in to redeem points 🌟';
        _isPointsLoading = false;
      });
    }
  }

  Future<void> _redeemPoints() async {
    final restaurant = context.read<Restaurant>();
    final redemptionProvider = context.read<RedemptionProvider>();
    final amount = restaurant.getTotalPrice();
    final receipt = restaurant.displayCartReceipt();
    final requiredPoints = amount; // 1 point = 1 KES

    final userEmail = context.read<FirestoreServices>().currentUserEmail;
    if (userEmail == null) {
      setState(() {
        resultMessage = 'Please sign in to redeem points 🌟';
      });
      return;
    }

    if (_isPointsLoading || userPoints == null) {
      setState(() {
        resultMessage = 'Please wait, loading your points... ⏳';
      });
      return;
    }

    if (userPoints! < requiredPoints) {
      final pointsNeeded = requiredPoints - userPoints!;
      setState(() {
        resultMessage =
            'Oops! You need ${pointsNeeded.toStringAsFixed(2)} more points to redeem this order! 😋 Keep ordering to earn more!';
      });
      return;
    }

    final confirmRedemption = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Redemption'),
        content: Text(
            'Use ${requiredPoints.toStringAsFixed(2)} points to pay KES ${amount.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmRedemption != true) {
      setState(() {
        resultMessage = 'Redemption cancelled 😞';
      });
      return;
    }

    setState(() {
      resultMessage = 'Processing redemption... ⏳';
    });

    try {
      await redemptionProvider.initiateRedemption(
        amount: amount,
        receipt: receipt,
        onSuccess: (message) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('🎉 Redemption Successful!'),
              content: SingleChildScrollView(child: Text(message)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    restaurant.clearCart();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          _fetchUserPoints();
        },
        onError: (error) {
          setState(() {
            if (error.contains('Failed to save payment record')) {
              resultMessage =
                  'Error saving payment record, but order was saved. Please contact support 😞';
            } else {
              resultMessage = error;
            }
          });
        },
      );
    } catch (e) {
      setState(() {
        resultMessage = 'Error redeeming points: $e 😞';
      });
    }
  }

  void _cancelRedemption() {
    final redemptionProvider = context.read<RedemptionProvider>();
    redemptionProvider.cancelRedemption();
    setState(() {
      resultMessage = 'Redemption cancelled. You can try again. 😞';
    });
  }

  @override
  Widget build(BuildContext context) {
    final amount = context.watch<Restaurant>().getTotalPrice();
    final redemptionProvider = context.watch<RedemptionProvider>();
    final requiredPoints = amount; // 1 point = 1 KES

    return Scaffold(
      appBar: AppBar(title: const Text('Pay with Points')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Total Amount: KES ${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _isPointsLoading
                  ? 'Loading points... ⏳'
                  : 'Your Points: ${userPoints?.toStringAsFixed(2) ?? 'Sign in to view points 🌟'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            const Text(
              'Note: 1 point = KES 1. You must have enough points to cover the full amount.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (redemptionProvider.isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _getStatusText(redemptionProvider.redemptionStatus),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _cancelRedemption,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Cancel Redemption'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: userPoints != null && userPoints! >= requiredPoints
                    ? _redeemPoints
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Redeem Points'),
              ),
            ],
            const SizedBox(height: 20),
            if (resultMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getMessageBackgroundColor(),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getMessageBorderColor()),
                ),
                child: Text(
                  resultMessage,
                  style: TextStyle(color: _getMessageTextColor()),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'initiating':
        return 'Initiating redemption... ⏳';
      case 'success':
        return 'Redemption successful! 🎉';
      case 'error':
        return 'Redemption failed 😞';
      case 'insufficient_points':
        return 'Oops! Insufficient points 😋';
      case 'cancelled':
        return 'Redemption cancelled 😞';
      default:
        return 'Processing redemption... ⏳';
    }
  }

  Color _getMessageBackgroundColor() {
    if (resultMessage.contains('Error') ||
        resultMessage.contains('Failed') ||
        resultMessage.contains('Insufficient') ||
        resultMessage.contains('Network') ||
        resultMessage.contains('payment record')) {
      return Colors.red.shade50;
    } else if (resultMessage.contains('cancelled') ||
        resultMessage.contains('Cancel')) {
      return Colors.orange.shade50;
    } else if (resultMessage.contains('successful') ||
        resultMessage.contains('🎉')) {
      return Colors.green.shade50;
    }
    return Colors.blue.shade50;
  }

  Color _getMessageBorderColor() {
    if (resultMessage.contains('Error') ||
        resultMessage.contains('Failed') ||
        resultMessage.contains('Insufficient') ||
        resultMessage.contains('Network') ||
        resultMessage.contains('payment record')) {
      return Colors.red.shade200;
    } else if (resultMessage.contains('cancelled') ||
        resultMessage.contains('Cancel')) {
      return Colors.orange.shade200;
    } else if (resultMessage.contains('successful') ||
        resultMessage.contains('🎉')) {
      return Colors.green.shade200;
    }
    return Colors.blue.shade200;
  }

  Color _getMessageTextColor() {
    if (resultMessage.contains('Error') ||
        resultMessage.contains('Failed') ||
        resultMessage.contains('Insufficient') ||
        resultMessage.contains('Network') ||
        resultMessage.contains('payment record')) {
      return Colors.red.shade700;
    } else if (resultMessage.contains('cancelled') ||
        resultMessage.contains('Cancel')) {
      return Colors.orange.shade700;
    } else if (resultMessage.contains('successful') ||
        resultMessage.contains('🎉')) {
      return Colors.green.shade700;
    }
    return Colors.blue.shade700;
  }
}
