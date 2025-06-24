import 'package:flutter/material.dart';
import 'package:shlih_kitchen/components/mybutton.dart';
import 'package:shlih_kitchen/components/mycontainer.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  int selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signin');
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forget Password',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select which contact detail should we use to reset your password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 30),
              MyContainer(
                text: 'Email',
                icon: Icon(Icons.email_outlined, color: Colors.white, size: 24),
                subtitle: 'Send to your email',
                isSelected: selectedOption == 0,
                onTap: () {
                  setState(() {
                    selectedOption = 0;
                  });
                },
              ),
              SizedBox(height: 16),
              MyContainer(
                text: 'Phone Number',
                icon: Icon(Icons.phone_outlined, color: Colors.white, size: 24),
                subtitle: 'Send to your phone number',
                isSelected: selectedOption == 1,
                onTap: () {
                  setState(() {
                    selectedOption = 1;
                  });
                },
              ),
              Spacer(),
              MyButton(
                  text: 'Continue',
                  foregroundColor: Colors.white,
                  onPress: () {
                    if (selectedOption == 0) {
                      print('Reset via email');
                    } else {
                      print('Reset via phone');
                    }
                  },
                  color: Color(0xFF0F2A12)),
              SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
