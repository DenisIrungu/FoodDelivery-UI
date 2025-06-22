import 'package:flutter/material.dart';
import 'package:shlih_kitchen/components/mybutton.dart';
import 'package:shlih_kitchen/components/mytextfield.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool obscurePassword = true;
  IconData iconPassword = Icons.visibility;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome Back👋',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Login to your account',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                ),
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
              MyTextField(
                controller: _emailController,
                hintText: 'Your Email',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              const Text(
                'Password',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot your Password?',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2A12)),
                  )),
              MyButton(
                foregroundColor: Colors.white,
                text: 'Sign In',
                onPress: () {},
                color: Color(0xFF0F2A12),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 1,
                  ),
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                            color: Color(0xFF0F2A12),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ))
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: Divider(
                    color: Colors.grey[500],
                    thickness: 2,
                  )),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or with',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Divider(thickness: 2, color: Colors.grey[500])),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              MyButton(
                text: 'Sign in with Google',
                onPress: () {},
                color: Colors.grey.shade200,
                foregroundColor: Color(0xFF0F2A12),
                leadingIcon: ClipOval(
                  child: Image.asset(
                    'assets/google.jpg',
                    height: 24,
                    width: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MyButton(
                text: 'Sign in with Apple',
                onPress: () {},
                color: Colors.grey.shade200,
                foregroundColor: Color(0xFF0F2A12),
                leadingIcon: ClipOval(
                  child: Image.asset(
                    'assets/apple.jpg',
                    height: 30,
                    width: 30,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
