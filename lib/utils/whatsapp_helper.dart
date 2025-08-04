import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void whatsAppChatOption(BuildContext context, String name, String email, String orderId) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        'My Order',
        'Payment Issue',
        'Cancel an Order',
        'General Inquiry'
      ].map((reason) {
        return ListTile(
          title: Text(reason),
          onTap: () {
            Navigator.pop(context);
            launchWhatsAppWithDetails(name, email, reason, orderId); 
          },
        );
      }).toList(),
    ),
  );
}

void launchWhatsAppWithDetails(String name, String email, String reason, String orderId) async {
  final message = '''
👋 Hi Admin! I need help with my recent order.

Name: $name
Email: $email
Order ID: #$orderId
Reason: $reason
''';

  final phoneNumber = '+254721904342';
  final url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    debugPrint('Could not launch WhatsApp');
  }
}
