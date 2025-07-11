import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shlih_kitchen/components/mybutton.dart';
import 'package:shlih_kitchen/services/auth_gate.dart';

class SplashScreen2 extends StatelessWidget {
  final PageController pageController;
  const SplashScreen2({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    final double circleRadius = 140;
    final double floatingImageSize = 45;
    final double borderWidth = 10;

    final List<double> baseAngles = [-pi / 2, pi, 0, pi / 2];
    final List<String> floatingImages = [
      'assets/favfood1.jpg',
      'assets/favfood2.jpg',
      'assets/favfood3.jpg',
      'assets/favfood4.jpg',
    ];

    final double containerRadius = 140;
    final double positionRadius =
        containerRadius + (borderWidth / 2) - (floatingImageSize / 6);
    final double stackSize =
        (containerRadius + borderWidth + floatingImageSize) * 2;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child:
                          Image.asset('assets/log1.png', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    'SHLIH Kitchen',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                flex: 3,
                child: Center(
                  child: SizedBox(
                    width: stackSize,
                    height: stackSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 280,
                          width: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.1),
                            border: Border.all(
                                color: Colors.white, width: borderWidth),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: ClipOval(
                                child: Image.asset('assets/favfood4.jpg',
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                        for (int i = 0; i < baseAngles.length; i++)
                          Positioned(
                            left: (stackSize / 2) +
                                cos(baseAngles[i]) *
                                    (i == 1
                                        ? containerRadius + borderWidth
                                        : (i == 2
                                            ? positionRadius - 10
                                            : positionRadius)) -
                                floatingImageSize / 2,
                            top: (stackSize / 2) +
                                sin(baseAngles[i]) *
                                    (i == 0
                                        ? containerRadius + borderWidth + 10
                                        : (i == 3
                                            ? positionRadius - 25
                                            : positionRadius)) -
                                floatingImageSize / 2,
                            child: Container(
                              width: floatingImageSize,
                              height: floatingImageSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(floatingImages[i],
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const Text(
                    'All your favourite foods',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 37,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Order your food with ease and get it delivered hot and fresh',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16, height: 1.4, color: Colors.grey[800]),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  SizedBox(
                    height: 56,
                    child: MyButton(
                      text: 'Continue',
                      onPress: () {
                        pageController.animateToPage(2,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      },
                      color: const Color(0xFF0F2A12),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  MyButton(
                    text: 'Sign In',
                    onPress: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthGate()),
                      );
                    },
                    color: Colors.grey.shade500,
                    foregroundColor: const Color(0xFF0F2A12),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
