import 'package:flutter/material.dart';
import 'package:shlih_kitchen/components/mybutton.dart';
import '../components/mytextfield.dart';
import 'verificationscreen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool obscurePassword = true;
  IconData iconPassword = Icons.visibility;

  void _registerUser() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sending verification code...'),
        backgroundColor: Color(0xFF0F2A12),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EmailVerificationScreen(email: _emailController.text),
        ),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Important to avoid overflow
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signin');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20.0),
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
              ),
              const SizedBox(height: 20),
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
              ),
              const SizedBox(height: 20),
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
                suffixIcon: IconButton(
                  icon: Icon(
                    iconPassword,
                    color: const Color(0xFF0F2A12),
                  ),
                  onPressed: () {
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
              MyButton(
                text: 'Register',
                onPress: _registerUser,
                color: const Color(0xFF0F2A12),
                foregroundColor: Colors.white,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Have an account?",
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signin');
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xFF0F2A12),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'By Clicking Register you agree to our',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Terms and Data Policy',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0F2A12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
