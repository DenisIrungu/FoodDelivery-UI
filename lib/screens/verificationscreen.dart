import 'package:flutter/material.dart';
import 'package:shlih_kitchen/components/mybutton.dart';
import 'package:shlih_kitchen/services/auth_services.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthServices _authService = AuthServices();
  bool _isLoading = false;
  static const Color primaryColor = Color(0xFF0F2A12);

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  // Periodically check if email is verified
  void _checkEmailVerification() async {
    setState(() {
      _isLoading = true;
    });
    bool isVerified = await _authService.isEmailVerified();
    if (isVerified && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/congrats', (route) => false);
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Resend verification email
  Future<void> _resendEmail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _authService.resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent! Check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A verification email has been sent to your inbox.\nPlease click the link to verify your email.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    )
                  : MyButton(
                      text: 'Resend Email',
                      onPress: _resendEmail,
                      color: primaryColor,
                      foregroundColor: Colors.white,
                      child: null,
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _isLoading ? null : _checkEmailVerification,
                child: const Text(
                  'I’ve verified my email',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
