import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shlih_kitchen/components/mybutton.dart';

class Congrats extends StatefulWidget {
  const Congrats({super.key});

  @override
  State<Congrats> createState() => _CongratsState();
}

class _CongratsState extends State<Congrats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              SizedBox(
                height: 150,
                width: 150,
                child: Lottie.asset('assets/congrats.json'),
              ),
              SizedBox(height: 40),
              Text(
                'Congratulation!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Your account is complete, please enjoy the best menu from us.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(flex: 3),
              MyButton(
                  text: 'Get Started',
                  foregroundColor: Colors.white,
                  onPress: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  color: Color(0xFF0F2A12)),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
