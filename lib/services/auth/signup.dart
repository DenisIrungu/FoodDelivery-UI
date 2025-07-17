import 'package:flutter/material.dart';
import 'package:shlih_kitchen/components/mybutton.dart';
import 'package:shlih_kitchen/components/mytextfield.dart';
import 'package:shlih_kitchen/screens/verificationscreen.dart';
import 'package:shlih_kitchen/services/auth_services.dart';

class SignUp extends StatefulWidget {
  final VoidCallback onTap; // Non-nullable
  const SignUp({super.key, required this.onTap});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isLoading = false;
  IconData iconPassword = Icons.visibility;
  IconData iconConfirmPassword = Icons.visibility;

  // Constants
  static const Color primaryColor = Color(0xFF0F2A12);
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Validation methods
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    final name = value.trim();
    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (name.length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final email = value.trim();
    final emailRegex = RegExp(emailPattern);
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // User-friendly error messages
  String _getErrorMessage(String error) {
    if (error.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else {
      return 'An error occurred while creating your account. Please try again.';
    }
  }

  void _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Creating your account...'),
          backgroundColor: primaryColor,
        ),
      );

      final authService = AuthServices();
      await authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Account created successfully! Please check your email to verify.'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmailVerificationScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Failed'),
            content: Text(_getErrorMessage(e.toString())),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pushNamed(context, '/signin');
                },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Create Account and choose your favorite Menu',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),

                // Name Field
                const Text(
                  'Name',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _nameController,
                  hintText: 'Your Name',
                  obscureText: false,
                  validator: _validateName,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 20),

                // Email Field
                const Text(
                  'Email',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _emailController,
                  hintText: 'Your Email',
                  obscureText: false,
                  validator: _validateEmail,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password Field
                const Text(
                  'Password',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'Your Password',
                  obscureText: obscurePassword,
                  validator: _validatePassword,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.visiblePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      iconPassword,
                      color: primaryColor,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                              iconPassword = obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off;
                            });
                          },
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                const Text(
                  'Confirm Password',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.visiblePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      iconConfirmPassword,
                      color: primaryColor,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                              iconConfirmPassword = obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off;
                            });
                          },
                  ),
                ),
                const SizedBox(height: 20),

                // Password Requirements
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• At least 8 characters long\n• Contains uppercase and lowercase letters\n• Contains at least one number',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Register Button
                MyButton(
                  text: 'Register',
                  onPress: _isLoading ? null : _registerUser,
                  color: primaryColor,
                  foregroundColor: Colors.white,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 20),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Have an account?",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: _isLoading ? () {} : widget.onTap,
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Terms and Policy
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'By clicking Register you agree to our',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Terms and Policy page not implemented yet'),
                                ),
                              );
                            },
                      child: const Text(
                        'Terms and Data Policy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
