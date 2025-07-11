import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shlih_kitchen/models/restaurant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MpesaPaymentPage extends StatefulWidget {
  const MpesaPaymentPage({super.key});

  @override
  State<MpesaPaymentPage> createState() => _MpesaPaymentPageState();
}

class _MpesaPaymentPageState extends State<MpesaPaymentPage> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  bool isLoading = false;
  String resultMessage = '';

  Future<void> _payWithMpesa() async {
    final restaurant = context.read<Restaurant>();
    final amount = restaurant.getTotalPrice(); // From Cart
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();

    if (phone.isEmpty || name.isEmpty) {
      setState(() {
        resultMessage = 'Please fill all fields';
      });
      return;
    }

    // Show info dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Processing'),
        content: const Text(
          'Dear customer, your payment request is being processed.\n'
          'Please wait for an M-Pesa push on your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Okay'),
          ),
        ],
      ),
    );

    setState(() {
      isLoading = true;
      resultMessage = '';
    });

    try {
      final url = Uri.parse('https://stkpush-jiaqytu5na-uc.a.run.app');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'amount': amount.ceil(), // Make sure it's an integer
          'name': name,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['ResponseCode'] == '0') {
        final account = data['accountReference'] ?? 'N/A';
        final pushedAmount = data['pushedAmount'] ?? amount;

        setState(() {
          resultMessage =
              'Do you want to pay KES ${pushedAmount.toStringAsFixed(0)} to Shlih Kitchen?\n'
              'Account number: $account';
        });
      } else {
        setState(() {
          resultMessage =
              'Payment failed: ${data['errorMessage'] ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        resultMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

    return Scaffold(
      appBar: AppBar(title: const Text('Pay with M-Pesa')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Total Amount: KES ${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number (e.g. 2547...)',
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _payWithMpesa,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Pay Now'),
            ),
            const SizedBox(height: 20),
            if (resultMessage.isNotEmpty)
              Text(
                resultMessage,
                style: const TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
