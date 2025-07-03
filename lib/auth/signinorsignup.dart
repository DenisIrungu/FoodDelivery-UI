import 'package:flutter/material.dart';
import 'package:shlih_kitchen/auth/signin.dart';
import 'package:shlih_kitchen/auth/signup.dart';

class SignInorSignUp extends StatefulWidget {
  const SignInorSignUp({super.key});

  @override
  State<SignInorSignUp> createState() => _SignInorSignUpState();
}

class _SignInorSignUpState extends State<SignInorSignUp> {
  bool showSignInPage = true;

  void togglePages() {
    setState(() {
      showSignInPage = !showSignInPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSignInPage) {
      return SignIn(
        onTap: togglePages,
      );
    } else {
      return SignUp(
        onTap: togglePages,
      );
    }
  }
}
