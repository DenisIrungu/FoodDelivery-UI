import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shlih_kitchen/models/restaurant.dart';
import 'package:shlih_kitchen/screens/payments/mpesa/mpesa_provider.dart';

class MpesaPaymentPage extends StatefulWidget {
  const MpesaPaymentPage({super.key});

  @override
  State<MpesaPaymentPage> createState() => _MpesaPaymentPageState();
}

class _MpesaPaymentPageState extends State<MpesaPaymentPage> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  String resultMessage = '';

  Future<void> _payWithMpesa() async {
    final restaurant = context.read<Restaurant>();
    final mpesaProvider = context.read<MpesaProvider>();

    final amount = restaurant.getTotalPrice();
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final receipt = restaurant.displayCartReceipt();

    // Validate input fields
    if (phone.isEmpty || name.isEmpty) {
      setState(() {
        resultMessage = 'Please fill all fields';
      });
      return;
    }

    // Validate phone number format
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (!cleanPhone.startsWith('254') || cleanPhone.length != 12) {
      setState(() {
        resultMessage = 'Please enter phone number in format 254XXXXXXXXX';
      });
      return;
    }

    // Clear previous messages
    setState(() {
      resultMessage = '';
    });

    try {
      await mpesaProvider.initiatePayment(
        phone: phone,
        amount: amount,
        name: name,
        receipt: receipt,
        onSuccess: (message) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('🎉 Payment Successful!'),
              content: SingleChildScrollView(
                child: Text(message),
              ),
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
        },
        onError: (error) {
          setState(() {
            resultMessage = error;
          });
        },
      );

      setState(() {
        resultMessage =
            'STK Push sent! Please check your phone and enter your M-Pesa PIN.';
      });
    } catch (e) {
      setState(() {
        resultMessage = 'Error: $e';
      });
    }
  }

  void _cancelPayment() {
    final mpesaProvider = context.read<MpesaProvider>();
    mpesaProvider.cancelPayment();
    setState(() {
      resultMessage = 'Payment cancelled. You can try again.';
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = context.watch<Restaurant>().getTotalPrice();
    final mpesaProvider = context.watch<MpesaProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pay with M-Pesa')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Total Amount: KES ${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number (e.g. 254719004342)',
                hintText: '254XXXXXXXXX',
                border: OutlineInputBorder(),
              ),
              enabled: !mpesaProvider.isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
              enabled: !mpesaProvider.isLoading,
            ),
            const SizedBox(height: 24),

            // Show loading indicator and status when processing
            if (mpesaProvider.isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _getStatusText(mpesaProvider.paymentStatus),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Cancel button when payment is processing
              OutlinedButton(
                onPressed: _cancelPayment,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Cancel Payment'),
              ),
            ] else ...[
              // Pay Now button when not processing
              ElevatedButton(
                onPressed: _payWithMpesa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Pay Now'),
              ),
            ],

            const SizedBox(height: 20),
            if (resultMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getMessageBackgroundColor(),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getMessageBorderColor(),
                  ),
                ),
                child: Text(
                  resultMessage,
                  style: TextStyle(
                    color: _getMessageTextColor(),
                  ),
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
        return 'Initiating payment request...';
      case 'waiting_for_payment':
        return 'Waiting for M-Pesa PIN entry...\nPlease check your phone.';
      case 'success':
        return 'Payment successful!';
      case 'error':
      case 'failed':
        return 'Payment failed';
      case 'timeout':
        return 'Payment timed out';
      case 'cancelled':
        return 'Payment cancelled';
      default:
        return 'Processing payment...';
    }
  }

  Color _getMessageBackgroundColor() {
    if (resultMessage.contains('Error') ||
        resultMessage.contains('Failed') ||
        resultMessage.contains('❌')) {
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
        resultMessage.contains('❌')) {
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
        resultMessage.contains('❌')) {
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
